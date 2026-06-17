-- Prevent replay exploits: uncomplete + complete again must not re-award coins/XP.
-- rewards_granted_at is set on first successful reward grant and never cleared on uncomplete.

ALTER TABLE public.user_daily_tasks
  ADD COLUMN IF NOT EXISTS rewards_granted_at TIMESTAMPTZ;

COMMENT ON COLUMN public.user_daily_tasks.rewards_granted_at IS
  'First time coins/XP were credited for this task row; persists if user un-marks complete.';

-- Existing completed tasks: treat as already rewarded so toggling cannot mint new karma.
UPDATE public.user_daily_tasks
SET rewards_granted_at = COALESCE(completed_at, created_at, now())
WHERE status = 'completed'
  AND rewards_granted_at IS NULL;
