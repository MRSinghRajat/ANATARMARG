-- AM-2: sacred_stories + sacred_texts must exist before 00019 (story_pages FK).
-- DDL matched live pg_catalog on qyikatemonzykqamtvod (2026-09-01).
-- Public SELECT only — no seed INSERT policies.

ALTER TABLE public.books ADD COLUMN IF NOT EXISTS is_premium boolean NOT NULL DEFAULT false;
CREATE INDEX IF NOT EXISTS idx_books_is_premium ON public.books (is_premium);

CREATE TABLE IF NOT EXISTS public.sacred_stories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  title_hindi text,
  deity_slug text REFERENCES public.deities(slug),
  source text,
  category text DEFAULT 'mythology',
  pages jsonb NOT NULL DEFAULT '[]'::jsonb,
  cover_image_url text,
  key_teaching text,
  reflection_prompt text,
  estimated_minutes integer DEFAULT 3,
  is_featured boolean DEFAULT false,
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  cover_video_url text,
  video_url text,
  trailer_url text,
  total_pages integer DEFAULT 0,
  tags text[] DEFAULT '{}'::text[],
  source_book text,
  source_chapter text,
  moral text,
  characters text[] DEFAULT '{}'::text[],
  reading_level text DEFAULT 'all',
  is_premium boolean NOT NULL DEFAULT false,
  audio_url text,
  audio_url_en text,
  CONSTRAINT sacred_stories_category_check CHECK (
    category = ANY (ARRAY['mythology','moral','saint','miracle','folk','leela','epic'])
  ),
  CONSTRAINT sacred_stories_reading_level_check CHECK (
    reading_level = ANY (ARRAY['children','beginner','intermediate','advanced','all'])
  )
);
CREATE INDEX IF NOT EXISTS idx_sacred_stories_category ON public.sacred_stories (category);
CREATE INDEX IF NOT EXISTS idx_sacred_stories_characters ON public.sacred_stories USING gin (characters);
CREATE INDEX IF NOT EXISTS idx_sacred_stories_deity ON public.sacred_stories (deity_slug);
CREATE INDEX IF NOT EXISTS idx_sacred_stories_is_premium ON public.sacred_stories (is_premium);
CREATE INDEX IF NOT EXISTS idx_sacred_stories_tags ON public.sacred_stories USING gin (tags);

CREATE TABLE IF NOT EXISTS public.sacred_texts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  title_hindi text,
  type text NOT NULL DEFAULT 'stotra',
  deity_slug text REFERENCES public.deities(slug),
  text_hindi text,
  text_english text,
  transliteration text,
  audio_url text,
  duration_seconds integer,
  benefits text,
  when_to_recite text,
  verse_count integer,
  category text DEFAULT 'daily_prayer',
  difficulty text DEFAULT 'beginner',
  is_featured boolean DEFAULT false,
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  cover_image_url text,
  audio_url_en text,
  CONSTRAINT sacred_texts_category_check CHECK (
    category = ANY (ARRAY['daily_prayer','festival','deity_specific','protection','wealth','wisdom'])
  ),
  CONSTRAINT sacred_texts_difficulty_check CHECK (
    difficulty = ANY (ARRAY['beginner','intermediate','advanced'])
  ),
  CONSTRAINT sacred_texts_type_check CHECK (
    type = ANY (ARRAY['chalisa','stotra','mantra','aarti','stuti','suktam','kavach','sahasranama'])
  )
);
CREATE INDEX IF NOT EXISTS idx_sacred_texts_deity ON public.sacred_texts (deity_slug);
CREATE INDEX IF NOT EXISTS idx_sacred_texts_type ON public.sacred_texts (type);

ALTER TABLE public.sacred_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sacred_texts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active sacred stories" ON public.sacred_stories;
CREATE POLICY "Anyone can view active sacred stories"
  ON public.sacred_stories FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Anyone can view active sacred texts" ON public.sacred_texts;
CREATE POLICY "Anyone can view active sacred texts"
  ON public.sacred_texts FOR SELECT USING (is_active = true);
