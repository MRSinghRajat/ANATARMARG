-- LOCAL DISPOSABLE DATABASE ONLY. psql -X -v ON_ERROR_STOP=1 -f this_file.sql
-- Minimal behavioral fixture, not a recreation of the complete production schema.
-- Everything rolls back. Refuse databases already containing application tables.
\set ON_ERROR_STOP on
BEGIN;
DO $$ BEGIN
  IF to_regclass('public.books') IS NOT NULL THEN
    RAISE EXCEPTION 'Run only in an empty disposable database';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
END $$;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
CREATE FUNCTION public.has_active_entitlement(uid uuid) RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT uid = '00000000-0000-0000-0000-000000000001'::uuid
$$;
CREATE TABLE books (id text PRIMARY KEY, is_premium boolean, is_active boolean DEFAULT true, audio_url text, audio_url_en text);
CREATE TABLE chapters (id text PRIMARY KEY, book_id text, is_active boolean DEFAULT true);
CREATE TABLE verses (id text PRIMARY KEY, book_id text, chapter_id text);
CREATE TABLE verse_translations (id text PRIMARY KEY, verse_id text);
CREATE TABLE sacred_stories (id text PRIMARY KEY, is_active boolean, is_premium boolean, pages jsonb DEFAULT '[]', audio_url text, audio_url_en text, video_url text);
CREATE TABLE story_pages (id text PRIMARY KEY, story_id text);
CREATE TABLE journey_types (id text PRIMARY KEY, is_active boolean, is_premium boolean);
CREATE TABLE journey_phases (id text PRIMARY KEY, journey_type_id text, is_active boolean DEFAULT true);
CREATE TABLE journey_tasks (id text PRIMARY KEY, phase_id text, slug text, is_premium boolean, is_active boolean DEFAULT true);
CREATE TABLE journey_content_pool (id text PRIMARY KEY, journey_type_id text, task_slug text, is_active boolean DEFAULT true);
CREATE TABLE garbh_sanskar_content (id text PRIMARY KEY, is_active boolean, is_premium boolean);
CREATE VIEW v_journey_tasks_full AS SELECT t.* FROM journey_tasks t JOIN journey_phases p ON p.id=t.phase_id JOIN journey_types jt ON jt.id=p.journey_type_id;
CREATE VIEW v_journey_content_resolved AS SELECT * FROM journey_content_pool;
-- Keep deliberately broad legacy policies to prove they cannot reopen content.
DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['books','chapters','verses','verse_translations','sacred_stories','story_pages','journey_types','journey_phases','journey_tasks','journey_content_pool','garbh_sanskar_content'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY legacy_open_read ON public.%I FOR SELECT USING (true)', t);
    EXECUTE format('CREATE POLICY legacy_open_write ON public.%I FOR ALL USING (true) WITH CHECK (true)', t);
  END LOOP;
END $$;
-- Test a parent hidden by another policy even though it remains active.
CREATE POLICY hidden_book ON books AS RESTRICTIVE FOR SELECT USING (id <> 'hidden');
CREATE POLICY hidden_journey ON journey_types AS RESTRICTIVE FOR SELECT USING (id <> 'hidden');
CREATE POLICY hidden_story ON sacred_stories AS RESTRICTIVE FOR SELECT USING (id <> 'hidden');
CREATE POLICY hidden_phase ON journey_phases AS RESTRICTIVE FOR SELECT USING (id <> 'hidden-phase');
GRANT USAGE ON SCHEMA public, auth TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public TO anon, authenticated;
-- Deliberately grant individual columns too: table-level REVOKE alone does not
-- remove these, so the restrictive write guards must still stop reclassification.
GRANT UPDATE (is_premium) ON books TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public, auth TO anon, authenticated;
\ir ../migrations/20260914030000_l07b_activate_premium_rls.sql
\ir ../migrations/20260914030000_l07b_activate_premium_rls.sql

-- Simulate a later accidental column grant; write guards must still hold.
GRANT UPDATE (is_premium) ON books TO anon, authenticated;
INSERT INTO books(id,is_premium,is_active) VALUES ('free',false,true),('paid',true,true),('hidden',true,true),('inactive',false,false),('null-active',false,null),('unknown-price',null,true);
INSERT INTO chapters(id,book_id,is_active) VALUES ('free','free',true),('paid','paid',true),('hidden','hidden',true),('inactive','inactive',true),('orphan','missing',true),('null-active','null-active',true),('inactive-chapter','free',false),('unknown-price','unknown-price',true);
INSERT INTO verses(id,book_id,chapter_id) SELECT id,book_id,id FROM chapters;
INSERT INTO verses VALUES ('mismatched','free','paid'),('missing-chapter','free','missing');
INSERT INTO verse_translations SELECT id,id FROM verses;
INSERT INTO verse_translations VALUES ('missing-verse','missing');
INSERT INTO sacred_stories(id,is_active,is_premium) VALUES ('free',true,false),('paid',true,true),('hidden',true,true),('inactive',false,false),('null-active',null,false);
INSERT INTO story_pages SELECT id,id FROM sacred_stories;
INSERT INTO story_pages VALUES ('orphan','missing');
INSERT INTO journey_types VALUES ('free',true,false),('paid',true,true),('hidden',true,true),('inactive',false,false),('null-active',null,false),('unknown-price',true,null);
INSERT INTO journey_phases(id,journey_type_id) SELECT id,id FROM journey_types;
INSERT INTO journey_phases VALUES ('hidden-phase','free',true),('inactive-phase','free',false),('orphan-phase','missing',true);
INSERT INTO journey_tasks(id,phase_id,slug,is_premium) SELECT id,id,id,false FROM journey_phases;
INSERT INTO journey_tasks(id,phase_id,slug,is_premium,is_active) VALUES ('premium-task','free','premium-task',true,true),('inactive-task','free','inactive-task',false,false),('orphan-task','missing','orphan-task',false,true),('null-parent',null,'null-parent',false,true);
INSERT INTO journey_content_pool(id,journey_type_id,task_slug) SELECT t.id,p.journey_type_id,t.slug FROM journey_tasks t LEFT JOIN journey_phases p ON p.id=t.phase_id;
INSERT INTO journey_content_pool VALUES ('missing-task','free','missing',true),('no-parent',null,'free',true),('inactive-pool','free','free',false),('wrong-journey','paid','premium-task',true);
INSERT INTO garbh_sanskar_content VALUES ('free',true,false),('paid',true,true),('inactive',false,false),('null-active',null,false),('unknown-price',true,null);

CREATE FUNCTION public.assert_ids(tbl text, expected text[]) RETURNS void LANGUAGE plpgsql AS $$
DECLARE actual text[];
BEGIN
  EXECUTE format('SELECT coalesce(array_agg(id ORDER BY id), ARRAY[]::text[]) FROM public.%I',tbl) INTO actual;
  IF actual IS DISTINCT FROM expected THEN RAISE EXCEPTION '%: expected %, received %',tbl,expected,actual; END IF;
END $$;
GRANT EXECUTE ON FUNCTION public.assert_ids(text,text[]) TO anon, authenticated;
SET LOCAL ROLE anon;
SELECT set_config('request.jwt.claim.sub','',true);
SELECT assert_ids(t,ARRAY['free']) FROM unnest(ARRAY['chapters','verses','verse_translations','story_pages','journey_tasks','v_journey_tasks_full','journey_content_pool','v_journey_content_resolved','garbh_sanskar_content']) t;
-- Old column-level grants cannot reclassify or publish content.
DO $$ BEGIN
  UPDATE books SET is_premium=false WHERE id='paid';
  IF FOUND THEN RAISE EXCEPTION 'Client reclassified premium book'; END IF;
  BEGIN
    INSERT INTO books(id,is_premium) VALUES ('injected',false);
    RAISE EXCEPTION 'Client published shared content';
  EXCEPTION WHEN insufficient_privilege THEN NULL; END;
  BEGIN
    TRUNCATE books;
    RAISE EXCEPTION 'Client truncated shared content';
  EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
-- Premium catalog metadata stays visible to free users.
DO $$ BEGIN
  IF NOT EXISTS(SELECT 1 FROM books WHERE id='paid') OR NOT EXISTS(SELECT 1 FROM sacred_stories WHERE id='paid') OR NOT EXISTS(SELECT 1 FROM journey_types WHERE id='paid') THEN
    RAISE EXCEPTION 'Paid catalog disappeared';
  END IF;
END $$;
RESET ROLE;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',true);
SELECT assert_ids(t,ARRAY['free']) FROM unnest(ARRAY['chapters','verses','verse_translations','story_pages','journey_tasks','journey_content_pool','garbh_sanskar_content']) t;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
SELECT assert_ids(t,ARRAY['free','paid','unknown-price']) FROM unnest(ARRAY['chapters','verses','verse_translations','garbh_sanskar_content']) t;
SELECT assert_ids('story_pages',ARRAY['free','paid']);
SELECT assert_ids(t,ARRAY['free','paid','premium-task','unknown-price']) FROM unnest(ARRAY['journey_tasks','v_journey_tasks_full','journey_content_pool','v_journey_content_resolved']) t;
RESET ROLE;
DO $$ BEGIN
  BEGIN
    UPDATE sacred_stories SET pages='[{"text":"protected"}]' WHERE id='paid';
    RAISE EXCEPTION 'Premium inline pages unexpectedly accepted';
  EXCEPTION WHEN check_violation THEN NULL; END;
  BEGIN
    UPDATE sacred_stories SET audio_url='https://example.invalid/full.mp3' WHERE id='paid';
    RAISE EXCEPTION 'Premium catalog audio unexpectedly accepted';
  EXCEPTION WHEN check_violation THEN NULL; END;
  BEGIN
    UPDATE sacred_stories SET video_url='https://example.invalid/full.mp4' WHERE id='paid';
    RAISE EXCEPTION 'Premium catalog video unexpectedly accepted';
  EXCEPTION WHEN check_violation THEN NULL; END;
  BEGIN
    UPDATE books SET audio_url_en='https://example.invalid/full.mp3' WHERE id='paid';
    RAISE EXCEPTION 'Premium book catalog audio unexpectedly accepted';
  EXCEPTION WHEN check_violation THEN NULL; END;
  UPDATE sacred_stories SET pages='[{"text":"free"}]' WHERE id='free';
END $$;
ROLLBACK;
\echo 'PASS: L07 content policies, views, catalog invariants, inactive/hidden/orphan boundaries'
