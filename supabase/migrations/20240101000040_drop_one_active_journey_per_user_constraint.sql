-- Fix: duplicate key violates unique constraint "idx_one_active_journey_per_user" when starting
-- a second journey while another is active.
--
-- Some databases never applied 20240101000025_allow_multiple_active_journeys.sql, or the
-- constraint/index was recreated. Drop both forms (Postgres implements UNIQUE as either
-- a table constraint or a standalone unique index).

ALTER TABLE public.user_journeys
  DROP CONSTRAINT IF EXISTS idx_one_active_journey_per_user;

DROP INDEX IF EXISTS public.idx_one_active_journey_per_user;
