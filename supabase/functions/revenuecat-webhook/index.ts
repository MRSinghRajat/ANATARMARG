import { jsonResponse } from '../_shared/cors.ts';
import { supabaseAdmin } from '../_shared/supabase.ts';
import { affectedUsers, object, reconcile } from '../_shared/revenuecat.ts';

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return jsonResponse({ error: 'method_not_allowed' }, 405);
  const secret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
  const apiKey = Deno.env.get('REVENUECAT_SECRET_API_KEY');
  const appId = Deno.env.get('REVENUECAT_EXPECTED_APP_ID');
  const sandbox = Deno.env.get('REVENUECAT_ALLOW_SANDBOX');
  if (!secret || !apiKey || !appId || !['true', 'false'].includes(sandbox ?? '')) {
    return jsonResponse({ error: 'not_configured' }, 503);
  }
  if (req.headers.get('Authorization') !== secret) return jsonResponse({ error: 'unauthorized' }, 401);
  let event: Record<string, unknown>;
  try {
    // Do not persist or log this payload: it can contain customer attributes.
    const raw = await req.text();
    if (raw.length > 262144) return jsonResponse({ error: 'payload_too_large' }, 413);
    event = object(object(JSON.parse(raw), 'body').event, 'event');
    if (typeof event.id !== 'string' || !event.id || event.id.length > 200
      || typeof event.type !== 'string' || !event.type || event.type.length > 100) throw new Error();
  } catch { return jsonResponse({ error: 'malformed_event' }, 400); }
  if (event.type === 'TEST') return jsonResponse({ ok: true, test: true });
  if (event.app_id != null && event.app_id !== appId) return jsonResponse({ error: 'wrong_app' }, 403);
  // Project-level transfer/promotional events can omit app_id; the private
  // webhook secret plus project-scoped API key authenticate those explicitly.
  if (event.app_id == null && event.type !== 'TRANSFER' && event.store !== 'PROMOTIONAL') {
    return jsonResponse({ error: 'missing_app_id' }, 400);
  }
  try {
    const result = await reconcile(supabaseAdmin(), event.id as string, event.type as string,
      affectedUsers(event), apiKey, sandbox === 'true');
    return jsonResponse(result);
  } catch (error) {
    // Fixed error codes only, no SDK responses, user IDs or credentials.
    console.error('revenuecat_reconciliation_failed', error instanceof Error ? error.message : 'unknown');
    return jsonResponse({ error: 'reconciliation_pending_retry' }, 503);
  }
});
