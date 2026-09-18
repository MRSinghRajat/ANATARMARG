-- L07b: activate only after L07a, verified subscriber backfill, content/media
-- preflight, and role-based staging tests. Do not db push the divergent history.
-- No rows are deleted or made free by this migration. Existing premium inline
-- catalog bodies cause constraint validation to FAIL: migrate them into protected
-- children before retrying. See docs/L07_CONTENT_ACCESS_VERIFICATION.md.
--
-- Restrictive guards are deliberate. Historical/live permissive policy names
-- differ; PostgreSQL ORs permissive policies, so dropping one known name cannot
-- establish protection. The client-role guards below AND with every permissive
-- read policy. Existing service-role editorial access is unaffected.

-- These flags exist in production but were absent from the tracked base schema.
ALTER TABLE public.journey_tasks ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;
ALTER TABLE public.journey_content_pool ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;

-- Keep catalog discovery public, but make inline premium bodies impossible.
-- Full media belongs on gated children; cover images/trailers are public previews.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'public.sacred_stories'::regclass AND conname = 'premium_story_body_not_in_catalog') THEN
    ALTER TABLE public.sacred_stories ADD CONSTRAINT premium_story_body_not_in_catalog
      CHECK (is_premium IS FALSE OR (
        pages = '[]'::jsonb AND audio_url IS NULL AND audio_url_en IS NULL AND video_url IS NULL
      )) NOT VALID;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'public.books'::regclass AND conname = 'premium_book_audio_not_in_catalog') THEN
    ALTER TABLE public.books ADD CONSTRAINT premium_book_audio_not_in_catalog
      CHECK (is_premium IS FALSE OR (audio_url IS NULL AND audio_url_en IS NULL)) NOT VALID;
  END IF;
END $$;
ALTER TABLE public.sacred_stories VALIDATE CONSTRAINT premium_story_body_not_in_catalog;
ALTER TABLE public.books VALIDATE CONSTRAINT premium_book_audio_not_in_catalog;

ALTER VIEW public.v_journey_tasks_full SET (security_invoker = true);
DO $$
BEGIN
  IF to_regclass('public.v_journey_content_resolved') IS NOT NULL THEN
    ALTER VIEW public.v_journey_content_resolved SET (security_invoker = true);
  END IF;
END $$;

-- Explicit eligible-parent existence is required, including for Pro users.
-- RLS-hidden, inactive, missing and null parents cannot become implicitly free.
-- Books/phases do not have is_active in the tracked base schema. When that field
-- exists in a target schema it must be explicitly true (null fails closed).
ALTER TABLE public.journey_tasks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS l07_body_read ON public.journey_tasks;
CREATE POLICY l07_body_read ON public.journey_tasks FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS l07_content_guard ON public.journey_tasks;
CREATE POLICY l07_content_guard ON public.journey_tasks AS RESTRICTIVE FOR SELECT TO anon, authenticated
USING (
  is_active IS TRUE AND EXISTS (
    SELECT 1 FROM public.journey_phases p
    JOIN public.journey_types jt ON jt.id = p.journey_type_id
    WHERE p.id = journey_tasks.phase_id AND jt.is_active IS TRUE
      AND (NOT (to_jsonb(p) ? 'is_active') OR to_jsonb(p)->'is_active' = 'true'::jsonb)
      AND ((journey_tasks.is_premium IS FALSE AND jt.is_premium IS FALSE)
        OR public.has_active_entitlement(auth.uid()))
  )
);

ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS l07_body_read ON public.chapters;
CREATE POLICY l07_body_read ON public.chapters FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS l07_content_guard ON public.chapters;
CREATE POLICY l07_content_guard ON public.chapters AS RESTRICTIVE FOR SELECT TO anon, authenticated
USING (
  (NOT (to_jsonb(chapters) ? 'is_active') OR to_jsonb(chapters)->'is_active' = 'true'::jsonb)
  AND EXISTS (
    SELECT 1 FROM public.books b WHERE b.id = chapters.book_id
      AND (NOT (to_jsonb(b) ? 'is_active') OR to_jsonb(b)->'is_active' = 'true'::jsonb)
      AND (b.is_premium IS FALSE OR public.has_active_entitlement(auth.uid()))
  )
);

ALTER TABLE public.verses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS l07_body_read ON public.verses;
CREATE POLICY l07_body_read ON public.verses FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS l07_content_guard ON public.verses;
CREATE POLICY l07_content_guard ON public.verses AS RESTRICTIVE FOR SELECT TO anon, authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.chapters c JOIN public.books b ON b.id = c.book_id
    WHERE c.id = verses.chapter_id AND b.id = verses.book_id
      AND (NOT (to_jsonb(b) ? 'is_active') OR to_jsonb(b)->'is_active' = 'true'::jsonb)
      AND (b.is_premium IS FALSE OR public.has_active_entitlement(auth.uid()))
  )
);

ALTER TABLE public.verse_translations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS l07_body_read ON public.verse_translations;
CREATE POLICY l07_body_read ON public.verse_translations FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS l07_content_guard ON public.verse_translations;
CREATE POLICY l07_content_guard ON public.verse_translations AS RESTRICTIVE FOR SELECT TO anon, authenticated
USING (EXISTS (SELECT 1 FROM public.verses v WHERE v.id = verse_translations.verse_id));

ALTER TABLE public.story_pages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS l07_body_read ON public.story_pages;
CREATE POLICY l07_body_read ON public.story_pages FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS l07_content_guard ON public.story_pages;
CREATE POLICY l07_content_guard ON public.story_pages AS RESTRICTIVE FOR SELECT TO anon, authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.sacred_stories s WHERE s.id = story_pages.story_id
      AND s.is_active IS TRUE
      AND (s.is_premium IS FALSE OR public.has_active_entitlement(auth.uid()))
  )
);

ALTER TABLE public.garbh_sanskar_content ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS l07_body_read ON public.garbh_sanskar_content;
CREATE POLICY l07_body_read ON public.garbh_sanskar_content FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS l07_content_guard ON public.garbh_sanskar_content;
CREATE POLICY l07_content_guard ON public.garbh_sanskar_content AS RESTRICTIVE FOR SELECT TO anon, authenticated
USING (is_active IS TRUE AND (is_premium IS FALSE OR public.has_active_entitlement(auth.uid())));

ALTER TABLE public.journey_content_pool ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS l07_body_read ON public.journey_content_pool;
CREATE POLICY l07_body_read ON public.journey_content_pool FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS l07_content_guard ON public.journey_content_pool;
CREATE POLICY l07_content_guard ON public.journey_content_pool AS RESTRICTIVE FOR SELECT TO anon, authenticated
USING (
  is_active IS TRUE AND EXISTS (
    SELECT 1 FROM public.journey_types jt
    WHERE jt.id = journey_content_pool.journey_type_id AND jt.is_active IS TRUE
      AND (jt.is_premium IS FALSE OR public.has_active_entitlement(auth.uid()))
      -- A pool body tied to a premium task must not bypass task RLS. Require
      -- at least one visible matching task within the same journey. Shared or
      -- orphan pool rows need explicit task/parent ownership before publication.
      AND EXISTS (
        SELECT 1 FROM public.journey_tasks t
        JOIN public.journey_phases p ON p.id = t.phase_id
        WHERE p.journey_type_id = jt.id AND t.slug = journey_content_pool.task_slug
      )
  )
);

-- Shared content is editorial data. An old seed UPDATE/INSERT policy must not
-- let a client mark paid parents free, inject bodies into the public catalog, or
-- reassign children. Restrictive write guards also cover column-level grants;
-- privileged service-role publication continues to bypass RLS as before.
DO $$
DECLARE relation_name text;
BEGIN
  FOREACH relation_name IN ARRAY ARRAY[
    'books','chapters','verses','verse_translations','sacred_stories','story_pages',
    'journey_types','journey_phases','journey_tasks','journey_content_pool','garbh_sanskar_content'
  ] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', relation_name);
    EXECUTE format('DROP POLICY IF EXISTS l07_no_client_insert ON public.%I', relation_name);
    EXECUTE format('CREATE POLICY l07_no_client_insert ON public.%I AS RESTRICTIVE FOR INSERT TO anon, authenticated WITH CHECK (false)', relation_name);
    EXECUTE format('DROP POLICY IF EXISTS l07_no_client_update ON public.%I', relation_name);
    EXECUTE format('CREATE POLICY l07_no_client_update ON public.%I AS RESTRICTIVE FOR UPDATE TO anon, authenticated USING (false) WITH CHECK (false)', relation_name);
    EXECUTE format('DROP POLICY IF EXISTS l07_no_client_delete ON public.%I', relation_name);
    EXECUTE format('CREATE POLICY l07_no_client_delete ON public.%I AS RESTRICTIVE FOR DELETE TO anon, authenticated USING (false)', relation_name);
    -- RLS does not protect TRUNCATE; remove that and other editorial privileges.
    EXECUTE format('REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON public.%I FROM PUBLIC, anon, authenticated', relation_name);
  END LOOP;
END $$;
