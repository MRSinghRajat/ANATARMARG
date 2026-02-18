-- FIX: Add SELECT policy for sacred_stories so the app can read stories.
-- When we ran ENABLE ROW LEVEL SECURITY without a SELECT policy, all reads were blocked.
-- Run this immediately in Supabase SQL Editor!

DROP POLICY IF EXISTS "Anyone can view active sacred stories" ON sacred_stories;
CREATE POLICY "Anyone can view active sacred stories"
  ON sacred_stories FOR SELECT
  USING (is_active = true);
