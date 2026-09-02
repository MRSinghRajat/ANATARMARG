-- Remove the AI Guru chat feature entirely (product decision: cut from both free and premium).
-- Drops everything created by 20240101000015 (spiritual_chat_schema), 20240101000023
-- (feeling_and_suggestions), 20240101000031/32 (spiritual_chat_service expand/reapply),
-- 20240101000034 (guru_ai_weekly_credits), and 20240101000041 (guru_ai_credit_security),
-- assuming those migrations are already applied to production. If 041 was never pushed,
-- delete that migration file instead of relying on this one to undo it.

-- Guru AI credit system (034 + 041)
DROP FUNCTION IF EXISTS public.grant_guru_ai_purchased_credits_for_user(uuid, integer, text, text);
DROP FUNCTION IF EXISTS public.sync_guru_ai_tier_for_user(uuid, text);
DROP FUNCTION IF EXISTS public.consume_guru_ai_credit();
DROP FUNCTION IF EXISTS public.peek_guru_ai_credits();
DROP FUNCTION IF EXISTS public.grant_guru_ai_purchased_credits(integer);
DROP FUNCTION IF EXISTS public.sync_guru_ai_tier_to_profile(text);
DROP TABLE IF EXISTS public.guru_credit_grant_log;
DROP TABLE IF EXISTS public.user_guru_ai_weekly;
ALTER TABLE public.app_profiles DROP COLUMN IF EXISTS guru_ai_tier;

-- Spiritual chat / multi-service consultation schema (015, 031, 032)
DROP TABLE IF EXISTS public.spiritual_chat_messages CASCADE;
DROP TABLE IF EXISTS public.spiritual_readings_archive CASCADE;
DROP TABLE IF EXISTS public.spiritual_chat_conversations CASCADE;
DROP TABLE IF EXISTS public.spiritual_user_profiles CASCADE;
DROP TABLE IF EXISTS public.user_consultation_usage CASCADE;
DROP FUNCTION IF EXISTS public.increment_consultation_count(uuid);
DROP FUNCTION IF EXISTS public.get_consultation_count(uuid);
DROP FUNCTION IF EXISTS public.update_spiritual_chat_updated_at() CASCADE;

-- Feeling check-in + weekday suggestions (023) — confirmed used only by the removed chat UI
DROP TABLE IF EXISTS public.user_feeling_log CASCADE;
DROP TABLE IF EXISTS public.feeling_weekday_suggestions CASCADE;
