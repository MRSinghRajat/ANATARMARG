-- Aangan in-app notifications (e.g. Happy Holi, New update coming soon).
-- Records are shown to users by target: all users, by region (location), or by user_id.

CREATE TABLE IF NOT EXISTS public.aangan_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subtitle TEXT,
    emoji_or_icon TEXT,
    target_type TEXT NOT NULL DEFAULT 'all' CHECK (target_type IN ('all', 'region', 'user')),
    target_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    target_region TEXT,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_aangan_notifications_active_dates
ON public.aangan_notifications(is_active, start_date, end_date)
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_aangan_notifications_target
ON public.aangan_notifications(target_type, target_region, target_user_id);

ALTER TABLE public.aangan_notifications ENABLE ROW LEVEL SECURITY;

-- Anyone can read active notifications (app filters by target_type/region/user client-side or via RPC)
CREATE POLICY "Allow read active aangan notifications"
ON public.aangan_notifications
FOR SELECT
USING (is_active = true);

-- No INSERT/UPDATE/DELETE policies for anon key: only service_role (dashboard/backend) can write.
-- App uses anon key and only reads via "Allow read active aangan notifications".

COMMENT ON TABLE public.aangan_notifications IS 'In-app notifications shown on Aangan screen; target_type: all | region | user; target_region e.g. IN, US for location-based delivery';
