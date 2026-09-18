// Apple Sign in with Apple server-to-server helpers: building the required
// client_secret JWT (ES256, per Apple's spec) and revoking a stored refresh
// token on account deletion. Used by apple-auth-store (captures the token
// right after sign-in) and delete-account (revokes it on deletion).
//
// Required secrets (owner-provided; never something this session can set):
//   APPLE_TEAM_ID     — Apple Developer Team ID
//   APPLE_KEY_ID      — the Key ID of the "Sign in with Apple" private key
//   APPLE_CLIENT_ID   — the Services ID (or bundle id) used for Sign in with
//                       Apple on this app
//   APPLE_PRIVATE_KEY — the .p8 private key's contents, PEM/PKCS8 format,
//                       exactly as downloaded from the Apple Developer portal
//
// If any of these are unset, both functions below skip Apple-specific work
// gracefully (return null / log and continue) rather than fail the whole
// request — signing in or deleting an account must not hard-depend on
// Apple credentials being configured, since Google/OTP users never touch
// this path at all.

function base64url(bytes: Uint8Array): string {
  let str = "";
  for (const b of bytes) str += String.fromCharCode(b);
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function base64urlFromString(s: string): string {
  return base64url(new TextEncoder().encode(s));
}

async function importApplePrivateKey(pem: string): Promise<CryptoKey> {
  const pkcs8 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const raw = Uint8Array.from(atob(pkcs8), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    "pkcs8",
    raw,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );
}

export interface AppleConfig {
  teamId: string;
  keyId: string;
  clientId: string;
  privateKey: string;
}

export function loadAppleConfig(): AppleConfig | null {
  const teamId = Deno.env.get("APPLE_TEAM_ID");
  const keyId = Deno.env.get("APPLE_KEY_ID");
  const clientId = Deno.env.get("APPLE_CLIENT_ID");
  const privateKey = Deno.env.get("APPLE_PRIVATE_KEY");
  if (!teamId || !keyId || !clientId || !privateKey) return null;
  return { teamId, keyId, clientId, privateKey };
}

/// Builds the ES256-signed client_secret JWT Apple requires on every
/// server-to-server call (token exchange and revoke). Valid for 5 minutes —
/// generated fresh per call rather than cached, since these calls are
/// infrequent (once per sign-in, once per deletion).
export async function buildAppleClientSecret(
  config: AppleConfig,
): Promise<string> {
  const header = { alg: "ES256", kid: config.keyId };
  const nowSec = Math.floor(Date.now() / 1000);
  const payload = {
    iss: config.teamId,
    iat: nowSec,
    exp: nowSec + 300,
    aud: "https://appleid.apple.com",
    sub: config.clientId,
  };
  const encodedHeader = base64urlFromString(JSON.stringify(header));
  const encodedPayload = base64urlFromString(JSON.stringify(payload));
  const signingInput = `${encodedHeader}.${encodedPayload}`;

  const key = await importApplePrivateKey(config.privateKey);
  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    key,
    new TextEncoder().encode(signingInput),
  );
  return `${signingInput}.${base64url(new Uint8Array(signature))}`;
}

/// Exchanges a Sign in with Apple authorization code (from the client,
/// immediately after a fresh native sign-in) for a refresh token. The
/// refresh token — not the authorization code, which is single-use and
/// short-lived — is what must be stored for later revocation.
export interface AppleTokenExchange {
  refreshToken: string;
  subject: string;
}

function decodeJwtPart(value: string): Uint8Array {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/");
  return Uint8Array.from(
    atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, "=")),
    (c) => c.charCodeAt(0),
  );
}

// Verify Apple's signature, issuer, audience and lifetime before trusting sub.
// A subject supplied in the request or in unverified JWT claims is never used.
export async function verifyAppleIdentityToken(
  token: string,
  clientId: string,
  fetcher: typeof fetch = fetch,
): Promise<string> {
  const parts = token.split(".");
  if (parts.length !== 3) throw new Error("invalid_apple_identity");
  const header = JSON.parse(new TextDecoder().decode(decodeJwtPart(parts[0])));
  const claims = JSON.parse(new TextDecoder().decode(decodeJwtPart(parts[1])));
  const now = Math.floor(Date.now() / 1000);
  if (
    header.alg !== "RS256" || typeof header.kid !== "string" ||
    claims.iss !== "https://appleid.apple.com" || claims.aud !== clientId ||
    !Number.isFinite(claims.exp) || claims.exp <= now ||
    !Number.isFinite(claims.iat) || claims.iat > now + 60 ||
    typeof claims.sub !== "string" || !claims.sub
  ) {
    throw new Error("invalid_apple_identity");
  }
  const response = await fetcher("https://appleid.apple.com/auth/keys", {
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) throw new Error("apple_keys_unavailable");
  const jwks = await response.json();
  const jwk = jwks.keys?.find((key: JsonWebKey & { kid?: string }) =>
    key.kid === header.kid && key.kty === "RSA" && key.alg === "RS256"
  );
  if (!jwk) throw new Error("unknown_apple_signing_key");
  const key = await crypto.subtle.importKey(
    "jwk",
    jwk,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["verify"],
  );
  const valid = await crypto.subtle.verify(
    "RSASSA-PKCS1-v1_5",
    key,
    decodeJwtPart(parts[2]),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  );
  if (!valid) throw new Error("invalid_apple_signature");
  return claims.sub;
}

export function isLinkedAppleSubject(
  identities:
    | Array<{ provider: string; identity_data?: Record<string, unknown> }>
    | undefined,
  subject: string,
): boolean {
  return identities?.some((identity) =>
    identity.provider === "apple" &&
    identity.identity_data?.sub === subject
  ) === true;
}

export async function exchangeAppleAuthorizationCode(
  config: AppleConfig,
  authorizationCode: string,
): Promise<AppleTokenExchange | null> {
  const clientSecret = await buildAppleClientSecret(config);
  const res = await fetch("https://appleid.apple.com/auth/token", {
    method: "POST",
    signal: AbortSignal.timeout(10_000),
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: config.clientId,
      client_secret: clientSecret,
      code: authorizationCode,
      grant_type: "authorization_code",
    }),
  });
  if (!res.ok) return null; // Never log provider bodies or credentials.
  const data = await res.json();
  if (
    typeof data.refresh_token !== "string" || !data.refresh_token ||
    typeof data.id_token !== "string"
  ) return null;
  const subject = await verifyAppleIdentityToken(
    data.id_token,
    config.clientId,
  );
  return { refreshToken: data.refresh_token, subject };
}

/// Revokes a previously-issued Apple refresh token. Returns true on success
/// (including "already invalid" — Apple returns success-shaped responses
/// for tokens it no longer recognizes, which is fine for our purposes:
/// the goal is "this token must not work anymore," which is already true).
export async function revokeAppleRefreshToken(
  config: AppleConfig,
  refreshToken: string,
): Promise<boolean> {
  const clientSecret = await buildAppleClientSecret(config);
  const res = await fetch("https://appleid.apple.com/auth/revoke", {
    method: "POST",
    signal: AbortSignal.timeout(10_000),
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: config.clientId,
      client_secret: clientSecret,
      token: refreshToken,
      token_type_hint: "refresh_token",
    }),
  });
  if (!res.ok) {
    console.warn("apple: revocation pending", res.status);
    return false;
  }
  return true;
}
