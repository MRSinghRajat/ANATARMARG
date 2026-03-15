-- How you feeling: log user mood and suggest content by weekday + feeling.
-- feeling_id matches app: calm, inspired, anxious, healing, lost, joyful, flow, seeking.
-- weekday: 1 = Monday .. 7 = Sunday (DateTime.weekday).

-- Log each feeling selection (one row per tap; optional one-per-day view via latest per user/day).
CREATE TABLE IF NOT EXISTS public.user_feeling_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    feeling_id TEXT NOT NULL,
    logged_date DATE NOT NULL DEFAULT (CURRENT_DATE AT TIME ZONE 'UTC'),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT feeling_id_valid CHECK (feeling_id IN (
        'calm','inspired','anxious','healing','lost','joyful','flow','seeking'
    ))
);

CREATE INDEX IF NOT EXISTS idx_user_feeling_log_user_date
ON public.user_feeling_log(user_id, logged_date);

ALTER TABLE public.user_feeling_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own feeling log"
ON public.user_feeling_log FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own feeling log"
ON public.user_feeling_log FOR INSERT WITH CHECK (auth.uid() = user_id);

GRANT ALL ON public.user_feeling_log TO authenticated;

-- Suggestions per feeling + weekday (1=Mon .. 7=Sun). One row per (feeling_id, weekday).
CREATE TABLE IF NOT EXISTS public.feeling_weekday_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feeling_id TEXT NOT NULL,
    weekday INT NOT NULL,
    suggestion_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    content_slug TEXT,
    display_order INT NOT NULL DEFAULT 0,
    CONSTRAINT feeling_fk CHECK (feeling_id IN (
        'calm','inspired','anxious','healing','lost','joyful','flow','seeking'
    )),
    CONSTRAINT weekday_fk CHECK (weekday >= 1 AND weekday <= 7),
    CONSTRAINT suggestion_type_fk CHECK (suggestion_type IN (
        'mantra','chant','activity','reading','meditation','walk','gratitude','japa','other'
    )),
    UNIQUE(feeling_id, weekday)
);

CREATE INDEX IF NOT EXISTS idx_feeling_weekday_suggestions_lookup
ON public.feeling_weekday_suggestions(feeling_id, weekday);

ALTER TABLE public.feeling_weekday_suggestions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read feeling suggestions"
ON public.feeling_weekday_suggestions FOR SELECT USING (true);

GRANT SELECT ON public.feeling_weekday_suggestions TO authenticated;
GRANT SELECT ON public.feeling_weekday_suggestions TO anon;

-- Seed: weekday themes (Mon=Shiva, Tue=Hanuman, Wed=Ganesh, Thu=Guru/Vishnu, Fri=Lakshmi, Sat=Hanuman/Shani, Sun=Surya)
-- Insert one suggestion per (feeling_id, weekday). title + description shown in app.
INSERT INTO public.feeling_weekday_suggestions (feeling_id, weekday, suggestion_type, title, description, content_slug, display_order) VALUES
-- Monday (1) - Shiva
('calm', 1, 'meditation', 'Om Namah Shivaya', 'Start with 5 minutes of silent repetition. Let the mantra steady your mind.', 'om-namah-shivaya', 0),
('inspired', 1, 'mantra', 'Shiva mantra', 'Channel inspiration into 108 repetitions of Om Namah Shivaya.', 'shiva-mantra', 0),
('anxious', 1, 'meditation', 'Breath and Shiva', 'Sit quietly, 4-6 breath cycles, then softly repeat Om Namah Shivaya to ground.', NULL, 0),
('healing', 1, 'chant', 'Shiva peace chant', 'A short Shiva chant can support healing. Listen or hum along.', NULL, 0),
('lost', 1, 'activity', 'Short walk', 'Take a 10-minute walk. Ask: What is one small step I can take today?', NULL, 0),
('joyful', 1, 'japa', 'Offer your joy', 'Do 11 or 21 rounds of Om Namah Shivaya, dedicating the merit to someone you care about.', NULL, 0),
('flow', 1, 'meditation', 'Deeper meditation', 'Use this flow for 15–20 min meditation or longer japa on Monday’s Shiva energy.', NULL, 0),
('seeking', 1, 'reading', 'Reflect on clarity', 'Read one short verse or quote on clarity. Write one question in your journal.', NULL, 0),
-- Tuesday (2) - Hanuman
('calm', 2, 'chant', 'Hanuman Chalisa', 'Your calm is ideal for Hanuman Chalisa. Recite once with focus.', 'hanuman-chalisa', 0),
('inspired', 2, 'chant', 'Hanuman Chalisa', 'Channel inspiration into Hanuman Chalisa—a Tuesday favourite for strength and devotion.', 'hanuman-chalisa', 0),
('anxious', 2, 'chant', 'Hanuman Chalisa', 'Hanuman Chalisa can ease anxiety. Recite slowly; let the rhythm steady you.', 'hanuman-chalisa', 0),
('healing', 2, 'chant', 'Hanuman Chalisa', 'Hanuman’s energy supports healing. Listen or recite at a gentle pace.', 'hanuman-chalisa', 0),
('lost', 2, 'chant', 'Hanuman Chalisa', 'When lost, Hanuman Chalisa can guide. Even one chaupai can light the next step.', 'hanuman-chalisa', 0),
('joyful', 2, 'chant', 'Hanuman Chalisa', 'Offer your joy with Hanuman Chalisa—Tuesday’s sacred practice.', 'hanuman-chalisa', 0),
('flow', 2, 'chant', 'Hanuman Chalisa', 'Use your flow for full Hanuman Chalisa and optional bajrang ban.', 'hanuman-chalisa', 0),
('seeking', 2, 'chant', 'Hanuman Chalisa', 'Seek strength and clarity with Hanuman Chalisa on Hanuman’s day.', 'hanuman-chalisa', 0),
-- Wednesday (3) - Ganesh
('calm', 3, 'mantra', 'Ganesh mantra', 'Repeat Om Gam Ganapataye Namaha 11 or 21 times to deepen calm.', 'ganesh-mantra', 0),
('inspired', 3, 'mantra', 'Ganesh mantra', 'Set an intention and do 108 Ganesh mantras to remove obstacles.', 'ganesh-mantra', 0),
('anxious', 3, 'activity', 'Walk and mantra', 'Short walk + soft repetition of Om Gam Ganapataye Namaha to ease worry.', NULL, 0),
('healing', 3, 'meditation', 'Ganesh visualisation', 'Visualise Ganesh’s gentle presence; breathe slowly for 5–10 minutes.', NULL, 0),
('lost', 3, 'mantra', 'Ganesh mantra', 'Ganesh clears obstacles. Chant Om Gam Ganapataye Namaha and ask for the next step.', 'ganesh-mantra', 0),
('joyful', 3, 'mantra', 'Ganesh mantra', 'Share joy with 21 Ganesh mantras, dedicating to someone in need.', 'ganesh-mantra', 0),
('flow', 3, 'japa', 'Ganesh japa', 'Use flow for 108 or 216 Ganesh mantras on Wednesday.', 'ganesh-mantra', 0),
('seeking', 3, 'reading', 'Ganesh and wisdom', 'Read a short passage on Ganesh and wisdom. Note one insight.', NULL, 0),
-- Thursday (4) - Guru / Vishnu
('calm', 4, 'mantra', 'Guru mantra', 'Guru mantra or Vishnu mantra in silence to deepen Thursday’s blessing.', NULL, 0),
('inspired', 4, 'reading', 'Sacred text', 'Thursday is for learning. Read one page of a sacred text or listen to a talk.', NULL, 0),
('anxious', 4, 'mantra', 'Vishnu mantra', 'Om Namo Bhagavate Vasudevaya—repeat slowly to calm the mind.', NULL, 0),
('healing', 4, 'meditation', 'Gratitude', 'List three things you are grateful for. Sit with each for a breath.', NULL, 0),
('lost', 4, 'reading', 'One verse', 'Read one verse on guidance or grace. Let it point to the next step.', NULL, 0),
('joyful', 4, 'gratitude', 'Thanksgiving', 'Offer thanks with a short prayer or 5 minutes of gratitude meditation.', NULL, 0),
('flow', 4, 'reading', 'Deeper study', 'Use flow for 20–30 min reading or listening to spiritual content.', NULL, 0),
('seeking', 4, 'reading', 'Ask one question', 'Pick one question and find one verse or quote that speaks to it.', NULL, 0),
-- Friday (5) - Lakshmi
('calm', 5, 'mantra', 'Lakshmi mantra', 'Soft repetition of Lakshmi mantra to nurture peace and abundance.', NULL, 0),
('inspired', 5, 'mantra', 'Lakshmi mantra', 'Channel inspiration into Lakshmi mantra or a short Lakshmi stotra.', NULL, 0),
('anxious', 5, 'meditation', 'Gentle breath', '5 min breath focus, then offer a simple prayer for peace (Lakshmi’s grace).', NULL, 0),
('healing', 5, 'activity', 'Light and beauty', 'Light a diya or sit where you see something beautiful. Rest in that sight.', NULL, 0),
('lost', 5, 'mantra', 'Lakshmi mantra', 'Lakshmi brings clarity. Chant with sincerity and ask for inner abundance.', NULL, 0),
('joyful', 5, 'mantra', 'Lakshmi mantra', 'Share Friday joy with Lakshmi mantra or a gratitude offering.', NULL, 0),
('flow', 5, 'japa', 'Lakshmi japa', 'Use flow for a longer Lakshmi mantra or stotra on Friday.', NULL, 0),
('seeking', 5, 'reading', 'Abundance within', 'Read one passage on inner abundance. Note what resonates.', NULL, 0),
-- Saturday (6) - Hanuman / Shani
('calm', 6, 'chant', 'Hanuman Chalisa', 'Hanuman Chalisa on Saturday brings peace and protection.', 'hanuman-chalisa', 0),
('inspired', 6, 'chant', 'Hanuman Chalisa', 'Saturday: strengthen resolve with Hanuman Chalisa.', 'hanuman-chalisa', 0),
('anxious', 6, 'chant', 'Hanuman Chalisa', 'Hanuman Chalisa can ease Saturday anxiety. Recite at your own pace.', 'hanuman-chalisa', 0),
('healing', 6, 'walk', 'Gentle walk', 'A gentle walk, then 5 min of silence or a short Hanuman mantra.', NULL, 0),
('lost', 6, 'chant', 'Hanuman Chalisa', 'When lost, Hanuman Chalisa offers courage and direction.', 'hanuman-chalisa', 0),
('joyful', 6, 'chant', 'Hanuman Chalisa', 'Offer joy with Hanuman Chalisa on Saturday.', 'hanuman-chalisa', 0),
('flow', 6, 'chant', 'Hanuman Chalisa', 'Full Hanuman Chalisa to honour Saturday’s energy.', 'hanuman-chalisa', 0),
('seeking', 6, 'chant', 'Hanuman Chalisa', 'Seek strength with Hanuman Chalisa today.', 'hanuman-chalisa', 0),
-- Sunday (7) - Surya
('calm', 7, 'mantra', 'Surya mantra', 'Surya mantra or 12 Surya Namaskar to greet the day with calm.', NULL, 0),
('inspired', 7, 'activity', 'Sun salutation', 'Channel inspiration into 3–6 rounds of Surya Namaskar or sun meditation.', NULL, 0),
('anxious', 7, 'walk', 'Morning walk', 'A short walk in sunlight with slow breathing to ease anxiety.', NULL, 0),
('healing', 7, 'meditation', 'Sun visualisation', 'Visualise gentle sunlight filling you with warmth and healing.', NULL, 0),
('lost', 7, 'activity', 'One step', 'Step outside. One small action—walk, mantra, or one line of prayer.', NULL, 0),
('joyful', 7, 'mantra', 'Surya mantra', 'Offer joy with Surya mantra or gratitude to the sun.', NULL, 0),
('flow', 7, 'activity', 'Surya Namaskar', 'Use flow for 12 rounds of Surya Namaskar or longer Surya mantra.', NULL, 0),
('seeking', 7, 'reading', 'Light and clarity', 'Read one verse on light or clarity. Set one intention for the week.', NULL, 0)
ON CONFLICT (feeling_id, weekday) DO NOTHING;
