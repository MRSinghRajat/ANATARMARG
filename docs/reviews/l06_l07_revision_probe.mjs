// Diagnostic probes of actual handlers; external services mocked, no network.
import { readFileSync } from 'node:fs';
import { stripTypeScriptTypes } from 'node:module';
import vm from 'node:vm';
import assert from 'node:assert/strict';

const root = process.cwd();
function handler(file, mocks) {
  let serve;
  const source = readFileSync(`${root}/${file}`, 'utf8').replace(/^import .*;\n/gm, '');
  vm.runInNewContext(stripTypeScriptTypes(source), {
    Request, Response, Date, console,
    corsHeaders: {},
    jsonResponse: (body, status = 200) => Response.json(body, { status }),
    Deno: { serve: fn => { serve = fn; }, env: { get: () => 'synthetic-secret' } },
    ...mocks,
  });
  return serve;
}
const uid = '11111111-1111-4111-8111-111111111111';
function request(event) {
  return new Request('https://test.invalid', { method: 'POST', headers: {
    Authorization: 'synthetic-secret', 'Content-Type': 'application/json',
  }, body: JSON.stringify({ event }) });
}
const event = id => ({ id, type: 'RENEWAL', app_user_id: uid });

// Execute deletion handler with cleanup's documented SQL token deletion.
const cleanupSQL = readFileSync(`${root}/supabase/migrations/20260914020000_l06_account_deletion_support.sql`, 'utf8');
assert.match(cleanupSQL, /DELETE FROM public\.apple_auth_tokens WHERE user_id = tid/);
let token = 'synthetic-refresh-token', revocations = 0;
const deleteHandler = handler('supabase/functions/delete-account/index.ts', {
  supabaseUserClient: () => ({ auth: { getUser: async () => ({ data: { user: { id: uid } } }) },
    rpc: async () => { token = null; return { data: { ok: true } }; } }),
  supabaseAdmin: () => ({
    from: () => ({ select: () => ({ eq: () => ({ maybeSingle: async () => ({ data: token ? { refresh_token: token } : null }) }) }) }),
    auth: { admin: { deleteUser: async () => ({ error: null }) } },
  }),
  loadAppleConfig: () => ({}),
  revokeAppleRefreshToken: async () => { revocations++; return true; },
});
const deletion = await (await deleteHandler(request({}))).json();
assert.equal(revocations, 0);
assert.equal(deletion.appleRevoked, 'not_applicable');
console.log('CONFIRMED: deletion returns success without calling Apple revocation after cleanup removes stored token.');

// Capture real webhook RPC arguments for an empty authoritative snapshot.
let emptyArgs;
const emptyHandler = handler('supabase/functions/revenuecat-webhook/index.ts', {
  fetch: async () => Response.json({ subscriber: { entitlements: {} } }),
  supabaseAdmin: () => ({ rpc: async (_name, args) => { emptyArgs = args; return { data: { ok: true } }; } }),
});
await emptyHandler(request(event('empty')));
assert.equal(emptyArgs.p_rows.length, 0);
assert.equal(Object.hasOwn(emptyArgs, 'p_affected_user_ids'), false);
console.log('CONFIRMED: empty snapshot sends zero entitlement rows, without an explicit affected-user list. SQL removal semantics require separate review.');

// Delay the older fetched snapshot before its database invocation.
let releaseOld, oldCaptured;
const oldReady = new Promise(resolve => { oldCaptured = resolve; });
const oldGate = new Promise(resolve => { releaseOld = resolve; });
let fetchCount = 0;
const applied = [];
const raceHandler = handler('supabase/functions/revenuecat-webhook/index.ts', {
  fetch: async () => {
    const old = fetchCount++ === 0;
    return { ok: true, status: 200, json: async () => {
      const snapshot = { subscriber: { entitlements: { 'Antar marg Pro': {
        expires_date: old ? '2090-01-01T00:00:00Z' : '2091-01-01T00:00:00Z',
      } } } };
      if (old) { oldCaptured(); await oldGate; }
      return snapshot;
    } };
  },
  supabaseAdmin: () => ({ rpc: async (_name, args) => { applied.push(args); return { data: { ok: true } }; } }),
});
const first = raceHandler(request(event('old')));
await oldReady;
await raceHandler(request(event('new')));
releaseOld();
await first;
assert.deepEqual(applied.map(a => a.p_event_id), ['new', 'old']);
assert.equal(applied[1].p_rows[0].expires_at, '2090-01-01T00:00:00Z');
console.log('CONFIRMED: older snapshot can reach database after newer snapshot. Current SQL upsert has no freshness guard.');

let malformedArgs;
const malformedHandler = handler('supabase/functions/revenuecat-webhook/index.ts', {
  fetch: async () => Response.json({ subscriber: { entitlements: { 'Antar marg Pro': {} } } }),
  supabaseAdmin: () => ({ rpc: async (_name, args) => { malformedArgs = args; return { data: { ok: true } }; } }),
});
await malformedHandler(request(event('malformed')));
assert.equal(malformedArgs.p_rows[0].is_active, true);
assert.equal(malformedArgs.p_rows[0].expires_at, null);
console.log('CONFIRMED: malformed entitlement missing expires_date becomes an active unlimited grant.');
console.log('Limits: Node strips TypeScript syntax; this is not Deno type checking or PostgreSQL integration testing. All services mocked; no production calls.');
