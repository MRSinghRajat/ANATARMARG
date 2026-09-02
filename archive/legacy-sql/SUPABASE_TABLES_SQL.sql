-- Supabase Database Schema for Antar Marg App
-- Run these SQL commands in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE 1: parvas
-- Stores the 18 Parvas of Mahabharata
-- ============================================
CREATE TABLE IF NOT EXISTS parvas (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'locked' CHECK (status IN ('completed', 'active', 'locked')),
  required_level INTEGER,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default parvas
INSERT INTO parvas (id, name, subtitle, status, required_level) VALUES
(1, 'ADI PARVA', 'The Beginning', 'completed', NULL),
(2, 'SABHA PARVA', 'The Hall', 'completed', NULL),
(3, 'VANA PARVA', 'The Forest Exile', 'active', NULL),
(4, 'VIRATA PARVA', 'The Incognito', 'locked', 5),
(5, 'UDYOGA PARVA', 'The Effort', 'locked', 6),
(6, 'BHISHMA PARVA', 'The Bhagavad Gita', 'locked', 7),
(7, 'DRONA PARVA', 'The Command', 'locked', 8),
(8, 'KARNA PARVA', 'The Sun-Son', 'locked', 9),
(9, 'SHALYA PARVA', 'The Last Battle', 'locked', 10),
(10, 'SAUPTIKA PARVA', 'The Night Attack', 'locked', 11),
(11, 'STRI PARVA', 'The Women', 'locked', 12),
(12, 'SHANTI PARVA', 'The Peace', 'locked', 13),
(13, 'ANUSHASANA PARVA', 'The Instructions', 'locked', 14),
(14, 'ASHVAMEDHIKA PARVA', 'The Horse Sacrifice', 'locked', 15),
(15, 'ASHRAMAVASIKA PARVA', 'The Hermitage', 'locked', 16),
(16, 'MOUSALA PARVA', 'The Clubs', 'locked', 17),
(17, 'MAHAPRASTHANIKA PARVA', 'The Great Journey', 'locked', 18),
(18, 'SVARGAROHANA PARVA', 'The Ascent to Heaven', 'locked', 19)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TABLE 2: quest_stages
-- Stores quest stages within each parva
-- ============================================
CREATE TABLE IF NOT EXISTS quest_stages (
  id TEXT PRIMARY KEY,
  parva_id INTEGER NOT NULL REFERENCES parvas(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'locked' CHECK (status IN ('completed', 'current', 'locked')),
  order_index INTEGER NOT NULL,
  image_url TEXT,
  content TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default stages for Vana Parva
INSERT INTO quest_stages (id, parva_id, title, description, status, order_index) VALUES
('vana_1', 3, 'KAMYAKA FOREST', 'The Pandavas enter the forest of Kamyaka.', 'completed', 1),
('vana_2', 3, 'DWAITA LAKE', 'The sacred lake where the Pandavas spent time in reflection.', 'completed', 2),
('vana_3', 3, 'INDRA''S HEAVEN', 'Arjuna''s quest for celestial weapons. Witness his divine test.', 'current', 3),
('vana_4', 3, 'YAKSHA PRASHNA', 'The Yaksha''s questions test Yudhishthira''s wisdom.', 'locked', 4)
ON CONFLICT (id) DO NOTHING;

-- Insert stages for Adi Parva
INSERT INTO quest_stages (id, parva_id, title, description, status, order_index) VALUES
('adi_1', 1, 'BIRTH OF HEROES', 'The birth of the Pandavas and Kauravas.', 'completed', 1),
('adi_2', 1, 'CHILDHOOD', 'Growing up in Hastinapur.', 'completed', 2),
('adi_3', 1, 'HOUSE OF LAC', 'Escape from the burning house.', 'current', 3),
('adi_4', 1, 'DRAUPADI''S SWAYAMVARA', 'Arjuna wins Draupadi.', 'locked', 4)
ON CONFLICT (id) DO NOTHING;

-- Insert stages for Sabha Parva
INSERT INTO quest_stages (id, parva_id, title, description, status, order_index) VALUES
('sabha_1', 2, 'THE ASSEMBLY HALL', 'The great hall built by the Pandavas.', 'completed', 1),
('sabha_2', 2, 'THE DICE GAME', 'Yudhishthira loses everything.', 'current', 2),
('sabha_3', 2, 'DRAUPADI''S CRY', 'The attempt to disrobe Draupadi.', 'locked', 3)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TABLE 3: user_parva_progress
-- Tracks user progress for each parva
-- ============================================
CREATE TABLE IF NOT EXISTS user_parva_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  parva_id INTEGER NOT NULL REFERENCES parvas(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'locked' CHECK (status IN ('completed', 'active', 'locked')),
  completed_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, parva_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_parva_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own progress
CREATE POLICY "Users can view own parva progress"
  ON user_parva_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own parva progress"
  ON user_parva_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own parva progress"
  ON user_parva_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- TABLE 4: user_progress
-- Tracks user progress for quest stages
-- ============================================
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  stage_id TEXT NOT NULL REFERENCES quest_stages(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'locked' CHECK (status IN ('completed', 'current', 'locked')),
  completed_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  coins_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, stage_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own progress
CREATE POLICY "Users can view own stage progress"
  ON user_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stage progress"
  ON user_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stage progress"
  ON user_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- INDEXES for better query performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_quest_stages_parva_id ON quest_stages(parva_id);
CREATE INDEX IF NOT EXISTS idx_user_parva_progress_user_id ON user_parva_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_parva_progress_parva_id ON user_parva_progress(parva_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_stage_id ON user_progress(stage_id);

-- ============================================
-- FUNCTIONS for updating timestamps
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers to auto-update updated_at
CREATE TRIGGER update_parvas_updated_at BEFORE UPDATE ON parvas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quest_stages_updated_at BEFORE UPDATE ON quest_stages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_parva_progress_updated_at BEFORE UPDATE ON user_parva_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
