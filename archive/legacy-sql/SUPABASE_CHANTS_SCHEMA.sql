-- Supabase Granthalaya Chants Table
-- Run in Supabase SQL Editor after SUPABASE_GRANTHALAYA_SCHEMA.sql
--
-- AUDIO FROM SUPABASE STORAGE:
-- 1. Create a storage bucket named 'granthalaya-chants' in Supabase Dashboard (Storage)
-- 2. Make it PUBLIC so getPublicUrl works
-- 3. Upload audio files (e.g. shiva-chant.mp3)
-- 4. Insert row with storage_path = 'shiva-chant.mp3' (path relative to bucket)
-- 5. App automatically constructs: storage.from('granthalaya-chants').getPublicUrl('shiva-chant.mp3')
--
-- Alternatively, use audio_url for a full URL (e.g. from another CDN).
-- If audio_url is set, it takes precedence over storage.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: granthalaya_chants
-- Chants section: Shiva chant, mantras, etc.
-- Audio from Supabase Storage (storage_path) or direct URL (audio_url)
-- ============================================
CREATE TABLE IF NOT EXISTS granthalaya_chants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  subtitle TEXT,
  image_url TEXT,
  -- Supabase Storage: bucket + path. App constructs public URL via storage.from(bucket).getPublicUrl(path)
  storage_bucket TEXT NOT NULL DEFAULT 'granthalaya-chants',
  storage_path TEXT NOT NULL,
  -- Alternative: full audio URL (takes precedence if set - for external CDN or direct links)
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

-- Seed: Shiva Chant (replace storage_path with your actual file after uploading to Storage)
INSERT INTO granthalaya_chants (title, subtitle, image_url, storage_bucket, storage_path, duration_seconds, deity_slug, order_index)
SELECT
  'Shiva Chant',
  'Om Namah Shivaya • The five-syllable mantra',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv',
  'granthalaya-chants',
  'shiva-chant.wav',
  300,
  'shiva',
  1
WHERE NOT EXISTS (SELECT 1 FROM granthalaya_chants WHERE title = 'Shiva Chant');
