-- ============================================================
-- THREE NEW JOURNEYS
-- 1. Hanuman Chalisa 40-Day Challenge
-- 2. 21-Day Stress-Free Working Life
-- 3. Gayatri Sadhana 40-Day
--
-- All use the same generic schema built for Garbh Sanskar.
-- Safe to re-run (ON CONFLICT DO UPDATE / DO NOTHING throughout).
-- ============================================================

DO $$
DECLARE
  -- Journey type IDs (fixed so re-runs are idempotent)
  hc_id  UUID := 'a1b2c3d4-e5f6-7890-abcd-ef1234567801'; -- hanuman-chalisa-40
  wl_id  UUID := 'a1b2c3d4-e5f6-7890-abcd-ef1234567802'; -- work-stress-21
  gs_id  UUID := 'a1b2c3d4-e5f6-7890-abcd-ef1234567803'; -- gayatri-sadhana-40

  -- Hanuman Chalisa phases
  hc_ph_learn   UUID;
  hc_ph_build   UUID;
  hc_ph_deepen  UUID;
  hc_ph_complete UUID;

  -- Work-Life phases
  wl_ph_found   UUID;
  wl_ph_prac    UUID;
  wl_ph_integ   UUID;

  -- Gayatri phases
  gs_ph_init    UUID;
  gs_ph_disc    UUID;
  gs_ph_comp    UUID;

BEGIN

-- ═══════════════════════════════════════════════════════════════════════
-- JOURNEY TYPES
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO journey_types (
  id, slug, title, title_hindi, description, description_hindi,
  subtitle, subtitle_hindi, icon, color_primary,
  category, target_audience,
  is_premium, required_plan,
  setup_type, setup_schema, is_active, display_order
) VALUES

-- 1. Hanuman Chalisa 40-Day
(hc_id,
 'hanuman-chalisa-40',
 'Hanuman Chalisa 40-Day Challenge',
 'हनुमान चालीसा ४० दिन साधना',
 '40 consecutive days of Hanuman Chalisa recitation — one of the most transformative and widely recognised spiritual practices in the Hindu tradition. Build discipline, devotion, and an unshakeable inner calm.',
 '४० दिनों तक लगातार हनुमान चालीसा का पाठ — हिंदू परंपरा की सबसे प्रभावशाली और व्यापक साधनाओं में से एक। अनुशासन, भक्ति और अटूट आंतरिक शांति का निर्माण करें।',
 '40 days of devotion, discipline & inner strength',
 '४० दिन — भक्ति, अनुशासन और आंतरिक शक्ति',
 '🚩', '#FF6B35',
 'devotion', 'all',
 true, 'pro',
 'day_based',
 '[{"type":"single_select","key":"experience","label":"Your experience with Hanuman Chalisa",
    "options":[
      {"value":"beginner","label":"I am new to it"},
      {"value":"familiar","label":"I know it partially"},
      {"value":"daily","label":"I already recite it daily"}
    ]}
 ]'::jsonb,
 true, 2),

-- 2. 21-Day Stress-Free Working Life
(wl_id,
 'work-stress-21',
 '21-Day Stress-Free Working Life',
 '२१ दिन तनावमुक्त कार्यजीवन',
 'Ancient Vedic tools applied to modern workplace stress — pranayama at your desk, Karma Yoga philosophy for deadlines, and evening rituals that genuinely switch off the mind. Designed for busy professionals.',
 'आधुनिक कार्यस्थल के तनाव के लिए प्राचीन वैदिक उपकरण — डेस्क पर प्राणायाम, समयसीमा के लिए कर्मयोग दर्शन, और शाम की ऐसी दिनचर्या जो मन को सच में बंद कर दे।',
 'Ancient tools for modern burnout',
 'आधुनिक थकान के लिए प्राचीन समाधान',
 '🧘', '#6366F1',
 'wellness', 'working_professionals',
 true, 'pro',
 'day_based',
 '[{"type":"single_select","key":"stress_level","label":"How stressed are you right now?",
    "options":[
      {"value":"mild","label":"Mildly — I want to maintain balance"},
      {"value":"moderate","label":"Moderately — some days are hard"},
      {"value":"high","label":"Very — I feel burnout approaching"}
    ]}
 ]'::jsonb,
 true, 3),

-- 3. Gayatri Sadhana 40-Day
(gs_id,
 'gayatri-sadhana-40',
 'Gayatri Sadhana — 40 Days',
 'गायत्री साधना — ४० दिन',
 'The Gayatri Mantra is the most sacred mantra in the Vedic tradition — a prayer to the divine intelligence of the Sun to illuminate our minds. 40 days of sunrise recitation transforms the practitioner at a cellular level.',
 'गायत्री मंत्र वैदिक परंपरा का सबसे पवित्र मंत्र है — सूर्य की दिव्य बुद्धि से हमारे मन को प्रकाशित करने की प्रार्थना। ४० दिन सूर्योदय पर जप साधक को कोशिकीय स्तर पर रूपांतरित करता है।',
 '40 days of sunrise mantra — illuminate your mind',
 'सूर्योदय पर ४० दिन मंत्र जप — मन को प्रकाशित करें',
 '🌅', '#F59E0B',
 'mantra', 'all',
 true, 'pro',
 'day_based',
 '[{"type":"single_select","key":"experience","label":"Have you chanted Gayatri Mantra before?",
    "options":[
      {"value":"never","label":"Never — teach me"},
      {"value":"sometimes","label":"Occasionally"},
      {"value":"regular","label":"I chant it regularly already"}
    ]}
 ]'::jsonb,
 true, 4)

ON CONFLICT (slug) DO UPDATE SET
  title             = EXCLUDED.title,
  title_hindi       = EXCLUDED.title_hindi,
  description       = EXCLUDED.description,
  subtitle          = EXCLUDED.subtitle,
  subtitle_hindi    = EXCLUDED.subtitle_hindi,
  is_premium        = EXCLUDED.is_premium,
  display_order     = EXCLUDED.display_order,
  setup_schema      = EXCLUDED.setup_schema,
  updated_at        = NOW();


-- ═══════════════════════════════════════════════════════════════════════
-- ENSURE CONSTRAINTS EXIST (idempotent — must run before any inserts)
-- ═══════════════════════════════════════════════════════════════════════

-- journey_phases: UNIQUE(journey_type_id, slug)
IF NOT EXISTS (
  SELECT 1 FROM pg_constraint
  WHERE conrelid = 'journey_phases'::regclass AND contype = 'u'
    AND conname = 'journey_phases_journey_type_id_slug_key'
) THEN
  ALTER TABLE journey_phases ADD CONSTRAINT journey_phases_journey_type_id_slug_key UNIQUE (journey_type_id, slug);
END IF;

-- journey_tasks: UNIQUE(phase_id, slug)
IF NOT EXISTS (
  SELECT 1 FROM pg_constraint
  WHERE conrelid = 'journey_tasks'::regclass AND contype = 'u'
    AND conname = 'journey_tasks_phase_id_slug_key'
) THEN
  ALTER TABLE journey_tasks ADD CONSTRAINT journey_tasks_phase_id_slug_key UNIQUE (phase_id, slug);
END IF;

-- journey_content_pool: UNIQUE(journey_type_id, task_slug, slug)
IF NOT EXISTS (
  SELECT 1 FROM pg_constraint
  WHERE conrelid = 'journey_content_pool'::regclass AND contype = 'u'
    AND conname = 'journey_content_pool_journey_type_id_task_slug_slug_key'
) THEN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'journey_content_pool' AND column_name = 'slug'
  ) THEN
    ALTER TABLE journey_content_pool
      ADD CONSTRAINT journey_content_pool_journey_type_id_task_slug_slug_key
      UNIQUE (journey_type_id, task_slug, slug);
  END IF;
END IF;

-- journey_milestones: UNIQUE(journey_type_id, slug)
IF NOT EXISTS (
  SELECT 1 FROM pg_constraint
  WHERE conrelid = 'journey_milestones'::regclass AND contype = 'u'
    AND conname = 'journey_milestones_journey_type_id_slug_key'
) THEN
  ALTER TABLE journey_milestones
    ADD CONSTRAINT journey_milestones_journey_type_id_slug_key UNIQUE (journey_type_id, slug);
END IF;

-- ═══════════════════════════════════════════════════════════════════════
-- RE-FETCH IDs (in case rows existed before with different UUIDs)
-- ═══════════════════════════════════════════════════════════════════════

SELECT id INTO hc_id FROM journey_types WHERE slug = 'hanuman-chalisa-40';
SELECT id INTO wl_id FROM journey_types WHERE slug = 'work-stress-21';
SELECT id INTO gs_id FROM journey_types WHERE slug = 'gayatri-sadhana-40';

-- ═══════════════════════════════════════════════════════════════════════
-- ① HANUMAN CHALISA 40-DAY — PHASES
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO journey_phases (journey_type_id, slug, title, title_hindi, description, phase_order, trigger_type, trigger_value, duration_label, icon, color_hex)
VALUES
(hc_id, 'hc_learning',  'Learning',    'अभ्यास',      'Days 1–7: Learn each chaupai, pronunciation and meaning.',          1, 'immediate',  NULL,                              'Days 1–7',  '📖', '#FCD34D'),
(hc_id, 'hc_building',  'Building',    'निर्माण',     'Days 8–21: Daily full recitation, Tuesday special practices.',       2, 'day_offset', '{"days": 7}'::jsonb,              'Days 8–21', '🔥', '#F97316'),
(hc_id, 'hc_deepening', 'Deepening',   'गहराई',       'Days 22–33: Understanding the science and bhakti behind each verse.',3, 'day_offset', '{"days": 21}'::jsonb,             'Days 22–33','🪔', '#EF4444'),
(hc_id, 'hc_complete',  'Sampurna',    'सम्पूर्ण',   'Days 34–40: Completion sadhana — recite, reflect, celebrate.',      4, 'day_offset', '{"days": 33}'::jsonb,             'Days 34–40','🚩', '#DC2626')
ON CONFLICT (journey_type_id, slug) DO UPDATE SET
  title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
  phase_order = EXCLUDED.phase_order, trigger_value = EXCLUDED.trigger_value,
  duration_label = EXCLUDED.duration_label, icon = EXCLUDED.icon, color_hex = EXCLUDED.color_hex;

SELECT id INTO hc_ph_learn    FROM journey_phases WHERE journey_type_id = hc_id AND slug = 'hc_learning';
SELECT id INTO hc_ph_build    FROM journey_phases WHERE journey_type_id = hc_id AND slug = 'hc_building';
SELECT id INTO hc_ph_deepen   FROM journey_phases WHERE journey_type_id = hc_id AND slug = 'hc_deepening';
SELECT id INTO hc_ph_complete FROM journey_phases WHERE journey_type_id = hc_id AND slug = 'hc_complete';


-- ─── Hanuman Chalisa — Tasks ──────────────────────────────────────────

INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, description, task_type, frequency, duration_minutes, mantra_count, display_order, icon, coin_reward, is_premium)
VALUES
-- Learning phase
(hc_ph_learn, 'hc_listen_full',   'Listen to Full Hanuman Chalisa',  'हनुमान चालीसा सुनें',    'Listen to the complete Hanuman Chalisa once to familiarise yourself with the melody and pace before you begin chanting.',  'ritual',     'daily', 10, NULL, 1, '🎧', 5, true),
(hc_ph_learn, 'hc_learn_chaupai', 'Learn 2 Chaupais Per Day',        'प्रतिदिन २ चौपाई सीखें', 'Read, understand and memorise 2 chaupais. The Chalisa has 40 chaupais — at 2 per day you will know the full text in 20 days.', 'read',       'daily', 15, NULL, 2, '📖', 5, true),
(hc_ph_learn, 'hc_morning_chant', 'Morning Chant (Partial)',          'प्रातः जप (आंशिक)',       'Chant the portions you have learnt so far at sunrise. Even 2 chaupais count today.',                                        'mantra',     'daily', 10, NULL, 3, '🌅', 3, true),

-- Building phase
(hc_ph_build, 'hc_full_chant',    'Full Hanuman Chalisa Recitation', 'पूर्ण हनुमान चालीसा जप', 'Recite the complete Hanuman Chalisa from start to finish — Doha, 40 Chaupais, closing Doha. Do not rush.',                   'mantra',     'daily', 15, NULL, 1, '🙏', 8, true),
(hc_ph_build, 'hc_tuesday_fast',  'Tuesday Discipline',              'मंगलवार व्रत',            'On Tuesdays: wake before sunrise, take a bath, offer sindoor to Hanuman ji, complete the Chalisa recitation, eat simple food.', 'ritual',     'weekly',30, NULL, 2, '🚩', 10, true),
(hc_ph_build, 'hc_108_chant',     'Optional: 108 Names of Hanuman',  'हनुमान १०८ नाम जप',      'After the Chalisa, chant the 108 names of Hanuman ji on a mala. Adds 10–15 minutes to your practice.',                       'mantra',     'daily', 15, 108, 3, '📿', 5, true),

-- Deepening phase
(hc_ph_deepen, 'hc_meaning',      'Understand Today''s Chaupai',     'चौपाई का अर्थ जानें',    'Read the meaning of 2–3 chaupais and reflect on how they apply to your life today.',                                         'read',       'daily', 10, NULL, 1, '💡', 5, true),
(hc_ph_deepen, 'hc_full_deep',    'Full Recitation with Bhava',      'भाव सहित पूर्ण पाठ',     'Chant the full Chalisa slowly, word by word, feeling the meaning behind each line rather than rushing through.',               'mantra',     'daily', 20, NULL, 2, '🪔', 8, true),
(hc_ph_deepen, 'hc_journaling',   'Devotion Journal',                'भक्ति डायरी',             'After recitation, write 3–5 sentences: What did I feel today? Which line struck me most? What am I surrendering to Hanuman ji?','ritual',     'daily', 10, NULL, 3, '✍️', 5, true),

-- Sampurna phase
(hc_ph_complete, 'hc_sampurna',   'Sampurna Paath — Full Recitation','सम्पूर्ण पाठ',            'Complete the Hanuman Chalisa with full attention, love and gratitude. You have earned this.',                                  'mantra',     'daily', 15, NULL, 1, '🚩', 10, true),
(hc_ph_complete, 'hc_gratitude',  'Gratitude Offering',              'कृतज्ञता अर्पण',         'Offer something to Hanuman ji today — a flower, a sindoor tilak, a diya. Speak your gratitude aloud.',                       'ritual',     'daily', 10, NULL, 2, '🌺', 8, true)
ON CONFLICT (phase_id, slug) DO NOTHING;


-- ─── Hanuman Chalisa — Content Pool (one INSERT per row to prevent length mismatch) ──

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'hc_full_chant', 'hc_full_chalisa_v1', 'mantra', 'Hanuman Chalisa — Complete Text', 'हनुमान चालीसा — सम्पूर्ण पाठ', E'॥ दोहा ॥\nश्रीगुरु चरन सरोज रज, निज मनु मुकुरु सुधारि।\nबरनउँ रघुबर बिमल जसु, जो दायकु फल चारि॥\nबुद्धिहीन तनु जानिके, सुमिरौं पवन-कुमार।\nबल बुधि बिद्या देहु मोहिं, हरहु कलेस बिकार॥\n\n॥ चौपाई ॥\nजय हनुमान ज्ञान गुन सागर।\nजय कपीस तिहुँ लोक उजागर॥\nराम दूत अतुलित बल धामा।\nअंजनि-पुत्र पवन-सुत नामा॥\nमहाबीर बिक्रम बजरंगी।\nकुमति निवार सुमति के संगी॥\nकंचन बरन बिराज सुबेसा।\nकानन कुंडल कुंचित केसा॥\nहाथ बज्र औ ध्वजा बिराजै।\nकाँधे मूँज जनेउ साजै॥\nशंकर सुवन केसरी नंदन।\nतेज प्रताप महा जग वंदन॥\nबिद्यावान गुनी अति चातुर।\nराम काज करिबे को आतुर॥\nप्रभु चरित्र सुनिबे को रसिया।\nराम लखन सीता मन बसिया॥\nसूक्ष्म रूप धरि सियहिं दिखावा।\nबिकट रूप धरि लंक जरावा॥\nभीम रूप धरि असुर संहारे।\nरामचंद्र के काज सँवारे॥\nलाय सजीवन लखन जियाए।\nश्रीरघुबीर हरषि उर लाए॥\nरघुपति कीन्ही बहुत बड़ाई।\nतुम मम प्रिय भरतहि सम भाई॥\nसहस बदन तुम्हरो जस गावैं।\nअस कहि श्रीपति कंठ लगावैं॥\nसनकादिक ब्रह्मादि मुनीसा।\nनारद सारद सहित अहीसा॥\nजम कुबेर दिगपाल जहाँ ते।\nकबि कोबिद कहि सके कहाँ ते॥\nतुम उपकार सुग्रीवहिं कीन्हा।\nराम मिलाय राज-पद दीन्हा॥\nतुम्हरो मंत्र बिभीषन माना।\nलंकेश्वर भए सब जग जाना॥\nजुग सहस्त्र जोजन पर भानू।\nलील्यो ताहि मधुर फल जानू॥\nप्रभु मुद्रिका मेलि मुख माहीं।\nजलधि लाँघि गये अचरज नाहीं॥\nदुर्गम काज जगत के जेते।\nसुगम अनुग्रह तुम्हरे तेते॥\nराम दुआरे तुम रखवारे।\nहोत न आज्ञा बिनु पैसारे॥\nसब सुख लहै तुम्हारी सरना।\nतुम रच्छक काहू को डर ना॥\nआपन तेज सम्हारो आपै।\nतीनों लोक हाँक ते काँपै॥\nभूत पिसाच निकट नहिं आवै।\nमहाबीर जब नाम सुनावै॥\nनासै रोग हरै सब पीरा।\nजपत निरंतर हनुमत बीरा॥\nसंकट से हनुमान छुड़ावै।\nमन क्रम बचन ध्यान जो लावै॥\nसब पर राम तपस्वी राजा।\nतिन के काज सकल तुम साजा॥\nऔर मनोरथ जो कोई लावै।\nसोइ अमित जीवन फल पावै॥\nचारों जुग परताप तुम्हारा।\nहै परसिद्ध जगत उजियारा॥\nसाधु-संत के तुम रखवारे।\nअसुर निकंदन राम दुलारे॥\nअष्ट सिद्धि नौ निधि के दाता।\nअस बर दीन जानकी माता॥\nराम रसायन तुम्हरे पासा।\nसदा रहो रघुपति के दासा॥\nतुम्हरे भजन राम को पावै।\nजनम जनम के दुख बिसरावै॥\nअंत काल रघुबर पुर जाई।\nजहाँ जन्म हरि-भक्त कहाई॥\nऔर देवता चित्त न धरई।\nहनुमत सेई सर्ब सुख करई॥\nसंकट कटै मिटै सब पीरा।\nजो सुमिरै हनुमत बलबीरा॥\nजय जय जय हनुमान गोसाईं।\nकृपा करहु गुरुदेव की नाईं॥\nजो सत बार पाठ कर कोई।\nछूटहि बंदि महा सुख होई॥\nजो यह पढ़ै हनुमान चालीसा।\nहोय सिद्धि साखी गौरीसा॥\nतुलसीदास सदा हरि चेरा।\nकीजै नाथ हृदय महँ डेरा॥\n\n॥ दोहा ॥\nपवन तनय संकट हरण, मंगल मूरति रूप।\nराम लखन सीता सहित, हृदय बसहु सुर भूप॥', NULL, E'|| Doha ||\nShri Guru Charan Saroj Raj, Nij Manu Mukuru Sudhari.\nBarnaun Raghubar Bimal Jasu, Jo Dayaku Phal Chari.\nBuddhihin Tanu Janike, Sumiroun Pawan Kumar.\nBal Budhi Bidya Dehu Mohin, Harahu Kales Bikar.\n\n|| Chaupai ||\nJay Hanuman Gyan Gun Sagar. Jay Kapis Tihun Lok Ujagar...', E'Glory to Hanuman, ocean of wisdom and virtue — illuminator of all three worlds.', '["Recitation of Hanuman Chalisa builds courage and dispels fear", "Regular practice strengthens focus and mental clarity", "Creates a powerful protective spiritual field around the practitioner", "Builds devotion (bhakti) — the most direct path to inner peace", "Tulsidas composed this in the 16th century; it has been recited billions of times since"]'::jsonb, E'HOW TO RECITE:\n1. Take a bath or wash your hands and face.\n2. Sit facing East or South (Hanuman''s direction).\n3. Light a diya or incense if available.\n4. Take 3 deep breaths. Set an intention.\n5. Recite the opening Doha slowly.\n6. Move through each Chaupai without rushing.\n7. Finish with the closing Doha.\n8. Sit in silence for 2 minutes after completion.\n\nBeginner tip: If you cannot recite from memory, read from the screen. The devotion matters more than perfection.', E'कैसे पाठ करें:\n1. स्नान करें या हाथ-मुँह धोएं।\n2. पूर्व या दक्षिण दिशा की ओर मुख करके बैठें।\n3. दीपक या अगरबत्ती जलाएं।\n4. तीन गहरी सांसें लें, संकल्प करें।\n5. प्रारंभिक दोहा धीरे-धीरे पढ़ें।\n6. हर चौपाई बिना जल्दबाजी के बोलें।\n7. अंतिम दोहे के साथ समाप्त करें।\n8. पाठ के बाद 2 मिनट मौन में बैठें।', 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'hc_learn_chaupai', 'hc_chaupai_meaning_v1', 'read', 'Understanding the Hanuman Chalisa', 'हनुमान चालीसा का अर्थ', E'THE STRUCTURE:\nThe Hanuman Chalisa ("forty verses of Hanuman") was composed by Goswami Tulsidas in the 16th century in Awadhi Hindi. It consists of:\n• 2 opening Dohas (couplets) — invocation and humility\n• 40 Chaupais (quatrains) — the body of the prayer\n• 1 closing Doha — the final blessing\n\nKEY CHAUPAIS AND THEIR MEANING:\n\n"जय हनुमान ज्ञान गुन सागर" — Victory to Hanuman, ocean of wisdom and virtue. Hanuman is not worshipped for material power but for wisdom, virtue, and selfless service.\n\n"बुद्धिहीन तनु जानिके, सुमिरौं पवन-कुमार" — Knowing my intellect is weak, I remember the son of the Wind.\n\n"जुग सहस्त्र जोजन पर भानू, लील्यो ताहि मधुर फल जानू" — As a child, Hanuman leapt 96 million miles toward the Sun thinking it was a sweet fruit. A metaphor for fearless aspiration.\n\n"नासै रोग हरै सब पीरा, जपत निरंतर हनुमत बीरा" — All disease is destroyed, all pain is removed, for one who continuously chants Hanuman''s name.', NULL, NULL, NULL, '["Each of the 40 chaupais encodes a teaching about Hanuman''s qualities: courage, devotion, strength, humility, service", "Understanding the meaning transforms mechanical recitation into conscious prayer", "Tulsidas himself recited the Chalisa during the plague of Kashi — it is a text forged in genuine crisis", "The Awadhi language was the common tongue of the people — this prayer was intentionally accessible to all", "Memory of the Chalisa is itself a form of japa — the text lives in the body"]'::jsonb, E'Today''s Practice:\n1. Read the Chaupai aloud in Hindi.\n2. Read the transliteration.\n3. Read the meaning slowly.\n4. Close your eyes and reflect: "What does this line mean for my life today?"\n5. Write one sentence in your journal about it.\n6. Tomorrow, add the next 2 chaupais.', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'hc_journaling', 'hc_journal_1', 'ritual', 'Day''s Reflection: Surrender', NULL, E'Today''s journaling prompt:\n\n"What am I holding onto that I need to give to Hanuman ji today?"\n\nWrite for 5–7 minutes without stopping. Begin with the words: "Today I surrender..."\n\nHanuman is the embodiment of complete surrender to Ram — not passive surrender, but the surrender of a warrior. He did not give up his power. He gave it fully to a purpose larger than himself.', NULL, NULL, NULL, '["Journaling after recitation deepens the integration of the mantra''s vibration", "Writing about surrender helps identify attachment — the root of most stress", "This practice bridges devotion and psychology", "Creates a record of your 40-day inner journey"]'::jsonb, E'1. Sit with your journal immediately after recitation.\n2. Write the date and which day of your 40-day journey you are on.\n3. Begin: "Today I surrender..."\n4. Write for 5–7 minutes without lifting your pen.\n5. End with: "Jai Shri Ram."', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'hc_journaling', 'hc_journal_2', 'ritual', 'Day''s Reflection: Courage', NULL, E'Today''s journaling prompt:\n\n"Where in my life do I need the courage of Hanuman?"\n\nHanuman leapt across the ocean alone, into enemy territory, with no guarantee of success — only the certainty of his devotion. He is the patron deity of every person facing an impossible task.\n\nWrite about what feels impossible right now. Then write about what you would do if you had Hanuman''s certainty.', NULL, NULL, NULL, '["Identifying where we need courage is the first step toward finding it", "Hanuman''s mythology is a practical guide for facing fear", "Writing the impossible makes it less impossibly large"]'::jsonb, E'1. Sit quietly after recitation.\n2. Re-read Chaupai 2: "Mahavir Vikram Bajrangi" — Great Hero, mighty one with the strength of a thunderbolt.\n3. Begin writing: "The impossible thing in my life right now is..."\n4. Then write: "If I had Hanuman''s certainty, I would..."', NULL, 2, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'wisdom', 'wisdom_hc_1', 'wisdom', 'On Devotion as Strength', NULL, E'Hanuman is the strongest being in the Ramayana — and the most devoted. In the Vedic vision, strength and devotion are not opposites. Bhakti does not make you weak. It removes the one thing that truly weakens you: the ego that insists it must do everything alone.', NULL, NULL, NULL, NULL, NULL, NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'wisdom', 'wisdom_hc_2', 'wisdom', 'On Consistency', NULL, E'Tulsidas composed the Hanuman Chalisa while in chains, in prison, in the middle of a plague. The practice does not require ideal conditions. It requires only your presence. Begin where you are. The 40 days are not about perfection — they are about showing up.', NULL, NULL, NULL, NULL, NULL, NULL, 2, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'wisdom', 'wisdom_hc_3', 'wisdom', 'On the Power of Name', NULL, E'In the Chalisa, Tulsidas writes that Hanuman''s name alone — not his form, not his image, but his name — is enough to destroy all obstacles. This is the science of mantra: sound is not decoration. Sound is substance. When you chant, you are not describing power. You are generating it.', NULL, NULL, NULL, NULL, NULL, NULL, 3, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'wisdom', 'wisdom_hc_4', 'wisdom', 'On Tuesday', NULL, E'Tuesday (Mangalvar) is Hanuman''s day. Mars (Mangal) rules courage, action and the will to overcome obstacles. When you fast or simplify your food on a Tuesday, you are aligning your body with the energy of that day. The fast is not punishment — it is a choice to prioritise something over comfort.', NULL, NULL, NULL, NULL, NULL, NULL, 4, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(hc_id, 'wisdom', 'wisdom_hc_5', 'wisdom', 'On Completion', NULL, E'"Jo sat bār pāth kar koī, chūṭahi bandi mahā sukh hoī" — Whoever recites this 100 times, all bondage is released and great joy arises. You are on a 40-day journey. Every single day counts as one more lap around the mountain. Keep going.', NULL, NULL, NULL, NULL, NULL, NULL, 5, 'sequential')
ON CONFLICT DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════════
-- Hanuman Chalisa — Milestones
-- ═══════════════════════════════════════════════════════════════════════

-- Ensure unique constraint exists before ON CONFLICT
IF NOT EXISTS (
  SELECT 1 FROM pg_constraint
  WHERE conrelid = 'journey_milestones'::regclass AND contype = 'u'
    AND conname = 'journey_milestones_journey_type_id_slug_key'
) THEN
  ALTER TABLE journey_milestones
    ADD CONSTRAINT journey_milestones_journey_type_id_slug_key UNIQUE (journey_type_id, slug);
END IF;

INSERT INTO journey_milestones (journey_type_id, phase_id, slug, title, title_hindi, description, milestone_type, milestone_order, icon, allow_photo, allow_notes, is_required, coin_reward)
VALUES
(hc_id, hc_ph_learn, 'hc_first_recitation', 'First Complete Recitation', 'प्रथम सम्पूर्ण पाठ',
 E'You have recited the Hanuman Chalisa from beginning to end for the first time. This is no small thing. Tulsidas wrote this to be accessible to everyone — and today you proved that it is accessible to you.\n\nMark this moment. Light a diya. Offer a flower. Say thank you.',
 'samskara', 1, '🎉', true, true, true, 25),
(hc_id, hc_ph_build, 'hc_7day', '7-Day Streak', '७ दिन की साधना',
 E'Seven consecutive days. In Vedic tradition, 7 days completes one rhythmic cycle of energy (the 7 days of the week correspond to the 7 planets and 7 chakras). You have completed your first full energy cycle of this sadhana.',
 'samskara', 2, '🔥', false, true, true, 25),
(hc_id, hc_ph_build, 'hc_21day', '21-Day Milestone', '२१ दिन',
 E'21 days. Neuroscience confirms that 21 days of consistent practice begins to rewire neural pathways. Vedic tradition says 21 days creates a samskara — an impression that becomes part of your nature. You are no longer just reciting a prayer. You are becoming a devotee.',
 'samskara', 3, '🌟', false, true, true, 50),
(hc_id, hc_ph_complete, 'hc_40day_sampurna', 'Sampurna — 40 Days Complete!', 'सम्पूर्ण साधना',
 E'40 days. This is what Tulsidas promised: "Jo yah padhe Hanuman Chalisa — Hoy Siddhi Sakhi Gaurisa." Whoever reads the Hanuman Chalisa — Shiva himself is the witness to their attainment.\n\nYou have done it. 40 days, one day at a time. Hanuman ji is watching.',
 'samskara', 4, '🚩', true, true, true, 100)
ON CONFLICT (journey_type_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description,
  coin_reward = EXCLUDED.coin_reward, updated_at = NOW();


-- ═══════════════════════════════════════════════════════════════════════
-- ② 21-DAY STRESS-FREE WORKING LIFE — PHASES
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO journey_phases (journey_type_id, slug, title, title_hindi, description, phase_order, trigger_type, trigger_value, duration_label, icon, color_hex)
VALUES
(wl_id, 'wl_foundation',   'Foundation',  'नींव',       'Week 1: Build the morning and evening pillars of a stress-resistant day.', 1, 'immediate', NULL,                 'Week 1', '🌱', '#6EE7B7'),
(wl_id, 'wl_practice',     'Practice',    'अभ्यास',     'Week 2: Apply Karma Yoga principles directly to your work.',              2, 'day_offset', '{"days": 7}'::jsonb, 'Week 2', '⚡', '#A5B4FC'),
(wl_id, 'wl_integration',  'Integration', 'एकीकरण',    'Week 3: Integrate — make these tools permanent habits.',                  3, 'day_offset', '{"days": 14}'::jsonb,'Week 3', '🌊', '#67E8F9')
ON CONFLICT (journey_type_id, slug) DO UPDATE SET
  title = EXCLUDED.title, phase_order = EXCLUDED.phase_order,
  trigger_value = EXCLUDED.trigger_value, duration_label = EXCLUDED.duration_label,
  icon = EXCLUDED.icon, color_hex = EXCLUDED.color_hex;

SELECT id INTO wl_ph_found FROM journey_phases WHERE journey_type_id = wl_id AND slug = 'wl_foundation';
SELECT id INTO wl_ph_prac  FROM journey_phases WHERE journey_type_id = wl_id AND slug = 'wl_practice';
SELECT id INTO wl_ph_integ FROM journey_phases WHERE journey_type_id = wl_id AND slug = 'wl_integration';


-- ─── Work-Life — Tasks ────────────────────────────────────────────────

INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, description, task_type, frequency, duration_minutes, mantra_count, display_order, icon, coin_reward, is_premium)
VALUES
-- Foundation
(wl_ph_found, 'wl_morning_breath', 'Morning Desk Pranayama',        'प्रातः प्राणायाम',        'Before opening your laptop: 5 minutes of Nadi Shodhana (alternate nostril breathing) at your desk. No props required.',            'yoga',   'daily', 5,  NULL, 1, '🌬️', 5, true),
(wl_ph_found, 'wl_intention',      'Daily Work Intention',           'दिन का संकल्प',           'Set one clear, dharmic intention for the day: "Today I will give my best to ___." Write it. Pin it to your screen.',               'ritual', 'daily', 5,  NULL, 2, '🎯', 3, true),
(wl_ph_found, 'wl_evening_detox',  'Evening Digital Detox Ritual',   'संध्या डिजिटल व्रत',      'At the end of your workday: close all screens, take 3 deep breaths, and mentally say "My work is done. I am at peace."',           'ritual', 'daily', 5,  NULL, 3, '🌙', 5, true),

-- Practice
(wl_ph_prac, 'wl_karma_yoga',     'Karma Yoga Reading (BG 3.19)',   'कर्मयोग अध्ययन',          'Read and reflect on one verse from Bhagavad Gita Chapter 3 (Karma Yoga) and write how it applies to today''s work.',                'read',   'daily', 10, NULL, 1, '📖', 5, true),
(wl_ph_prac, 'wl_desk_stretch',   '5-Min Desk Yoga Break',          'डेस्क योग विराम',          'Mid-afternoon: neck rolls, shoulder shrugs, seated cat-cow, and 10 deep breaths. Set a timer.',                                   'yoga',   'daily', 5,  NULL, 2, '🧘', 3, true),
(wl_ph_prac, 'wl_shanti_mantra',  'Pre-Meeting Shanti Mantra',      'बैठक से पूर्व शांति मंत्र', 'Before any important meeting or call: close your eyes for 60 seconds and silently chant "Om Shanti" 7 times.',                    'mantra', 'daily', 5,  21, 3, '🕉️', 5, true),

-- Integration
(wl_ph_integ, 'wl_full_morning', 'Full Morning Ritual (15 min)',     'पूर्ण प्रातः दिनचर्या',    'Pranayama + intention + 1 Gita verse = your permanent morning system. 15 minutes total.',                                          'ritual', 'daily', 15, NULL, 1, '🌅', 8, true),
(wl_ph_integ, 'wl_gratitude',    'Work Gratitude Practice',          'कार्य कृतज्ञता',           'End of day: name 3 things that went right at work today, however small.',                                                        'ritual', 'daily', 5,  NULL, 2, '🙏', 5, true),
(wl_ph_integ, 'wl_review',       'Weekly Review (Svadhyaya)',        'साप्ताहिक समीक्षा',        'Every Sunday: review the week. What worked? What drained you? What would Karma Yoga say about next week?',                       'ritual', 'weekly',20, NULL, 3, '📋', 10, true)
ON CONFLICT (phase_id, slug) DO NOTHING;


-- ─── Work-Life — Content Pool (one INSERT per row) ────────────────────

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wl_morning_breath', 'wl_nadi_shodhana_v1', 'yoga', 'Nadi Shodhana at Your Desk', 'डेस्क पर नाड़ी शोधन', E'The most powerful 5-minute tool for a working professional. Nadi Shodhana balances the left brain (analytical/language) with the right brain (creative/intuitive) in a way that no coffee or meeting prep can match.', NULL, NULL, NULL, '["Reduces cortisol (stress hormone) within 3 minutes of practice", "Improves decision-making by balancing left/right hemispheres", "Zero equipment, zero props — only your hands and breath", "Can be done invisibly at a desk before a difficult call", "Cumulative: daily practice rewires the stress response over 21 days"]'::jsonb, E'You do not need to leave your chair.\n\n1. Sit upright. Drop your shoulders.\n2. Bring your right hand to your nose.\n3. Close your right nostril with your thumb. Inhale through the LEFT for 4 counts.\n4. Close both nostrils briefly (1 count).\n5. Open the right nostril. Exhale for 4 counts.\n6. Inhale through the RIGHT for 4 counts.\n7. Close both briefly. Open left. Exhale 4 counts.\n8. This is one round. Do 9 rounds. Time: ~4 minutes.\n\nDo this BEFORE opening email, Slack, or any screen. It will change your morning.', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wl_karma_yoga', 'wl_bg_3_19_v1', 'read', 'Bhagavad Gita on Work — Chapter 3', 'भगवद्गीता — कर्मयोग', E'VERSE: BG 3.19\nतस्मादसक्तः सततं कार्यं कर्म समाचर।\nअसक्तो ह्याचरन् कर्म परमाप्नोति पूरुषः॥\n\nMEANING:\n"Therefore, always perform your duty without attachment. By performing action without attachment, one attains the Supreme."\n\nWHAT THIS MEANS FOR YOU AT WORK:\nKrishna is not saying "don''t care about your work." He is saying: care deeply about the work itself, but release attachment to the outcome, the recognition, the promotion, the validation. Do the work because it is the right work to do. The result will follow — but it is not yours to control.\n\nTHE PRACTICAL SHIFT:\nBefore a big presentation: "I have prepared my best. What happens next is not mine to control."\n\nBefore a difficult email: "What is the most honest, clear, helpful thing I can say?"\n\nThis is Karma Yoga in the office.', E'इसलिए, सदैव अनासक्त रहकर अपने कर्तव्य का निष्पादन करें। अनासक्त होकर कर्म करने से मनुष्य परम को प्राप्त होता है।', 'Tasmādasaktaḥ satataṁ kāryaṁ karma samācara. Asakto hyācaran karma param āpnoti pūruṣaḥ.', 'Therefore, always perform your duty without attachment. By performing action without attachment, one attains the Supreme.', '["Reduces performance anxiety by shifting focus from result to action", "Increases work quality — attachment to outcomes creates fear which reduces performance", "Builds a sustainable long-term career — not dependent on external validation", "Creates genuine equanimity in success and failure", "Thousands of executives globally have used this framework — it is the world''s first leadership text"]'::jsonb, E'After reading:\n1. Write: "Today I will focus on the DOING of _____, not the outcome."\n2. Identify one task you''ve been procrastinating because of fear of the result.\n3. Do that task first today.\n4. Notice: does the fear diminish when you focus on the action alone?', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wl_shanti_mantra', 'wl_om_shanti_v1', 'mantra', 'Om Shanti — Before Every Meeting', 'ॐ शान्ति — बैठक से पूर्व', 'ॐ शान्ति: शान्ति: शान्ति:', NULL, 'Om Shantih Shantih Shantih', E'OM — peace in body, peace in mind, peace in spirit. The three repetitions of "Shantih" address the three types of disturbance: physical (Adhibhautika), mental (Adhidaivika), and spiritual (Adhyatmika).', '["One minute of this practice measurably slows heart rate before a stressful meeting", "Shifts mental state from reactive to responsive", "The threefold Shanti addresses all three sources of human disturbance", "Creates an invisible protective field of calm that others can feel in the room", "Used by Vedic scholars for millennia before important discourse — it works"]'::jsonb, E'60 seconds before any important meeting or difficult call:\n1. Close your eyes.\n2. Drop your shoulders.\n3. Inhale deeply.\n4. Exhale and internally chant: "Om... Shantih... Shantih... Shantih..."\n5. Repeat 7 times.\n6. Open your eyes. You are ready.', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wl_evening_detox', 'wl_evening_ritual_v1', 'ritual', 'The Workday Closing Ritual', 'कार्यदिवस बंद करने की विधि', E'The most underrated productivity tool: a clear ending to the workday.\n\nMost professionals never officially "close" their workday. They drift from work to dinner to phone to bed — cortisol elevated the entire time. The mind does not switch off because it was never told to.\n\nThis 5-minute ritual tells your nervous system: it is done. You are safe. Rest now.', NULL, NULL, NULL, '["Cortisol drops measurably when a clear end-signal is given to the nervous system", "Reduces work-related insomnia by 40% (research on boundary rituals)", "Prevents the ''always on'' culture from eroding your personal life", "Creates a clear identity boundary: worker → human being → family member", "5 minutes investment protects all evening hours from mental contamination"]'::jsonb, E'The Closing Ritual (5 minutes):\n1. Close every screen intentionally — one at a time.\n2. Tidy one small thing on your desk.\n3. Stand up. Take 5 slow breaths.\n4. Place your hands in Namaste.\n5. Say aloud or internally: "My work for today is complete. I gave what I had. The rest is tomorrow. Om Shanti."\n6. Walk away. Do not return to the screen tonight unless there is a genuine emergency.', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wisdom', 'wisdom_wl_1', 'wisdom', 'On Busyness', NULL, E'"Action is indeed better than inaction" — but the Gita is equally clear that feverish, scattered action is not karma yoga. It is just karma. The quality of your presence in one task is worth more than the quantity of your multitasking. Deep work is a spiritual practice.', NULL, NULL, NULL, NULL, NULL, NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wisdom', 'wisdom_wl_2', 'wisdom', 'On Stress', NULL, E'Stress is not caused by too much work. Stress is caused by working against your own values, without purpose, under conditions of fear. When work becomes an expression of dharma — when it is honest, purposeful, and offered without clinging to the result — the same amount of work produces energy instead of exhaustion.', NULL, NULL, NULL, NULL, NULL, NULL, 2, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wisdom', 'wisdom_wl_3', 'wisdom', 'On Breath', NULL, E'The Upanishads say the breath is the bridge between the voluntary and involuntary nervous system — the one thing you can consciously control that directly affects the unconscious body. Every time you consciously slow your breath at your desk, you are performing a genuine act of self-governance. This is pratyahara: withdrawal of the senses from the noise.', NULL, NULL, NULL, NULL, NULL, NULL, 3, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(wl_id, 'wisdom', 'wisdom_wl_4', 'wisdom', 'On Monday Morning', NULL, E'In Sanskrit, the word for Monday is "Somavar" — the day of Soma, the nectar of the moon. The week begins not with urgency but with the cool, reflective energy of the moon. Before you open your inbox on Monday morning, take one breath and ask: "What truly matters this week?" The rest is noise.', NULL, NULL, NULL, NULL, NULL, NULL, 4, 'sequential')
ON CONFLICT DO NOTHING;


-- Work-Life Milestones
INSERT INTO journey_milestones (journey_type_id, phase_id, slug, title, title_hindi, description, milestone_type, milestone_order, icon, allow_photo, allow_notes, is_required, coin_reward)
VALUES
(wl_id, wl_ph_found, 'wl_7day', 'Week 1 Complete — Foundation Built', 'पहला सप्ताह सम्पूर्ण',
 E'Seven days of morning pranayama and evening closing ritual. You have proven to yourself that change is possible even in a busy schedule. The foundation is laid. The next two weeks build on this.',
 'samskara', 1, '🌱', false, true, true, 25),
(wl_id, wl_ph_prac, 'wl_14day', 'Week 2 Complete — Karma Yoga Applied', 'कर्मयोग का अभ्यास',
 E'You have spent 7 days applying Karma Yoga to real workplace situations. This is the most intellectually and practically demanding week of the journey. It requires you to challenge thoughts you have held for years. You did it.',
 'samskara', 2, '⚡', false, true, true, 25),
(wl_id, wl_ph_integ, 'wl_21day', '21 Days — Transformation Complete', '२१ दिन — परिवर्तन सम्पूर्ण',
 E'21 days. These practices are no longer external techniques — they are becoming part of how you think and work. The science is clear: neural pathways formed by 21 days of consistent practice become the default. You have rewired your stress response.',
 'samskara', 3, '🌟', true, true, true, 100)
ON CONFLICT (journey_type_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description,
  coin_reward = EXCLUDED.coin_reward, updated_at = NOW();


-- ═══════════════════════════════════════════════════════════════════════
-- ③ GAYATRI SADHANA 40-DAY — PHASES
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO journey_phases (journey_type_id, slug, title, title_hindi, description, phase_order, trigger_type, trigger_value, duration_label, icon, color_hex)
VALUES
(gs_id, 'gayatri_init',     'Initiation',  'दीक्षा',     'Days 1–10: Learn the mantra, establish the sunrise habit.',         1, 'immediate',  NULL,                  'Days 1–10', '🌅', '#FDE68A'),
(gs_id, 'gayatri_disc',     'Discipline',  'अनुशासन',    'Days 11–30: 108 recitations at sunrise every day, no exceptions.',  2, 'day_offset', '{"days": 10}'::jsonb, 'Days 11–30','🔥', '#FCD34D'),
(gs_id, 'gayatri_complete', 'Completion',  'सम्पूर्णता', 'Days 31–40: Deep meditation on each word of the mantra.',           3, 'day_offset', '{"days": 30}'::jsonb, 'Days 31–40','✨', '#F59E0B')
ON CONFLICT (journey_type_id, slug) DO UPDATE SET
  title = EXCLUDED.title, phase_order = EXCLUDED.phase_order,
  trigger_value = EXCLUDED.trigger_value, duration_label = EXCLUDED.duration_label,
  icon = EXCLUDED.icon, color_hex = EXCLUDED.color_hex;

SELECT id INTO gs_ph_init FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'gayatri_init';
SELECT id INTO gs_ph_disc FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'gayatri_disc';
SELECT id INTO gs_ph_comp FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'gayatri_complete';


-- ─── Gayatri — Tasks ──────────────────────────────────────────────────

INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, description, task_type, frequency, duration_minutes, mantra_count, display_order, icon, coin_reward, is_premium)
VALUES
-- Initiation
(gs_ph_init, 'gayatri_learn',  'Learn the Gayatri Mantra',       'गायत्री मंत्र सीखें',    'Master the pronunciation and meaning of the 24 syllables of the Gayatri Mantra before you begin the daily japa.',         'read',   'daily', 10, NULL, 1, '📖', 5, true),
(gs_ph_init, 'gayatri_11',     'Chant 11 Times at Sunrise',      'सूर्योदय पर ११ जप',      'Wake before sunrise. Face East. Chant the Gayatri Mantra 11 times with full attention. Build the sunrise habit first.',    'mantra', 'daily', 5,  11,  2, '🌅', 5, true),
(gs_ph_init, 'gayatri_word',   'Meditate on One Word per Day',   'एक शब्द ध्यान',          'Each day, choose one word from the mantra and sit with it for 5 minutes. 24 syllables, 24 days of depth.',                'meditation','daily',5, NULL, 3, '🧘', 5, true),

-- Discipline
(gs_ph_disc, 'gayatri_108',    'Chant 108 Times at Sunrise',     'सूर्योदय पर १०८ जप',     'The core practice. 108 recitations at sunrise on a mala. This is the daily non-negotiable of the sadhana.',               'mantra', 'daily', 20, 108, 1, '📿', 8, true),
(gs_ph_disc, 'gayatri_silent', 'Silent Mental Japa (11 times)',  'मानसिक जप ११ बार',       'During the day — while walking, waiting, commuting — chant the Gayatri mentally 11 times. No mala required.',             'mantra', 'daily', 5,  11,  2, '💫', 5, true),

-- Completion
(gs_ph_comp, 'gayatri_deep',   'Deep Meditation on the Mantra',  'मंत्र ध्यान',            'After 108 chants, sit for 10 minutes in silence. Visualise the sun''s light entering through your crown chakra.',          'meditation','daily',30,NULL, 1, '☀️', 10, true),
(gs_ph_comp, 'gayatri_purna',  '40-Day Completion Paath',        'पूर्ण साधना',            'Today is special. Chant 108 times. Offer water to the sun. Write what this journey has given you.',                      'mantra', 'daily', 30, 108, 2, '✨', 10, true)
ON CONFLICT (phase_id, slug) DO NOTHING;


-- ─── Gayatri — Content Pool (one INSERT per row) ─────────────────────

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'gayatri_108', 'gayatri_mantra_full_v1', 'mantra', 'The Gayatri Mantra', 'गायत्री मंत्र', E'ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात् ॥', NULL, 'Om Bhūr Bhuvaḥ Svaḥ\nTat Savitur Vareṇyaṃ\nBhargo Devasya Dhīmahi\nDhiyo Yo Naḥ Prachodayāt', E'OM — We meditate upon the divine light of the Sun (Savitur), which pervades the earth (Bhur), the atmosphere (Bhuvah) and the heavens (Svah). May that divine radiance illuminate and inspire our intellect.', '["The Gayatri Mantra contains 24 syllables corresponding to the 24 vertebrae of the spine", "Savitur (the Sun) is the source of all light and intelligence in our solar system", "Regular practice has been shown in studies to reduce cortisol and increase alpha brainwaves", "The mantra is from the Rigveda (3.62.10) — one of the oldest texts in human history, conserved for 3500+ years", "It is called the mother of all mantras — knowledge of this mantra alone is considered complete spiritual education in some traditions"]'::jsonb, E'HOW TO CHANT:\n1. Wake before sunrise (Brahma Muhurta: 4–6 AM).\n2. Splash water on your face.\n3. Stand or sit facing East — toward the rising sun.\n4. Hold your mala in your right hand.\n5. Take 3 deep breaths.\n6. Begin chanting. Move one bead per chant.\n7. Chant clearly — each syllable should be distinct.\n8. Complete 108 repetitions (one full mala).\n9. Sit silently for 5 minutes after completion.\n\nOffer water to the sun:\nAfter chanting, pour a small amount of water facing East as an offering (Arghya). Salute the sun with folded hands.', E'जप कैसे करें:\n1. सूर्योदय से पूर्व उठें।\n2. मुँह-हाथ धोएं।\n3. पूर्व दिशा में खड़े हों या बैठें।\n4. माला दाहिने हाथ में रखें।\n5. तीन गहरी सांसें लें।\n6. जप प्रारंभ करें।\n7. स्पष्ट उच्चारण करें।\n8. १०८ बार पूरा करें।\n9. जप के बाद ५ मिनट मौन में बैठें।', 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'gayatri_word', 'gayatri_word_bhargo_v1', 'meditation', 'Bhargo — The Radiance of Purification', 'भर्ग — शुद्धि की आभा', E'THE WORD: BHARGO\nBhargo comes from the Sanskrit root "bhrj" meaning to shine, to radiate, to purify.\n\nIn the mantra: "Bhargo Devasya Dhīmahi" — we meditate on the divine radiance.\n\nBhargo is not just light in the physical sense. It is the light that burns away impurity — the light of awareness that, when we turn toward it, dissolves everything false in us.\n\nMEDITATION:\nClose your eyes. Visualise a warm golden light at the centre of the sun. See that light travelling across space and entering through the crown of your head. As it descends, everything cloudy, fearful, or confused in your mind simply becomes transparent — not fought, not suppressed, but illuminated into clarity.\n\nThis is Bhargo.', NULL, NULL, NULL, '["Word-by-word meditation on mantra reveals layers of meaning unavailable from speed-recitation", "Visualisation of light during meditation activates the pineal gland", "Bhargo understood experientially becomes a tool for self-purification in daily life", "This practice deepens the personal relationship with the mantra"]'::jsonb, E'5-Minute Practice:\n1. Sit comfortably. Close your eyes.\n2. Breathe naturally for 1 minute.\n3. Internally repeat "Bhargo... Bhargo... Bhargo..." slowly.\n4. Visualise golden light filling your mind.\n5. With each repetition, feel something releasing — a worry, a grudge, a story.\n6. After 5 minutes, open your eyes slowly.', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'gayatri_silent', 'gayatri_silent_v1', 'mantra', 'Manasik Japa — Silent Mental Chanting', 'मानसिक जप', E'Manasik Japa (mental chanting) is considered by many traditions to be more powerful than audible chanting — because it requires more concentration. When you chant aloud, the sound carries some of the effort. When you chant internally, the entire weight of the mantra falls on your attention.\n\nThis is a skill. Beginners find the mind wanders after 2–3 repetitions. Do not be discouraged. Return. This is the practice.\n\nWHERE TO DO IT:\n• Walking to your car or bus stop\n• Waiting in a queue\n• During lunch if eating alone\n• In the elevator\n• In the shower\n• Any transition moment of the day', NULL, 'Manasik Japa — inner, mental chanting of the Gayatri Mantra', NULL, '["Mental japa builds concentration (dharana) more effectively than audible chanting", "Can be practiced anywhere — transforms commute time into sadhana time", "Maintains the thread of the mantra throughout the day", "Each mental repetition plants a seed of the mantra''s vibration in the subconscious"]'::jsonb, E'How to do it:\n1. No setup required — begin anywhere, anytime.\n2. Internally begin: "Om Bhur Bhuvah Svah..."\n3. When the mind wanders (and it will), return without judgment.\n4. Count on your fingers if you have no mala.\n5. Target: 11 silent repetitions during one transition moment today.', NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'wisdom', 'wisdom_gayatri_1', 'wisdom', 'On the Sun', NULL, E'The Gayatri addresses Savitur — the Sun as the source of divine intelligence. Every photon of sunlight that reaches you has traveled 8 minutes across 150 million kilometers. That photon is what makes the food you eat, and the food is what makes the thought you are thinking right now. You are, quite literally, made of sunlight asking itself to wake up.', NULL, NULL, NULL, NULL, NULL, NULL, 1, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'wisdom', 'wisdom_gayatri_2', 'wisdom', 'On Sunrise', NULL, E'Brahma Muhurta — the Hour of Brahma — is 96 minutes before sunrise. At this time, the air has a higher concentration of negative ions, the electromagnetic field of the earth is at its quietest, and the brain is naturally in a theta-alpha transitional state. The ancient rishis did not choose this time arbitrarily. They observed it. So do your alarm.', NULL, NULL, NULL, NULL, NULL, NULL, 2, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'wisdom', 'wisdom_gayatri_3', 'wisdom', 'On 108', NULL, E'Why 108? The distance from the Earth to the Sun is approximately 108 times the Sun''s diameter. The distance from the Earth to the Moon is 108 times the Moon''s diameter. There are 108 Upanishads. There are 108 energy lines (nadis) that converge on the heart chakra. The number is not superstition — it is the universe''s own geometry.', NULL, NULL, NULL, NULL, NULL, NULL, 3, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'wisdom', 'wisdom_gayatri_4', 'wisdom', 'On the 24 Syllables', NULL, E'The Gayatri Mantra has exactly 24 syllables. The human spine has 24 vertebrae. Vedic yogis held that each syllable, when chanted correctly, resonates with a corresponding vertebral nerve centre. The mantra is, in this reading, a spinal tune-up — a sound-based alignment of the physical and subtle body.', NULL, NULL, NULL, NULL, NULL, NULL, 4, 'sequential')
ON CONFLICT DO NOTHING;

INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, transliteration, translation, benefits, instruction, instruction_hindi, display_order, rotation_type) VALUES
(gs_id, 'wisdom', 'wisdom_gayatri_5', 'wisdom', 'On Consistency Over Intensity', NULL, E'The Gayatri Sadhana is not asking you for dramatic intensity. It asks for one thing: sunrise. Every day. For 40 days. The ancient teachers understood that transformation is not an event — it is a direction maintained over time. Show up at sunrise. The sun will show up too.', NULL, NULL, NULL, NULL, NULL, NULL, 5, 'sequential')
ON CONFLICT DO NOTHING;


-- Gayatri Milestones
INSERT INTO journey_milestones (journey_type_id, phase_id, slug, title, title_hindi, description, milestone_type, milestone_order, icon, allow_photo, allow_notes, is_required, coin_reward)
VALUES
(gs_id, gs_ph_init, 'gayatri_first_sunrise', 'First Sunrise Practice', 'प्रथम सूर्योदय साधना',
 E'You woke before the sun and faced East. You chanted the oldest known prayer for illumination. This is not ordinary. Most people will never do this even once. You have done it, and the forty days ahead will compound this moment into something transformative.',
 'samskara', 1, '🌅', true, true, true, 25),
(gs_id, gs_ph_disc, 'gayatri_1000', '1000th Recitation', 'सहस्र जप',
 E'1000 recitations. In the Vedic tradition, a thousand repetitions of a mantra (Sahasra Japa) is a complete offering. You have crossed this threshold. The mantra is no longer a text you are reading — it is becoming part of your subconscious vocabulary.',
 'samskara', 2, '🔥', false, true, true, 50),
(gs_id, gs_ph_disc, 'gayatri_21day', '21-Day Mark', '२१ दिवसीय',
 E'21 consecutive mornings of sunrise practice. The neural pattern is established. The habit is real. You will find, if you miss a day now, that something genuinely feels absent. That absence is the proof that the mantra has taken root.',
 'samskara', 3, '⭐', false, true, true, 25),
(gs_id, gs_ph_comp, 'gayatri_sampurna', 'Gayatri Sadhana Sampurna', 'गायत्री साधना सम्पूर्ण',
 E'40 days of sunrise. 40 × 108 = 4320 recitations. You have completed the Gayatri Sadhana.\n\nThe Rigveda says: "The wise always seek the divine light of Savitur." Today you have been among the wise. Offer water to the sun. Sit in gratitude. Write what changed.',
 'samskara', 4, '✨', true, true, true, 100)
ON CONFLICT (journey_type_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description,
  coin_reward = EXCLUDED.coin_reward, updated_at = NOW();


END$$;
