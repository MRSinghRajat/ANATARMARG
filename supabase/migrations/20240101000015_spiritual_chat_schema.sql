-- =====================================================
-- SPIRITUAL CHAT SCHEMA
-- Tables for AI spiritual chatbot conversations and user profiles
-- =====================================================

-- 1. Spiritual Chat Conversations
-- Stores metadata about each conversation with a spiritual service
CREATE TABLE IF NOT EXISTS spiritual_chat_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  service TEXT NOT NULL CHECK (service IN (
    'numerology', 'kundli', 'palmistry', 'tarot', 'vastu',
    'gemstone', 'muhurat', 'dreamAnalysis', 'mantra', 'kundliMatching'
  )),
  title TEXT, -- Optional title for the conversation
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Spiritual Chat Messages
-- Stores individual messages in each conversation
CREATE TABLE IF NOT EXISTS spiritual_chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES spiritual_chat_conversations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  is_reading BOOLEAN DEFAULT false, -- True if this is a formatted reading response
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Spiritual User Profiles
-- Stores user profile data for each service (name, DOB, birth details, etc.)
CREATE TABLE IF NOT EXISTS spiritual_user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service TEXT NOT NULL CHECK (service IN (
    'numerology', 'kundli', 'palmistry', 'tarot', 'vastu',
    'gemstone', 'muhurat', 'dreamAnalysis', 'mantra', 'kundliMatching'
  )),
  payload JSONB NOT NULL DEFAULT '{}', -- Service-specific data (name, dob, birth_time, etc.)
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, service) -- One profile per user per service
);

-- 4. Spiritual Readings Archive (Optional)
-- Stores completed readings for history/reference
CREATE TABLE IF NOT EXISTS spiritual_readings_archive (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES spiritual_chat_conversations(id) ON DELETE SET NULL,
  service TEXT NOT NULL,
  summary TEXT, -- Brief summary of the reading
  full_reading TEXT, -- Full reading content
  user_profile JSONB, -- Snapshot of user profile at time of reading
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. User Consultation Usage (for premium limits)
-- Tracks monthly consultation count for free tier limits
CREATE TABLE IF NOT EXISTS user_consultation_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  year_month TEXT NOT NULL, -- Format: 'YYYY-MM' for easy monthly reset
  consultation_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, year_month)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_spiritual_chat_conversations_user_id ON spiritual_chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_spiritual_chat_conversations_service ON spiritual_chat_conversations(service);
CREATE INDEX IF NOT EXISTS idx_spiritual_chat_messages_conversation_id ON spiritual_chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_spiritual_user_profiles_user_id ON spiritual_user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_spiritual_readings_archive_user_id ON spiritual_readings_archive(user_id);
CREATE INDEX IF NOT EXISTS idx_user_consultation_usage_user_month ON user_consultation_usage(user_id, year_month);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE spiritual_chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE spiritual_chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE spiritual_user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE spiritual_readings_archive ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_consultation_usage ENABLE ROW LEVEL SECURITY;

-- Conversations: Users can only access their own conversations
CREATE POLICY "Users can view own conversations"
  ON spiritual_chat_conversations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations"
  ON spiritual_chat_conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations"
  ON spiritual_chat_conversations FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations"
  ON spiritual_chat_conversations FOR DELETE
  USING (auth.uid() = user_id);

-- Messages: Users can only access messages from their conversations
CREATE POLICY "Users can view messages from own conversations"
  ON spiritual_chat_messages FOR SELECT
  USING (
    conversation_id IN (
      SELECT id FROM spiritual_chat_conversations WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert messages to own conversations"
  ON spiritual_chat_messages FOR INSERT
  WITH CHECK (
    conversation_id IN (
      SELECT id FROM spiritual_chat_conversations WHERE user_id = auth.uid()
    )
  );

-- User Profiles: Users can only access their own profiles
CREATE POLICY "Users can view own profiles"
  ON spiritual_user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profiles"
  ON spiritual_user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profiles"
  ON spiritual_user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Readings Archive: Users can only access their own readings
CREATE POLICY "Users can view own readings"
  ON spiritual_readings_archive FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own readings"
  ON spiritual_readings_archive FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Consultation Usage: Users can only access their own usage
CREATE POLICY "Users can view own usage"
  ON user_consultation_usage FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own usage"
  ON user_consultation_usage FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own usage"
  ON user_consultation_usage FOR UPDATE
  USING (auth.uid() = user_id);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_spiritual_chat_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_spiritual_chat_conversations_updated_at
  BEFORE UPDATE ON spiritual_chat_conversations
  FOR EACH ROW EXECUTE FUNCTION update_spiritual_chat_updated_at();

CREATE TRIGGER update_spiritual_user_profiles_updated_at
  BEFORE UPDATE ON spiritual_user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_spiritual_chat_updated_at();

CREATE TRIGGER update_user_consultation_usage_updated_at
  BEFORE UPDATE ON user_consultation_usage
  FOR EACH ROW EXECUTE FUNCTION update_spiritual_chat_updated_at();

-- Function to increment consultation count (upsert)
CREATE OR REPLACE FUNCTION increment_consultation_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  current_month TEXT;
  new_count INTEGER;
BEGIN
  current_month := to_char(now(), 'YYYY-MM');
  
  INSERT INTO user_consultation_usage (user_id, year_month, consultation_count)
  VALUES (p_user_id, current_month, 1)
  ON CONFLICT (user_id, year_month)
  DO UPDATE SET 
    consultation_count = user_consultation_usage.consultation_count + 1,
    updated_at = now()
  RETURNING consultation_count INTO new_count;
  
  RETURN new_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get current month's consultation count
CREATE OR REPLACE FUNCTION get_consultation_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  current_month TEXT;
  current_count INTEGER;
BEGIN
  current_month := to_char(now(), 'YYYY-MM');
  
  SELECT consultation_count INTO current_count
  FROM user_consultation_usage
  WHERE user_id = p_user_id AND year_month = current_month;
  
  RETURN COALESCE(current_count, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
