-- ============================================================
-- GARBH SANSKAR JOURNEY — Schema per Technical Spec
-- journey_types, journey_phases, journey_tasks + v_journey_tasks_full
-- Supports: 9 phases, polymorphic content_type/content_ref, week_from/week_to
-- ============================================================

-- journey_types (if not exists)
CREATE TABLE IF NOT EXISTS journey_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  title_hindi TEXT,
  description TEXT,
  icon TEXT,
  color_primary TEXT,
  card_image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO journey_types (id, slug, title, title_hindi, description, icon, color_primary, is_active, display_order)
VALUES (
  '11b628c4-07d5-408f-8fe1-d570bac8a799',
  'garbh-sanskar',
  'Garbh Sanskar',
  'गर्भ संस्कार',
  'Sacred journey from planning to baby''s first year',
  '🪷',
  '#C5A059',
  true,
  1
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  title_hindi = EXCLUDED.title_hindi,
  description = EXCLUDED.description,
  updated_at = NOW();

-- journey_phases (if not exists)
CREATE TABLE IF NOT EXISTS journey_phases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  journey_type_id UUID NOT NULL REFERENCES journey_types(id) ON DELETE CASCADE,
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  title_hindi TEXT,
  phase_order INTEGER NOT NULL DEFAULT 0,
  trigger_type TEXT NOT NULL DEFAULT 'immediate',
  trigger_value JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(journey_type_id, slug)
);

-- Garbh Sanskar 9 phases
INSERT INTO journey_phases (journey_type_id, slug, title, phase_order, trigger_type, trigger_value) VALUES
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'planning', 'Planning', 1, 'immediate', NULL),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'trimester_1', 'Trimester 1', 2, 'week', '{"week": 1}'),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'trimester_2', 'Trimester 2', 3, 'week', '{"week": 14}'),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'trimester_3', 'Trimester 3', 4, 'week', '{"week": 28}'),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'newborn', 'Newborn', 5, 'age_days', '{"age_days_from": 0, "age_days_to": 27}'),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'month_1_3', 'Month 1–3', 6, 'age_days', '{"age_days_from": 28, "age_days_to": 89}'),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'month_3_6', 'Month 3–6', 7, 'age_days', '{"age_days_from": 90, "age_days_to": 179}'),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'month_6_12', 'Month 6–12', 8, 'age_days', '{"age_days_from": 180, "age_days_to": 364}'),
  ('11b628c4-07d5-408f-8fe1-d570bac8a799', 'year_1_plus', 'Year 1+', 9, 'age_days', '{"age_days_from": 365, "age_days_to": 99999}')
ON CONFLICT (journey_type_id, slug) DO NOTHING;

-- journey_tasks (if not exists) — content_type + content_ref for polymorphic resolution
CREATE TABLE IF NOT EXISTS journey_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phase_id UUID NOT NULL REFERENCES journey_phases(id) ON DELETE CASCADE,
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  title_hindi TEXT,
  description TEXT,
  instruction TEXT,
  task_type TEXT NOT NULL DEFAULT 'ritual',
  content_type TEXT,
  content_ref TEXT,
  week_from INTEGER,
  week_to INTEGER,
  frequency TEXT DEFAULT 'daily',
  duration_minutes INTEGER,
  mantra_count INTEGER,
  display_order INTEGER DEFAULT 0,
  icon TEXT,
  coin_reward INTEGER DEFAULT 0,
  is_premium BOOLEAN DEFAULT false,
  inline_content TEXT,
  inline_content_hindi TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_journey_tasks_phase ON journey_tasks(phase_id);
CREATE INDEX IF NOT EXISTS idx_journey_tasks_display ON journey_tasks(phase_id, display_order);

-- View: v_journey_tasks_full (joins tasks + phases + types for app)
CREATE OR REPLACE VIEW v_journey_tasks_full AS
SELECT
  t.id,
  t.id AS task_id,
  t.phase_id,
  t.slug AS task_slug,
  t.slug,
  t.title AS task_title,
  t.title,
  t.title_hindi AS task_title_hindi,
  t.title_hindi,
  t.description AS task_description,
  t.description,
  t.instruction AS task_instruction,
  t.instruction,
  t.task_type,
  t.content_type,
  t.content_ref,
  t.week_from,
  t.week_to,
  t.frequency,
  t.duration_minutes,
  t.mantra_count,
  t.display_order,
  t.icon,
  t.coin_reward,
  t.is_premium,
  t.inline_content,
  t.inline_content_hindi,
  jt.id AS journey_type_id,
  jt.slug AS journey_slug,
  p.slug AS phase_slug,
  p.title AS phase_title,
  p.title_hindi AS phase_title_hindi,
  p.phase_order,
  p.trigger_type,
  p.trigger_value,
  NULL::TEXT AS phase_duration_label,
  NULL::TEXT AS phase_icon,
  NULL::TEXT AS phase_color_hex
FROM journey_tasks t
JOIN journey_phases p ON p.id = t.phase_id
JOIN journey_types jt ON jt.id = p.journey_type_id
WHERE jt.is_active = true;

-- RLS for new tables (optional; allow read for authenticated)
ALTER TABLE journey_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE journey_phases ENABLE ROW LEVEL SECURITY;
ALTER TABLE journey_tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read journey_types" ON journey_types;
CREATE POLICY "Allow read journey_types" ON journey_types FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow read journey_phases" ON journey_phases;
CREATE POLICY "Allow read journey_phases" ON journey_phases FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow read journey_tasks" ON journey_tasks;
CREATE POLICY "Allow read journey_tasks" ON journey_tasks FOR SELECT USING (true);
