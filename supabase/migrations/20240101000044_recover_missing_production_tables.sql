-- AM-2 remainder: push_tokens (no earlier ALTER depends on it).
-- sacred_stories / sacred_texts / user_journeys / daily tasks are created in
-- 000181, 000241, 000321 so later numbered migrations can reference them.

CREATE TABLE IF NOT EXISTS public.push_tokens (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  token text NOT NULL,
  platform text NOT NULL DEFAULT 'ios',
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own push token" ON public.push_tokens;
CREATE POLICY "Users can manage own push token"
  ON public.push_tokens FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

COMMENT ON TABLE public.push_tokens IS
  'FCM/APNs device tokens for push notifications; used by backend to send to specific users.';
