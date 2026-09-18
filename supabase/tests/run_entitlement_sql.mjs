// Actual PostgreSQL engine (PGlite); isolated in-memory fixture, no network.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
const modulePath = process.env.PGLITE_MODULE || '@electric-sql/pglite';
const { PGlite } = await import(modulePath);
const db = new PGlite();
const A = '11111111-1111-4111-8111-111111111111';
const B = '22222222-2222-4222-8222-222222222222';
await db.exec(`CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role BYPASSRLS;
 CREATE SCHEMA auth; CREATE TABLE auth.users(id uuid PRIMARY KEY);
 CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql AS 'SELECT nullif(current_setting(''request.jwt.claim.sub'',true),'''')::uuid';
 GRANT USAGE ON SCHEMA public, auth TO anon, authenticated, service_role;
 -- Simulate inherited Supabase legacy defaults; migration must explicitly revoke.
 ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO anon, authenticated, service_role;
 CREATE TABLE public.account_deletions(deleted_user_id uuid UNIQUE);
 INSERT INTO auth.users VALUES('${A}'),('${B}');`);
await db.exec(await readFile('supabase/migrations/20260914010000_l07a_entitlement_infrastructure.sql', 'utf8'));
const claim = async (event, ids = [A]) => (await db.query('SELECT public.claim_revenuecat_sync($1,$2::uuid[]) AS result', [event, ids])).rows[0].result;
const row = (id, active = true) => ({ user_id: id, entitlement_id: 'Antar marg Pro', is_active: active,
 expires_at: null, environment: active ? 'PRODUCTION' : null });
const apply = async (event, token, ids = [A], rows = [row(A)]) => db.query(
 'SELECT public.apply_revenuecat_event($1,$2,$3::uuid,$4::uuid[],$5::jsonb)', [event, 'TEST_FIXTURE', token, ids, JSON.stringify(rows)]);
const get = async id => (await db.query('SELECT * FROM public.user_entitlements WHERE user_id=$1', [id])).rows;
try {
  for (const role of ['anon', 'authenticated']) {
    await db.exec(`SET ROLE ${role}`);
    await assert.rejects(() => claim('forbidden'));
    await assert.rejects(() => db.query('INSERT INTO public.user_entitlements VALUES($1,$2,true,null,null,now())', [A, 'Antar marg Pro']));
    await db.exec('RESET ROLE');
  }
  await db.exec('SET ROLE service_role');
  const c1 = await claim('one');
  await assert.rejects(() => claim('overlap'), /reconciliation_busy/);
  await apply('one', c1.lease_token);
  assert.equal((await get(A))[0].is_active, true);
  assert.equal((await claim('one')).already_processed, true);
  await db.exec('RESET ROLE');
  await db.exec(`SET ROLE authenticated; SET "request.jwt.claim.sub"='${B}'`);
  assert.equal((await get(A)).length, 0);
  await db.exec(`SET "request.jwt.claim.sub"='${A}'`);
  assert.equal((await db.query('SELECT public.has_active_entitlement($1) AS active', [A])).rows[0].active, true);
  await db.exec('RESET ROLE; SET ROLE service_role');
  const transfer = await claim('transfer', [A, B]);
  await apply('transfer', transfer.lease_token, [A, B], [row(A, false), row(B)]);
  assert.equal((await get(A))[0].is_active, false);
  assert.equal((await get(B))[0].is_active, true);
  // Failed write rolls back event + prior rows, leaving the lease usable for retry.
  const retry = await claim('retry', [A, B]);
  const malformed = { ...row(B), expires_at: 'bad-date' };
  await assert.rejects(() => apply('retry', retry.lease_token, [A, B], [row(A), malformed]));
  assert.equal((await get(A))[0].is_active, false);
  assert.equal((await db.query("SELECT count(*)::int AS n FROM public.revenuecat_webhook_events WHERE event_id='retry'")).rows[0].n, 0);
  await apply('retry', retry.lease_token, [A, B], [row(A), row(B)]);
  // Crash recovery and fencing: newer worker reclaims expired network lease.
  const old = await claim('old');
  await db.exec("UPDATE public.revenuecat_sync_leases SET lease_until=now()-interval '1 second'");
  const newer = await claim('new');
  await apply('new', newer.lease_token, [A], [row(A, false)]);
  await assert.rejects(() => apply('old', old.lease_token), /stale_sync_lease/);
  assert.equal((await get(A))[0].is_active, false);
  // Deletion interleaved after fetch; same tombstone contract as L06.
  const late = await claim('late');
  await db.exec('RESET ROLE');
  await db.query('INSERT INTO public.account_deletions VALUES($1)', [A]);
  await db.query('DELETE FROM public.user_entitlements WHERE user_id=$1', [A]);
  await db.query('DELETE FROM public.revenuecat_sync_leases WHERE user_id=$1', [A]);
  await db.exec('SET ROLE service_role');
  await apply('late', late.lease_token);
  assert.equal((await get(A)).length, 0);
  assert.deepEqual((await claim('after-deletion')).user_ids, []);
  console.log('PASS: PostgreSQL permissions, RLS account isolation, transfer revocation, atomic rollback/retry, lease contention/expiry/fencing, deletion exclusion.');
} finally { await db.close(); }
