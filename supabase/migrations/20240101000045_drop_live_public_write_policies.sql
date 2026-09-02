-- AM-4 follow-up: drop the policies that actually exist on production
-- (qyikatemonzykqamtvod as of 2026-09-01). Migration 042 drops different names
-- ("Allow anon insert verses") that are NOT present live, so pushing 042 would
-- not close the hole.
--
-- Live (proven by scripts/verify_rls_lockdown.sh):
--   verses: "Allow public all on verses" FOR ALL USING (true) WITH CHECK (true)
--     → anon INSERT returned HTTP 201
--   verse_translations: "Allow public all on verse_translations" FOR ALL true
--   story_pages: "Allow public all on story_pages" FOR ALL true
--   prayers: authenticated insert/update still present
--   parvas: already SELECT-only (probe got RLS 42501)
--
-- Apply this file in the Supabase SQL editor. Do NOT `supabase db push` the
-- whole local 20240101* history onto this project (disjoint remote 202602* log).

DROP POLICY IF EXISTS "Allow public all on verses" ON public.verses;
DROP POLICY IF EXISTS "Allow public all on verse_translations" ON public.verse_translations;
DROP POLICY IF EXISTS "Allow public all on story_pages" ON public.story_pages;

DROP POLICY IF EXISTS "Authenticated users can insert prayers" ON public.prayers;
DROP POLICY IF EXISTS "Authenticated users can update prayers" ON public.prayers;
