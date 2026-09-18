import { assert, assertEquals, assertMatch } from 'https://deno.land/std@0.221.0/assert/mod.ts';
import { verify } from 'https://deno.land/x/djwt@v3.0.2/mod.ts';
import { createAppleClientSecret, decodeAppleIdTokenSub } from './apple.ts';

function bytesToBase64(bytes: Uint8Array): string {
  let s = '';
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s);
}

async function exportPkcs8Pem(privateKey: CryptoKey): Promise<string> {
  const pkcs8 = new Uint8Array(await crypto.subtle.exportKey('pkcs8', privateKey));
  const b64 = bytesToBase64(pkcs8);
  const lines = b64.match(/.{1,64}/g) ?? [b64];
  return `-----BEGIN PRIVATE KEY-----\n${lines.join('\n')}\n-----END PRIVATE KEY-----\n`;
}

Deno.test('createAppleClientSecret produces a verifiable ES256 JWT', async () => {
  const { privateKey, publicKey } = await crypto.subtle.generateKey(
    { name: 'ECDSA', namedCurve: 'P-256' },
    true,
    ['sign', 'verify'],
  ) as CryptoKeyPair;

  const token = await createAppleClientSecret({
    teamId: 'TEAM123',
    keyId: 'KEY123',
    clientId: 'com.example.app',
    privateKeyPem: await exportPkcs8Pem(privateKey),
  });

  assertMatch(token, /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/);

  const payload = await verify(token, publicKey) as Record<string, unknown>;
  assertEquals(payload.iss, 'TEAM123');
  assertEquals(payload.sub, 'com.example.app');
  assertEquals(payload.aud, 'https://appleid.apple.com');
  assert(typeof payload.exp === 'number');
  assert(typeof payload.iat === 'number');
});

Deno.test('decodeAppleIdTokenSub extracts sub from JWT payload', () => {
  const header = btoa(JSON.stringify({ alg: 'none' })).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  const payload = btoa(JSON.stringify({ sub: 'apple-user-123' })).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  const token = `${header}.${payload}.`;
  assertEquals(decodeAppleIdTokenSub(token), 'apple-user-123');
});

