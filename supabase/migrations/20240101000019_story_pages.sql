-- Sacred Stories: keep sacred_stories for title, cover, video, metadata.
-- Pages live in story_pages (one row per page).
-- Run after existing sacred_stories table exists.

-- story_pages: one row per page of a sacred story
CREATE TABLE IF NOT EXISTS story_pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID NOT NULL REFERENCES sacred_stories(id) ON DELETE CASCADE,
  page_number INTEGER NOT NULL,
  text_hindi TEXT DEFAULT '',
  text_english TEXT DEFAULT '',
  text_sanskrit TEXT,
  image_url TEXT,
  audio_url TEXT,
  layout_type TEXT NOT NULL DEFAULT 'text' CHECK (layout_type IN ('text', 'image-top', 'full-bleed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(story_id, page_number)
);

CREATE INDEX IF NOT EXISTS idx_story_pages_story_id ON story_pages(story_id);
CREATE INDEX IF NOT EXISTS idx_story_pages_story_page ON story_pages(story_id, page_number);

ALTER TABLE story_pages ENABLE ROW LEVEL SECURITY;

-- Anyone can read story_pages (same as sacred_stories: public content)
CREATE POLICY "Anyone can view story_pages"
  ON story_pages FOR SELECT
  USING (true);

-- Optional: allow anon to insert/update for seeding (match sacred_stories)
CREATE POLICY "Allow anon insert story_pages"
  ON story_pages FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow anon update story_pages"
  ON story_pages FOR UPDATE USING (true);

COMMENT ON TABLE story_pages IS 'One row per page of a sacred story. sacred_stories holds title, cover, video, metadata.';
