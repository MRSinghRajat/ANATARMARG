-- ============================================
-- AANGAN FEATURE SCHEMA
-- ============================================

-- 1. Create table for User Presence (Aangan)
CREATE TABLE IF NOT EXISTS user_presence (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  last_seen_at TIMESTAMP WITH TIME ZONE,
  -- We store the locked intention ID and date here to sync across devices
  daily_intention_id TEXT,
  daily_intention_date DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one row per user
  UNIQUE(user_id)
);

-- 2. Enable RLS
ALTER TABLE user_presence ENABLE ROW LEVEL SECURITY;

-- 3. Policies
CREATE POLICY "Users can view own presence"
  ON user_presence FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own presence"
  ON user_presence FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own presence"
  ON user_presence FOR UPDATE
  USING (auth.uid() = user_id);

-- 4. Triggers
CREATE TRIGGER update_user_presence_updated_at BEFORE UPDATE ON user_presence
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
