-- AM-42: remove empty placeholder sacred_stories from production catalog.
-- Orphan check (live, 2026-09-01): 0 story_pages by id/slug, 0 pages jsonb,
-- 0 journey_content_pool refs. Safe hard delete. Idempotent.

DELETE FROM sacred_stories
WHERE title IN ('Test mythology', 'Test leela', 'Test moral');
