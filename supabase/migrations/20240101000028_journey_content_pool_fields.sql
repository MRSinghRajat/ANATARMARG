-- Add unified content fields if table was created with older columns
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS content_hindi TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS instruction TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS instruction_hindi TEXT;
-- Optional: for structured INSTRUCTION (Transliteration, Meaning, Benefits)
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS transliteration TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS translation TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS benefits JSONB;
