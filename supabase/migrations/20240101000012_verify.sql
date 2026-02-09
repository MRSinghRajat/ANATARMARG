-- Run these queries in Supabase SQL Editor to verify your data
-- Copy-paste each query and run separately

-- 1. Check VERSES table (REQUIRED - app fetches this FIRST)
--    If EMPTY: verses won't load! Run SUPABASE_BOOKS_SCHEMA.sql + SUPABASE_GITA_DATA.sql
SELECT * FROM verses WHERE chapter_id = 'bg_chapter_1' ORDER BY order_index LIMIT 10;

-- 2. Check VERSE_TRANSLATIONS (you confirmed this has data)
SELECT * FROM verse_translations WHERE verse_id = 'bg_1_1' LIMIT 5;

-- 3. Check if RLS is blocking (if verses has data but app gets empty)
--    rowsecurity=true means RLS is ON - need policy for anon to read
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN ('verses', 'verse_translations');

-- 4. If RLS is ON and blocking: Add policy to allow public read
--    (Only run if step 3 shows rowsecurity=true)
-- CREATE POLICY "Allow public read verses" ON verses FOR SELECT USING (true);
-- CREATE POLICY "Allow public read verse_translations" ON verse_translations FOR SELECT USING (true);
