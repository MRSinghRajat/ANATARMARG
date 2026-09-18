import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

function requireEnv(name: string): string {
  const v = Deno.env.get(name);
  if (!v) throw new Error(`Missing env: ${name}`);
  return v;
}

function base64ToBytes(b64: string): Uint8Array {
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

function pemPkcs8ToDer(pem: string): Uint8Array {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  return base64ToBytes(body);
}

async function importApplePrivateKey(pemPkcs8: string): Promise<CryptoKey> {
  const der = pemPkcs8ToDer(pemPkcs8);
  return await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );
}

export type AppleEnv = {
  teamId: string;
  keyId: string;
  clientId: string;
  privateKeyPem: string;
};

export function appleEnvFromDeno(): AppleEnv {
  return {
    teamId: requireEnv("APPLE_TEAM_ID"),
    keyId: requireEnv("APPLE_KEY_ID"),
    clientId: requireEnv("APPLE_CLIENT_ID"),
    privateKeyPem: requireEnv("APPLE_PRIVATE_KEY_PEM"),
  };
}

export async function createAppleClientSecret(env: AppleEnv): Promise<string> {
  const key = await importApplePrivateKey(env.privateKeyPem);
  const now = Math.floor(Date.now() / 1000);

  return await create(
    { alg: "ES256", kid: env.keyId, typ: "JWT" },
    {
      iss: env.teamId,
      iat: now,
      exp: getNumericDate(5 * 60),
      aud: "https://appleid.apple.com",
      sub: env.clientId,
    },
    key,
  );
}

export type AppleTokenResponse = {
  access_token?: string;
  expires_in?: number;
  id_token?: string;
  refresh_token?: string;
  token_type?: string;
  error?: string;
  error_description?: string;
};

async function postForm(
  url: string,
  params: Record<string, string>,
): Promise<Response> {
  const body = new URLSearchParams(params);
  return await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body,
  });
}

export async function exchangeAppleAuthorizationCode(
  env: AppleEnv,
  authorizationCode: string,
): Promise<AppleTokenResponse> {
  const clientSecret = await createAppleClientSecret(env);

  const res = await postForm("https://appleid.apple.com/auth/token", {
    grant_type: "authorization_code",
    code: authorizationCode,
    client_id: env.clientId,
    client_secret: clientSecret,
  });

  const json = (await res.json()) as AppleTokenResponse;
  if (!res.ok) return json;
  return json;
}

export type AppleRevokeResponse = {
  ok: boolean;
  status: number;
  bodyText?: string;
};

export async function revokeAppleRefreshToken(
  env: AppleEnv,
  refreshToken: string,
): Promise<AppleRevokeResponse> {
  const clientSecret = await createAppleClientSecret(env);
  const res = await postForm("https://appleid.apple.com/auth/revoke", {
    token: refreshToken,
    client_id: env.clientId,
    client_secret: clientSecret,
    token_type_hint: "refresh_token",
  });

  const text = await res.text().catch(() => "");
  return { ok: res.ok, status: res.status, bodyText: text || undefined };
}

export function decodeAppleIdTokenSub(idToken: string): string | null {
  const parts = idToken.split(".");
  if (parts.length < 2) return null;
  const payloadB64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
  const padded = payloadB64.padEnd(Math.ceil(payloadB64.length / 4) * 4, "=");
  try {
    const json = JSON.parse(new TextDecoder().decode(base64ToBytes(padded)));
    return typeof json?.sub === "string" ? json.sub : null;
  } catch {
    return null;
  }
}
