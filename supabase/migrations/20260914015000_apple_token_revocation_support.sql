-- Responds to docs/L06_L07_DEPLOYMENT_REVIEW.md finding 7: account
-- deletion did not revoke Sign in with Apple tokens, which Apple's account
-- deletion guidance calls for. Purely additive.
--
-- Stores the Apple refresh token obtained right after a native Sign in
-- with Apple (see supabase/functions/apple-auth-store), so
-- supabase/functions/delete-account can revoke it later. This is a
-- genuinely sensitive credential — it is never read by the client and
-- never appears in any authenticated/anon-readable table; RLS is enabled
-- with zero policies, so only the service role (these two Edge Functions)
-- can touch it, matching the same locked-table pattern already used for
-- revenuecat_webhook_events.

CREATE TABLE IF NOT EXISTS public.apple_auth_tokens (
  user_id uuid PRIMARY KEY,
  refresh_token text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.apple_auth_tokens ENABLE ROW LEVEL SECURITY;
-- No policies: inaccessible to anon/authenticated by design.

ALTER TABLE public.apple_auth_tokens ADD COLUMN IF NOT EXISTS apple_subject text;
REVOKE ALL ON public.apple_auth_tokens FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.apple_auth_tokens TO service_role;
