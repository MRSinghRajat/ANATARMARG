-- Allow anon to INSERT/UPDATE sacred_stories for one-time seeding.
-- Run this in Supabase SQL Editor BEFORE running insert_sacred_stories.py

ALTER TABLE sacred_stories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon insert sacred_stories" ON sacred_stories;
CREATE POLICY "Allow anon insert sacred_stories" ON sacred_stories FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Allow anon update sacred_stories" ON sacred_stories;
CREATE POLICY "Allow anon update sacred_stories" ON sacred_stories FOR UPDATE USING (true);
