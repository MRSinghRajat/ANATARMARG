-- App profile: display name and avatar for Ashram/Profile screens.
-- Synced from auth user_metadata and onboarding; one row per user.

CREATE TABLE IF NOT EXISTS public.app_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_app_profiles_user_id ON public.app_profiles(user_id);

ALTER TABLE public.app_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own app profile"
  ON public.app_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own app profile"
  ON public.app_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own app profile"
  ON public.app_profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_app_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_app_profiles_updated_at ON public.app_profiles;
CREATE TRIGGER update_app_profiles_updated_at
  BEFORE UPDATE ON public.app_profiles
  FOR EACH ROW EXECUTE FUNCTION update_app_profiles_updated_at();

GRANT ALL ON public.app_profiles TO authenticated;
