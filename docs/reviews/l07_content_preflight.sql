-- Read-only, aggregate content/media inventory. Run as a trusted database
-- operator before activating L07b. No customer records or full URLs are output.
-- An inventory result is not proof that an HTTP object is inaccessible.
WITH issues AS (
  SELECT 'premium_story_inline_or_full_media' AS issue, count(*) AS rows
  FROM public.sacred_stories
  WHERE is_premium IS NOT FALSE AND (pages <> '[]'::jsonb OR audio_url IS NOT NULL OR audio_url_en IS NOT NULL OR video_url IS NOT NULL)
  UNION ALL
  SELECT 'premium_book_catalog_full_audio', count(*) FROM public.books
  WHERE is_premium IS NOT FALSE AND (audio_url IS NOT NULL OR audio_url_en IS NOT NULL)
  UNION ALL
  SELECT 'pool_missing_parent', count(*) FROM public.journey_content_pool cp
  WHERE NOT EXISTS (SELECT 1 FROM public.journey_types jt WHERE jt.id=cp.journey_type_id)
  UNION ALL
  SELECT 'pool_missing_matching_task', count(*) FROM public.journey_content_pool cp
  WHERE NOT EXISTS (
    SELECT 1 FROM public.journey_tasks t JOIN public.journey_phases p ON p.id=t.phase_id
    WHERE p.journey_type_id=cp.journey_type_id AND t.slug=cp.task_slug
  )
  UNION ALL
  SELECT 'verse_mismatched_or_missing_parents', count(*) FROM public.verses v
  WHERE NOT EXISTS (SELECT 1 FROM public.chapters c JOIN public.books b ON b.id=c.book_id WHERE c.id=v.chapter_id AND b.id=v.book_id)
)
SELECT * FROM issues ORDER BY issue;

WITH bodies AS (
  SELECT 'books' AS source, to_jsonb(b) AS body, b.is_premium IS NOT FALSE AS premium FROM public.books b
  UNION ALL SELECT 'chapters',to_jsonb(c),b.is_premium IS NOT FALSE FROM public.chapters c JOIN public.books b ON b.id=c.book_id
  UNION ALL SELECT 'sacred_stories',to_jsonb(s),s.is_premium IS NOT FALSE FROM public.sacred_stories s
  UNION ALL SELECT 'story_pages',to_jsonb(p),s.is_premium IS NOT FALSE FROM public.story_pages p JOIN public.sacred_stories s ON s.id=p.story_id
  UNION ALL SELECT 'journey_tasks',to_jsonb(t),(t.is_premium IS NOT FALSE OR jt.is_premium IS NOT FALSE) FROM public.journey_tasks t JOIN public.journey_phases p ON p.id=t.phase_id JOIN public.journey_types jt ON jt.id=p.journey_type_id
  UNION ALL SELECT 'journey_content_pool',to_jsonb(cp),jt.is_premium IS NOT FALSE OR EXISTS (
    SELECT 1 FROM public.journey_tasks t JOIN public.journey_phases p ON p.id=t.phase_id
    WHERE p.journey_type_id=jt.id AND t.slug=cp.task_slug AND t.is_premium IS NOT FALSE
  ) FROM public.journey_content_pool cp JOIN public.journey_types jt ON jt.id=cp.journey_type_id
  UNION ALL SELECT 'garbh_sanskar_content',to_jsonb(g),g.is_premium IS NOT FALSE FROM public.garbh_sanskar_content g
), media AS (
  SELECT source,premium,k.key AS field,k.value,
    CASE WHEN k.value LIKE '%/storage/v1/object/public/%' THEN 'supabase_public_object'
         WHEN k.value LIKE '%/storage/v1/object/sign/%' THEN 'persisted_signed_url_review_expiry'
         WHEN k.value ~ '^https?://' THEN 'external_or_other_http'
         ELSE 'storage_path_or_other_reference' END AS access_form
  FROM bodies CROSS JOIN LATERAL jsonb_each_text(body) k
  WHERE (k.key ~ '(_url|_path)$') AND nullif(k.value,'') IS NOT NULL
)
SELECT source,premium,field,access_form,count(*) AS references
FROM media GROUP BY source,premium,field,access_form ORDER BY source,premium,field,access_form;

-- Public buckets serve known public-object URLs independently of table RLS.
SELECT id,public FROM storage.buckets ORDER BY id;
SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check
FROM pg_policies
WHERE (schemaname='storage' AND tablename='objects') OR
      (schemaname='public' AND tablename IN ('books','chapters','verses','verse_translations','sacred_stories','story_pages','journey_types','journey_phases','journey_tasks','journey_content_pool','garbh_sanskar_content'))
ORDER BY schemaname,tablename,policyname;
SELECT c.oid::regclass AS view_name,c.reloptions
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relkind='v' AND c.relname LIKE '%journey%';
-- Review remaining functions/views for owner-privileged body paths too.
SELECT p.oid::regprocedure AS privileged_function
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='public' AND p.prosecdef
ORDER BY 1;
