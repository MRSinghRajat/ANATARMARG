import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { requireUser, supabaseAdmin } from "../_shared/supabase.ts";

const MAX_SESSION_AGE_MS = 10 * 60 * 1000;

function parseIsoDate(s: string | null | undefined): Date | null {
  if (!s) return null;
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? null : d;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ ok: false, error: "method_not_allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  const user = await requireUser(authHeader);
  if (!user) {
    return jsonResponse({ ok: false, error: "not_authenticated" }, 401);
  }

  const lastSignInAt = parseIsoDate(
    (user as unknown as { last_sign_in_at?: string }).last_sign_in_at,
  );
  if (
    !lastSignInAt || Date.now() - lastSignInAt.getTime() > MAX_SESSION_AGE_MS
  ) {
    return jsonResponse(
      {
        ok: false,
        error: "reauth_required",
        reauth_max_age_seconds: Math.floor(MAX_SESSION_AGE_MS / 1000),
      },
      401,
    );
  }

  const admin = supabaseAdmin();
  const { data: beginData, error: beginError } = await admin.rpc(
    "begin_account_deletion",
    {
      p_user_id: user.id,
    },
  );

  if (beginError || !beginData?.ok || !beginData?.job_id) {
    return jsonResponse(
      { ok: false, error: "begin_account_deletion_failed" },
      500,
    );
  }

  // Durable job exists; now remove Auth user. Even if Apple revocation fails later,
  // the worker can retry from the job payload.
  const del = await admin.auth.admin.deleteUser(user.id);
  if (
    del.error &&
    del.error.message?.toLowerCase?.().includes("user not found") !== true
  ) {
    return jsonResponse(
      { ok: false, error: "auth_delete_failed" },
      502,
    );
  }

  await admin
    .from("account_deletion_jobs")
    .update({ auth_deleted_at: new Date().toISOString() })
    .eq("id", beginData.job_id);

  return jsonResponse(
    {
      ok: true,
      status: "pending",
      job_id: beginData.job_id,
      already_requested: beginData.already_requested ?? false,
    },
    202,
  );
});
