-- Granthalaya Chants - playable audio from Supabase Storage
-- Storage: create bucket 'granthalaya-chants' (public) in Supabase Dashboard

CREATE TABLE IF NOT EXISTS granthalaya_chants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  subtitle TEXT,
  image_url TEXT,
  storage_bucket TEXT NOT NULL DEFAULT 'granthalaya-chants',
  storage_path TEXT NOT NULL,
  audio_url TEXT,
  duration_seconds INTEGER,
  deity_slug TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chants_order ON granthalaya_chants(order_index);
CREATE INDEX IF NOT EXISTS idx_chants_deity ON granthalaya_chants(deity_slug);

ALTER TABLE granthalaya_chants ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active chants" ON granthalaya_chants;
CREATE POLICY "Anyone can view active chants"
  ON granthalaya_chants FOR SELECT
  USING (is_active = true);
