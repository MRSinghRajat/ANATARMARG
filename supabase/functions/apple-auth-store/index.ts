import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { requireUser, supabaseAdmin } from "../_shared/supabase.ts";
import {
  appleEnvFromDeno,
  decodeAppleIdTokenSub,
  exchangeAppleAuthorizationCode,
} from "../_shared/apple.ts";

type StoreRequest = {
  authorizationCode?: string;
};

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

  let body: StoreRequest;
  try {
    body = (await req.json()) as StoreRequest;
  } catch {
    return jsonResponse({ ok: false, error: "invalid_json" }, 400);
  }

  const authorizationCode = body.authorizationCode?.trim();
  if (!authorizationCode) {
    return jsonResponse(
      { ok: false, error: "missing_authorization_code" },
      400,
    );
  }

  const env = appleEnvFromDeno();
  const token = await exchangeAppleAuthorizationCode(env, authorizationCode);
  if (token.error || !token.refresh_token) {
    return jsonResponse(
      {
        ok: false,
        error: "apple_token_exchange_failed",
        apple_error: token.error ?? null,
        apple_error_description: token.error_description ?? null,
      },
      502,
    );
  }

  const appleSub = token.id_token
    ? decodeAppleIdTokenSub(token.id_token)
    : null;

  const admin = supabaseAdmin();
  const { error } = await admin.from("apple_auth_store").upsert(
    {
      user_id: user.id,
      apple_sub: appleSub,
      refresh_token: token.refresh_token,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );

  if (error) {
    return jsonResponse({ ok: false, error: "db_upsert_failed" }, 500);
  }

  return jsonResponse({ ok: true }, 200);
});
