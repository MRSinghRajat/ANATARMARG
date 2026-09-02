-- Align live app writes with production tables (applied via SQL editor, not db push).
-- sanctuary_customization: Mandir ground/light/deity live in mandir_data jsonb.
-- books: Listen tab filters on audio_url; chapter-level audio stays on chapters.

ALTER TABLE public.sanctuary_customization
  ADD COLUMN IF NOT EXISTS mandir_data jsonb;

ALTER TABLE public.books
  ADD COLUMN IF NOT EXISTS audio_url text;

ALTER TABLE public.books
  ADD COLUMN IF NOT EXISTS audio_url_en text;
