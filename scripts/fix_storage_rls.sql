-- Fix the Supabase Storage Bucket Policies for the 'sacred-stories' bucket
-- These allow the Python script to upload audio (and any other files) via the API anonymously.

-- 1. Create a policy for INSERT operations
CREATE POLICY "Allow public insert to sacred-stories" 
ON storage.objects FOR INSERT TO public 
WITH CHECK (bucket_id = 'sacred-stories');

-- 2. Create a policy for UPDATE operations (since the script uses x-upsert: true)
CREATE POLICY "Allow public update to sacred-stories" 
ON storage.objects FOR UPDATE TO public 
WITH CHECK (bucket_id = 'sacred-stories');

-- 3. Create a policy for SELECT operations (just in case they need to read it)
CREATE POLICY "Allow public read from sacred-stories" 
ON storage.objects FOR SELECT TO public 
USING (bucket_id = 'sacred-stories');
