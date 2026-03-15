-- Add explicit language audio column to the story_pages table for English
-- We will use the existing 'audio_url' column for Hindi
ALTER TABLE story_pages ADD COLUMN IF NOT EXISTS audio_url_en TEXT;
