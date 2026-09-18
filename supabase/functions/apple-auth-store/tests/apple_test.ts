import { isLinkedAppleSubject, verifyAppleIdentityToken } from '../../_shared/apple.ts';
function assert(value: unknown): asserts value { if (!value) throw new Error('assertion failed'); }
Deno.test('Apple subject must match the verified linked Apple identity, never an email', () => {
  assert(isLinkedAppleSubject([{ provider: 'apple', identity_data: { sub: 'expected' } }], 'expected'));
  assert(!isLinkedAppleSubject([{ provider: 'apple', identity_data: { sub: 'other' } }], 'expected'));
  assert(!isLinkedAppleSubject([{ provider: 'google', identity_data: { sub: 'expected' } }], 'expected'));
  assert(!isLinkedAppleSubject(undefined, 'expected'));
});
function encode(value: unknown): string { return btoa(JSON.stringify(value)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_'); }
Deno.test('Apple identity verifies RSA signature and rejects wrong audience, expiration, and tampering', async () => {
  const pair = await crypto.subtle.generateKey({ name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048,
    publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' }, true, ['sign', 'verify']);
  const jwk = { ...await crypto.subtle.exportKey('jwk', pair.publicKey), kid: 'test-key', alg: 'RS256' };
  const fetcher: typeof fetch = async () => new Response(JSON.stringify({ keys: [jwk] }));
  const now = Math.floor(Date.now() / 1000);
  async function token(claims: Record<string, unknown>) {
    const input = `${encode({ alg: 'RS256', kid: 'test-key' })}.${encode(claims)}`;
    const signature = new Uint8Array(await crypto.subtle.sign('RSASSA-PKCS1-v1_5', pair.privateKey, new TextEncoder().encode(input)));
    return `${input}.${btoa(String.fromCharCode(...signature)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')}`;
  }
  const claims = { iss: 'https://appleid.apple.com', aud: 'com.example.test', sub: 'expected', iat: now, exp: now + 300 };
  const good = await token(claims);
  assert(await verifyAppleIdentityToken(good, 'com.example.test', fetcher) === 'expected');
  for (const bad of [await token({ ...claims, exp: now - 10 }), await token({ ...claims, aud: 'another-app' }),
    `${good.split('.')[0]}.${encode({ ...claims, sub: 'attacker' })}.${good.split('.')[2]}`]) {
    let rejected = false;
    try { await verifyAppleIdentityToken(bad, 'com.example.test', fetcher); } catch { rejected = true; }
    assert(rejected);
  }
});
