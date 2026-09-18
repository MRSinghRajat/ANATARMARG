import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { appleEnvFromDeno, revokeAppleRefreshToken } from "../_shared/apple.ts";
import { supabaseAdmin } from "../_shared/supabase.ts";

const DEFAULT_BATCH_LIMIT = 5;
const MAX_REMOVE_PER_JOB = 2000;

function backoffSeconds(attempt: number): number {
  const capped = Math.min(Math.max(attempt, 1), 10);
  return Math.min(60 * 60, 30 * 2 ** (capped - 1));
}

function requireWorkerSecret(req: Request): boolean {
  const expected = Deno.env.get("ACCOUNT_DELETION_WORKER_SECRET");
  if (!expected) return false;
  const got = req.headers.get("x-account-deletion-worker-secret");
  return got === expected;
}

async function clearStorageObjectsForOwner(
  userId: string,
): Promise<{ removed: number }> {
  const admin = supabaseAdmin();

  const { data: objects, error } = await admin
    .schema("storage")
    .from("objects")
    .select("bucket_id,name")
    .eq("owner", userId)
    .limit(MAX_REMOVE_PER_JOB);

  if (error) throw new Error(`storage_list_failed: ${error.message}`);
  if (!objects || objects.length === 0) return { removed: 0 };

  const byBucket = new Map<string, string[]>();
  for (const o of objects) {
    const bucket = (o as { bucket_id: string }).bucket_id;
    const name = (o as { name: string }).name;
    if (!bucket || !name) continue;
    const arr = byBucket.get(bucket) ?? [];
    arr.push(name);
    byBucket.set(bucket, arr);
  }

  let removed = 0;
  for (const [bucket, names] of byBucket.entries()) {
    const chunks: string[][] = [];
    for (let i = 0; i < names.length; i += 100) {
      chunks.push(names.slice(i, i + 100));
    }

    for (const chunk of chunks) {
      const res = await admin.storage.from(bucket).remove(chunk);
      if (res.error) {
        throw new Error(
          `storage_remove_failed(${bucket}): ${res.error.message}`,
        );
      }
      removed += chunk.length;
    }
  }

  return { removed };
}

async function processJob(job: Record<string, unknown>) {
  const admin = supabaseAdmin();
  const jobId = String(job.id);
  const userId = String(job.user_id);
  const attemptCount = Number(job.attempt_count ?? 1);

  // Step 1: Apple revocation (retryable even after Auth deletion).
  const appleToken = typeof job.apple_refresh_token === "string"
    ? job.apple_refresh_token
    : null;
  const appleRevokedAt = job.apple_revoked_at
    ? String(job.apple_revoked_at)
    : null;

  if (appleToken && !appleRevokedAt) {
    const env = appleEnvFromDeno();
    const revoke = await revokeAppleRefreshToken(env, appleToken);

    // Apple may return 400 if token is already invalid/revoked; treat that as terminal for us.
    const treatAsSuccess = revoke.ok || revoke.status === 400;
    if (!treatAsSuccess) {
      const next = new Date(Date.now() + backoffSeconds(attemptCount) * 1000)
        .toISOString();
      await admin.from("account_deletion_jobs").update({
        state: "pending",
        locked_at: null,
        locked_by: null,
        next_attempt_at: next,
        last_error: `apple_revoke_failed status=${revoke.status}`,
      }).eq("id", jobId);
      return { ok: false, job_id: jobId, step: "apple_revoke", retry_at: next };
    }

    await admin.from("account_deletion_jobs").update({
      apple_revoked_at: new Date().toISOString(),
      apple_refresh_token: null,
      last_error: null,
    }).eq("id", jobId);
  }

  // Step 2: Storage cleanup (best-effort; retry on failure).
  const { removed } = await clearStorageObjectsForOwner(userId);

  // If we hit the per-run cap, schedule another run soon to continue cleanup.
  if (removed >= MAX_REMOVE_PER_JOB) {
    const next = new Date(Date.now() + 60 * 1000).toISOString();
    await admin.from("account_deletion_jobs").update({
      state: "pending",
      locked_at: null,
      locked_by: null,
      next_attempt_at: next,
      last_error: null,
    }).eq("id", jobId);
    return { ok: true, job_id: jobId, status: "pending_cleanup", removed };
  }

  await admin.from("account_deletion_jobs").update({
    state: "complete",
    completed_at: new Date().toISOString(),
    locked_at: null,
    locked_by: null,
    last_error: null,
  }).eq("id", jobId);

  return { ok: true, job_id: jobId, status: "complete", removed };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ ok: false, error: "method_not_allowed" }, 405);
  }

  if (!requireWorkerSecret(req)) {
    return jsonResponse({ ok: false, error: "unauthorized" }, 401);
  }

  const admin = supabaseAdmin();
  const workerId = crypto.randomUUID();

  const { data: jobs, error } = await admin.rpc("claim_account_deletion_jobs", {
    p_worker_id: workerId,
    p_limit: DEFAULT_BATCH_LIMIT,
  });

  if (error) {
    return jsonResponse({ ok: false, error: "claim_failed" }, 500);
  }

  const results: unknown[] = [];
  for (const job of (jobs ?? []) as Record<string, unknown>[]) {
    try {
      results.push(await processJob(job));
    } catch (e) {
      const jobId = String(job.id);
      const attemptCount = Number(job.attempt_count ?? 1);
      const next = new Date(Date.now() + backoffSeconds(attemptCount) * 1000)
        .toISOString();
      await admin.from("account_deletion_jobs").update({
        state: "pending",
        locked_at: null,
        locked_by: null,
        next_attempt_at: next,
        last_error: e instanceof Error ? e.message : String(e),
      }).eq("id", jobId);
      results.push({
        ok: false,
        job_id: jobId,
        error: "job_failed",
        retry_at: next,
      });
    }
  }

  return jsonResponse({ ok: true, claimed: (jobs ?? []).length, results }, 200);
});
