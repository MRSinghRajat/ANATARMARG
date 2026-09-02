-- AM-2: daily_task_templates + user_daily_tasks before 00033 (ALTER rewards_granted_at).
-- rewards_granted_at is added by 00033. DDL otherwise matches live (2026-09-01).

CREATE TABLE IF NOT EXISTS public.daily_task_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  category text NOT NULL,
  title text NOT NULL,
  title_hindi text,
  description text,
  icon_name text DEFAULT 'auto_awesome',
  coin_reward integer DEFAULT 5,
  karma_reward integer DEFAULT 1,
  streak_multiplier numeric DEFAULT 1.0,
  is_daily boolean DEFAULT true,
  is_system_task boolean DEFAULT true,
  requires_verification boolean DEFAULT false,
  estimated_minutes integer DEFAULT 5,
  available_days integer[] DEFAULT '{0,1,2,3,4,5,6}'::integer[],
  unlock_after_days integer DEFAULT 0,
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT daily_task_templates_category_check CHECK (
    category = ANY (ARRAY['scripture','meditation','seva','lifestyle','devotion','learning','custom'])
  )
);

CREATE TABLE IF NOT EXISTS public.user_daily_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  task_date date NOT NULL DEFAULT CURRENT_DATE,
  template_id uuid REFERENCES public.daily_task_templates(id),
  dynamic_content jsonb DEFAULT '{}'::jsonb,
  status text DEFAULT 'pending',
  completed_at timestamptz,
  coins_earned integer DEFAULT 0,
  karma_earned integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT user_daily_tasks_status_check CHECK (
    status = ANY (ARRAY['pending','completed','skipped','expired'])
  ),
  CONSTRAINT unique_user_task_date UNIQUE (user_id, template_id, task_date)
);
CREATE INDEX IF NOT EXISTS idx_user_daily_tasks_status ON public.user_daily_tasks (status);
CREATE INDEX IF NOT EXISTS idx_user_daily_tasks_user_date ON public.user_daily_tasks (user_id, task_date);

ALTER TABLE public.daily_task_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_daily_tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read task templates" ON public.daily_task_templates;
CREATE POLICY "Anyone can read task templates"
  ON public.daily_task_templates FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can read own daily tasks" ON public.user_daily_tasks;
DROP POLICY IF EXISTS "Users can insert own daily tasks" ON public.user_daily_tasks;
DROP POLICY IF EXISTS "Users can update own daily tasks" ON public.user_daily_tasks;
CREATE POLICY "Users can read own daily tasks"
  ON public.user_daily_tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own daily tasks"
  ON public.user_daily_tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own daily tasks"
  ON public.user_daily_tasks FOR UPDATE USING (auth.uid() = user_id);
