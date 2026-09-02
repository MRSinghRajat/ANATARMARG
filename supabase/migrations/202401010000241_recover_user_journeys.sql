-- AM-2: user_journeys must exist before 00025 (ALTER TABLE).
-- journey_types / journey_phases are created in 00026, so type/phase FKs
-- are added in 00026_recover_user_journeys_fks.sql. DDL otherwise matches live (2026-09-01).

CREATE TABLE IF NOT EXISTS public.user_journeys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  journey_type_id uuid,
  current_phase_id uuid,
  status text NOT NULL DEFAULT 'active',
  start_date date NOT NULL DEFAULT CURRENT_DATE,
  target_date date,
  paused_at timestamptz,
  resumed_at timestamptz,
  completed_at timestamptz,
  metadata jsonb DEFAULT '{}'::jsonb,
  plan_at_start text DEFAULT 'free',
  companion_user_id uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT user_journeys_user_id_journey_type_id_key UNIQUE (user_id, journey_type_id)
);
CREATE INDEX IF NOT EXISTS idx_user_journeys_type ON public.user_journeys (journey_type_id);
CREATE INDEX IF NOT EXISTS idx_user_journeys_user ON public.user_journeys (user_id, status);

ALTER TABLE public.user_journeys ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_journeys_select" ON public.user_journeys;
DROP POLICY IF EXISTS "user_journeys_insert" ON public.user_journeys;
DROP POLICY IF EXISTS "user_journeys_update" ON public.user_journeys;
DROP POLICY IF EXISTS "user_journeys_delete" ON public.user_journeys;
CREATE POLICY "user_journeys_select" ON public.user_journeys FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "user_journeys_insert" ON public.user_journeys FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "user_journeys_update" ON public.user_journeys FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "user_journeys_delete" ON public.user_journeys FOR DELETE USING (auth.uid() = user_id);
