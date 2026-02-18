-- Allow anon INSERT/UPDATE on sacred_texts for seeding.
-- Run in Supabase SQL Editor BEFORE running the insert script.

ALTER TABLE sacred_texts ENABLE ROW LEVEL SECURITY;

-- SELECT policy (to read)
DROP POLICY IF EXISTS "Anyone can view active sacred texts" ON sacred_texts;
CREATE POLICY "Anyone can view active sacred texts"
  ON sacred_texts FOR SELECT
  USING (is_active = true);

-- INSERT policy (for seeding)
DROP POLICY IF EXISTS "Allow anon insert sacred_texts" ON sacred_texts;
CREATE POLICY "Allow anon insert sacred_texts"
  ON sacred_texts FOR INSERT WITH CHECK (true);

-- UPDATE policy (for seeding)
DROP POLICY IF EXISTS "Allow anon update sacred_texts" ON sacred_texts;
CREATE POLICY "Allow anon update sacred_texts"
  ON sacred_texts FOR UPDATE USING (true);
