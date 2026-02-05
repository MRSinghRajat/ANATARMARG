-- Supabase Database Schema for Prayers
-- Daily Prayers and Mantras
-- Run these SQL commands in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: prayers
-- Stores prayer/mantra information
-- ============================================
CREATE TABLE IF NOT EXISTS prayers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  name_sanskrit TEXT,
  description TEXT NOT NULL,
  icon_name TEXT NOT NULL DEFAULT 'menu_book',
  category TEXT NOT NULL DEFAULT 'daily',
  order_index INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Daily Prayers (matching current UI)
INSERT INTO prayers (id, name, name_sanskrit, description, icon_name, category, order_index) VALUES
('hanuman_chalisa', 'Hanuman Chalisa', 'हनुमान चालीसा', '40 Verses of Devotion', 'menu_book', 'daily', 1),
('shiva_stotram', 'Shiva Stotram', 'शिव स्तोत्रम्', 'Praise to Mahadev', 'auto_stories', 'daily', 2),
('gayatri_mantra', 'Gayatri Mantra', 'गायत्री मंत्र', 'Universal Prayer', 'star', 'daily', 3),
('vishnu_sahasra', 'Vishnu Sahasra', 'विष्णु सहस्रनाम', '1000 Names', 'favorite', 'daily', 4)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- INDEXES for better query performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_prayers_category ON prayers(category);
CREATE INDEX IF NOT EXISTS idx_prayers_order ON prayers(order_index);

-- ============================================
-- FUNCTION for updating timestamps
-- ============================================
CREATE OR REPLACE FUNCTION update_prayers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_prayers_updated_at_trigger ON prayers;
CREATE TRIGGER update_prayers_updated_at_trigger 
  BEFORE UPDATE ON prayers
  FOR EACH ROW 
  EXECUTE FUNCTION update_prayers_updated_at();

-- ============================================
-- Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE prayers ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read prayers (public data)
DROP POLICY IF EXISTS "Anyone can view prayers" ON prayers;
CREATE POLICY "Anyone can view prayers"
  ON prayers FOR SELECT
  USING (true);

-- Only authenticated users can insert/update (admin only in production)
DROP POLICY IF EXISTS "Authenticated users can insert prayers" ON prayers;
CREATE POLICY "Authenticated users can insert prayers"
  ON prayers FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated users can update prayers" ON prayers;
CREATE POLICY "Authenticated users can update prayers"
  ON prayers FOR UPDATE
  USING (auth.role() = 'authenticated');
