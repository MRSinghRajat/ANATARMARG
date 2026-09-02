-- Supabase Granthalaya (Library) Dynamic Content Schema
-- Run in Supabase SQL Editor
-- Prerequisite: Run SUPABASE_DEITIES_SCHEMA.sql first (for ALTER TABLE deities)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: granthalaya_resource_cards
-- Read mode - Resource Library (Terminology, Pronunciation)
-- ============================================
CREATE TABLE IF NOT EXISTS granthalaya_resource_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  icon_name TEXT NOT NULL DEFAULT 'menu_book',
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_resource_cards_order ON granthalaya_resource_cards(order_index);

ALTER TABLE granthalaya_resource_cards ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active resource cards" ON granthalaya_resource_cards;
CREATE POLICY "Anyone can view active resource cards"
  ON granthalaya_resource_cards FOR SELECT
  USING (is_active = true);

INSERT INTO granthalaya_resource_cards (title, subtitle, icon_name, order_index)
SELECT 'Terminology', 'Sanskrit Glossary', 'menu_book', 1
WHERE NOT EXISTS (SELECT 1 FROM granthalaya_resource_cards WHERE title = 'Terminology');
INSERT INTO granthalaya_resource_cards (title, subtitle, icon_name, order_index)
SELECT 'Pronunciation', 'Chanting Rules', 'record_voice_over', 2
WHERE NOT EXISTS (SELECT 1 FROM granthalaya_resource_cards WHERE title = 'Pronunciation');

-- ============================================
-- TABLE: granthalaya_deep_dive
-- Read mode - Deep Dive / Today's Reflection article cards
-- ============================================
CREATE TABLE IF NOT EXISTS granthalaya_deep_dive (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  quote TEXT NOT NULL,
  duration_label TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_deep_dive_order ON granthalaya_deep_dive(order_index);

ALTER TABLE granthalaya_deep_dive ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active deep dive" ON granthalaya_deep_dive;
CREATE POLICY "Anyone can view active deep dive"
  ON granthalaya_deep_dive FOR SELECT
  USING (is_active = true);

INSERT INTO granthalaya_deep_dive (title, quote, duration_label, order_index)
SELECT 'The Nature of ''Atman''', '"The Self is not born, nor does it ever die... Unborn, eternal, ever-existing, and primeval."', '4 min read', 1
WHERE NOT EXISTS (SELECT 1 FROM granthalaya_deep_dive WHERE title LIKE '%Atman%');

-- ============================================
-- TABLE: granthalaya_audio_categories
-- Listen mode - Sacred Library categories (Audio Books, Chants, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS granthalaya_audio_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audio_categories_order ON granthalaya_audio_categories(order_index);

ALTER TABLE granthalaya_audio_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active audio categories" ON granthalaya_audio_categories;
CREATE POLICY "Anyone can view active audio categories"
  ON granthalaya_audio_categories FOR SELECT
  USING (is_active = true);

INSERT INTO granthalaya_audio_categories (slug, name, order_index) VALUES
  ('audio_books', 'Audio Books', 1),
  ('chants', 'Chants', 2),
  ('guided', 'Guided', 3),
  ('nature', 'Nature', 4)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, order_index = EXCLUDED.order_index;

-- ============================================
-- TABLE: granthalaya_audio_wisdom_cards
-- Listen mode - Sacred Library wisdom cards (Shiva Purana, Rig Veda, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS granthalaya_audio_wisdom_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  image_url TEXT NOT NULL,
  category_slug TEXT DEFAULT 'audio_books',
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audio_wisdom_order ON granthalaya_audio_wisdom_cards(order_index);
CREATE INDEX IF NOT EXISTS idx_audio_wisdom_category ON granthalaya_audio_wisdom_cards(category_slug);

ALTER TABLE granthalaya_audio_wisdom_cards ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active wisdom cards" ON granthalaya_audio_wisdom_cards;
CREATE POLICY "Anyone can view active wisdom cards"
  ON granthalaya_audio_wisdom_cards FOR SELECT
  USING (is_active = true);

INSERT INTO granthalaya_audio_wisdom_cards (title, subtitle, image_url, category_slug, order_index) VALUES
  ('Shiva Purana', '42 Tracks • 12 Cantos', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO', 'audio_books', 1),
  ('Rig Veda', '108 Mandalas • Shruti', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1', 'audio_books', 2),
  ('Sama Veda', '1875 Melodies', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCeFNfyF3TMbtQ7up4KjskhDXsUja_ezF57r7yXtsw7qht7MWETTO5t-dTRJ5yKLGjVidywqNDN_tYKaEhCT-GW6PgKdHyCJivzZEk3MFKeenhqQE9lW9dmulcDAGEtzqlDKk9-V_1vAxfrsXu5ER-bNWtcVzRI4zSyvvmNDPJ58EPRheqIFknQUzuOF0zLsTHepqZozzC058V3Vhz4FC7I0MqtbnhK3mRrEBauKk-OBOllQvmPoUhxzI3oicigPXbW4HNzglsA3JZD', 'audio_books', 3);

-- ============================================
-- TABLE: granthalaya_audio_in_progress
-- Listen mode - In Progress audio items (featured/sample)
-- ============================================
CREATE TABLE IF NOT EXISTS granthalaya_audio_in_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tag TEXT NOT NULL,
  title TEXT NOT NULL,
  image_url TEXT NOT NULL,
  current_time_seconds INTEGER DEFAULT 0,
  total_time_seconds INTEGER NOT NULL,
  is_active_item BOOLEAN NOT NULL DEFAULT false,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audio_in_progress_order ON granthalaya_audio_in_progress(order_index);

ALTER TABLE granthalaya_audio_in_progress ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active in progress items" ON granthalaya_audio_in_progress;
CREATE POLICY "Anyone can view active in progress items"
  ON granthalaya_audio_in_progress FOR SELECT
  USING (is_active = true);

INSERT INTO granthalaya_audio_in_progress (tag, title, image_url, current_time_seconds, total_time_seconds, is_active_item, order_index)
SELECT 'Itihasa • Chapter 4', 'Bhagavad Gita', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCeFNfyF3TMbtQ7up4KjskhDXsUja_ezF57r7yXtsw7qht7MWETTO5t-dTRJ5yKLGjVidywqNDN_tYKaEhCT-GW6PgKdHyCJivzZEk3MFKeenhqQE9lW9dmulcDAGEtzqlDKk9-V_1vAxfrsXu5ER-bNWtcVzRI4zSyvvmNDPJ58EPRheqIFknQUzuOF0zLsTHepqZozzC058V3Vhz4FC7I0MqtbnhK3mRrEBauKk-OBOllQvmPoUhxzI3oicigPXbW4HNzglsA3JZD', 765, 1710, true, 1
WHERE NOT EXISTS (SELECT 1 FROM granthalaya_audio_in_progress WHERE title = 'Bhagavad Gita' AND tag = 'Itihasa • Chapter 4');
INSERT INTO granthalaya_audio_in_progress (tag, title, image_url, current_time_seconds, total_time_seconds, is_active_item, order_index)
SELECT 'Shruti • Isha', 'Mukhya Upanishads', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO', 135, 900, false, 2
WHERE NOT EXISTS (SELECT 1 FROM granthalaya_audio_in_progress WHERE title = 'Mukhya Upanishads');

-- Add description to deities if not exists (for Divine Presence)
ALTER TABLE deities ADD COLUMN IF NOT EXISTS description TEXT;

UPDATE deities SET description = 'The cosmic dancer who performs the Ananda Tandava, creating and destroying the universe.' WHERE slug = 'shiva';
UPDATE deities SET description = 'The sustainer of the universe, reclining on the serpent Shesha in the causal ocean.' WHERE slug = 'vishnu';
UPDATE deities SET description = 'The supreme feminine energy, embodying power, knowledge, and compassion.' WHERE slug = 'devi';
UPDATE deities SET description = 'The remover of obstacles, lord of wisdom and new beginnings.' WHERE slug = 'ganesha';
