-- Allow multiple active journeys per user: drop the one-active-per-user constraint.
-- Run this after the app has been updated to support multiple active + pause/resume.
-- The constraint may be a unique index or a table constraint; drop both if present.

DROP INDEX IF EXISTS idx_one_active_journey_per_user;

ALTER TABLE user_journeys DROP CONSTRAINT IF EXISTS idx_one_active_journey_per_user;
