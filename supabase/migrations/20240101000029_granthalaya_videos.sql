-- Granthalaya Video section: YouTube videos from your channel (curated in Supabase)
CREATE TABLE IF NOT EXISTS granthalaya_videos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id TEXT NOT NULL,
  title TEXT NOT NULL,
  title_hindi TEXT,
  description TEXT,
  thumbnail_url TEXT,
  duration_seconds INTEGER,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_granthalaya_videos_video_id
  ON granthalaya_videos(video_id);
CREATE INDEX IF NOT EXISTS idx_granthalaya_videos_active_order
  ON granthalaya_videos(is_active, display_order);

ALTER TABLE granthalaya_videos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow read granthalaya_videos" ON granthalaya_videos;
CREATE POLICY "Allow read granthalaya_videos" ON granthalaya_videos FOR SELECT USING (is_active = true);

COMMENT ON TABLE granthalaya_videos IS 'YouTube videos shown in Granthalaya Video tab. video_id = YouTube video ID (e.g. dQw4w9WgXcQ). thumbnail_url optional: defaults to https://img.youtube.com/vi/VIDEO_ID/mqdefault.jpg';

-- Seed: Hanuman Chalisa
INSERT INTO granthalaya_videos (video_id, title, title_hindi, display_order)
VALUES ('3wXsEryaREg', 'Hanuman Chalisa', 'हनुमान चालीसा', 1)
ON CONFLICT (video_id) DO NOTHING;
