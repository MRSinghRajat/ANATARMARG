-- AI Guru weekly included credits + purchased top-ups (server-side, survives reinstall).
-- Tiers: free (5/wk), plus (10/wk), pro (20/wk). Purchased credits used after included exhausted.

ALTER TABLE public.app_profiles
  ADD COLUMN IF NOT EXISTS guru_ai_tier TEXT NOT NULL DEFAULT 'free'
    CHECK (guru_ai_tier IN ('free', 'plus', 'pro'));

CREATE TABLE IF NOT EXISTS public.user_guru_ai_weekly (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  week_bucket TEXT NOT NULL DEFAULT '',
  included_used INTEGER NOT NULL DEFAULT 0,
  purchased_credits INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_guru_ai_weekly_updated ON public.user_guru_ai_weekly(updated_at);

ALTER TABLE public.user_guru_ai_weekly ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own guru ai weekly"
  ON public.user_guru_ai_weekly FOR SELECT
  USING (auth.uid() = user_id);

GRANT SELECT ON public.user_guru_ai_weekly TO authenticated;

-- Sync tier from app after RevenueCat resolves subscription (used by consume for allowance).
CREATE OR REPLACE FUNCTION public.sync_guru_ai_tier_to_profile(p_tier text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_tier IS NULL OR p_tier NOT IN ('free', 'plus', 'pro') THEN
    RAISE EXCEPTION 'invalid tier';
  END IF;
  INSERT INTO public.app_profiles (user_id, guru_ai_tier)
  VALUES (auth.uid(), p_tier)
  ON CONFLICT (user_id) DO UPDATE
  SET guru_ai_tier = EXCLUDED.guru_ai_tier,
      updated_at = NOW();
END;
$$;

GRANT EXECUTE ON FUNCTION public.sync_guru_ai_tier_to_profile(text) TO authenticated;

-- Peek remaining credits (no consume).
CREATE OR REPLACE FUNCTION public.peek_guru_ai_credits()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  tid UUID := auth.uid();
  wb TEXT;
  ap_tier TEXT;
  allowance INT;
  rec RECORD;
  inc_rem INT;
  pur INT;
BEGIN
  IF tid IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'not_authenticated');
  END IF;

  wb := to_char((timezone('utc', now()))::date, 'IYYY_IW');

  SELECT COALESCE(guru_ai_tier, 'free') INTO ap_tier
  FROM public.app_profiles WHERE user_id = tid;
  ap_tier := COALESCE(ap_tier, 'free');

  allowance := CASE ap_tier
    WHEN 'pro' THEN 20
    WHEN 'plus' THEN 10
    ELSE 5
  END;

  SELECT * INTO rec FROM public.user_guru_ai_weekly WHERE user_id = tid;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'ok', true,
      'week_bucket', wb,
      'tier', ap_tier,
      'allowance', allowance,
      'included_used', 0,
      'included_remaining', allowance,
      'purchased_credits', 0,
      'total_sendable', allowance
    );
  END IF;

  IF rec.week_bucket IS DISTINCT FROM wb THEN
    inc_rem := allowance;
  ELSE
    inc_rem := GREATEST(0, allowance - rec.included_used);
  END IF;

  pur := GREATEST(0, rec.purchased_credits);

  RETURN jsonb_build_object(
    'ok', true,
    'week_bucket', wb,
    'tier', ap_tier,
    'allowance', allowance,
    'included_used', CASE WHEN rec.week_bucket IS DISTINCT FROM wb THEN 0 ELSE rec.included_used END,
    'included_remaining', inc_rem,
    'purchased_credits', pur,
    'total_sendable', inc_rem + pur
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.peek_guru_ai_credits() TO authenticated;

-- Consume one credit (included first, then purchased). Call before LLM.
CREATE OR REPLACE FUNCTION public.consume_guru_ai_credit()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  tid UUID := auth.uid();
  wb TEXT;
  ap_tier TEXT;
  allowance INT;
  rec RECORD;
BEGIN
  IF tid IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'reason', 'not_authenticated');
  END IF;

  wb := to_char((timezone('utc', now()))::date, 'IYYY_IW');

  SELECT COALESCE(guru_ai_tier, 'free') INTO ap_tier
  FROM public.app_profiles WHERE user_id = tid;
  ap_tier := COALESCE(ap_tier, 'free');

  allowance := CASE ap_tier
    WHEN 'pro' THEN 20
    WHEN 'plus' THEN 10
    ELSE 5
  END;

  INSERT INTO public.user_guru_ai_weekly (user_id, week_bucket, included_used, purchased_credits)
  VALUES (tid, wb, 0, 0)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT * INTO rec FROM public.user_guru_ai_weekly WHERE user_id = tid FOR UPDATE;

  IF rec.week_bucket IS DISTINCT FROM wb THEN
    UPDATE public.user_guru_ai_weekly
    SET week_bucket = wb, included_used = 0, updated_at = NOW()
    WHERE user_id = tid;
    rec.week_bucket := wb;
    rec.included_used := 0;
  END IF;

  IF rec.included_used < allowance THEN
    UPDATE public.user_guru_ai_weekly
    SET included_used = included_used + 1, updated_at = NOW()
    WHERE user_id = tid;
    RETURN jsonb_build_object('ok', true, 'source', 'included');
  END IF;

  IF rec.purchased_credits > 0 THEN
    UPDATE public.user_guru_ai_weekly
    SET purchased_credits = purchased_credits - 1, updated_at = NOW()
    WHERE user_id = tid;
    RETURN jsonb_build_object('ok', true, 'source', 'purchased');
  END IF;

  RETURN jsonb_build_object('ok', false, 'reason', 'quota_exceeded');
END;
$$;

GRANT EXECUTE ON FUNCTION public.consume_guru_ai_credit() TO authenticated;

-- Add purchased pack (10 / 30 / 100). Client calls after verified RevenueCat consumable purchase.
CREATE OR REPLACE FUNCTION public.grant_guru_ai_purchased_credits(p_amount integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  tid UUID := auth.uid();
  wb TEXT;
BEGIN
  IF tid IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'not_authenticated');
  END IF;
  IF p_amount IS NULL OR p_amount NOT IN (10, 30, 100) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_pack_amount');
  END IF;

  wb := to_char((timezone('utc', now()))::date, 'IYYY_IW');

  INSERT INTO public.user_guru_ai_weekly (user_id, week_bucket, included_used, purchased_credits)
  VALUES (tid, wb, 0, p_amount)
  ON CONFLICT (user_id) DO UPDATE
  SET purchased_credits = public.user_guru_ai_weekly.purchased_credits + EXCLUDED.purchased_credits,
      updated_at = NOW();

  RETURN jsonb_build_object('ok', true, 'added', p_amount);
END;
$$;

GRANT EXECUTE ON FUNCTION public.grant_guru_ai_purchased_credits(integer) TO authenticated;

COMMENT ON TABLE public.user_guru_ai_weekly IS 'Weekly included AI Guru usage + purchased credit balance; enforced via consume_guru_ai_credit()';
COMMENT ON COLUMN public.app_profiles.guru_ai_tier IS 'free | plus | pro — synced from app/RevenueCat for server-side allowance';
