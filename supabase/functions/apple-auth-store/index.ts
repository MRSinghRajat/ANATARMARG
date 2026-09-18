// Authenticated native Apple code capture. The exchanged, cryptographically
// verified Apple subject must match the caller's verified linked identity.
import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { supabaseAdmin, supabaseUserClient } from "../_shared/supabase.ts";
import {
  exchangeAppleAuthorizationCode,
  isLinkedAppleSubject,
  loadAppleConfig,
} from "../_shared/apple.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ ok: false, error: "method_not_allowed" }, 405);
  }
  const auth = req.headers.get("Authorization");
  if (!auth) {
    return jsonResponse({ ok: false, error: "not_authenticated" }, 401);
  }
  const { data, error } = await supabaseUserClient(auth).auth.getUser();
  if (error || !data.user) {
    return jsonResponse({ ok: false, error: "not_authenticated" }, 401);
  }
  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ ok: false, error: "invalid_json" }, 400);
  }
  if (
    typeof body?.authorizationCode !== "string" || !body.authorizationCode ||
    body.authorizationCode.length > 8192
  ) {
    return jsonResponse(
      { ok: false, error: "invalid_authorization_code" },
      400,
    );
  }
  const config = loadAppleConfig();
  if (!config) return jsonResponse({ ok: false, error: "not_configured" }, 503);
  try {
    const exchange = await exchangeAppleAuthorizationCode(
      config,
      body.authorizationCode,
    );
    if (!exchange) {
      return jsonResponse({ ok: false, error: "exchange_failed" }, 502);
    }
    if (!isLinkedAppleSubject(data.user.identities, exchange.subject)) {
      return jsonResponse({ ok: false, error: "apple_identity_mismatch" }, 403);
    }
    // RPC checks the linked identity again under the deletion lock, so a
    // concurrent deletion cannot recreate a credential after cleanup.
    const { error: storeError } = await supabaseAdmin().rpc(
      "store_apple_auth_token",
      {
        p_user_id: data.user.id,
        p_subject: exchange.subject,
        p_refresh_token: exchange.refreshToken,
      },
    );
    if (storeError) {
      return jsonResponse({ ok: false, error: "store_failed" }, 409);
    }
    return jsonResponse({ ok: true });
  } catch {
    return jsonResponse({ ok: false, error: "apple_capture_failed" }, 502);
  }
});
