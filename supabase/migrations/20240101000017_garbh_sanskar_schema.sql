-- ============================================================
-- GARBH SANSKAR FEATURE SCHEMA
-- Complete schema for pregnancy, postnatal, and newborn care
-- Covers: content library, user journey, milestones, lullabies
-- ============================================================

-- Enable UUID extension (if not already)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLE 1: garbh_sanskar_content
-- Master content library: mantras, meditations, yoga, rituals
-- ============================================================
CREATE TABLE IF NOT EXISTS garbh_sanskar_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Classification
  phase TEXT NOT NULL CHECK (phase IN ('prenatal', 'postnatal', 'newborn', 'all')),
  content_type TEXT NOT NULL CHECK (content_type IN (
    'mantra', 'meditation', 'yoga', 'pranayama',
    'diet_tip', 'ritual', 'story', 'affirmation', 'lullaby'
  )),
  
  -- Week targeting (NULL = applies to all weeks in phase)
  week_start INTEGER CHECK (week_start BETWEEN 1 AND 40),
  week_end   INTEGER CHECK (week_end   BETWEEN 1 AND 40),
  
  -- Trimester shortcut (1=weeks1-13, 2=weeks14-27, 3=weeks28-40)
  trimester INTEGER CHECK (trimester IN (1, 2, 3)),
  
  -- Content
  title TEXT NOT NULL,
  title_hindi TEXT,
  title_sanskrit TEXT,
  subtitle TEXT,
  description TEXT,
  body_text TEXT,          -- Full text / lyrics / instructions
  transliteration TEXT,    -- Roman transliteration for Sanskrit
  translation TEXT,        -- English meaning
  
  -- Media
  audio_storage_path TEXT,  -- Path in 'garbh-sanskar-audio' bucket
  video_url TEXT,
  image_url TEXT,
  duration_seconds INTEGER,
  
  -- Metadata
  deity_associated TEXT,
  benefits TEXT[],          -- e.g. ['calms baby', 'reduces anxiety', 'improves focus']
  tags TEXT[],
  
  -- Gamification
  coins_reward INTEGER DEFAULT 5,
  is_premium BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  order_index INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gs_content_phase ON garbh_sanskar_content(phase);
CREATE INDEX IF NOT EXISTS idx_gs_content_type ON garbh_sanskar_content(content_type);
CREATE INDEX IF NOT EXISTS idx_gs_content_week ON garbh_sanskar_content(week_start, week_end);
CREATE INDEX IF NOT EXISTS idx_gs_content_trimester ON garbh_sanskar_content(trimester);
CREATE INDEX IF NOT EXISTS idx_gs_content_active ON garbh_sanskar_content(is_active) WHERE is_active = true;

ALTER TABLE garbh_sanskar_content ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active garbh sanskar content"
  ON garbh_sanskar_content FOR SELECT USING (is_active = true);

-- ============================================================
-- TABLE 2: user_pregnancy_journey
-- One row per user — tracks their pregnancy/postnatal state
-- ============================================================
CREATE TABLE IF NOT EXISTS user_pregnancy_journey (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Pregnancy details
  due_date DATE,
  birth_date DATE,          -- Set after delivery; switches app to postnatal mode
  baby_name TEXT,
  baby_gender TEXT CHECK (baby_gender IN ('boy', 'girl', 'surprise')),
  
  -- Computed current week (1-40); NULL if not pregnant
  -- Updated by trigger or app logic
  current_week INTEGER CHECK (current_week BETWEEN 1 AND 42),
  
  -- Mode
  mode TEXT NOT NULL DEFAULT 'prenatal' CHECK (mode IN ('prenatal', 'postnatal', 'completed')),
  
  -- Personalisation
  mother_name TEXT,
  preferred_language TEXT DEFAULT 'hi',
  
  -- Stats
  total_sessions_completed INTEGER DEFAULT 0,
  total_minutes_listened INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id)
);

ALTER TABLE user_pregnancy_journey ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own journey" ON user_pregnancy_journey FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own journey" ON user_pregnancy_journey FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own journey" ON user_pregnancy_journey FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================
-- TABLE 3: user_gs_content_progress
-- Tracks which content items a user has completed
-- ============================================================
CREATE TABLE IF NOT EXISTS user_gs_content_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL REFERENCES garbh_sanskar_content(id) ON DELETE CASCADE,
  
  status TEXT NOT NULL DEFAULT 'started' CHECK (status IN ('started', 'completed')),
  completed_at TIMESTAMPTZ,
  listen_duration_seconds INTEGER DEFAULT 0,
  coins_earned INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, content_id)
);

ALTER TABLE user_gs_content_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own gs progress" ON user_gs_content_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own gs progress" ON user_gs_content_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own gs progress" ON user_gs_content_progress FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================
-- TABLE 4: baby_milestones
-- Tracks Samskaras and developmental milestones for the baby
-- ============================================================
CREATE TABLE IF NOT EXISTS baby_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  milestone_type TEXT NOT NULL CHECK (milestone_type IN (
    'jatakarma', 'namakarana', 'nishkramana', 'annaprashana',
    'chudakarana', 'karnavedha', 'vidyarambha',
    'first_smile', 'first_word', 'first_step',
    'first_laugh', 'head_control', 'sitting', 'crawling', 'custom'
  )),
  milestone_date DATE NOT NULL,
  baby_age_days INTEGER,   -- Age in days at milestone
  notes TEXT,
  photo_storage_path TEXT, -- Path in 'user-baby-photos' bucket
  coins_earned INTEGER DEFAULT 10,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE baby_milestones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own baby milestones" ON baby_milestones FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- TABLE 5: lullabies
-- Dedicated lullaby library (separate from general content)
-- ============================================================
CREATE TABLE IF NOT EXISTS lullabies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  title_hindi TEXT,
  language TEXT NOT NULL DEFAULT 'hi',
  deity_associated TEXT,
  lyrics TEXT,
  transliteration TEXT,
  translation TEXT,
  audio_storage_path TEXT NOT NULL,
  image_url TEXT,
  duration_seconds INTEGER,
  age_range_months_min INTEGER DEFAULT 0,
  age_range_months_max INTEGER DEFAULT 36,
  mood TEXT CHECK (mood IN ('calming', 'playful', 'devotional', 'bedtime')),
  is_active BOOLEAN DEFAULT true,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE lullabies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active lullabies" ON lullabies FOR SELECT USING (is_active = true);

-- ============================================================
-- TABLE 6: garbh_sanskar_samskaras
-- The 3 prenatal Samskaras with full ritual guides
-- ============================================================
CREATE TABLE IF NOT EXISTS garbh_sanskar_samskaras (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  name_sanskrit TEXT NOT NULL,
  timing TEXT NOT NULL,        -- e.g. 'Before conception', '3rd month of pregnancy'
  description TEXT NOT NULL,
  significance TEXT,
  ritual_steps JSONB NOT NULL, -- Array of {step, title, description, mantra, audio_path}
  required_items TEXT[],
  mantras TEXT[],
  image_url TEXT,
  order_index INTEGER NOT NULL
);

INSERT INTO garbh_sanskar_samskaras (id, name, name_sanskrit, timing, description, significance, ritual_steps, required_items, mantras, order_index) VALUES
(1, 'Garbhadhana', 'गर्भाधान', 'Before conception',
 'The conception ceremony. Parents pray together for a virtuous, healthy, and spiritually inclined child. This Samskara sanctifies the act of conception as a sacred duty (dharma) rather than mere physical union.',
 'Sets the spiritual intention for the child''s soul to enter. The quality of the parents'' thoughts and prayers at this moment is believed to influence the child''s nature.',
 '[{"step":1,"title":"Purification Bath","description":"Both parents take a purifying bath and wear clean, preferably white or yellow clothes.","mantra":"Om Apavitrah Pavitro Va"},{"step":2,"title":"Sankalpa (Intention)","description":"Sit facing east. The husband places his right hand on the wife''s head and both recite the Sankalpa mantra, stating their intention to bring a noble soul into the world.","mantra":"Om Tat Sat"},{"step":3,"title":"Pooja","description":"Offer flowers, incense, and a diya to Lord Vishnu and Goddess Lakshmi. Pray for their blessings."},{"step":4,"title":"Mantra Recitation","description":"Recite the Purusha Sukta (Rig Veda 10.90) together 3 times.","mantra":"Sahasrashirsha Purushah"},{"step":5,"title":"Prasad","description":"Share prasad of milk, honey, and ghee together."}]'::jsonb,
 ARRAY['Diya', 'Flowers', 'Incense', 'Milk', 'Honey', 'Ghee', 'Yellow cloth'],
 ARRAY['Purusha Sukta', 'Vishnu Sahasranama (selected verses)', 'Sankalpa Mantra'],
 1),

(2, 'Pumsavana', 'पुंसवन', '3rd month of pregnancy',
 'Performed in the 3rd month of pregnancy, this Samskara is done for the healthy development of the foetus — particularly to ensure the child is born with a sharp mind and strong body.',
 'The 3rd month is when the foetus''s brain begins to develop. This ceremony channels positive energy and divine blessings toward the child''s mental and physical development.',
 '[{"step":1,"title":"Preparation","description":"The mother wears new clothes and is adorned with flowers. A small Pooja space is prepared at home."},{"step":2,"title":"Invocation","description":"The husband invokes Lord Vishnu and Goddess Saraswati for the child''s intelligence and virtue.","mantra":"Om Namo Bhagavate Vasudevaya"},{"step":3,"title":"Nyagrodha Ceremony","description":"A few drops of juice from the Nyagrodha (banyan) tree are placed in the mother''s right nostril. This is a traditional Ayurvedic practice for foetal health."},{"step":4,"title":"Mantra Recitation","description":"The Pumsavana mantra from Atharva Veda is recited 108 times.","mantra":"Pumansam Patni Vishvavara"},{"step":5,"title":"Blessings","description":"Elders of the family bless the mother and the unborn child."}]'::jsonb,
 ARRAY['Nyagrodha (banyan) juice or paste', 'Flowers', 'Diya', 'New clothes for mother', 'Fruits'],
 ARRAY['Pumsavana Mantra (Atharva Veda)', 'Om Namo Bhagavate Vasudevaya', 'Saraswati Vandana'],
 2),

(3, 'Simantonnayana', 'सीमन्तोन्नयन', '7th month of pregnancy',
 'The hair-parting ceremony performed in the 7th month. The husband parts the wife''s hair upward (from front to back) three times, symbolising the protection of the mother and child from negative energies.',
 'The 7th month is when the baby''s senses are fully developing. This ceremony is a celebration of the mother''s journey and a community blessing for her wellbeing and safe delivery.',
 '[{"step":1,"title":"Gathering","description":"Family and close friends gather. The home is decorated with mango leaves and flowers."},{"step":2,"title":"Abhyanga (Oil Massage)","description":"The mother is given a gentle oil massage with sesame or coconut oil mixed with turmeric."},{"step":3,"title":"Hair Parting","description":"The husband parts the wife''s hair from front to back three times using a porcupine quill or a comb adorned with flowers, while reciting the Simantonnayan mantra.","mantra":"Bhur Bhuvah Svah"},{"step":4,"title":"Music & Stories","description":"Auspicious music is played and stories of great heroes and saints are told to the mother, so the child may absorb their qualities."},{"step":5,"title":"Community Blessing","description":"All women present bless the mother with turmeric, kumkum, and flowers. Gifts of fruits and sweets are exchanged."}]'::jsonb,
 ARRAY['Sesame or coconut oil', 'Turmeric', 'Kumkum', 'Flowers', 'Mango leaves', 'Porcupine quill or decorated comb', 'Fruits and sweets'],
 ARRAY['Simantonnayan Mantra', 'Gayatri Mantra', 'Devi Stuti'],
 3)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE garbh_sanskar_samskaras ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view garbh sanskar samskaras" ON garbh_sanskar_samskaras FOR SELECT USING (true);

-- ============================================================
-- TABLE 7: postnatal_samskaras
-- Birth and early childhood Samskaras (Jatakarma through Annaprashana)
-- ============================================================
CREATE TABLE IF NOT EXISTS postnatal_samskaras (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  name_sanskrit TEXT NOT NULL,
  timing TEXT NOT NULL,
  description TEXT NOT NULL,
  significance TEXT,
  ritual_steps JSONB NOT NULL,
  required_items TEXT[],
  mantras TEXT[],
  image_url TEXT,
  order_index INTEGER NOT NULL
);

INSERT INTO postnatal_samskaras (id, name, name_sanskrit, timing, description, significance, ritual_steps, required_items, mantras, order_index) VALUES
(4, 'Jatakarma', 'जातकर्म', 'Immediately after birth',
 'The birth ceremony. The father performs this ritual before the umbilical cord is cut. A small amount of honey and ghee (Medhajanan) is placed on the newborn''s tongue while the father whispers the Veda mantra into the baby''s right ear.',
 'This is the child''s first spiritual initiation. The honey represents sweetness of life; the ghee represents intelligence. The mantra whispered into the ear is the first sacred sound the child hears.',
 '[{"step":1,"title":"Medhajanan","description":"The father dips a golden ring or clean finger in a mixture of honey and ghee and places a tiny drop on the newborn''s tongue.","mantra":"Medham Te Deva Savita"},{"step":2,"title":"Whispering the Mantra","description":"The father gently whispers ''Om'' and then the Gayatri Mantra into the baby''s right ear three times.","mantra":"Om Bhur Bhuvah Svah"},{"step":3,"title":"Naming the Sun","description":"The father takes the baby outside (or to a window) and shows the baby the sun or sky, saying ''This is the Sun, the source of all life.''"},{"step":4,"title":"Secret Name","description":"The father whispers the child''s secret name (not the public name) into the baby''s ear. This name is known only to the parents."}]'::jsonb,
 ARRAY['Honey', 'Ghee', 'Gold ring (optional)', 'Clean cloth'],
 ARRAY['Gayatri Mantra', 'Medham Te Deva Savita', 'Om'],
 1),

(5, 'Namakarana', 'नामकरण', 'Day 11 or 12 after birth',
 'The naming ceremony. The baby is formally given their name in the presence of family, elders, and the divine. The name is whispered into the baby''s ear by the father, then announced to the family.',
 'In Hindu tradition, a name is not just a label — it is a mantra. The name chosen should reflect a divine quality, a deity, or a noble virtue, so that every time the child is called, they are reminded of their highest potential.',
 '[{"step":1,"title":"Purification","description":"The mother and baby are bathed and dressed in new clothes. The home is cleaned and decorated."},{"step":2,"title":"Pooja Setup","description":"A small Pooja is arranged with a diya, flowers, incense, and images of the family deity."},{"step":3,"title":"Horoscope Consultation","description":"The family priest or astrologer announces the auspicious syllable (akshar) based on the birth nakshatra. The name should begin with this syllable."},{"step":4,"title":"Name Announcement","description":"The father whispers the chosen name into the baby''s right ear three times, then announces it to the assembled family.","mantra":"Asya Shri Namakarana Karma"},{"step":5,"title":"Blessings","description":"Elders bless the child by name. Gifts are exchanged. A feast is shared."}]'::jsonb,
 ARRAY['New clothes for baby and mother', 'Diya', 'Flowers', 'Incense', 'Family deity image', 'Sweets for distribution'],
 ARRAY['Namakarana Mantra', 'Nakshatra Mantra for baby''s birth star', 'Kul Devata Mantra'],
 2),

(6, 'Nishkramana', 'निष्क्रमण', '4th month after birth',
 'The first outing ceremony. The baby is taken outside the home for the first time to see the sun and the world. This is performed in the 4th month.',
 'The baby has been protected inside the home for three months. This ceremony marks their first encounter with the wider world and the cosmic forces of nature — sun, wind, and earth.',
 '[{"step":1,"title":"Auspicious Timing","description":"Choose an auspicious day (preferably a Sunday for sun worship or the baby''s birth nakshatra day)."},{"step":2,"title":"Preparation","description":"Dress the baby in new clothes. Apply a small black dot (kajal) behind the ear to ward off the evil eye."},{"step":3,"title":"Sun Darshan","description":"The father carries the baby outside and faces east. He shows the baby the sun and recites the Surya mantra.","mantra":"Om Suryaya Namah"},{"step":4,"title":"Earth Touch","description":"The baby''s feet are gently touched to the earth for the first time."},{"step":5,"title":"Return & Blessings","description":"Return home. Elders bless the baby. A small Pooja is offered in gratitude."}]'::jsonb,
 ARRAY['New clothes for baby', 'Kajal', 'Flowers'],
 ARRAY['Surya Mantra', 'Prithvi Mantra', 'Vayu Mantra'],
 3),

(7, 'Annaprashana', 'अन्नप्राशन', '6th month after birth',
 'The first solid food ceremony. The baby is given their first taste of solid food — traditionally rice kheer (sweet rice pudding) — in a ceremonial setting.',
 'The transition from milk to solid food is a major developmental milestone. This ceremony marks the baby''s entry into the world of taste and nourishment, and is an occasion for family celebration.',
 '[{"step":1,"title":"Preparation","description":"Prepare sweet rice kheer (rice cooked in milk with sugar, saffron, and cardamom). This is the traditional first food."},{"step":2,"title":"Pooja","description":"Offer the kheer to the family deity first. Then place a small amount in a silver or gold spoon."},{"step":3,"title":"First Feeding","description":"The father or a respected elder feeds the baby the first spoonful of kheer while reciting the Annaprashana mantra.","mantra":"Annapate Annasya No Dehya"},{"step":4,"title":"Baby Choice","description":"The baby is placed before several objects (book, pen, soil, money, toy) to see which one they reach for first — a playful prediction of their future path."},{"step":5,"title":"Feast","description":"A family feast is held. The mother is given special nutritious foods."}]'::jsonb,
 ARRAY['Rice kheer', 'Silver or gold spoon', 'Family deity image', 'Diya', 'Flowers', 'Various objects for the ''choosing'' ritual'],
 ARRAY['Annaprashana Mantra', 'Annapurna Stuti', 'Om Namo Bhagavate Vasudevaya'],
 4)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE postnatal_samskaras ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view postnatal samskaras" ON postnatal_samskaras FOR SELECT USING (true);

-- ============================================================
-- TABLE 8: user_samskara_completions
-- Tracks which Samskaras a user has completed/logged
-- ============================================================
CREATE TABLE IF NOT EXISTS user_samskara_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  samskara_type TEXT NOT NULL CHECK (samskara_type IN ('prenatal', 'postnatal')),
  samskara_id INTEGER NOT NULL,
  completed_date DATE,
  notes TEXT,
  photo_storage_path TEXT,
  coins_earned INTEGER DEFAULT 25,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, samskara_type, samskara_id)
);

ALTER TABLE user_samskara_completions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own samskara completions" ON user_samskara_completions FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- TRIGGERS: auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_gs_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_gs_content_updated_at BEFORE UPDATE ON garbh_sanskar_content
  FOR EACH ROW EXECUTE FUNCTION update_gs_updated_at();

CREATE TRIGGER update_gs_journey_updated_at BEFORE UPDATE ON user_pregnancy_journey
  FOR EACH ROW EXECUTE FUNCTION update_gs_updated_at();

CREATE TRIGGER update_gs_progress_updated_at BEFORE UPDATE ON user_gs_content_progress
  FOR EACH ROW EXECUTE FUNCTION update_gs_updated_at();
