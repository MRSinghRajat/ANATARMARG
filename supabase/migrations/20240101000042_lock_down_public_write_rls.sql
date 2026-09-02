-- AM-4: Remove permanent public-write seed policies; enable read-only RLS on parvas/quest_stages.
-- Production ANTARMARG used different policy names; 045 dropped those live names.
-- Do not `db push` this 20240101* folder onto that project (disjoint 202602* history).

-- verses / verse_translations: read-only for anon/authenticated
DROP POLICY IF EXISTS "Allow anon insert verses" ON public.verses;
DROP POLICY IF EXISTS "Allow anon update verses" ON public.verses;
DROP POLICY IF EXISTS "Allow anon insert verse_translations" ON public.verse_translations;
DROP POLICY IF EXISTS "Allow anon update verse_translations" ON public.verse_translations;

-- story_pages: read-only
DROP POLICY IF EXISTS "Allow anon insert story_pages" ON public.story_pages;
DROP POLICY IF EXISTS "Allow anon update story_pages" ON public.story_pages;

-- prayers: remove authenticated insert/update (service-role seeding only)
DROP POLICY IF EXISTS "Authenticated users can insert prayers" ON public.prayers;
DROP POLICY IF EXISTS "Authenticated users can update prayers" ON public.prayers;

-- parvas / quest_stages: public SELECT only
ALTER TABLE public.parvas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quest_stages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read parvas" ON public.parvas;
CREATE POLICY "Allow public read parvas"
  ON public.parvas FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Allow public read quest_stages" ON public.quest_stages;
CREATE POLICY "Allow public read quest_stages"
  ON public.quest_stages FOR SELECT
  USING (true);
