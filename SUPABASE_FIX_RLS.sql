-- Fix: Allow app to read verses and verse_translations
-- Run this in Supabase SQL Editor if verses don't load in the app
-- (SQL Editor works because it uses elevated privileges; app uses anon key)

-- Enable RLS on verses (if not already) and allow public read
ALTER TABLE verses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read verses" ON verses;
CREATE POLICY "Allow public read verses"
  ON verses FOR SELECT
  USING (true);

-- Enable RLS on verse_translations (if not already) and allow public read  
ALTER TABLE verse_translations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read verse_translations" ON verse_translations;
CREATE POLICY "Allow public read verse_translations"
  ON verse_translations FOR SELECT
  USING (true);

-- Also allow public read on books and chapters (for chapter list)
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read books" ON books;
CREATE POLICY "Allow public read books"
  ON books FOR SELECT
  USING (true);

ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read chapters" ON chapters;
CREATE POLICY "Allow public read chapters"
  ON chapters FOR SELECT
  USING (true);
