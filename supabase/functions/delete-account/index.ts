// Authenticated deletion request. Cleanup atomically creates a durable job
// before removing app data or credentials. A scheduled service worker recovers
// after crashes, Apple outages, lost HTTP responses and Auth removal failures.
import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { supabaseAdmin, supabaseUserClient } from "../_shared/supabase.ts";
import { processDeletionJob } from "./worker.ts";
import { deletionOperations } from "./operations.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ ok: false, error: "method_not_allowed" }, 405);
  }
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonResponse({ ok: false, error: "not_authenticated" }, 401);
  }
  const userClient = supabaseUserClient(authHeader);
  const { data, error } = await userClient.auth.getUser();
  if (error || !data.user) {
    return jsonResponse({ ok: false, error: "not_authenticated" }, 401);
  }
  const { data: cleanup, error: cleanupError } = await userClient.rpc(
    "delete_own_account_data",
  );
  if (cleanupError) {
    return jsonResponse({ ok: false, error: "cleanup_failed" }, 500);
  }
  if (cleanup?.ok !== true) {
    return jsonResponse({
      ok: false,
      error: cleanup?.error ?? "cleanup_failed",
    }, 409);
  }
  let status: "complete" | "pending" | "busy" = "pending";
  try {
    status = await processDeletionJob(
      deletionOperations(supabaseAdmin()),
      data.user.id,
    );
  } catch {
    console.warn("delete-account: accepted job needs background retry");
  }
  // Accepted is distinct from complete. Clients sign out and show the accurate
  // status, rather than requiring an already deleted account to retry.
  return jsonResponse({
    ok: true,
    accepted: true,
    pending: status !== "complete",
  }, status === "complete" ? 200 : 202);
});
