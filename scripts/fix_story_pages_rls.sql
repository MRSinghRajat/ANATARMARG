-- Temporarily allow all operations for the public/anon role on story_pages
-- This will ensure the Python script can reliably update the audio_url and audio_url_en fields!

ALTER TABLE story_pages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public all on story_pages" ON story_pages;

CREATE POLICY "Allow public all on story_pages" 
ON story_pages 
FOR ALL TO public 
USING (true) 
WITH CHECK (true);
