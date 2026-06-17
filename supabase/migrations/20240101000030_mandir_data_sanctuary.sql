-- Add Mandir preferences to sanctuary_customization (same table as Aatma, like user preference)
ALTER TABLE public.sanctuary_customization
ADD COLUMN IF NOT EXISTS mandir_data JSONB DEFAULT '{
  "temple_ground": "mud",
  "deity_background": null,
  "light": "mood_midday"
}'::jsonb;

COMMENT ON COLUMN public.sanctuary_customization.mandir_data IS 'Mandir 3D preferences: temple_ground, deity_background (slug or null), light (mood/diya item id)';
