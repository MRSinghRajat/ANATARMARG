-- Mark samskaras/milestones that gate journey completion reporting (app reads is_required).
ALTER TABLE public.journey_milestones
  ADD COLUMN IF NOT EXISTS is_required BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN public.journey_milestones.is_required IS 'When true, UI highlights and completion checkbox tracks required samskaras only.';
