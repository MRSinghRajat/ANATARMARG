-- User Verse Notes - Store notes for shlokas (persists across login)
-- Run after SUPABASE_BOOKS_SCHEMA.sql (which creates update_updated_at_column)

-- ============================================
-- TABLE: user_verse_notes
-- ============================================
CREATE TABLE IF NOT EXISTS user_verse_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  verse_id TEXT NOT NULL REFERENCES verses(id) ON DELETE CASCADE,
  verse_text TEXT NOT NULL,
  note TEXT NOT NULL,
  book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  chapter_id TEXT NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  shloka_number INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_verse_notes_user_id ON user_verse_notes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_verse_notes_verse_id ON user_verse_notes(verse_id);
CREATE INDEX IF NOT EXISTS idx_user_verse_notes_chapter_id ON user_verse_notes(chapter_id);
CREATE INDEX IF NOT EXISTS idx_user_verse_notes_book_id ON user_verse_notes(book_id);

-- RLS
ALTER TABLE user_verse_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own notes" ON user_verse_notes;
CREATE POLICY "Users can view own notes"
  ON user_verse_notes FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own notes" ON user_verse_notes;
CREATE POLICY "Users can insert own notes"
  ON user_verse_notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notes" ON user_verse_notes;
CREATE POLICY "Users can update own notes"
  ON user_verse_notes FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own notes" ON user_verse_notes;
CREATE POLICY "Users can delete own notes"
  ON user_verse_notes FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger for updated_at
DROP TRIGGER IF EXISTS update_user_verse_notes_updated_at ON user_verse_notes;
CREATE TRIGGER update_user_verse_notes_updated_at BEFORE UPDATE ON user_verse_notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
