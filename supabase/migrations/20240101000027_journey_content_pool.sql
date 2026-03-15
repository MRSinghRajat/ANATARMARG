-- ============================================================
-- Layer 3: journey_content_pool — content for tasks (task_slug = journey_tasks.slug)
-- One task can have multiple pool rows; rotation_type (sequential/random) picks which to show today.
-- ============================================================

CREATE TABLE IF NOT EXISTS journey_content_pool (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_slug TEXT NOT NULL,
  journey_type_id UUID REFERENCES journey_types(id) ON DELETE CASCADE,

  title TEXT,
  title_hindi TEXT,
  content TEXT,
  content_hindi TEXT,
  instruction TEXT,
  instruction_hindi TEXT,
  audio_url TEXT,
  ref_type TEXT,
  ref_id TEXT,
  duration_seconds INTEGER,

  rotation_type TEXT NOT NULL DEFAULT 'sequential' CHECK (rotation_type IN ('sequential', 'random')),
  display_order INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_journey_content_pool_task_slug ON journey_content_pool(task_slug);
CREATE INDEX IF NOT EXISTS idx_journey_content_pool_journey_type ON journey_content_pool(journey_type_id);

ALTER TABLE journey_content_pool ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow read journey_content_pool" ON journey_content_pool;
CREATE POLICY "Allow read journey_content_pool" ON journey_content_pool FOR SELECT USING (true);
