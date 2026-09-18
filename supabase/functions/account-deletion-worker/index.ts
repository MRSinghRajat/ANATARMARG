// Schedule every minute with X-Deletion-Worker-Secret from server-side Vault.
// Deploy with verify_jwt=false; only this dedicated >=32-character secret can
// invoke the worker. A user's bearer token never authorizes background work.
import { jsonResponse } from '../_shared/cors.ts';
import { supabaseAdmin } from '../_shared/supabase.ts';
import { processDeletionJob } from '../delete-account/worker.ts';
import { deletionOperations } from '../delete-account/operations.ts';

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return jsonResponse({ error: 'method_not_allowed' }, 405);
  const expected = Deno.env.get('DELETION_WORKER_SECRET');
  if (!expected || expected.length < 32 || req.headers.get('X-Deletion-Worker-Secret') !== expected) {
    return jsonResponse({ error: 'not_authorized' }, 401);
  }
  const admin = supabaseAdmin();
  let complete = 0;
  let pending = 0;
  try {
    // One job per invocation keeps the worker bounded below the Edge timeout.
    const status = await processDeletionJob(deletionOperations(admin));
    if (status === 'complete') complete++;
    if (status === 'pending') pending++;
    const { error } = await admin.rpc('prune_account_deletion_records');
    if (error) throw new Error('prune_failed');
    // Counts only: no user IDs, tokens, provider bodies or user records in logs.
    return jsonResponse({ ok: true, complete, pending });
  } catch {
    console.error('account-deletion-worker: retry required');
    return jsonResponse({ ok: false, error: 'retry_required' }, 500);
  }
});
