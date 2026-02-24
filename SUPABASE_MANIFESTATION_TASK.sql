-- Insert the Manifestation daily task template so it appears in Ashram.
-- If you get error "violates check constraint daily_task_templates_category_check",
-- the category value is not allowed. Check existing rows: SELECT DISTINCT category FROM daily_task_templates;
-- Then use one of those values (e.g. devotion, meditation, scripture, custom) in place of 'devotion' below.

INSERT INTO daily_task_templates (
  id, slug, category, title, title_hindi, description, icon_name,
  coin_reward, karma_reward, streak_multiplier, is_daily, is_system_task,
  requires_verification, estimated_minutes, available_days, unlock_after_days,
  order_index, is_active
) VALUES (
  gen_random_uuid(),
  'manifestation',
  'devotion',
  'Manifestation',
  NULL,
  NULL,
  'auto_awesome',
  5,
  1,
  1.0,
  true,
  true,
  false,
  5,
  ARRAY[0,1,2,3,4,5,6],
  0,
  20,
  true
);
