-- Link Hanuman Chalisa 40-Day full-chant content to Granthalaya sacred text (slug: hanuman-chalisa).
-- App reads ref_type + ref_id or ref_slug from journey_content_pool in JourneyTaskDetailScreen.

UPDATE journey_content_pool
SET
  ref_type = 'sacred_text',
  ref_slug = 'hanuman-chalisa',
  ref_id = NULL
WHERE slug = 'hc_full_chalisa_v1'
  AND task_slug = 'hc_full_chant';
