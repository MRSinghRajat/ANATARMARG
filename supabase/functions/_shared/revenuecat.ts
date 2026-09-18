// One reconciliation contract shared by webhook and subscriber backfill.
// No imports: also runnable under Node's TypeScript support for offline tests.
export const PRO_ENTITLEMENT = 'Antar marg Pro';
export const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
type Obj = Record<string, unknown>;
export interface EntitlementRow {
  user_id: string; entitlement_id: string; is_active: boolean;
  expires_at: string | null; environment: 'SANDBOX' | 'PRODUCTION' | 'PROMOTIONAL' | null;
}
export interface RpcClient {
  rpc(name: string, args: Record<string, unknown>): PromiseLike<{ data: unknown; error: { message: string } | null }>;
}
export function object(value: unknown, name: string): Obj {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`invalid_${name}`);
  return value as Obj;
}
function date(value: unknown, nullable: boolean): number | null {
  if (nullable && value === null) return null;
  if (typeof value !== 'string' || !/^\d{4}-\d\d-\d\dT/.test(value) || !Number.isFinite(Date.parse(value))) {
    throw new Error('invalid_subscriber_date');
  }
  return Date.parse(value);
}
export function snapshot(userId: string, body: unknown, allowSandbox: boolean, now = Date.now()): EntitlementRow {
  if (!UUID_RE.test(userId)) throw new Error('invalid_account_id');
  const subscriber = object(object(body, 'response').subscriber, 'subscriber');
  const entitlements = object(subscriber.entitlements, 'entitlements');
  const base: EntitlementRow = { user_id: userId, entitlement_id: PRO_ENTITLEMENT,
    is_active: false, expires_at: null, environment: null };
  if (!Object.hasOwn(entitlements, PRO_ENTITLEMENT)) return base;
  const e = object(entitlements[PRO_ENTITLEMENT], 'entitlement');
  const expires = date(e.expires_date, true); // undefined must NEVER mean lifetime
  const grace = e.grace_period_expires_date == null ? null : date(e.grace_period_expires_date, false);
  if (typeof e.product_identifier !== 'string' || !e.product_identifier) throw new Error('invalid_product');
  const purchaseDate = date(e.purchase_date, false);
  const subscriptions = object(subscriber.subscriptions, 'subscriptions');
  const nonSubscriptions = object(subscriber.non_subscriptions, 'non_subscriptions');
  let transaction: Obj;
  if (Object.hasOwn(subscriptions, e.product_identifier)) {
    transaction = object(subscriptions[e.product_identifier], 'subscription');
  } else {
    const entries = nonSubscriptions[e.product_identifier];
    if (!Array.isArray(entries)) throw new Error('missing_purchase_provenance');
    const match = entries.map(x => object(x, 'purchase')).find(x => date(x.purchase_date, false) === purchaseDate);
    if (!match) throw new Error('missing_purchase_provenance');
    transaction = match;
  }
  if (typeof transaction.is_sandbox !== 'boolean') throw new Error('invalid_purchase_environment');
  const environment = transaction.store === 'promotional' ? 'PROMOTIONAL'
    : transaction.is_sandbox ? 'SANDBOX' : 'PRODUCTION';
  const until = expires === null ? null : Math.max(expires, grace ?? expires);
  const refunded = transaction.refunded_at != null;
  if (refunded) date(transaction.refunded_at, false);
  return { ...base, environment, expires_at: until === null ? null : new Date(until).toISOString(),
    is_active: !refunded && (allowSandbox || environment !== 'SANDBOX') && (until === null || until > now) };
}

export function affectedUsers(event: Obj): string[] {
  const strings = (v: unknown) => {
    if (!Array.isArray(v) || v.some(x => typeof x !== 'string')) throw new Error('invalid_identity_array');
    return v as string[];
  };
  if (event.type === 'TRANSFER') {
    const ids = [...strings(event.transferred_from), ...strings(event.transferred_to)];
    const resolved = [...new Set(ids.filter(x => UUID_RE.test(x)).map(x => x.toLowerCase()))].sort();
    if (!resolved.length || resolved.length > 100) throw new Error('unresolved_transfer_identity');
    return resolved;
  }
  if (typeof event.app_user_id === 'string' && UUID_RE.test(event.app_user_id)) return [event.app_user_id.toLowerCase()];
  // Exact verified UUID aliases only. Multiple aliases require a human-reviewed
  // mapping; never infer account ownership from names, emails or attributes.
  const aliases = event.aliases == null ? [] : strings(event.aliases);
  const candidates = [...new Set([...aliases, event.original_app_user_id]
    .filter((x): x is string => typeof x === 'string' && UUID_RE.test(x)).map(x => x.toLowerCase()))];
  if (candidates.length !== 1) throw new Error('unresolved_subscriber_identity');
  return candidates;
}

export async function fetchSnapshot(id: string, key: string, allowSandbox: boolean, fetcher: typeof fetch = fetch) {
  const response = await fetcher(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(id)}`, {
    headers: { Authorization: `Bearer ${key}` }, signal: AbortSignal.timeout(25000),
  });
  // This endpoint gets OR CREATES a subscriber. Unexpected 404 is an error,
  // not evidence permitting existing paid access to be erased.
  if (!response.ok) throw new Error(`subscriber_http_${response.status}`);
  return snapshot(id, await response.json(), allowSandbox);
}
async function rpc(client: RpcClient, name: string, args: Record<string, unknown>) {
  const result = await client.rpc(name, args);
  if (result.error) throw new Error(`rpc_${name}_failed`);
  return result.data;
}
export async function reconcile(client: RpcClient, eventId: string, eventType: string,
  userIds: string[], key: string, allowSandbox: boolean, fetcher: typeof fetch = fetch) {
  const claim = object(await rpc(client, 'claim_revenuecat_sync', { p_event_id: eventId, p_user_ids: userIds }), 'claim');
  if (claim.already_processed === true) return { ok: true, already_processed: true };
  if (typeof claim.lease_token !== 'string' || !Array.isArray(claim.user_ids)
    || claim.user_ids.some(x => typeof x !== 'string' || !UUID_RE.test(x))) throw new Error('invalid_lease');
  const ids = claim.user_ids as string[];
  try {
    const rows = await Promise.all(ids.map(id => fetchSnapshot(id, key, allowSandbox, fetcher)));
    return await rpc(client, 'apply_revenuecat_event', { p_event_id: eventId, p_event_type: eventType,
      p_lease_token: claim.lease_token, p_user_ids: ids, p_rows: rows });
  } finally {
    // Token-scoped release cannot delete a newer lease after ours expires.
    // A failed release expires automatically; never mask the original failure.
    try { await rpc(client, 'release_revenuecat_sync', { p_lease_token: claim.lease_token }); } catch { /* expiry */ }
  }
}
