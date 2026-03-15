-- User Daily Streak: app-open streak and optional commitment goal per user.
-- One row per user (user_id).

CREATE TABLE IF NOT EXISTS public.user_daily_streak (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    last_active_date DATE NOT NULL,
    current_streak INT NOT NULL DEFAULT 0,
    has_seen_day1_celebration BOOLEAN NOT NULL DEFAULT FALSE,
    has_committed_goal BOOLEAN NOT NULL DEFAULT FALSE,
    committed_goal_days INT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT committed_goal_days_valid CHECK (committed_goal_days IS NULL OR committed_goal_days IN (2, 5, 7, 14))
);

CREATE INDEX IF NOT EXISTS idx_user_daily_streak_user_id ON public.user_daily_streak(user_id);

ALTER TABLE public.user_daily_streak ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own daily streak"
ON public.user_daily_streak FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily streak"
ON public.user_daily_streak FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily streak"
ON public.user_daily_streak FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own daily streak"
ON public.user_daily_streak FOR DELETE
USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_user_daily_streak_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_daily_streak_timestamp ON public.user_daily_streak;
CREATE TRIGGER update_user_daily_streak_timestamp
    BEFORE UPDATE ON public.user_daily_streak
    FOR EACH ROW
    EXECUTE FUNCTION update_user_daily_streak_updated_at();

GRANT ALL ON public.user_daily_streak TO authenticated;
