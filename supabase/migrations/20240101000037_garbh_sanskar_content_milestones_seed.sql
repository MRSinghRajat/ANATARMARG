-- ============================================================
-- GARBH SANSKAR — Rich Content & Milestones Seed
-- Populates journey_content_pool for all 24 task slugs,
-- seeds 8 Samskara milestones, and adds rotating Daily Wisdom.
-- All upserts use ON CONFLICT — safe to re-run.
-- ============================================================

DO $$
DECLARE
  gs_id       UUID := '11b628c4-07d5-408f-8fe1-d570bac8a799'; -- garbh-sanskar
  ph_planning UUID;
  ph_t1       UUID;
  ph_t2       UUID;
  ph_t3       UUID;
  ph_newborn  UUID;
  ph_m1_3     UUID;
  ph_m3_6     UUID;
  ph_m6_12    UUID;
  ph_y1       UUID;
BEGIN

  -- ── Ensure unique constraint exists (idempotent) ─────────────────────────
  -- Required for ON CONFLICT (journey_type_id, slug) below.
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'journey_milestones'::regclass
      AND contype   = 'u'
      AND conname   = 'journey_milestones_journey_type_id_slug_key'
  ) THEN
    ALTER TABLE journey_milestones
      ADD CONSTRAINT journey_milestones_journey_type_id_slug_key
      UNIQUE (journey_type_id, slug);
  END IF;

  -- Also ensure unique constraint exists for journey_content_pool
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'journey_content_pool'::regclass
      AND contype   = 'u'
      AND conname   = 'journey_content_pool_journey_type_id_task_slug_slug_key'
  ) THEN
    -- Only add if slug column exists (added by migration 36)
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'journey_content_pool' AND column_name = 'slug'
    ) THEN
      ALTER TABLE journey_content_pool
        ADD CONSTRAINT journey_content_pool_journey_type_id_task_slug_slug_key
        UNIQUE (journey_type_id, task_slug, slug);
    END IF;
  END IF;

  -- Fetch phase IDs
  SELECT id INTO ph_planning FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'planning';
  SELECT id INTO ph_t1       FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'trimester_1';
  SELECT id INTO ph_t2       FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'trimester_2';
  SELECT id INTO ph_t3       FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'trimester_3';
  SELECT id INTO ph_newborn  FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'newborn';
  SELECT id INTO ph_m1_3     FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'month_1_3';
  SELECT id INTO ph_m3_6     FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'month_3_6';
  SELECT id INTO ph_m6_12    FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'month_6_12';
  SELECT id INTO ph_y1       FROM journey_phases WHERE journey_type_id = gs_id AND slug = 'year_1_plus';

  -- ── Update journey_type: mark premium + add setup_schema ─────────────────
  UPDATE journey_types SET
    is_premium    = true,
    required_plan = 'pro',
    subtitle      = 'Sacred pregnancy, birth & first-year practices',
    subtitle_hindi = 'गर्भ से शिशु के प्रथम वर्ष तक की पवित्र यात्रा',
    category      = 'family',
    target_audience = 'pregnant_women',
    setup_type    = 'date_based',
    setup_schema  = '[
      {"type":"single_select","key":"mode","label":"Your stage","options":[
        {"value":"planning","label":"Planning for a baby"},
        {"value":"pregnant","label":"Currently pregnant"},
        {"value":"postnatal","label":"Baby is already born"}
      ]},
      {"type":"date","key":"due_date","label":"Expected due date","show_when":{"key":"mode","value":"pregnant"}},
      {"type":"date","key":"child_dob","label":"Baby''s date of birth","show_when":{"key":"mode","value":"postnatal"}}
    ]'::jsonb
  WHERE id = gs_id;

  -- ── Phase labels, icons, colors ──────────────────────────────────────────
  UPDATE journey_phases SET duration_label = 'Anytime',     icon = '🌱', color_hex = '#A8C5A0' WHERE journey_type_id = gs_id AND slug = 'planning';
  UPDATE journey_phases SET duration_label = 'Weeks 1–13',  icon = '🌅', color_hex = '#F0C27F' WHERE journey_type_id = gs_id AND slug = 'trimester_1';
  UPDATE journey_phases SET duration_label = 'Weeks 14–27', icon = '🌸', color_hex = '#E8A0BF' WHERE journey_type_id = gs_id AND slug = 'trimester_2';
  UPDATE journey_phases SET duration_label = 'Weeks 28–40', icon = '🕊️', color_hex = '#A0C4FF' WHERE journey_type_id = gs_id AND slug = 'trimester_3';
  UPDATE journey_phases SET duration_label = 'Days 0–27',   icon = '👶', color_hex = '#FFD6A5' WHERE journey_type_id = gs_id AND slug = 'newborn';
  UPDATE journey_phases SET duration_label = 'Months 1–3',  icon = '☀️', color_hex = '#CAFFBF' WHERE journey_type_id = gs_id AND slug = 'month_1_3';
  UPDATE journey_phases SET duration_label = 'Months 3–6',  icon = '🎨', color_hex = '#9BF6FF' WHERE journey_type_id = gs_id AND slug = 'month_3_6';
  UPDATE journey_phases SET duration_label = 'Months 6–12', icon = '📖', color_hex = '#BDB2FF' WHERE journey_type_id = gs_id AND slug = 'month_6_12';
  UPDATE journey_phases SET duration_label = 'Year 1+',     icon = '🤸', color_hex = '#FFC6FF' WHERE journey_type_id = gs_id AND slug = 'year_1_plus';

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — PLANNING PHASE
  -- ═══════════════════════════════════════════════════════════════════════════

  -- plan_mantra_daily — Garbhadhana / Pre-Conception Mantra
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, transliteration, translation,
     benefits, instruction, instruction_hindi, display_order, rotation_type)
  VALUES (
    gs_id, 'plan_mantra_daily', 'plan_mantra_daily_v1', 'mantra',
    'Hiranyagarbha Mantra', 'हिरण्यगर्भ मंत्र',
    'ॐ हिरण्यगर्भः समवर्तताग्रे\nभूतस्य जातः पतिरेक आसीत् ।\nस दाधार पृथिवीं द्यामुतेमां\nकस्मै देवाय हविषा विधेम ॥',
    'ॐ — सृष्टि के आरम्भ में हिरण्यगर्भ प्रकट हुए,\nवे समस्त जन्म लेने वाले प्राणियों के एकमात्र स्वामी थे।\nउन्होंने पृथ्वी और यह स्वर्ग को धारण किया —\nउस देव को हम अपना हविष् अर्पण करते हैं।',
    'Om Hiranyagarbhah samavartatagre bhutasya jatah patireka asit.\nSa dadhara prthivim dyam utimam kasmai devaya havisha vidhema.',
    'OM — The golden womb arose in the beginning; when born, He was the sole lord of all that exists. He established this earth and this sky. To which god shall we offer our oblation?',
    '["Purifies the body and mind as a vessel for new life", "Invokes the consciousness of the incoming soul", "Aligns the subtle energies (prana) of both partners", "Creates a sattvic (pure) vibrational field in the home", "Reduces anxiety and prepares the mind for conception"]'::jsonb,
    E'1. Choose a clean, quiet space — ideally the same spot each day.\n2. Light a ghee diya (lamp) or incense.\n3. Sit facing East. Keep your spine upright.\n4. Place both hands on your lap, palms facing up.\n5. Take 3 slow, deep breaths to settle your mind.\n6. Chant 108 times with a rudraksha or tulsi mala.\n7. Both partners chanting together amplifies the effect.\n8. After chanting, sit in silence for 2–3 minutes.',
    E'1. एक स्वच्छ व शांत स्थान चुनें।\n2. घी का दीपक या धूपबत्ती जलाएं।\n3. पूर्व दिशा की ओर मुख करके बैठें।\n4. दोनों हाथ गोद में, हथेलियां ऊपर की ओर रखें।\n5. तीन गहरी सांसें लेकर मन को शांत करें।\n6. रुद्राक्ष या तुलसी माला से 108 बार जप करें।\n7. दोनों साथी मिलकर जप करें तो प्रभाव दोगुना होता है।\n8. जप के बाद 2-3 मिनट मौन में बैठें।',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- plan_yoga_asana — Fertility Yoga
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, benefits, instruction, instruction_hindi, display_order, rotation_type)
  VALUES (
    gs_id, 'plan_yoga_asana', 'plan_yoga_asana_v1', 'yoga',
    'Fertility Yoga Sequence', 'प्रजनन योग क्रम',
    E'Baddha Konasana (Butterfly Pose)\nSupta Baddha Konasana (Reclined Butterfly)\nViparita Karani (Legs-Up-the-Wall)\nBalasana (Child''s Pose)',
    E'बद्ध कोणासन (तितली मुद्रा)\nसुप्त बद्ध कोणासन (लेटी तितली मुद्रा)\nविपरीत करणी (दीवार पर पैर)\nबालासन (बाल मुद्रा)',
    '["Improves blood circulation to the pelvic and reproductive organs", "Balances apana vayu — the downward moving life force essential for conception", "Reduces cortisol (stress hormones) that directly inhibit fertility", "Strengthens the pelvic floor muscles", "Prepares the body physically and energetically for pregnancy"]'::jsonb,
    E'Perform on an empty stomach, ideally at sunrise.\n\nBaddha Konasana (5 min):\nSit on the floor. Bring the soles of your feet together. Hold your feet and gently press your knees toward the floor. Breathe deeply.\n\nSupta Baddha Konasana (5 min):\nLie on your back. Bring soles together, let knees fall open. Place one hand on your heart, one on your womb. Breathe into your lower belly.\n\nViparita Karani (5 min):\nLie with your hips close to a wall. Extend legs up the wall. Relax completely. This posture increases blood flow to the uterus.\n\nBalasana (3 min):\nKneel and fold forward, arms extended. Rest your forehead on the mat.',
    E'खाली पेट, सूर्योदय के समय करें।\n\nबद्ध कोणासन (5 मिनट):\nज़मीन पर बैठें, पैरों के तलवे मिलाएं। घुटनों को धीरे-धीरे ज़मीन की ओर दबाएं।\n\nसुप्त बद्ध कोणासन (5 मिनट):\nपीठ के बल लेटें, तलवे मिलाएं, घुटने खुलने दें। एक हाथ हृदय पर, एक गर्भ पर रखें।\n\nविपरीत करणी (5 मिनट):\nदीवार के पास लेटकर पैर दीवार पर फैलाएं। पूरी तरह शिथिल हो जाएं।\n\nबालासन (3 मिनट):\nघुटनों के बल आगे झुकें, माथा चटाई पर रखें।',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — TRIMESTER 1
  -- ═══════════════════════════════════════════════════════════════════════════

  -- t1_morning_mantra — Garbh Gayatri
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, transliteration, translation,
     benefits, instruction, instruction_hindi, display_order, rotation_type)
  VALUES (
    gs_id, 't1_morning_mantra', 't1_morning_mantra_v1', 'mantra',
    'Garbh Gayatri Mantra', 'गर्भ गायत्री मंत्र',
    'ॐ तत्पुरुषाय विद्महे\nमहादेवाय धीमहि ।\nतन्नो गर्भः प्रचोदयात् ॥',
    'ॐ — उस परम पुरुष को हम जानते हैं,\nमहादेव का ध्यान करते हैं।\nवह गर्भस्थ शिशु हमें प्रेरित करे।',
    'Om Tatpurushaya vidmahe Mahadevaya dhimahi.\nTanno Garbhah prachodayat.',
    'OM — We contemplate the Supreme Being, we meditate on the Great God. May that child in the womb inspire and illuminate us.',
    '["Activates the baby''s nascent nervous system through sacred sound vibration", "Establishes a deep mother-child spiritual bond from the first trimester", "Reduces morning sickness and first-trimester anxiety", "Builds a sattvic (pure) subconscious imprint for the baby", "Synchronises the mother''s heart rate and brainwaves into a calm state"]'::jsonb,
    E'Best performed at sunrise (Brahma Muhurta: 4–6 AM) or after your morning bath.\n\n1. Sit comfortably facing East. Place both hands on your lower abdomen.\n2. Close your eyes and take 3 deep breaths.\n3. Visualise a warm golden light filling your womb with every inhale.\n4. Chant slowly and clearly — feel the vibration travel to the baby.\n5. Repeat 11 or 108 times depending on your time.\n6. After chanting, sit quietly for 5 minutes with your eyes closed.\n7. Whisper a loving intention to your baby.',
    E'सूर्योदय (ब्रह्म मुहूर्त: सुबह 4–6 बजे) या स्नान के बाद करें।\n\n1. पूर्व दिशा में आरामदायक स्थिति में बैठें। दोनों हाथ पेट पर रखें।\n2. आंखें बंद करें और 3 गहरी सांसें लें।\n3. कल्पना करें कि सुनहरी रोशनी गर्भ में भर रही है।\n4. धीरे-धीरे और स्पष्ट रूप से जप करें।\n5. 11 या 108 बार दोहराएं।\n6. जप के बाद 5 मिनट मौन में बैठें।\n7. शिशु को प्रेमपूर्ण संकल्प सुनाएं।',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t1_meditation — Bonding Meditation
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, instruction_hindi, display_order, rotation_type)
  VALUES (
    gs_id, 't1_meditation', 't1_meditation_v1', 'meditation',
    'Womb Bonding Visualisation', 'गर्भ-बंधन ध्यान',
    E'A guided 10-minute practice to establish your first conscious connection with your baby. Science confirms that maternal thoughts and emotions directly influence fetal neurological development from the first trimester.',
    '["Stimulates the release of oxytocin (the bonding hormone)", "Reduces first-trimester anxiety and fear around pregnancy", "Begins the mother-child emotional bond weeks before the baby can hear", "Trains the brain to respond to pregnancy with calm instead of stress", "Creates positive emotional memories in the baby''s developing limbic system"]'::jsonb,
    E'Find a quiet place where you will not be disturbed for 10 minutes.\n\n1. Lie down or sit with your spine supported.\n2. Place both hands gently on your lower abdomen.\n3. Close your eyes. Take 5 slow breaths — in through the nose, out through the mouth.\n4. With each exhale, let your body soften a little more.\n5. Now imagine a soft golden light glowing at the centre of your womb.\n6. In your mind, speak to your baby: "I see you. I love you. You are safe."\n7. Visualise the baby surrounded by warm light, peaceful and content.\n8. Stay here for 5–7 minutes, breathing gently.\n9. When ready, take 3 deep breaths and slowly open your eyes.\n10. Place your palms together and whisper "Namaste" to the new life within you.',
    E'10 मिनट के लिए एक शांत स्थान ढूंढें।\n\n1. लेट जाएं या पीठ को सहारा देकर बैठें।\n2. दोनों हाथ धीरे से पेट पर रखें।\n3. आंखें बंद करें। 5 धीमी सांसें लें।\n4. हर सांस के साथ शरीर को और शिथिल करें।\n5. गर्भ के केंद्र में सुनहरी रोशनी की कल्पना करें।\n6. मन में शिशु से कहें: "मैं तुम्हें देख रही हूं। मैं तुमसे प्यार करती हूं।"\n7. शिशु को गर्म प्रकाश से घिरा, शांत और प्रसन्न देखें।\n8. 5-7 मिनट यहाँ रहें।\n9. तैयार होने पर 3 गहरी सांसें लेकर आंखें खोलें।',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t1_diet_check — Garbhini Paricharya
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 't1_diet_check', 't1_diet_v1', 'read',
    'Trimester 1 Ayurvedic Diet (Garbhini Paricharya)', 'तिमाही 1 आयुर्वेदिक आहार',
    E'WHAT TO EAT:\n• Warm milk with a pinch of saffron (kesar) and ghee — every morning\n• Sesame seeds (til) and jaggery (gur) — rich in iron and calcium\n• Pomegranate juice — builds haemoglobin (blood quality)\n• Almonds soaked overnight — brain development support\n• Sweet fruits: mango, banana, dates (in moderation)\n• Rice, moong dal, khichdi — easy to digest, nourishing\n• Fennel (saunf) tea — relieves nausea naturally\n\nWHAT TO AVOID:\n• Raw or undercooked food\n• Papaya and pineapple (contains latex enzymes)\n• Excess salt, spice, and fried foods\n• Cold drinks and ice cream\n• Fasting or skipping meals',
    '["Builds Ojas — the vital essence that determines the baby''s immunity and vitality", "Prevents first-trimester anaemia through iron-rich foods", "Reduces morning sickness through warm, easily digestible foods", "Provides DHA and fatty acids crucial for fetal brain development", "Establishes a sattvic (pure, calm) food culture in the household"]'::jsonb,
    E'Daily checklist:\n☐ Morning: warm milk with ghee and saffron (1 strand)\n☐ Mid-morning: 5 soaked almonds\n☐ Lunch: dal, rice or khichdi — warm, not spicy\n☐ Afternoon: pomegranate juice or seasonal sweet fruit\n☐ Evening: fennel tea if nauseous\n☐ Before bed: warm turmeric milk (haldi doodh)\n\nAim to eat small amounts every 2-3 hours rather than large meals.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t1_pranayama_day4 — Nadi Shodhana
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, transliteration, benefits, instruction, instruction_hindi, display_order, rotation_type)
  VALUES (
    gs_id, 't1_pranayama_day4', 't1_pranayama_v1', 'yoga',
    'Nadi Shodhana Pranayama', 'नाड़ी शोधन प्राणायाम',
    'नाड़ी शोधन — Alternate Nostril Breathing\n\nThe word "Nadi" means subtle energy channel. "Shodhana" means purification. This pranayama purifies the 72,000 nadis (energy channels) in the body, balancing the solar (right nostril, Pingala) and lunar (left nostril, Ida) energies — essential during pregnancy.',
    'Nadi Shodhana — purification of the subtle energy channels',
    '["Balances Vata dosha — the primary dosha of movement, which governs fetal development", "Increases oxygen supply to the placenta, nourishing the baby", "Reduces anxiety, insomnia and mood swings common in T1", "Calms the nervous system within 3 minutes", "Prepares the lungs for the increased respiratory demands of pregnancy"]'::jsonb,
    E'Important: Do NOT hold your breath (kumbhaka) during pregnancy.\n\n1. Sit comfortably with your spine upright.\n2. Rest your left hand on your knee, palm facing up.\n3. Bring your right hand to your nose. Use your thumb to close the right nostril and your ring finger to close the left.\n4. Close the right nostril with your thumb. Inhale slowly through the LEFT nostril for 4 counts.\n5. Close BOTH nostrils briefly (1 count only — no retention).\n6. Open the right nostril. Exhale slowly for 4 counts.\n7. Inhale through the RIGHT nostril for 4 counts.\n8. Close both briefly. Open the left. Exhale for 4 counts.\n9. This completes one round. Do 9 rounds.\n10. Finish by exhaling through the left nostril.',
    E'महत्वपूर्ण: गर्भावस्था में श्वास रोकें नहीं।\n\n1. रीढ़ सीधी रखकर आरामदेह स्थिति में बैठें।\n2. बाएं हाथ को घुटने पर, हथेली ऊपर रखें।\n3. दाहिने हाथ को नाक पर लाएं।\n4. अंगूठे से दाहिनी नासिका बंद करें। बाईं से 4 की गिनती में सांस लें।\n5. दोनों बंद करें (1 गिनती)।\n6. दाहिनी नासिका खोलें। 4 की गिनती में सांस छोड़ें।\n7. दाहिनी से 4 की गिनती में सांस लें।\n8. दोनों बंद करें। बाईं खोलें। 4 की गिनती में छोड़ें।\n9. यह एक चक्र है। 9 चक्र करें।',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — TRIMESTER 2
  -- ═══════════════════════════════════════════════════════════════════════════

  -- t2_garbh_samvad — Neuro-Acoustic Stimulation
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 't2_garbh_samvad', 't2_garbh_samvad_v1', 'ritual',
    'Garbh Samvad — Talking to Your Baby', 'गर्भ संवाद — शिशु से संवाद',
    E'From week 18, your baby can hear. Neuroscience confirms that the mother''s voice is the primary auditory stimulus that shapes the baby''s brain architecture. Garbh Samvad is the ancient Vedic practice of conscious communication with the womb.\n\nSAMPLE SCRIPT (read aloud with hands on belly):\n\n"My dear little one — I am your mother. I love you completely. You are strong, healthy, and full of light. You are growing beautifully. The world you are coming into is warm and full of love. I will always protect you. Grow well, little one."\n\nThen read one positive affirmation, or a verse from the Bhagavad Gita, or a children''s story.',
    '["Stimulates the auditory cortex — the baby''s hearing centre — from week 18", "Maternal voice recognition is the baby''s first cognitive learning", "Reduces maternal cortisol and anxiety through the act of intentional speaking", "Creates a postnatal recognition bond — babies recognise their mother''s voice at birth", "Encourages linguistic neural pathway formation before birth"]'::jsonb,
    E'1. Choose a calm time — morning or before bed works well.\n2. Sit or lie comfortably. Place both hands on your belly.\n3. Take 3 deep breaths to centre yourself.\n4. Read the script above clearly and warmly — at normal speaking volume.\n5. Pause between sentences. Feel the baby''s response.\n6. Add your own words — speak from your heart.\n7. End with: "I love you. Sleep well, my little one."\n8. Practice daily for 5 minutes.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t2_evening_listening — Vishnu Sahasranama
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, instruction_hindi, display_order, rotation_type)
  VALUES (
    gs_id, 't2_evening_listening', 't2_vishnu_sahasranama_v1', 'ritual',
    'Vishnu Sahasranama — 1000 Names of Vishnu', 'विष्णु सहस्रनाम',
    E'The Vishnu Sahasranama consists of 1000 names of Lord Vishnu from the Mahabharata (Anushasana Parva). Listening to this during pregnancy is considered one of the most powerful ways to instil dharmic values, calmness, and protection in the unborn child.\n\nOpening verse:\n\nविश्वं विष्णुर्वषट्कारो भूतभव्यभवत्प्रभुः ।\nभूतकृद्भूतभृद्भावो भूतात्मा भूतभावनः ॥\n\nVishvam Vishnur-Vashatkaaro Bhoota-Bhavya-Bhavat-Prabhuh\nBhootakrid-Bhootabhrid-Bhaavo Bhoota-Atma Bhoota-Bhaavanah',
    '["The 108 mantric names within the 1000 names activate each chakra sequentially", "Creates an atmosphere of Vishnu''s protective energy in the womb space", "The rhythm of Sahasranama naturally entrains the baby''s heart rate", "Builds Dharmic (righteous) neural patterns in the baby''s developing brain", "Reduces maternal insomnia — the steady rhythm promotes deep sleep"]'::jsonb,
    E'1. Play Vishnu Sahasranama softly — near your abdomen if lying down.\n2. You may follow along with the text or simply listen.\n3. Keep the volume gentle — the baby''s hearing is sensitive.\n4. The ideal time is during the evening (Sandhyakaal — at twilight).\n5. You can chant 1–3 shlokas yourself if you know them.\n6. Rest with your hands on your belly while listening.\n7. Even 15 minutes of listening is deeply beneficial.',
    E'1. विष्णु सहस्रनाम धीमी आवाज में बजाएं — लेटे हों तो पेट के पास।\n2. पाठ के साथ अनुसरण करें या केवल सुनें।\n3. आवाज कोमल रखें — शिशु की श्रवण शक्ति संवेदनशील है।\n4. सांध्यकाल (शाम के समय) सर्वोत्तम है।\n5. यदि आती हों तो 1-3 श्लोक स्वयं भी बोलें।\n6. सुनते समय हाथ पेट पर रखें।',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t2_yoga_stretch — Prenatal Stretches
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 't2_yoga_stretch', 't2_yoga_v1', 'yoga',
    'Second Trimester Prenatal Yoga', 'दूसरी तिमाही प्रसवपूर्व योग',
    E'Sequence: Cat-Cow → Pelvic Tilts → Side-Lying Stretch → Supported Warrior II',
    '["Relieves the lower back pain that intensifies in T2 as the belly grows", "Pelvic tilts encourage optimal fetal positioning — head-down", "Gentle movements maintain muscle tone without stressing the uterus", "Improves circulation in the legs — prevents varicose veins", "Building flexibility now directly reduces labour duration"]'::jsonb,
    E'Important: Avoid lying flat on your back after week 20.\n\nCat-Cow (2 min):\nOn all fours, wrists under shoulders, knees under hips. Inhale — arch your back and look up (Cow). Exhale — round your back like a cat. Repeat 10 times.\n\nPelvic Tilts (2 min):\nStand with your back against a wall. Inhale. As you exhale, press your lower back into the wall by tilting your pelvis forward. Hold 2 counts. Release. Repeat 10 times.\n\nSide-Lying Stretch (3 min each side):\nLie on your left side with a pillow under your head. Slowly extend your right arm over your head. Feel the lengthening through your side body. Switch sides.\n\nSupported Warrior II (2 min each side):\nStand facing a chair for balance. Step right foot out wide. Bend the right knee to 90 degrees. Extend arms. Hold 30 seconds each side.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t2_creativity_rasa — Creative Expression
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 't2_creativity_rasa', 't2_creativity_v1', 'ritual',
    'Rasa Cultivation — Creative Practice', 'रस साधना — रचनात्मक अभ्यास',
    E'In Ayurveda and classical Indian thought, "Rasa" refers not just to taste but to emotional essence, aesthetic experience, and the juice of life. When a pregnant mother engages in conscious creative acts — painting, music, poetry, gardening — she floods her system with positive neurotransmitters (dopamine, serotonin) that directly cross the placenta.\n\nChoose one of the following today:\n\n• DRAWING / PAINTING: Draw or paint your feeling of today. It need not be beautiful — only honest.\n• JOURNALING: Write a letter to your baby about the world they are entering.\n• MUSIC: Sing or hum any tune you love. The baby hears your voice.\n• GARDENING: Plant something. Water something. The earth responds to care.\n• CRAFT: Make something with your hands — a bookmark, a small decoration.',
    '["Activates the baby''s Dhi (intelligence) through maternal aesthetic experience", "Dopamine released during creative acts crosses the placenta freely", "Reduces prenatal depression — one of the most underdiagnosed conditions in pregnancy", "Builds the mother''s sense of identity beyond her physical changes", "Creates a memory-object (painting, journal) that holds the story of this pregnancy"]'::jsonb,
    E'1. Choose one creative activity from the list above.\n2. Set a timer for 10–15 minutes.\n3. Begin without judgment — there is no right or wrong here.\n4. As you create, breathe deeply and consciously.\n5. Think of the activity as a gift to your baby''s developing mind.\n6. When done, take a photo of what you made or write one line about how it felt.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — TRIMESTER 3
  -- ═══════════════════════════════════════════════════════════════════════════

  -- t3_birth_prep_meditation — Pranayama & Apana Vayu
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, transliteration, translation,
     benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 't3_birth_prep_meditation', 't3_birth_prep_v1', 'meditation',
    'Apana Vayu Pranayama — Birth Preparation', 'अपान वायु प्राणायाम — प्रसव की तैयारी',
    'ॐ अपानाय नमः\nशरीर की नीचे की ओर प्रवाहित शक्ति को नमस्कार।',
    'ॐ अपानाय नमः — उस ऊर्जा को प्रणाम जो नीचे की ओर बहती है।',
    'Om Apanaya Namah — Salutation to the downward-moving energy',
    'OM — I bow to the vital force that governs downward movement, elimination, and birth.',
    '["Activates Apana Vayu — the downward-flowing vital force that governs birth", "Trains the pelvic floor to release on command — reduces fear of birth", "Reduces the production of stress hormones (adrenaline) that slow labour", "Builds breath awareness that is your most powerful tool during contractions", "Regular practice can shorten active labour by building body memory"]'::jsonb,
    E'Practice this 15 minutes daily from week 32 onwards.\n\n1. Sit cross-legged or on a chair with your feet flat on the floor.\n2. Place both hands on your lower belly, below the navel.\n3. Inhale slowly through the nose for 4 counts. Feel the belly expand downward.\n4. As you exhale for 6 counts, visualise the baby moving gently downward into the birth canal. Feel the pelvic floor soften and open.\n5. Chant "Om Apanaya Namah" softly at the end of each exhale.\n6. Repeat for 10 rounds.\n\nContraction preparation (add from week 36):\nWhen you feel a Braxton Hicks contraction, breathe in for 4, out for 6, and repeat the visualisation. This trains your nervous system to respond to contractions with relaxation instead of fear.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t3_hip_opening — Malasana
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 't3_hip_opening', 't3_hip_opening_v1', 'yoga',
    'Malasana (Supported Squat) — Pelvic Preparation', 'मलासन — श्रोणि की तैयारी',
    E'Malasana is one of the most powerful postures for birth preparation. Squatting opens the pelvis by up to 10%, which can significantly ease the baby''s descent during labour. Regular practice encourages the baby to adopt an optimal (head-down, anterior) position.',
    '["Opens the pelvis by up to 10% — directly easing the baby''s passage during birth", "Strengthens the hip flexors and inner thighs which support during pushing", "Encourages optimal fetal positioning (OFP) — baby head-down and facing spine", "Relieves the symphysis pubis (pelvic girdle) discomfort common in T3", "Builds the psychological confidence that your body is designed for birth"]'::jsonb,
    E'IMPORTANT: Do not practise Malasana if you have been told the baby is breech, or if you have pelvic girdle pain (PGP). Consult your midwife first.\n\nSupported Malasana (Use a wall or chair back):\n1. Stand with feet slightly wider than hip-width, toes turned out to 45 degrees.\n2. Hold the back of a sturdy chair or place your hands against a wall.\n3. Slowly bend your knees and lower into a squatting position as far as comfortable.\n4. Keep your spine long — do not slump forward.\n5. Press your elbows against your inner thighs to gently open the hips.\n6. Breathe deeply. Hold for 30 seconds.\n7. To come up, use your hands for support. Rise slowly to avoid dizziness.\n8. Repeat 3 times, building to 5 as you get stronger.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- t3_calming_lullaby — Dhanvantari Mantra
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, transliteration, translation,
     benefits, instruction, instruction_hindi, display_order, rotation_type)
  VALUES (
    gs_id, 't3_calming_lullaby', 't3_dhanvantari_v1', 'mantra',
    'Dhanvantari Mantra — Healing Before Birth', 'धन्वन्तरि मंत्र',
    'ॐ नमो भगवते वासुदेवाय\nधन्वन्तरये अमृत-कलश हस्ताय\nसर्व-आमय विनाशाय\nत्रैलोक्य नाथाय\nश्री महाविष्णवे नमः ॥',
    'ॐ — भगवान वासुदेव को नमस्कार,\nधन्वन्तरि को, जिनके हाथ में अमृत कलश है,\nजो सभी रोगों को नष्ट करते हैं,\nतीनों लोकों के स्वामी को,\nश्री महाविष्णु को प्रणाम।',
    'Om Namo Bhagavate Vasudevaya Dhanvantaraye Amruta-kalasha hastaya\nSarva-amaya vinashaaya Trailokya naathaya Sri Maha Vishnave namah.',
    'OM — Salutation to the Lord Vasudeva, to Dhanvantari who holds the pot of immortal nectar, who destroys all disease and suffering, who is the master of the three worlds — I bow to Maha Vishnu.',
    '["Invokes Dhanvantari — the divine physician — for a safe and healthy birth", "The rhythm of this mantra entrains the baby''s nervous system into a sleep state", "Regular chanting reduces the mother''s pre-birth anxiety", "Creates a sonic environment of healing and protection in the womb space", "Instils a sattvic vibration for the baby''s final weeks of development"]'::jsonb,
    E'Best performed in the evening before sleep.\n\n1. Dim the lights. Make the room calm and warm.\n2. Lie on your left side (improves circulation to the placenta) with a pillow between your knees.\n3. Place your right hand on your belly.\n4. Chant the Dhanvantari Mantra 11 times — softly, like a lullaby.\n5. After chanting, hum the melody gently for 2 minutes.\n6. Then speak to your baby: "You are healthy. You are strong. We are ready to meet you."\n7. Allow yourself to drift into sleep.',
    E'सोने से पहले शाम को करें।\n\n1. रोशनी कम करें। कमरा शांत और गर्म रखें।\n2. बाईं करवट लेटें, घुटनों के बीच तकिया रखें।\n3. दाहिना हाथ पेट पर रखें।\n4. धन्वन्तरि मंत्र को 11 बार — धीरे, लोरी की तरह — गाएं।\n5. जप के बाद 2 मिनट धुन गुनगुनाएं।\n6. शिशु से कहें: "तुम स्वस्थ हो। तुम शक्तिशाली हो। हम मिलने को तैयार हैं।"',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — NEWBORN PHASE
  -- ═══════════════════════════════════════════════════════════════════════════

  -- nb_mother_healing — Sutika Rest / Postpartum
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'nb_mother_healing', 'nb_mother_healing_v1', 'meditation',
    'Sutika Paricharya — Postpartum Healing Rest', 'सूतिका परिचर्या — प्रसव के बाद विश्राम',
    E'Ayurveda describes the 40 days after birth as "Sutika Kala" — a period of transformation as profound as the birth itself. Your body has just performed one of the most demanding physical acts possible. The uterus, which expanded to 500 times its original size, must now return to normal. The Sutika Paricharya protocol is designed to restore Vata dosha — the principle of movement that becomes severely aggravated during birth.',
    '["Pacifies the aggravated Vata dosha that governs all movement in the body", "Prevents postpartum mood disorders by establishing calm nervous system patterns", "Promotes faster uterine involution (return to normal size) through abdominal binding", "Warm oil massage stimulates oxytocin — supporting both bonding and milk production", "Rest in the first 40 days directly determines long-term maternal health"]'::jsonb,
    E'THE 40-DAY PROTOCOL (do what you can — even 20% is beneficial):\n\n1. REST: Sleep whenever the baby sleeps. Ask for help without apology.\n2. WARMTH: Keep your body warm at all times. Avoid cold water, cold food, cold environments. Vata is cold — counter it with heat.\n3. ABHYANGA (Oil Massage): Apply warm sesame oil to your entire body before your daily bath. Focus on the abdomen, lower back, and feet.\n4. BELLY BINDING: Wrap your abdomen with a soft muslin cloth (patta bandhan) to support the uterus and speed recovery.\n5. DIET: Eat warm, oily, easily digestible foods — khichdi, ghee, warm soups. Avoid raw salads, cold foods, and excess sugar.\n6. MEDITATION: Once the baby sleeps, lie down and do the womb-closing visualisation below.\n\nWomb-Closing Visualisation (5 min):\nClose your eyes. Place both hands on your abdomen. Breathe deeply. On each exhale, visualise a warm golden light filling the space inside — healing, restoring, closing. Whisper: "Thank you. You did it."',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- nb_ajwain_water — Ayurvedic Hydration
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'nb_ajwain_water', 'nb_ajwain_v1', 'ritual',
    'Ajwain (Carom Seed) Water — Postpartum Healing', 'अजवायन जल — प्रसव के बाद उपचार',
    E'Ajwain (Carom seeds / Trachyspermum ammi) is one of Ayurveda''s most powerful postpartum herbs. It is warming, digestive, anti-flatulent, uterine-cleansing, and galactagogue (promotes milk production).\n\nHOW TO PREPARE:\n• Dry roast 1 tsp of ajwain seeds in a pan (no oil) for 2 minutes until fragrant.\n• Add to 500ml of water.\n• Boil for 5 minutes. Reduce heat and simmer for 10 minutes.\n• Strain. Add a small piece of jaggery (gur) if desired.\n• Drink warm throughout the day.',
    '["Clears ama (undigested toxins) that accumulate during the birth process", "Relieves postpartum gas, bloating and constipation", "Stimulates the uterus to contract back to normal size faster", "Promotes healthy breast milk production (galactagogue)", "Warming properties directly counter the Vata aggravation of postpartum period"]'::jsonb,
    E'Prepare fresh each morning:\n\n1. Dry roast 1 tsp ajwain seeds until fragrant (2 min).\n2. Add to 500ml water. Boil 5 min, simmer 10 min.\n3. Strain into a thermos flask.\n4. Sip warm throughout the day — especially after feeding sessions.\n5. Add small jaggery piece if taste is too strong.\n\nNote: If exclusively breastfeeding, the ajwain benefits pass through the milk to the baby''s digestion too.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- nb_lullaby_time — Soothing Lullaby / Mantra
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'nb_lullaby_time', 'nb_lullaby_v1', 'ritual',
    'Sopana Geet — Sacred Sleep Song', 'सोपान गीत — पवित्र शयन गान',
    E'Traditional lullaby verse (Sopana Geet):\n\nSo ja raja beta so ja\nNaina band kar le so ja\nChanda mama door ke\nPuye pakaye boor ke\nAap khaye thali mein\nMunne ko de pyali mein\n\nThen softly sing or hum:\nRam Ram Rama, Krishna Krishna Kanha\n(Repeat 7 times)',
    E'सो जा राजा बेटा सो जा\nनैना बंद कर ले सो जा\nचंदा मामा दूर के\nपुए पकाए बूर के\nआप खाए थाली में\nमुन्ने को दे प्याली में\n\nफिर धीरे-धीरे गाएं:\nराम राम रामा, कृष्ण कृष्ण कन्हा\n(७ बार)',
    '["Newborn babies recognise their mother''s voice from birth — it is the most calming sound they know", "The rhythm of lullabies synchronises with the baby''s ideal 60-80 BPM heart rate", "Consistent bedtime singing creates a sleep-association cue within 2 weeks", "Sacred mantras embedded in lullabies build the first layers of dharmic memory", "Singing releases oxytocin in the mother — deepening the postnatal bond"]'::jsonb,
    E'At each sleep time (nap or night):\n\n1. Hold the baby close to your chest so they feel your heartbeat.\n2. Dim the lights and reduce stimulation.\n3. Begin rocking gently — side to side or forward and back.\n4. Sing the sopana geet softly — 2–3 times.\n5. Then hum "Ram Ram Rama" in a steady, gentle rhythm for 2–3 minutes.\n6. Let your voice slow down gradually as the baby settles.\n7. Once drowsy, lay the baby down before fully asleep (teaches self-settling).',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — MONTH 1–3
  -- ═══════════════════════════════════════════════════════════════════════════

  -- m1_3_abhyanga — Baby Oil Massage
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'm1_3_abhyanga', 'm1_3_abhyanga_v1', 'ritual',
    'Shishu Abhyanga — Baby Oil Massage', 'शिशु अभ्यंग — शिशु की तेल मालिश',
    E'Shishu Abhyanga is the cornerstone of Ayurvedic infant care. Daily oil massage from birth to 5 years has been proven to:\n\n• Increase weight gain in preterm infants by 47% (NICU studies)\n• Improve myelination — the development of the nerve sheath that speeds brain signals\n• Reduce colic and digestive discomfort\n• Strengthen bones and joints\n• Deepen the mother-child bond through touch\n\nBEST OIL FOR THIS AGE:\n• Sesame oil (til ka tel) — warming, nourishing, the classic choice\n• Coconut oil — cooling, good for warmer months\n• Almond oil (badam tel) — lighter, good for sensitive skin',
    '["Promotes weight gain and height — bone and muscle development", "Myelination of the nervous system — oil massage accelerates brain signal speed", "Reduces colic, gas and abdominal discomfort through abdominal strokes", "Improves sleep duration and quality", "The most powerful form of secure attachment outside feeding"]'::jsonb,
    E'Prepare: Warm the oil by placing the bottle in hot water for 5 minutes. Lay a soft cloth on a warm surface.\n\n1. START WITH LEGS: Hold the baby''s ankle. With your other hand, stroke from hip to ankle with firm, confident strokes. 5 times each leg.\n2. FEET: Roll each toe gently between your fingers. Stroke the sole from heel to toes.\n3. ARMS: Stroke from shoulder to wrist. Open and close the hands.\n4. CHEST: Place both thumbs at the centre of the chest. Stroke outward toward the shoulders. Repeat 5 times.\n5. ABDOMEN: With a flat palm, make slow clockwise circles around the navel. This follows the direction of digestion and relieves gas.\n6. BACK: Turn baby onto their tummy (once they have head control). Stroke from shoulders to buttocks with flat palms.\n7. GENTLE MOVEMENTS: After massage, gently bicycle the legs and open/close the arms.\n\nTotal time: 10–15 minutes. Then give a warm bath.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- m1_3_sun_time — Morning Sun / Nishkramana Prep
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'm1_3_sun_time', 'm1_3_sun_v1', 'ritual',
    'Nishkramana — The First Outing (Sun Preparation)', 'निष्क्रमण — प्रथम बाहरी भ्रमण',
    E'In the Vedic tradition, Nishkramana (the first outing) is a samskara that takes place in the third month. Before this formal ceremony, daily sunlight exposure is the prescribed preparation — building the baby''s immune system and vitamin D stores.\n\nSunlight in the first months:\n• Newborns have minimal melanin — their skin produces Vitamin D very efficiently\n• Even 5–10 minutes of morning light (before 9 AM) is sufficient\n• Sunlight on the baby''s back is most effective\n• Never expose to direct harsh midday sun',
    '["Prevents Vitamin D deficiency — essential for bone mineralisation and immune function", "Morning light sets the baby''s circadian rhythm (day-night cycle) within weeks", "Fresh air exposure builds respiratory strength", "Gentle outdoor stimulation supports sensory development", "Prepares the baby for the formal Nishkramana samskara ceremony"]'::jsonb,
    E'1. Choose the morning sun — between 7 and 9 AM is ideal.\n2. Take the baby outside or sit near a window where sunlight enters.\n3. Support the baby in your arms or in a carry cloth (janamaz / kangaroo hold).\n4. Let morning sunlight fall on the baby''s back and legs — avoid the face.\n5. Spend 10 minutes in this gentle morning light.\n6. Speak softly to the baby: name the trees, the birds, the sky.\n7. This sensory narration builds language pathways from this early age.\n8. End with a small prayer of gratitude for the morning.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — MONTH 3–6
  -- ═══════════════════════════════════════════════════════════════════════════

  -- m3_6_sensory_play — Sensory Play & Mantras
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'm3_6_sensory_play', 'm3_6_sensory_v1', 'ritual',
    'Mantra Play — Sensory Learning with Sacred Sound', 'मंत्र खेल — पवित्र ध्वनि के साथ संवेदी अधिगम',
    E'Simple mantras for play:\n\n"Om Namah Shivaya" — chant while making eye contact, touching baby''s fingers\n"Jai Jai Devi" — chant while gently bouncing\n"Om Namo Narayanaya" — chant while moving baby''s arms\n\nPlay song:\nNani teri morni ko mor le gaye\nBaaki jo bacha tha kaale chor le gaye\n(Repeat with gestures)',
    E'खेल के लिए सरल मंत्र:\n\n"ॐ नमः शिवाय" — आँखों में देखते हुए बोलें\n"जय जय देवी" — धीरे उछालते हुए बोलें\n"ॐ नमो नारायणाय" — हाथ हिलाते हुए बोलें',
    '["3–6 months is the critical window for sensory neural pathway formation", "Sacred mantras introduced during play create lasting positive neural associations", "Eye contact while chanting develops social bonding and mirror neuron systems", "Varied vocal tones during songs build auditory discrimination", "Mantra-linked movement creates body-sound-memory associations"]'::jsonb,
    E'1. Lay the baby on a clean, safe surface in front of you.\n2. Make sure they are alert (not drowsy or hungry).\n3. Begin with eye contact — hold their gaze and smile.\n4. Start with "Om Namah Shivaya" — say it slowly, touching each finger.\n5. Watch for smiles and vocalisations — these are their responses.\n6. Introduce a colourful object (red or yellow are most visible at this age).\n7. Move it slowly from side to side — baby will track it. This builds visual focus.\n8. Alternate between mantras, songs, and object-play for 10 minutes.\n9. Follow the baby''s lead — when they look away, it means "I need a break."',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- m3_6_tummy_time — Tummy Time
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'm3_6_tummy_time', 'm3_6_tummy_v1', 'ritual',
    'Tummy Time — Building Core Strength', 'टमी टाइम — मूल शक्ति निर्माण',
    E'Tummy time is non-negotiable for healthy motor development. Babies who get adequate daily tummy time develop:\n• Head and neck control (3–4 months)\n• Rolling over (4–5 months)\n• Sitting unsupported (6–7 months)\n• Crawling (8–10 months)\n\nAll of these milestones depend on the core strength built during tummy time.',
    '["Builds neck, shoulder, and core muscles critical for all major motor milestones", "Prevents positional plagiocephaly (flat head syndrome)", "Develops spatial awareness and proprioception", "Strengthens the vestibular (balance) system", "Tummy time frustration, when gently supported, builds resilience and tolerance for challenge"]'::jsonb,
    E'Start with 1-2 minutes and build to 10+ minutes by 4 months.\n\n1. Choose a time when the baby is alert and content (30–60 min after feeding).\n2. Lay a soft, firm surface (a play mat, not a soft bed).\n3. Place baby face-down, arms forward, elbows at shoulder level.\n4. Get down to their level — face-to-face. Maintain eye contact.\n5. Use toys, your voice, or a small mirror to encourage them to lift their head.\n6. If they cry, don''t rush to end it — stay encouraging for 1 more minute. Then gently roll them to their back.\n7. Gradually increase time each day.\n8. Supervised tummy time on your chest (chest-to-chest) also counts for newborns.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — MONTH 6–12
  -- ═══════════════════════════════════════════════════════════════════════════

  -- m6_12_solid_food — Annaprashana Mindful Feeding
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, transliteration, translation,
     benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'm6_12_solid_food', 'm6_12_food_v1', 'ritual',
    'Annapurna Mantra — Before First Foods', 'अन्नपूर्णा मंत्र — प्रथम आहार से पूर्व',
    'अन्नपूर्णे सदापूर्णे\nशंकरप्राणवल्लभे ।\nज्ञानवैराग्यसिद्ध्यर्थं\nभिक्षां देहि च पार्वति ॥',
    'अन्नपूर्णा माँ, जो सदा परिपूर्ण हैं,\nशंकर की प्रिय पार्वती,\nज्ञान और वैराग्य की सिद्धि के लिए\nहमें भिक्षा दें।',
    'Annapurne sadapurne Shankaraprana-vallabhe.\nJnana-vairagya-siddhyartham bhiksham dehi cha Parvati.',
    'O Annapurna, ever-complete, dear to the life of Shankara — for the attainment of knowledge and detachment, O Parvati, grant me nourishment.',
    '["Establishes a ritual of gratitude before food — builds a lifelong healthy relationship with eating", "Annapurna mantra invokes the divine feminine energy of nourishment", "Ritualised feeding reduces feeding refusals and food anxiety in toddlerhood", "Chanting before each meal creates a calming pre-feeding association for the baby", "Iron-rich first foods prevent the anaemia that peaks at 6–9 months"]'::jsonb,
    E'AT EACH MEAL:\n1. Before offering any food, chant the Annapurna Mantra 3 times.\n2. Show the food to the baby. Let them smell it.\n3. Offer a small amount on a clean finger first (before a spoon).\n4. Allow the baby to control the pace — never force.\n5. Keep mealtimes joyful — smile, use positive sounds.\n\nFIRST FOODS (introduce one at a time, 3 days apart):\nWeek 1: Rice kanji (thin rice water)\nWeek 2: Moong dal water\nWeek 3: Mashed sweet potato\nWeek 4: Mashed banana\nWeek 5: Mashed carrot with ghee\nAll foods should be warm, soft, and mixed with a little ghee.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- m6_12_story_time — First Stories
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'm6_12_story_time', 'm6_12_story_v1', 'read',
    'Panchatantra First Stories', 'पंचतंत्र — प्रथम कथाएं',
    E'THE CROW AND THE SNAKE (Panchatantra)\n\nOnce upon a time, in a great forest, a crow and his wife lived in a tall tree. At the foot of their tree lived a black snake who would eat their eggs every year.\n\nThe crow thought of a plan. He flew to a nearby king''s garden and stole a golden necklace from the princess. He flew back slowly, making sure the guards saw him. The guards followed him to the snake''s hole.\n\nWhen they reached the tree, the crow dropped the necklace into the snake''s hole. The guards dug up the hole to retrieve the necklace — and killed the snake.\n\nMORAL: Intelligence defeats brute strength. A clever plan achieves what force cannot.',
    '["Reading to babies from 6 months builds double the vocabulary compared to non-reading peers by age 3", "Varied intonation during storytelling builds auditory discrimination", "The moral structure of Panchatantra stories builds ethical reasoning from infancy", "Story sessions establish a reading habit that predicts academic success", "Physical closeness during story time deepens attachment"]'::jsonb,
    E'1. Choose a calm time — ideally before a nap or before bed.\n2. Hold the baby on your lap or lie facing them.\n3. Read in an expressive voice — vary your pitch, speed, and emotion.\n4. Show pictures if available, or use your hands to act out the story.\n5. Make animal sounds, voice the characters differently.\n6. At the moral of the story, pause and speak it clearly.\n7. Even if the baby doesn''t understand the words — they understand your voice, your emotion, and the ritual of being read to.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- CONTENT POOL — YEAR 1+
  -- ═══════════════════════════════════════════════════════════════════════════

  -- y1_toddler_yoga — Toddler Yoga Play
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'y1_toddler_yoga', 'y1_toddler_yoga_v1', 'yoga',
    'Animal Yoga Play — Toddler Movement', 'पशु योग खेल — शिशु गति',
    E'Poses to do TOGETHER with your toddler:\n\n🐱 CAT-COW (Marjariasana)\nGet on all fours together. "Meow like a cat" — arch back. "Moo like a cow" — look up.\n\n🐶 DOWNWARD DOG (Adho Mukha Svanasana)\n"Can you be a doggie?" Push hips up to make an upside-down V. Bark optional.\n\n🦋 BUTTERFLY (Baddha Konasana)\nSit facing each other. Soles of feet touching. Flutter knees up and down. "Flap your wings!"\n\n🌳 TREE POSE (Vrksasana)\n"Can you be a tree?" Stand on one foot. Arms up like branches. Wobbling is fine — it''s part of the game.\n\n🐸 FROG JUMPS (Malasana into jump)\nSquat down low like a frog. Then jump up with arms out.',
    '["Animal yoga builds coordination, balance, and gross motor skills", "Parent-child yoga significantly strengthens secure attachment", "Body-awareness through playful movement reduces injury risk in early childhood", "Imaginative play during yoga develops creative and cognitive flexibility", "Regular physical movement supports healthy sleep cycles in toddlers"]'::jsonb,
    E'1. Find a safe open floor space — clear of obstacles.\n2. Get down to the toddler''s level — be playful, not instructional.\n3. Do each pose together — demonstrate first, encourage them to copy.\n4. Use the animal sounds and names to make it memorable.\n5. Don''t worry about "correct" form — the movement itself is the benefit.\n6. When a toddler falls or wobbles, laugh and continue. This builds resilience.\n7. Play for 10 minutes, then end with a quiet "rest" (Savasana) — just lie down together for 1 minute.',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- y1_night_gratitude — Bedtime Gratitude
  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, title_hindi,
     content, content_hindi, benefits, instruction, display_order, rotation_type)
  VALUES (
    gs_id, 'y1_night_gratitude', 'y1_gratitude_v1', 'ritual',
    'Bedtime Dhanyavad — Gratitude Practice', 'सोने से पहले धन्यवाद',
    E'Bedtime ritual:\n\n1. "What made you happy today?"\n2. "Who did something kind for you?"\n3. "What are you grateful for?"\n\nThen together:\n"Dhanyavad Suraj ke liye" (Thank you for the sun)\n"Dhanyavad khane ke liye" (Thank you for the food)\n"Dhanyavad aaj ke liye" (Thank you for today)\n\nEnd with:\n"Om Shanti, Shanti, Shanti"',
    E'सोने से पहले:\n\n1. "आज तुम्हें क्या अच्छा लगा?"\n2. "किसने तुम्हारे लिए कुछ अच्छा किया?"\n3. "तुम किसके लिए आभारी हो?"\n\nसाथ में:\n"धन्यवाद सूरज के लिए"\n"धन्यवाद खाने के लिए"\n"धन्यवाद आज के लिए"\n\nअंत में:\n"ॐ शान्ति, शान्ति, शान्ति"',
    '["Gratitude practice before bed is the single most evidence-based predictor of childhood happiness", "Teaching a child to name what they are grateful for builds emotional vocabulary", "The routine of bedtime reflection creates a sense of safety and closure to the day", "Om Shanti chanting reduces cortisol and triggers the parasympathetic (rest) nervous system", "Toddlers who practice gratitude rituals show higher empathy scores by age 5"]'::jsonb,
    E'Each evening before sleep:\n\n1. Sit with the child on their bed or in a comfortable corner.\n2. Dim the lights and reduce noise.\n3. Ask the 3 gratitude questions — listen patiently to their answer.\n4. Offer your own answers too ("Mummy is grateful for playing with you today").\n5. Say the Dhanyavad phrases together — let the child repeat them.\n6. Chant "Om Shanti" 3 times softly.\n7. Place your hands together in prayer and bow gently.\n8. Lie the child down and say: "Sleep well. Tomorrow will be beautiful."',
    1, 'sequential'
  )
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- DAILY WISDOM POOL (category = 'wisdom', task_slug = 'wisdom')
  -- Works for every journey type — just change journey_type_id.
  -- App queries: WHERE category = 'wisdom' AND journey_type_id = ?
  -- Picks by: dayOfJourney % pool.length
  -- ═══════════════════════════════════════════════════════════════════════════

  INSERT INTO journey_content_pool
    (journey_type_id, task_slug, slug, category, title, content, display_order, rotation_type)
  VALUES
  (gs_id, 'wisdom', 'wisdom_gs_1', 'wisdom', 'On the Womb as a Classroom',
   E'The Vedas teach that the womb is the first gurukul — the first school. Every thought you think, every word you speak, every emotion you feel becomes the curriculum. You are not waiting for your child to be born to begin their education. You have already begun.',
   1, 'sequential'),
  (gs_id, 'wisdom', 'wisdom_gs_2', 'wisdom', 'On Sacred Sound',
   E'Repeating sacred mantras around a growing child does not require the child to understand the words. Sound vibration itself is the teaching. The Sama Veda was composed entirely for its sound, not its meaning. Your voice is the most powerful instrument in the universe for this child.',
   2, 'sequential'),
  (gs_id, 'wisdom', 'wisdom_gs_3', 'wisdom', 'On Rest as Duty',
   E'In our culture, the word for rest is "vishrama" — which also means to come home to oneself. A mother who rests is not being lazy. She is performing her highest dharma. You cannot pour from an empty vessel. Rest is sacred.',
   3, 'sequential'),
  (gs_id, 'wisdom', 'wisdom_gs_4', 'wisdom', 'On the Incoming Soul',
   E'Ancient texts describe the soul choosing its parents before birth — selecting the family, the environment, and even the challenges it needs for its evolution. You were chosen. This child trusted you with their earthly journey. That trust is the most profound gift and responsibility.',
   4, 'sequential'),
  (gs_id, 'wisdom', 'wisdom_gs_5', 'wisdom', 'On Sattvic Living',
   E'Sattvic means pure, calm, and luminous. A sattvic environment — gentle words, clean food, harmonious music, loving touch — does not just feel better. It literally shapes the baby''s epigenome: which genes are turned on or off in response to the environment. You are writing the first chapter of their biology.',
   5, 'sequential'),
  (gs_id, 'wisdom', 'wisdom_gs_6', 'wisdom', 'On Consistency',
   E'One day of perfect practice is worth less than one hundred days of imperfect consistency. The rituals do not need to be beautiful. They do not need to be long. They need only to be repeated. The river carves the rock not by force, but by showing up every day.',
   6, 'sequential'),
  (gs_id, 'wisdom', 'wisdom_gs_7', 'wisdom', 'On Letting Go',
   E'Bharata Muni, in the Natya Shastra, writes of the highest art being the ability to be fully present and then fully let go. Birth is this art in its most raw form. The mother who trusts her body and releases control does not give up — she surrenders to a wisdom older than thought.',
   7, 'sequential')
  ON CONFLICT DO NOTHING;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- JOURNEY MILESTONES — 8 Garbh Sanskar Samskaras
  -- ═══════════════════════════════════════════════════════════════════════════

  INSERT INTO journey_milestones
    (journey_type_id, phase_id, slug, title, title_hindi,
     description, description_hindi, milestone_type,
     milestone_order, icon, allow_photo, allow_notes, is_required, coin_reward)
  VALUES

  -- 1. Garbhadhana Samskara
  (gs_id, ph_planning, 'garbhadhana', 'Garbhadhana Samskara', 'गर्भाधान संस्कार',
   E'The first of the 16 Samskaras (sacred rites of passage). Garbhadhana is the conscious intention ceremony performed before conception, invoking divine blessings for the incoming soul. Mantras are chanted, a puja is performed, and both partners commit to nurturing a sattvic (pure) environment for the new life.\n\nSignificance: This samskara transforms the biological act of conception into a sacred, intentional, spiritually charged event. It is the difference between a child conceived in distraction and a child conceived in love and prayer.',
   E'16 संस्कारों में प्रथम। गर्भाधान संस्कार गर्भधारण से पूर्व की पवित्र अभिनव क्रिया है जिसमें आने वाली आत्मा के लिए दिव्य आशीर्वाद मांगा जाता है। मंत्र पठन, पूजा और संकल्प के साथ दोनों साथी शुद्ध वातावरण बनाने की प्रतिज्ञा लेते हैं।',
   'samskara', 1, '🌱', true, true, true, 50),

  -- 2. Punsavana
  (gs_id, ph_t1, 'punsavana', 'Punsavana Samskara', 'पुंसवन संस्कार',
   E'Performed in the 2nd or 3rd month of pregnancy, Punsavana is the ceremony for the protection and strengthening of the fetus. The name derives from "putra" (child) and "savana" (quickening/bringing forth). Mantras are chanted for the health, intellect, and spiritual nature of the child.\n\nTraditionally: The mother chants specific Atharva Veda mantras. Neem leaves and honey are offered. The father whispers a prayer into the mother''s right ear about the kind of human being they hope to welcome into the world.',
   E'गर्भावस्था के दूसरे या तीसरे माह में किया जाने वाला यह संस्कार भ्रूण की सुरक्षा और पुष्टि के लिए है। मंत्र पठन से शिशु के स्वास्थ्य, बुद्धि और आध्यात्मिक स्वभाव की कामना की जाती है।',
   'samskara', 2, '🌅', true, true, true, 50),

  -- 3. Simantonnayana
  (gs_id, ph_t2, 'simantonnayana', 'Simantonnayana Samskara', 'सीमन्तोन्नयन संस्कार',
   E'Performed in the 5th, 7th, or 8th month of pregnancy, Simantonnayana means "parting of the hair" (sima = parting, unnayana = upward movement). The husband performs a ritual hair-parting on the wife, accompanied by Vedic chants, symbolising protection, love, and shared responsibility for the coming birth.\n\nSignificance: This is one of the most beautiful samskaras — an intimate ritual of deep connection between husband and wife in the final phase of pregnancy. It acknowledges the woman''s courage and honours the life they are creating together.',
   E'गर्भावस्था के 5वें, 7वें या 8वें माह में किया जाता है। पति वैदिक मंत्रों के साथ पत्नी की मांग भरता है — यह आगामी प्रसव के लिए सुरक्षा, प्रेम और साझा जिम्मेदारी का प्रतीक है।',
   'samskara', 3, '🌸', true, true, true, 75),

  -- 4. Jatakarma
  (gs_id, ph_newborn, 'jatakarma', 'Jatakarma Samskara', 'जातकर्म संस्कार',
   E'Performed immediately after birth, before the umbilical cord is cut. Jatakarma is the welcoming ceremony for the newborn''s soul. The father touches the baby''s tongue with honey and ghee while chanting: "I give you wisdom, I give you energy, I give you life force."\n\nSaraswati Mantra is whispered into the baby''s right ear. This is the first sound the newborn hears — not a worldly word, but a sacred name.\n\nSignificance: Jatakarma acknowledges that this baby is not just a biological organism, but a conscious soul entering the material world. The ceremony creates the sacred boundary between the womb world and the earth world.',
   E'जन्म के तुरंत बाद, नाभिनाल काटने से पहले किया जाता है। पिता शहद और घी से शिशु की जीभ स्पर्श करते हुए मंत्र पढ़ते हैं। सरस्वती मंत्र शिशु के दाहिने कान में फुसफुसाया जाता है — पहली आवाज जो वह सुनता है।',
   'samskara', 4, '👶', true, true, true, 100),

  -- 5. Namakarana
  (gs_id, ph_m1_3, 'namakarana', 'Namakarana Samskara', 'नामकरण संस्कार',
   E'On the 11th or 12th day after birth (or on a muhurta chosen by a Jyotishi), the baby receives their name in a formal ceremony. The name is chosen according to the baby''s Nakshatra (birth star), with deep consideration of its sound vibrations and meaning.\n\nThe ceremony: The baby is placed in the father''s lap. The name is whispered into the baby''s right ear 3 times. The family then calls the child by their new name for the first time.\n\nSignificance: In Sanskrit, "Nama" means name, and "Karana" means making. The name is not just an identifier — it is a vibrational signature that the child will carry for life. A well-chosen name is considered a lifelong mantra.',
   E'जन्म के 11वें-12वें दिन या ज्योतिषी द्वारा निर्धारित मुहूर्त पर शिशु को उनके नक्षत्र के अनुसार नाम दिया जाता है। नाम पिता की गोद में बैठे शिशु के दाहिने कान में तीन बार फुसफुसाया जाता है।',
   'samskara', 5, '☀️', true, true, true, 75),

  -- 6. Nishkramana
  (gs_id, ph_m3_6, 'nishkramana', 'Nishkramana Samskara', 'निष्क्रमण संस्कार',
   E'In the 3rd or 4th month, the baby is formally taken outside for the first time in a ceremonial outing. The baby is dressed in new clothes. The father or senior family member carries the child out of the house at an auspicious time (typically sunrise or a muhurta).\n\nThe baby is shown the sun, the sky, and the earth. A short prayer is offered: "May this child grow as the sun rises — fresh, powerful, and full of light."\n\nSignificance: Nishkramana is the first introduction of the child to the world outside the home. It marks the expansion of their universe from the intimate circle of family to the wider world of nature and society.',
   E'3-4 माह में शिशु को पहली बार औपचारिक रूप से बाहर ले जाया जाता है। पिता या वरिष्ठ परिवारजन शिशु को शुभ मुहूर्त पर बाहर ले जाते हैं। शिशु को सूर्य, आकाश और धरती दिखाई जाती है।',
   'samskara', 6, '🎨', false, true, false, 50),

  -- 7. Annaprashana
  (gs_id, ph_m6_12, 'annaprashana', 'Annaprashana Samskara', 'अन्नप्राशन संस्कार',
   E'The first feeding of solid food — typically rice mixed with ghee and jaggery — is a celebrated samskara performed in the 6th month (for boys) or 5th or 7th month (for girls), at an auspicious time.\n\nThe ceremony: The Annapurna mantra is chanted. A small amount of kheer (rice pudding with milk and jaggery) is prepared. The father or grandfather feeds the first spoonful while the family chants "Annapurne sadapurne..."\n\nSignificance: This samskara marks the child''s first participation in the family''s food culture — the most fundamental expression of belonging, nourishment, and love. It is also a medical milestone: the first introduction of complementary nutrition beyond breast milk.',
   E'6वें माह में (लड़की के लिए 5वें या 7वें माह) शुभ मुहूर्त पर प्रथम अन्न खिलाया जाता है। अन्नपूर्णा मंत्र के साथ पिता या दादाजी खीर का पहला निवाला खिलाते हैं।',
   'samskara', 7, '📖', true, true, true, 75),

  -- 8. Chudakarana
  (gs_id, ph_y1, 'chudakarana', 'Chudakarana Samskara', 'चूड़ाकरण संस्कार',
   E'The first haircut ceremony, typically performed in the 1st or 3rd year. All hair grown from birth is shaved as a symbol of releasing the karma brought from past lives, and allowing the child to begin their life in this world with a clean, unburdened energetic slate.\n\nThe ceremony: A Vedic priest conducts a havan (fire ceremony). The hair is shaved by a barber while mantras are chanted. The hair is then immersed in a river or buried in sacred soil.\n\nSignificance: Hair in Vedic tradition carries memory — both genetic and karmic. The Chudakarana removes the child from the burden of all that came before and marks their full arrival into this incarnation as themselves.',
   E'पहले या तीसरे वर्ष में प्रथम मुंडन किया जाता है। जन्म से उगे सभी बाल काटे जाते हैं — पूर्वजन्मों के कर्म छोड़ने और इस जन्म में नई शुरुआत का प्रतीक। वैदिक पुरोहित द्वारा हवन के साथ यह संस्कार संपन्न होता है।',
   'samskara', 8, '🤸', true, true, false, 50)

  ON CONFLICT (journey_type_id, slug) DO UPDATE SET
    title             = EXCLUDED.title,
    title_hindi       = EXCLUDED.title_hindi,
    description       = EXCLUDED.description,
    description_hindi = EXCLUDED.description_hindi,
    milestone_order   = EXCLUDED.milestone_order,
    is_required       = EXCLUDED.is_required,
    coin_reward       = EXCLUDED.coin_reward,
    updated_at        = NOW();

END$$;
