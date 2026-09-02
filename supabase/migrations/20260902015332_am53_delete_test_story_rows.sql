-- AM-53: remove remaining Test Story placeholders from production catalog.
-- Orphan check (live, 2026-09-01):
--   test-story-001: 0 story_pages; pages jsonb length 1 (placeholder)
--   test-story-002: 1 story_pages row ("Hello"/"नमस्ते"); CASCADE on story_id
--   0 ls_fun_facts, 0 journey_content_pool, 0 user_audio_progress,
--   0 user_gs_content_progress, 0 daily_stories.
-- Broader sweep (source='Test' OR key_teaching='Test' OR title/slug Test*):
--   only these two rows. Idempotent.

DELETE FROM sacred_stories
WHERE slug IN ('test-story-001', 'test-story-002');
