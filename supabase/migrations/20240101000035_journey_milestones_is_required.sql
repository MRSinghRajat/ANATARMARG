-- Mark samskaras/milestones that gate journey completion reporting (app reads is_required).
-- CREATE TABLE first so a clean replay works (migration 36 also creates/backfills this table).
CREATE TABLE IF NOT EXISTS public.journey_milestones (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  journey_type_id   UUID NOT NULL REFERENCES journey_types(id) ON DELETE CASCADE,
  phase_id          UUID REFERENCES journey_phases(id) ON DELETE SET NULL,
  slug              TEXT NOT NULL,
  title             TEXT NOT NULL,
  title_hindi       TEXT,
  description       TEXT,
  description_hindi TEXT,
  milestone_type    TEXT NOT NULL DEFAULT 'samskara',
  trigger_type      TEXT NOT NULL DEFAULT 'manual',
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

ALTER TABLE public.journey_milestones
  ADD COLUMN IF NOT EXISTS is_required BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN public.journey_milestones.is_required IS 'When true, UI highlights and completion checkbox tracks required samskaras only.';
