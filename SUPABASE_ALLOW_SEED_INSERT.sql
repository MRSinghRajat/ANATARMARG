-- Allow anon to INSERT/UPDATE verses and verse_translations for one-time seeding.
-- Run this in Supabase SQL Editor BEFORE running upload_gita_to_supabase.py
-- (Optional: drop these policies after seeding if you want to lock down inserts)

-- Verses: allow insert and update for seeding
ALTER TABLE verses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon insert verses" ON verses;
CREATE POLICY "Allow anon insert verses" ON verses FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Allow anon update verses" ON verses;
CREATE POLICY "Allow anon update verses" ON verses FOR UPDATE USING (true);

-- Verse translations: allow insert and update for seeding  
ALTER TABLE verse_translations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon insert verse_translations" ON verse_translations;
CREATE POLICY "Allow anon insert verse_translations" ON verse_translations FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Allow anon update verse_translations" ON verse_translations;
CREATE POLICY "Allow anon update verse_translations" ON verse_translations FOR UPDATE USING (true);
