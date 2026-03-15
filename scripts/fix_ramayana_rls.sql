-- Temporarily allow all operations for the public/anon role on verses and verse_translations
-- This will fix the "Row Level Security" (RLS) policies blocking the Ramayana import agent.

-- Ensure RLS is enabled on the tables first
ALTER TABLE verses ENABLE ROW LEVEL SECURITY;
ALTER TABLE verse_translations ENABLE ROW LEVEL SECURITY;

-- Drop the policies if we've created them before to avoid conflicts
DROP POLICY IF EXISTS "Allow public all on verses" ON verses;
DROP POLICY IF EXISTS "Allow public all on verse_translations" ON verse_translations;

-- Create policies allowing ALL actions (SELECT, INSERT, UPDATE, DELETE) for anyone
CREATE POLICY "Allow public all on verses" 
ON verses 
FOR ALL TO public 
USING (true) 
WITH CHECK (true);

CREATE POLICY "Allow public all on verse_translations" 
ON verse_translations 
FOR ALL TO public 
USING (true) 
WITH CHECK (true);
