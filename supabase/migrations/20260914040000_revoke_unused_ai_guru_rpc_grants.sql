-- Hygiene follow-up, independent of L06/L07 — safe to deploy at any point
-- in the sequence, including before L07a. Surfaced by the Supabase security
-- advisor: these six SECURITY DEFINER functions are left over from the
-- removed AI Guru feature (see
-- supabase/migrations/20240101000043_remove_ai_guru_feature.sql) and are
-- still callable by the `anon` role — including while signed out — over
-- the public REST API. Each function does check `auth.uid() IS NULL`
-- internally and refuses to act for anon, so this was not independently
-- exploitable; this migration reduces surface area for a dead feature
-- rather than fixing an active leak. Confirmed via a repo-wide search that
-- no code in lib/ calls any of these six functions anymore.
--
-- Only the grants change. The functions themselves, and the tables they
-- touch (user_guru_ai_weekly, user_consultation_usage, app_profiles), are
-- left in place — dropping them is a separate decision if the feature stays
-- permanently removed, out of scope here.

REVOKE EXECUTE ON FUNCTION public.consume_guru_ai_credit() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.grant_guru_ai_purchased_credits(integer) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.peek_guru_ai_credits() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.sync_guru_ai_tier_to_profile(text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_consultation_count(uuid) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.increment_consultation_count(uuid) FROM anon, authenticated;
