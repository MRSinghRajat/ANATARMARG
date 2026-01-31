-- Supabase Avatar (Inner Self) Schema
-- Vision-aligned: Avatar grows through daily actions; no punishment
-- Run after SUPABASE_BOOKS_SCHEMA.sql if using same project

-- Enable UUID extension (if not already)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: avatars
-- Inner Self representation - grows through consistency
-- ============================================
CREATE TABLE IF NOT EXISTS avatars (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ashram TEXT NOT NULL DEFAULT 'brahmacharya',
  wisdom_level INTEGER NOT NULL DEFAULT 1,
  karma_balance INTEGER NOT NULL DEFAULT 0,
  streak_days INTEGER NOT NULL DEFAULT 0,
  last_activity_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Index for user lookup
CREATE INDEX IF NOT EXISTS idx_avatars_user_id ON avatars(user_id);

-- RLS: Users can only read/update their own avatar (DROP first for idempotency)
ALTER TABLE avatars ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own avatar" ON avatars;
CREATE POLICY "Users can view own avatar"
  ON avatars FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own avatar" ON avatars;
CREATE POLICY "Users can insert own avatar"
  ON avatars FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own avatar" ON avatars;
CREATE POLICY "Users can update own avatar"
  ON avatars FOR UPDATE
  USING (auth.uid() = user_id);
