-- Supabase Deities Schema
-- Reference table for Hindu deities shown in Explore Deities section
-- Run in Supabase SQL Editor

-- Enable UUID extension (if not already)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: deities
-- Stores deities for the Explore Deities section in Granthalaya
-- ============================================
CREATE TABLE IF NOT EXISTS deities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  name_sanskrit TEXT,
  image_url TEXT,
  description TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for display order and filtering
CREATE INDEX IF NOT EXISTS idx_deities_order ON deities(order_index);
CREATE INDEX IF NOT EXISTS idx_deities_active ON deities(is_active) WHERE is_active = true;

-- RLS: Public read access (reference data), restrict write to authenticated
ALTER TABLE deities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active deities" ON deities;
CREATE POLICY "Anyone can view active deities"
  ON deities FOR SELECT
  USING (is_active = true);

-- Insert default deities (from Explore Deities UI)
INSERT INTO deities (slug, name, image_url, order_index) VALUES
  ('shiva', 'Shiva', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv', 1),
  ('vishnu', 'Vishnu', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv', 2),
  ('devi', 'Devi', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCd_4JNasICaIaHij84HkpIMICry2qj9vQbv4E418yGFsZvKbS4Wk5J2i4pPOqk6gM2mWCKAS7JczuUgHfnRi0fUli5hU8gZovvHqoWo1GI22rS613kTYAxJVowoCXRgFDR7-97bUilllW6Z6rM_MEB4Hk9fe8yAcF-871rkAWzHsFNmpVDH0R7w0OW0g-tlL9Ncib0jHHxIuN-3O-lrpEiRaVouZoSikGTJQqEE0fD1rbpaJNRwDvfadeu6GWnWi2-30rmN0BAjiQr', 3),
  ('ganesha', 'Ganesha', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDT51ZKt0o37zUWn7OBW7NHAv_eqYJDBi4yZSbeFZsG98EbbMrXTd47UBFo-C-q6a_D5Wg7QkmTldlWo2U-Y6HXTvI8ZMGCeKCqeeY_SH_QML9bOxOaQmW3MahYkvWdvzedC3MC4eh1a__pyn4fjae8N3Nv0t3kjNR4AXPY0PcHYhJw7RD9oPYAhii6KgHEnis4nYoIPGi8mnmpm2BwyGDZVYSjZGHeofoTpepPJCe6VnrqAtyO98VkNkBPEHHvZZP7xXJcLm8pe54P', 4)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  image_url = EXCLUDED.image_url,
  order_index = EXCLUDED.order_index,
  updated_at = NOW();
