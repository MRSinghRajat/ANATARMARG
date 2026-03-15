-- Add is_premium column to books table
ALTER TABLE books ADD COLUMN IF NOT EXISTS is_premium boolean NOT NULL DEFAULT false;

-- Add is_premium column to sacred_stories table
ALTER TABLE sacred_stories ADD COLUMN IF NOT EXISTS is_premium boolean NOT NULL DEFAULT false;

-- Index for efficient filtering
CREATE INDEX IF NOT EXISTS idx_books_is_premium ON books (is_premium);
CREATE INDEX IF NOT EXISTS idx_sacred_stories_is_premium ON sacred_stories (is_premium);
