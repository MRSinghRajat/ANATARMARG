import assert from 'node:assert/strict';
import { test } from 'node:test';
import { snapshot, affectedUsers, reconcile, fetchSnapshot, PRO_ENTITLEMENT } from '../functions/_shared/revenuecat.ts';
const A = '11111111-1111-4111-8111-111111111111';
const B = '22222222-2222-4222-8222-222222222222';
const purchase = '2026-01-01T00:00:00Z';
const expiry = '2026-10-01T00:00:00Z';
const now = Date.parse('2026-09-15T00:00:00Z');
function body(overrides = {}, txn = {}) {
  return { subscriber: { entitlements: { [PRO_ENTITLEMENT]: {
    expires_date: expiry, grace_period_expires_date: null, product_identifier: 'monthly', purchase_date: purchase, ...overrides,
  } }, subscriptions: { monthly: { is_sandbox: false, store: 'app_store', ...txn } }, non_subscriptions: {} } };
}
test('paid snapshot and empty snapshot explicitly replace managed Pro state', () => {
  assert.equal(snapshot(A, body(), false, now).is_active, true);
  assert.deepEqual(snapshot(A, { subscriber: { entitlements: {} } }, false, now), {
    user_id: A, entitlement_id: PRO_ENTITLEMENT, is_active: false, expires_at: null, environment: null,
  });
});
test('missing expiry, malformed date, missing provenance and malformed body fail closed', () => {
  for (const b of [body({ expires_date: undefined }), body({ expires_date: 'not-a-date' }),
    body({ product_identifier: 'unknown' }), {}, { subscriber: {} }]) {
    assert.throws(() => snapshot(A, b, false, now));
  }
});
test('grace period retains access, then expires; refunds remove access', () => {
  const b = body({ expires_date: '2026-09-14T00:00:00Z', grace_period_expires_date: '2026-09-17T00:00:00Z' });
  assert.equal(snapshot(A, b, false, now).is_active, true);
  assert.equal(snapshot(A, b, false, Date.parse('2026-09-18T00:00:00Z')).is_active, false);
  assert.equal(snapshot(A, body({}, { refunded_at: purchase }), false, now).is_active, false);
});
test('explicit lifetime null with matching non-subscription transaction is honored', () => {
  const b = body({ expires_date: null });
  b.subscriber.subscriptions = {};
  b.subscriber.non_subscriptions = { monthly: [{ purchase_date: purchase, is_sandbox: false, store: 'app_store' }] };
  assert.equal(snapshot(A, b, false, now).is_active, true);
  assert.equal(snapshot(A, b, false, now).expires_at, null);
});
test('sandbox comes from transaction and requires explicit policy', () => {
  const b = body({}, { is_sandbox: true });
  assert.equal(snapshot(A, b, false, now).is_active, false);
  assert.equal(snapshot(A, b, true, now).is_active, true);
  assert.equal(snapshot(A, b, true, now).environment, 'SANDBOX');
});
test('TRANSFER includes losing and receiving accounts; ambiguous aliases fail', () => {
  assert.deepEqual(affectedUsers({ type: 'TRANSFER', transferred_from: [A], transferred_to: [B] }), [A, B]);
  assert.deepEqual(affectedUsers({ type: 'RENEWAL', app_user_id: '$RCAnonymousID:synthetic', aliases: [A] }), [A]);
  assert.throws(() => affectedUsers({ app_user_id: '$RCAnonymousID:synthetic', aliases: [A, B] }));
  assert.throws(() => affectedUsers({ type: 'TRANSFER', transferred_from: 'bad', transferred_to: [B] }));
});
test('unexpected 404 does not clear existing access', async () => {
  await assert.rejects(() => fetchSnapshot(A, 'synthetic', false, async () => new Response('', { status: 404 })), /subscriber_http_404/);
});
test('reconciliation acquires before fetch, writes inactive row, and releases on failure', async () => {
  const order: string[] = [];
  const client = { rpc: async (name: string, args: Record<string, unknown>) => {
    order.push(name);
    if (name === 'claim_revenuecat_sync') return { data: { lease_token: A, user_ids: [A] }, error: null };
    if (name === 'apply_revenuecat_event') {
      assert.equal((args.p_rows as { is_active: boolean }[])[0].is_active, false);
      return { data: null, error: { message: 'synthetic_failure' } };
    }
    return { data: null, error: null };
  } };
  await assert.rejects(() => reconcile(client, 'synthetic', 'TRANSFER', [A], 'fake', false, async () => {
    order.push('fetch'); return Response.json({ subscriber: { entitlements: {} } });
  }), /apply_revenuecat_event/);
  assert.deepEqual(order, ['claim_revenuecat_sync', 'fetch', 'apply_revenuecat_event', 'release_revenuecat_sync']);
});
test('completed duplicate does not fetch again', async () => {
  const client = { rpc: async () => ({ data: { already_processed: true }, error: null }) };
  await reconcile(client, 'duplicate', 'RENEWAL', [A], 'fake', false, async () => { throw new Error('must not fetch'); });
});
