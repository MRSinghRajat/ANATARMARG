-- AM-2: attach live FKs. Filename sorts after 00026_garbh_sanskar_journey_schema.sql.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'user_journeys_journey_type_id_fkey'
  ) THEN
    ALTER TABLE public.user_journeys
      ADD CONSTRAINT user_journeys_journey_type_id_fkey
      FOREIGN KEY (journey_type_id) REFERENCES public.journey_types(id);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'user_journeys_current_phase_id_fkey'
  ) THEN
    ALTER TABLE public.user_journeys
      ADD CONSTRAINT user_journeys_current_phase_id_fkey
      FOREIGN KEY (current_phase_id) REFERENCES public.journey_phases(id);
  END IF;
END $$;
