-- ============================================================
-- JOURNEY SCHEMA COMPLETENESS
-- Adds all columns the app Dart models expect but which were
-- absent from the original tracked migrations.
-- Every statement is idempotent — safe to run on any env.
-- ============================================================

-- ─── journey_types — 17 missing columns ──────────────────────────────────────
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS subtitle          TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS subtitle_hindi    TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS description_hindi TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS color_secondary   TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS banner_url        TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS category          TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS target_audience   TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS setup_schema      JSONB;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS setup_type        TEXT    DEFAULT 'date_based';
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS duration_days     INTEGER;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS can_repeat        BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS is_seasonal       BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS seasonal_key      TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS is_premium        BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS required_plan     TEXT;
ALTER TABLE journey_types ADD COLUMN IF NOT EXISTS is_coming_soon    BOOLEAN NOT NULL DEFAULT false;

-- ─── journey_phases — 3 missing columns used by UI chips ─────────────────────
-- v_journey_tasks_full previously returned NULL::TEXT for these.
ALTER TABLE journey_phases ADD COLUMN IF NOT EXISTS duration_label TEXT;
ALTER TABLE journey_phases ADD COLUMN IF NOT EXISTS icon           TEXT;
ALTER TABLE journey_phases ADD COLUMN IF NOT EXISTS color_hex      TEXT;

-- ─── journey_milestones — CREATE TABLE if not exists ─────────────────────────
-- Migration 35 assumes this table exists (ALTER only). This CREATE TABLE
-- covers a clean-deploy. The is_required column is included here so the
-- ALTER in migration 35 safely no-ops.
CREATE TABLE IF NOT EXISTS journey_milestones (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  journey_type_id   UUID NOT NULL REFERENCES journey_types(id)  ON DELETE CASCADE,
  phase_id          UUID          REFERENCES journey_phases(id) ON DELETE SET NULL,
  slug              TEXT NOT NULL,
  title             TEXT NOT NULL,
  title_hindi       TEXT,
  description       TEXT,
  description_hindi TEXT,
  milestone_type    TEXT    NOT NULL DEFAULT 'samskara',
  trigger_type      TEXT    NOT NULL DEFAULT 'manual',
  trigger_value     JSONB,
  milestone_order   INTEGER NOT NULL DEFAULT 0,
  icon              TEXT,
  allow_photo       BOOLEAN NOT NULL DEFAULT false,
  allow_notes       BOOLEAN NOT NULL DEFAULT true,
  is_required       BOOLEAN NOT NULL DEFAULT false,
  coin_reward       INTEGER NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(journey_type_id, slug)
);

-- Backfill columns the table may be missing if created by an older migration.
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS is_required       BOOLEAN     NOT NULL DEFAULT false;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS title_hindi       TEXT;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS description_hindi TEXT;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS milestone_type    TEXT        NOT NULL DEFAULT 'samskara';
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS trigger_type      TEXT        NOT NULL DEFAULT 'manual';
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS trigger_value     JSONB;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS milestone_order   INTEGER     NOT NULL DEFAULT 0;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS icon              TEXT;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS allow_photo       BOOLEAN     NOT NULL DEFAULT false;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS allow_notes       BOOLEAN     NOT NULL DEFAULT true;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS coin_reward       INTEGER     NOT NULL DEFAULT 0;
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS created_at        TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE journey_milestones ADD COLUMN IF NOT EXISTS updated_at        TIMESTAMPTZ DEFAULT NOW();

-- Add unique constraint if missing (needed for ON CONFLICT in seed migration).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'journey_milestones'::regclass
      AND contype = 'u'
      AND conname = 'journey_milestones_journey_type_id_slug_key'
  ) THEN
    ALTER TABLE journey_milestones
      ADD CONSTRAINT journey_milestones_journey_type_id_slug_key
      UNIQUE (journey_type_id, slug);
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_journey_milestones_journey_type ON journey_milestones(journey_type_id);
CREATE INDEX IF NOT EXISTS idx_journey_milestones_phase        ON journey_milestones(phase_id);
CREATE INDEX IF NOT EXISTS idx_journey_milestones_order        ON journey_milestones(journey_type_id, milestone_order);

ALTER TABLE journey_milestones ENABLE ROW LEVEL SECURITY;
DROP   POLICY IF EXISTS "Allow read journey_milestones" ON journey_milestones;
CREATE POLICY "Allow read journey_milestones" ON journey_milestones FOR SELECT USING (true);

-- ─── journey_content_pool — backfill missing columns ─────────────────────────
-- Migrations 27+28 may not have been applied to all envs.
-- These are all idempotent (IF NOT EXISTS).
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS title_hindi       TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS content_hindi     TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS instruction       TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS instruction_hindi TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS transliteration   TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS translation       TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS benefits          JSONB;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS audio_url         TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS ref_type          TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS ref_id            TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS ref_slug          TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS duration_seconds  INTEGER;
-- slug:     unique row identifier; enables safe ON CONFLICT upserts.
-- category: 'mantra' | 'meditation' | 'yoga' | 'ritual' | 'wisdom' | 'read' | 'lullaby'
--
-- PATTERN — Daily Wisdom (works for every future journey type with zero code changes):
--   INSERT rows with category='wisdom', task_slug='wisdom', journey_type_id=<any type>
--   The wisdomForJourneyProvider in Dart picks one by (dayOfJourney % pool.length).
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS slug     TEXT;
ALTER TABLE journey_content_pool ADD COLUMN IF NOT EXISTS category TEXT;

CREATE INDEX IF NOT EXISTS idx_journey_content_pool_category
  ON journey_content_pool(category, journey_type_id);

-- ─── v_journey_tasks_full — replace NULL::TEXT with actual phase columns ──────
-- DROP first because CREATE OR REPLACE cannot rename existing view columns.
DROP VIEW IF EXISTS v_journey_tasks_full;
CREATE VIEW v_journey_tasks_full AS
SELECT
  t.id,
  t.id                  AS task_id,
  t.phase_id,
  t.slug                AS task_slug,
  t.slug,
  t.title               AS task_title,
  t.title,
  t.title_hindi         AS task_title_hindi,
  t.title_hindi,
  t.description         AS task_description,
  t.description,
  t.instruction         AS task_instruction,
  t.instruction,
  t.task_type,
  t.content_type,
  t.content_ref,
  t.week_from,
  t.week_to,
  t.frequency,
  t.duration_minutes,
  t.mantra_count,
  t.display_order,
  t.icon,
  t.coin_reward,
  t.is_premium,
  t.inline_content,
  t.inline_content_hindi,
  jt.id                 AS journey_type_id,
  jt.slug               AS journey_slug,
  p.slug                AS phase_slug,
  p.title               AS phase_title,
  p.title_hindi         AS phase_title_hindi,
  p.phase_order,
  p.trigger_type,
  p.trigger_value,
  p.duration_label      AS phase_duration_label,
  p.icon                AS phase_icon,
  p.color_hex           AS phase_color_hex
FROM journey_tasks t
JOIN journey_phases p  ON p.id  = t.phase_id
JOIN journey_types  jt ON jt.id = p.journey_type_id
WHERE jt.is_active = true;
