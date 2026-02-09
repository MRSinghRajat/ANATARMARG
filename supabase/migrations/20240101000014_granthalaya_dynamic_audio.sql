-- Granthalaya Listen tab: deity-track relationships, playable audio for all content
-- Links deities to chants, adds audio support to wisdom cards and in progress

-- Add deity_slug to wisdom cards (links to deities)
ALTER TABLE granthalaya_audio_wisdom_cards ADD COLUMN IF NOT EXISTS deity_slug TEXT;
ALTER TABLE granthalaya_audio_wisdom_cards ADD COLUMN IF NOT EXISTS storage_bucket TEXT DEFAULT 'granthalaya-chants';
ALTER TABLE granthalaya_audio_wisdom_cards ADD COLUMN IF NOT EXISTS storage_path TEXT;
ALTER TABLE granthalaya_audio_wisdom_cards ADD COLUMN IF NOT EXISTS audio_url TEXT;
CREATE INDEX IF NOT EXISTS idx_audio_wisdom_deity ON granthalaya_audio_wisdom_cards(deity_slug);

-- Add deity_slug and audio to in_progress
ALTER TABLE granthalaya_audio_in_progress ADD COLUMN IF NOT EXISTS deity_slug TEXT;
ALTER TABLE granthalaya_audio_in_progress ADD COLUMN IF NOT EXISTS storage_bucket TEXT DEFAULT 'granthalaya-chants';
ALTER TABLE granthalaya_audio_in_progress ADD COLUMN IF NOT EXISTS storage_path TEXT;
ALTER TABLE granthalaya_audio_in_progress ADD COLUMN IF NOT EXISTS audio_url TEXT;
CREATE INDEX IF NOT EXISTS idx_audio_in_progress_deity ON granthalaya_audio_in_progress(deity_slug);
