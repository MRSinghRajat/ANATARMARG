-- Sanctuary Customization Schema
-- Stores user customization preferences for the Om Sanctuary (Aangan/Ashram)

-- Create the sanctuary_customization table
CREATE TABLE IF NOT EXISTS public.sanctuary_customization (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customization_data JSONB NOT NULL DEFAULT '{
        "omStyle": "classic",
        "ringStyle": "singleRing",
        "ringColor": "gold",
        "animationStyle": "gentle",
        "backgroundStyle": "geometricLines",
        "glowColor": "gold",
        "deityImage": null,
        "frameStyle": "none",
        "specialEffect": "none",
        "particleStyle": "none"
    }'::jsonb,
    purchased_items TEXT[] DEFAULT ARRAY[
        'omStyle_classic',
        'ringStyle_singleRing',
        'ringColor_gold',
        'animationStyle_gentle',
        'backgroundStyle_geometricLines',
        'glowColor_gold',
        'frameStyle_none',
        'specialEffect_none',
        'particleStyle_none'
    ],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_customization UNIQUE(user_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_sanctuary_customization_user_id 
ON public.sanctuary_customization(user_id);

-- Enable Row Level Security
ALTER TABLE public.sanctuary_customization ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own customization
CREATE POLICY "Users can read own customization"
ON public.sanctuary_customization
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own customization
CREATE POLICY "Users can insert own customization"
ON public.sanctuary_customization
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own customization
CREATE POLICY "Users can update own customization"
ON public.sanctuary_customization
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own customization
CREATE POLICY "Users can delete own customization"
ON public.sanctuary_customization
FOR DELETE
USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_sanctuary_customization_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on changes
DROP TRIGGER IF EXISTS update_sanctuary_customization_timestamp ON public.sanctuary_customization;
CREATE TRIGGER update_sanctuary_customization_timestamp
    BEFORE UPDATE ON public.sanctuary_customization
    FOR EACH ROW
    EXECUTE FUNCTION update_sanctuary_customization_updated_at();

-- Grant permissions
GRANT ALL ON public.sanctuary_customization TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
