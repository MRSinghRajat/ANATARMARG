-- Supabase Database Schema for Books, Chapters, and Verses
-- Bhagavad Gita Database Architecture
-- Run these SQL commands in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE 1: books
-- High-level book information
-- ============================================
CREATE TABLE IF NOT EXISTS books (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  name_sanskrit TEXT,
  description TEXT NOT NULL,
  total_chapters INTEGER NOT NULL,
  cover_image_url TEXT,
  category TEXT NOT NULL DEFAULT 'scripture',
  language TEXT NOT NULL DEFAULT 'en',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Bhagavad Gita
INSERT INTO books (id, name, name_sanskrit, description, total_chapters, category) VALUES
('bhagavad_gita', 'Bhagavad Gita', 'भगवद्गीता', 'The song of God, teachings on dharma, karma, and the path to liberation.', 18, 'scripture')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TABLE 2: chapters
-- Chapters within books
-- ============================================
CREATE TABLE IF NOT EXISTS chapters (
  id TEXT PRIMARY KEY,
  book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  chapter_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  title_sanskrit TEXT,
  subtitle TEXT,
  summary TEXT,
  key_themes TEXT[],
  key_characters TEXT[],
  estimated_reading_minutes INTEGER DEFAULT 2,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(book_id, chapter_number)
);

-- Insert Bhagavad Gita chapters (18 chapters)
INSERT INTO chapters (id, book_id, chapter_number, title, title_sanskrit, subtitle, order_index, estimated_reading_minutes) VALUES
('bg_chapter_1', 'bhagavad_gita', 1, 'Arjuna Vishada Yoga', 'अर्जुनविषादयोग', 'The Yoga of Arjuna''s Dejection', 1, 2),
('bg_chapter_2', 'bhagavad_gita', 2, 'Sankhya Yoga', 'साङ्ख्ययोग', 'The Yoga of Knowledge', 2, 2),
('bg_chapter_3', 'bhagavad_gita', 3, 'Karma Yoga', 'कर्मयोग', 'The Yoga of Action', 3, 2),
('bg_chapter_4', 'bhagavad_gita', 4, 'Jnana Karma Sanyasa Yoga', 'ज्ञानकर्मसन्यासयोग', 'The Yoga of Knowledge and Renunciation of Action', 4, 2),
('bg_chapter_5', 'bhagavad_gita', 5, 'Karma Sanyasa Yoga', 'कर्मसन्यासयोग', 'The Yoga of Renunciation of Action', 5, 2),
('bg_chapter_6', 'bhagavad_gita', 6, 'Dhyana Yoga', 'ध्यानयोग', 'The Yoga of Meditation', 6, 2),
('bg_chapter_7', 'bhagavad_gita', 7, 'Jnana Vijnana Yoga', 'ज्ञानविज्ञानयोग', 'The Yoga of Knowledge and Wisdom', 7, 2),
('bg_chapter_8', 'bhagavad_gita', 8, 'Aksara Brahma Yoga', 'अक्षरब्रह्मयोग', 'The Yoga of the Imperishable Brahman', 8, 2),
('bg_chapter_9', 'bhagavad_gita', 9, 'Raja Vidya Raja Guhya Yoga', 'राजविद्याराजगुह्ययोग', 'The Yoga of Royal Knowledge and Royal Secret', 9, 2),
('bg_chapter_10', 'bhagavad_gita', 10, 'Vibhuti Yoga', 'विभूतियोग', 'The Yoga of Divine Glories', 10, 2),
('bg_chapter_11', 'bhagavad_gita', 11, 'Vishvarupa Darshana Yoga', 'विश्वरूपदर्शनयोग', 'The Yoga of the Vision of the Universal Form', 11, 2),
('bg_chapter_12', 'bhagavad_gita', 12, 'Bhakti Yoga', 'भक्तियोग', 'The Yoga of Devotion', 12, 2),
('bg_chapter_13', 'bhagavad_gita', 13, 'Ksetra Ksetrajna Vibhaga Yoga', 'क्षेत्रक्षेत्रज्ञविभागयोग', 'The Yoga of the Field and the Knower of the Field', 13, 2),
('bg_chapter_14', 'bhagavad_gita', 14, 'Gunatraya Vibhaga Yoga', 'गुणत्रयविभागयोग', 'The Yoga of the Three Gunas', 14, 2),
('bg_chapter_15', 'bhagavad_gita', 15, 'Purusottama Yoga', 'पुरुषोत्तमयोग', 'The Yoga of the Supreme Person', 15, 2),
('bg_chapter_16', 'bhagavad_gita', 16, 'Daivasura Sampad Vibhaga Yoga', 'दैवासुरसम्पद्विभागयोग', 'The Yoga of the Division between the Divine and Demoniacal', 16, 2),
('bg_chapter_17', 'bhagavad_gita', 17, 'Shraddhatraya Vibhaga Yoga', 'श्रद्धात्रयविभागयोग', 'The Yoga of the Threefold Faith', 17, 2),
('bg_chapter_18', 'bhagavad_gita', 18, 'Moksha Sanyasa Yoga', 'मोक्षसन्यासयोग', 'The Yoga of Liberation and Renunciation', 18, 2)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TABLE 3: verses
-- Individual verses (one row per verse)
-- ============================================
CREATE TABLE IF NOT EXISTS verses (
  id TEXT PRIMARY KEY,
  book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  chapter_id TEXT NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  verse_number INTEGER NOT NULL,
  verse_number_display TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(chapter_id, verse_number)
);

-- Sample verses for Chapter 1 (Arjuna Vishada Yoga) - First 10 verses
INSERT INTO verses (id, book_id, chapter_id, verse_number, verse_number_display, order_index) VALUES
('bg_1_1', 'bhagavad_gita', 'bg_chapter_1', 1, '1.1', 1),
('bg_1_2', 'bhagavad_gita', 'bg_chapter_1', 2, '1.2', 2),
('bg_1_3', 'bhagavad_gita', 'bg_chapter_1', 3, '1.3', 3),
('bg_1_4', 'bhagavad_gita', 'bg_chapter_1', 4, '1.4', 4),
('bg_1_5', 'bhagavad_gita', 'bg_chapter_1', 5, '1.5', 5),
('bg_1_6', 'bhagavad_gita', 'bg_chapter_1', 6, '1.6', 6),
('bg_1_7', 'bhagavad_gita', 'bg_chapter_1', 7, '1.7', 7),
('bg_1_8', 'bhagavad_gita', 'bg_chapter_1', 8, '1.8', 8),
('bg_1_9', 'bhagavad_gita', 'bg_chapter_1', 9, '1.9', 9),
('bg_1_10', 'bhagavad_gita', 'bg_chapter_1', 10, '1.10', 10)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TABLE 4: verse_translations
-- Multi-language verse content
-- ============================================
CREATE TABLE IF NOT EXISTS verse_translations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  verse_id TEXT NOT NULL REFERENCES verses(id) ON DELETE CASCADE,
  language_code TEXT NOT NULL,
  language_name TEXT NOT NULL,
  text TEXT NOT NULL,
  transliteration TEXT,
  translation_source TEXT,
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(verse_id, language_code)
);

-- Sample translations for verse 1.1 (Sanskrit and English)
INSERT INTO verse_translations (verse_id, language_code, language_name, text, transliteration, is_primary, translation_source) VALUES
('bg_1_1', 'sa', 'Sanskrit', 'धृतराष्ट्र उवाच | धर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः | मामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय ||', 'dhṛtarāṣṭra uvāca | dharmakṣetre kurukṣetre samavetā yuyutsavaḥ | māmakāḥ pāṇḍavāścaiva kimakurvata sañjaya ||', TRUE, 'Original'),
('bg_1_1', 'en', 'English', 'Dhritarashtra said: O Sanjaya, what did my sons and the sons of Pandu do when they had assembled together, eager for battle, on the holy field of Kurukshetra?', NULL, FALSE, 'Swami Sivananda')
ON CONFLICT (verse_id, language_code) DO NOTHING;

-- ============================================
-- TABLE 5: user_book_progress
-- User progress tracking for books
-- ============================================
CREATE TABLE IF NOT EXISTS user_book_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  completed_chapters INTEGER DEFAULT 0,
  last_read_chapter_id TEXT REFERENCES chapters(id) ON DELETE SET NULL,
  last_read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, book_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_book_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own progress (DROP first for idempotency)
DROP POLICY IF EXISTS "Users can view own book progress" ON user_book_progress;
CREATE POLICY "Users can view own book progress"
  ON user_book_progress FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own book progress" ON user_book_progress;
CREATE POLICY "Users can insert own book progress"
  ON user_book_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own book progress" ON user_book_progress;
CREATE POLICY "Users can update own book progress"
  ON user_book_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- TABLE 6: user_chapter_progress
-- User progress tracking for chapters
-- ============================================
CREATE TABLE IF NOT EXISTS user_chapter_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  chapter_id TEXT NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
  completed_verses INTEGER DEFAULT 0,
  last_read_verse_id TEXT REFERENCES verses(id) ON DELETE SET NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, chapter_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_chapter_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own progress (DROP first for idempotency)
DROP POLICY IF EXISTS "Users can view own chapter progress" ON user_chapter_progress;
CREATE POLICY "Users can view own chapter progress"
  ON user_chapter_progress FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own chapter progress" ON user_chapter_progress;
CREATE POLICY "Users can insert own chapter progress"
  ON user_chapter_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own chapter progress" ON user_chapter_progress;
CREATE POLICY "Users can update own chapter progress"
  ON user_chapter_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- TABLE 7: user_verse_progress
-- User progress tracking for individual verses
-- ============================================
CREATE TABLE IF NOT EXISTS user_verse_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  verse_id TEXT NOT NULL REFERENCES verses(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT FALSE,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, verse_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_verse_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own progress (DROP first for idempotency)
DROP POLICY IF EXISTS "Users can view own verse progress" ON user_verse_progress;
CREATE POLICY "Users can view own verse progress"
  ON user_verse_progress FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own verse progress" ON user_verse_progress;
CREATE POLICY "Users can insert own verse progress"
  ON user_verse_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own verse progress" ON user_verse_progress;
CREATE POLICY "Users can update own verse progress"
  ON user_verse_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- INDEXES for better query performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_chapters_book_id ON chapters(book_id);
CREATE INDEX IF NOT EXISTS idx_chapters_book_chapter ON chapters(book_id, chapter_number);
CREATE INDEX IF NOT EXISTS idx_verses_book_id ON verses(book_id);
CREATE INDEX IF NOT EXISTS idx_verses_chapter_id ON verses(chapter_id);
CREATE INDEX IF NOT EXISTS idx_verses_book_chapter_verse ON verses(book_id, chapter_id, verse_number);
CREATE INDEX IF NOT EXISTS idx_verse_translations_verse_id ON verse_translations(verse_id);
CREATE INDEX IF NOT EXISTS idx_verse_translations_language ON verse_translations(language_code);
CREATE INDEX IF NOT EXISTS idx_user_book_progress_user_id ON user_book_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_book_progress_book_id ON user_book_progress(book_id);
CREATE INDEX IF NOT EXISTS idx_user_chapter_progress_user_id ON user_chapter_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_chapter_progress_chapter_id ON user_chapter_progress(chapter_id);
CREATE INDEX IF NOT EXISTS idx_user_verse_progress_user_id ON user_verse_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_verse_progress_verse_id ON user_verse_progress(verse_id);

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

-- Triggers to auto-update updated_at (DROP first for idempotency)
DROP TRIGGER IF EXISTS update_books_updated_at ON books;
CREATE TRIGGER update_books_updated_at BEFORE UPDATE ON books
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_chapters_updated_at ON chapters;
CREATE TRIGGER update_chapters_updated_at BEFORE UPDATE ON chapters
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_verses_updated_at ON verses;
CREATE TRIGGER update_verses_updated_at BEFORE UPDATE ON verses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_verse_translations_updated_at ON verse_translations;
CREATE TRIGGER update_verse_translations_updated_at BEFORE UPDATE ON verse_translations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_book_progress_updated_at ON user_book_progress;
CREATE TRIGGER update_user_book_progress_updated_at BEFORE UPDATE ON user_book_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_chapter_progress_updated_at ON user_chapter_progress;
CREATE TRIGGER update_user_chapter_progress_updated_at BEFORE UPDATE ON user_chapter_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_verse_progress_updated_at ON user_verse_progress;
CREATE TRIGGER update_user_verse_progress_updated_at BEFORE UPDATE ON user_verse_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
