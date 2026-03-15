-- ============================================================
-- GARBH SANSKAR JOURNEY TASKS & CONTENT POOL SEED
-- Full population with both English and Hindi for all tasks.
-- ============================================================

-- Ensure unique slug on journey_tasks so we can safely upsert
ALTER TABLE journey_tasks DROP CONSTRAINT IF EXISTS journey_tasks_slug_key;
ALTER TABLE journey_tasks ADD CONSTRAINT journey_tasks_slug_key UNIQUE (slug);

DO $$
DECLARE
  garbh_sanskar_id UUID := '11b628c4-07d5-408f-8fe1-d570bac8a799';

  phase_planning UUID;
  phase_t1 UUID;
  phase_t2 UUID;
  phase_t3 UUID;
  phase_newborn UUID;
  phase_m1_3 UUID;
  phase_m3_6 UUID;
  phase_m6_12 UUID;
  phase_y1_plus UUID;
BEGIN
  -- Fetch phase IDs
  SELECT id INTO phase_planning FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'planning';
  SELECT id INTO phase_t1 FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'trimester_1';
  SELECT id INTO phase_t2 FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'trimester_2';
  SELECT id INTO phase_t3 FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'trimester_3';
  SELECT id INTO phase_newborn FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'newborn';
  SELECT id INTO phase_m1_3 FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'month_1_3';
  SELECT id INTO phase_m3_6 FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'month_3_6';
  SELECT id INTO phase_m6_12 FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'month_6_12';
  SELECT id INTO phase_y1_plus FROM journey_phases WHERE journey_type_id = garbh_sanskar_id AND slug = 'year_1_plus';

  IF phase_planning IS NULL THEN
     RAISE EXCEPTION 'Phases not found. Did you run the schema migration?';
  END IF;

  -- ==========================================
  -- 1. PLANNING PHASE TASKS
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_planning, 'plan_mantra_daily', 'Daily Pre-Conception Mantra', 'दैनिक गर्भधारण पूर्व मंत्र', 'mantra', 1, '📿', 5, 10, 'Chant for a healthy body and pure mind.', 'Recite 108 times daily.'),
  (phase_planning, 'plan_yoga_asana', 'Fertility Yoga', 'प्रजनन योग', 'yoga', 2, '🧘‍♀️', 15, 15, 'Yoga poses to improve circulation to pelvic region.', 'Perform early morning on an empty stomach.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 2. TRIMESTER 1 TASKS (Weeks 1-13)
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_t1, 't1_morning_mantra', 'Morning Garbh Gayatri', 'प्रातः गर्भ गायत्री', 'mantra', 1, '🌅', 10, 10, 'Start your day with the powerful Garbh Gayatri mantra.', 'Listen or chant in a quiet space.'),
  (phase_t1, 't1_meditation', 'Bonding Meditation', 'जुड़ाव ध्यान', 'meditation', 2, '🧠', 10, 15, '10 minutes of visualization and deep connection.', 'Close eyes and imagine a golden light around your womb.'),
  (phase_t1, 't1_diet_check', 'Garbhini Paricharya (Ayurvedic Diet 1)', 'गर्भिणी परिचर्या (आयुर्वेदिक आहार 1)', 'read', 3, '🥗', 5, 5, 'Daily check for Trimester 1 Ayurvedic diet (Sattvic & Ojas building).', 'Review the diet tips and ensure you have your warm milk with ghee.'),
  (phase_t1, 't1_pranayama_day4', 'Day 4: Gentle Nadi Shodhana', 'दिन 4: सौम्य नाड़ी शोधन', 'yoga', 4, '🌬️', 10, 10, 'Alternate nostril breathing to balance Vata dosha during early pregnancy.', 'Practice gently without holding breath.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 3. TRIMESTER 2 TASKS (Weeks 14-27)
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_t2, 't2_garbh_samvad', 'Neuro-Acoustic Stimulation', 'गर्भ संवाद (मस्तिष्क ध्वनि उत्तेजना)', 'ritual', 1, '🗣️', 5, 10, 'Scientific stimulation of baby''s hearing via maternal voice.', 'Read the provided script clearly with hands on belly.'),
  (phase_t2, 't2_evening_listening', 'Vishnu Sahasranama & Ragas', 'विष्णु सहस्रनाम और राग', 'audio', 2, '🎵', 15, 15, 'Listen to sacred chants and Raga Malkauns for baby’s protection.', 'Play softly near your abdomen.'),
  (phase_t2, 't2_yoga_stretch', 'Gentle Prenatal Stretches', 'हल्का प्रसवपूर्व खिंचाव', 'yoga', 3, '🧘‍♀️', 10, 10, 'Cat-cow and pelvic tilts to relieve back pain and build flexibility.', 'Perform slowly and breathe deeply.'),
  (phase_t2, 't2_creativity_rasa', 'Creative Expression (Rasa)', 'रचनात्मक अभिव्यक्ति (रस)', 'ritual', 4, '🎨', 10, 15, 'Boost the baby''s intellect (Dhi) through maternal creativity.', 'Paint, draw, or write a journal entry.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 4. TRIMESTER 3 TASKS (Weeks 28-40)
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_t3, 't3_birth_prep_meditation', 'Pranayama & Apana Vayu', 'अपान वायु और श्वास ध्यान', 'meditation', 1, '🕊️', 15, 15, 'Focusing on downward-moving energy to prepare for childbirth.', 'Breathe deeply and visualize the pelvic floor opening.'),
  (phase_t3, 't3_hip_opening', 'Malasana & Pelvic Prep', 'मलासन और पेल्विक योग', 'yoga', 2, '🌸', 10, 10, 'Supported squatting for optimal fetal positioning (Requires caution).', 'Use a wall or block for support. Do not overstrain.'),
  (phase_t3, 't3_calming_lullaby', 'Night Lullaby & Dhanvantari', 'रात्रि लोरी और धन्वंतरि मंत्र', 'lullaby', 3, '🌙', 5, 10, 'Heal the body and calm the baby before sleeping.', 'Play or sing a lullaby and recite Dhanvantari Mantra.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 5. NEWBORN PHASE (0-27 Days) TASKS
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_newborn, 'nb_mother_healing', 'Jata Karma / Sutika Rest', 'जातकर्म / सूतिका विश्राम', 'meditation', 1, '❤️', 10, 15, 'Deep guided rest and Vata pacification for postpartum recovery.', 'Listen while the baby sleeps.'),
  (phase_newborn, 'nb_ajwain_water', 'Ayurvedic Hydration', 'आयुर्वेदिक जल (अजवायन)', 'ritual', 2, '💧', 2, 5, 'Drink warm ajwain water for digestion & healing.', 'Sip throughout the day as recommended.'),
  (phase_newborn, 'nb_lullaby_time', 'Soothing Lullaby', 'शांतिदायक लोरी', 'lullaby', 3, '🎶', 10, 10, 'Calm the baby to sleep with gentle sacred sounds.', 'Sing or play quietly in the nursery.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 6. MONTH 1-3 PHASE TASKS
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_m1_3, 'm1_3_abhyanga', 'Baby Oil Massage', 'शिशु तेल मालिश (अभ्यंग)', 'ritual', 1, '👶', 15, 15, 'Daily traditional massage to strengthen baby’s bones.', 'Use warm oil and gentle, loving strokes.'),
  (phase_m1_3, 'm1_3_sun_time', 'Morning Sun (Nishkramana Prep)', 'सुबह की धूप', 'ritual', 2, '☀️', 10, 10, 'Gentle early morning sunlight for Vitamin D.', 'Keep direct sunlight away from baby’s eyes.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 7. MONTH 3-6 PHASE TASKS
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_m3_6, 'm3_6_sensory_play', 'Sensory Play & Mantras', 'संवेदी खेल और मंत्र', 'audio', 1, '🎨', 10, 10, 'Engage the baby with soft chanting and colorful objects.', 'Sing simple mantras while making eye contact.'),
  (phase_m3_6, 'm3_6_tummy_time', 'Tummy Time Joy', 'टमी टाइम का आनंद', 'ritual', 2, '🧸', 5, 10, 'Essential for neck strength.', 'Place baby on tummy and supervise carefully.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 8. MONTH 6-12 PHASE TASKS
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_m6_12, 'm6_12_solid_food', 'Mindful Feeding (Annaprashana)', 'सजग भोजन (अन्नप्राशन)', 'ritual', 1, '🥣', 15, 10, 'Incorporate spiritual mindfulness into baby''s meals.', 'Chant Annapurna mantra before the first bite.'),
  (phase_m6_12, 'm6_12_story_time', 'First Stories (Panchatantra/Epics)', 'पहली कहानियाँ (पंचतंत्र/महाकाव्य)', 'read', 2, '📖', 10, 15, 'Read moral stories with varied voice tones.', 'Make it expressive and engaging for the child.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

  -- ==========================================
  -- 9. YEAR 1 PLUS PHASE TASKS
  -- ==========================================
  INSERT INTO journey_tasks (phase_id, slug, title, title_hindi, task_type, display_order, icon, duration_minutes, coin_reward, description, instruction) VALUES
  (phase_y1_plus, 'y1_toddler_yoga', 'Toddler Yoga Play', 'टॉडलर योगा खेल', 'yoga', 1, '🤸‍♂️', 10, 15, 'Fun animal poses to build toddler mobility and focus.', 'Do poses together (e.g., Cat, Dog, Tree).'),
  (phase_y1_plus, 'y1_night_gratitude', 'Bedtime Gratitude', 'सोते समय कृतज्ञता', 'ritual', 2, '🙏', 5, 10, 'Teach the child to say "Dhanyavad" (Thank you) before sleep.', 'List three good things that happened today.')
  ON CONFLICT (slug) DO UPDATE SET
      title = EXCLUDED.title, title_hindi = EXCLUDED.title_hindi,
      instruction = EXCLUDED.instruction, description = EXCLUDED.description;

END $$;

-- Clean up existing pool entries to re-seed fresh without duplicates
DELETE FROM journey_content_pool WHERE journey_type_id = '11b628c4-07d5-408f-8fe1-d570bac8a799';

-- ============================================================
-- CONTENT POOL SEED (English & Hindi Translations)
-- ============================================================
INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, instruction, instruction_hindi, display_order) VALUES

-- plan_mantra_daily
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'plan_mantra_daily', 'plan_mantra_daily_c1', 'general', 'Santana Gopala Mantra', 'संतान गोपाल मंत्र', 
'Om Shrim Hrim Klim Glaum Devaki-Suta Govinda Vasudeva Jagatpate, Dehi Me Tanayam Krishna Tvam Aham Sharanam Gatah', 
'ॐ श्रीं ह्रीं क्लीं ग्लौं देवकीसुत गोविन्द वासुदेव जगत्पते, देहि मे तनयं कृष्ण त्वामहं शरणं गतः', 
'Chant this 108 times using a Tulsi mala.', 'तुलसी माला का उपयोग करके इसे 108 बार जपें।', 1),

-- t1_morning_mantra
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't1_morning_mantra', 't1_morning_mantra_c1', 'general', 'Garbh Gayatri Mantra', 'गर्भ गायत्री मंत्र', 
'Om Bhur Bhuvah Svah, Tat Savitur Varenyam, Bhargo Devasya Dhimahi, Dhiyo Yo Nah Prachodayat', 
'ॐ भूर्भुवः स्वः, तत्सवितुर्वरेण्यं, भर्गो देवस्य धीमहि, धियो यो नः प्रचोदयात्', 
'Sit facing east. Close your eyes and focus on the light of the sun nourishing your womb.', 'पूर्व दिशा की ओर मुख करके बैठें। आंखें बंद करें और गर्भ को पोषित करने वाले सूर्य के प्रकाश पर ध्यान केंद्रित करें।', 1),

-- t1_meditation
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't1_meditation', 't1_meditation_c1', 'general', 'Golden Light Visualization', 'स्वर्णिम प्रकाश की परिकल्पना', 
'Imagine a warm, golden light above your head. As you breathe in, this light flows down into your womb, creating a glowing shield of protection and pure love around your developing baby.', 
'अपने सिर के ऊपर एक गर्म, सुनहरे प्रकाश की कल्पना करें। जैसे ही आप सांस लेती हैं, यह प्रकाश आपके गर्भ में प्रवाहित होता है, जो आपके विकसित हो रहे शिशु के चारों ओर सुरक्षा और शुद्ध प्रेम की एक चमकती ढाल बनाता है।', 
'Breathe deeply and gently for 10 minutes.', '10 मिनट तक गहरी और कोमल सांसें लें।', 1),

-- t1_diet_check
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't1_diet_check', 't1_diet_check_c1', 'general', 'Garbhini Paricharya (Ayurvedic Diet 1)', 'गर्भिणी परिचर्या (आयुर्वेदिक आहार 1)', 
'Trimester 1 is governed by Kapha and Vata doshas. Morning sickness is common. Focus on sweet, cooling, and easily digestible foods. Warm milk with a pinch of cardamom and ghee helps build Ojas (immunity) and nourishes the developing embryo’s nervous system.', 
'पहली तिमाही कफ और वात दोषों द्वारा शासित होती है। सुबह की मतली आम है। मीठे, ठंडे और आसानी से पचने वाले खाद्य पदार्थों पर ध्यान दें। एक चुटकी इलायची और घी के साथ गर्म दूध ओजस (प्रतिरक्षा) बनाने में मदद करता है और विकासशील भ्रूण के तंत्रिका तंत्र को पोषण देता है।', 
'Take small, frequent sattvic meals.', 'थोड़े-थोड़े समय में छोटे-छोटे सात्विक भोजन लें।', 1),

-- t1_pranayama_day4
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't1_pranayama_day4', 't1_pranayama_day4_c1', 'general', 'Day 4: Gentle Nadi Shodhana', 'दिन 4: सौम्य नाड़ी शोधन', 
'Nadi Shodhana (Alternate Nostril Breathing) soothes the nervous system, balances mind hemispheres, and delivers optimal oxygen to your womb. It is deeply restorative. Do not retain or hold breath.', 
'नाड़ी शोधन (अनुलोम विलोम) तंत्रिका तंत्र को शांत करता है, मन के दोनों हिस्सों को संतुलित करता है, और आपके गर्भ को भरपूर ऑक्सीजन पहुंचाता है। यह अत्यंत स्वास्थ्यवर्धक है। सांस न रोकें।', 
'Close right nostril. Inhale left. Close left, exhale right. Inhale right, exhale left. Repeat gently for 5 minutes.', 'दाहिनी नाक बंद करें। बाईं ओर से सांस लें। बाईं नाक बंद करें, दाईं ओर से छोड़ें। दाईं ओर से सांस लें, बाईं ओर से छोड़ें। धीरे-धीरे 5 मिनट दोहराएं।', 1),

-- t2_garbh_samvad
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't2_garbh_samvad', 't2_garbh_samvad_c1', 'general', 'Neuro-Acoustic Stimulation', 'गर्भ संवाद (मस्तिष्क ध्वनि उत्तेजना)', 
'Your baby can now hear distinct sounds! The mother’s voice actively builds the baby’s auditory neural pathways. Script: "Welcome to our lineage, sweet soul. We are building a world of light for you. You are deeply loved by the universe."', 
'आपका शिशु अब स्पष्ट ध्वनियाँ सुन सकता है! माँ की आवाज़ सक्रिय रूप से शिशु के श्रवण तंत्रिका मार्ग का निर्माण करती है। संवाद: "हमारे वंश में आपका स्वागत है, प्यारी आत्मा। हम आपके लिए प्रकाश की दुनिया का निर्माण कर रहे हैं। ब्रह्मांड आपसे गहरा प्रेम करता है।"', 
'Place both hands on your belly and speak softly and clearly.', 'अपने दोनों हाथों को पेट पर रखें और धीरे-धीरे और स्पष्ट रूप से बोलें।', 1),

-- t2_evening_listening
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't2_evening_listening', 't2_evening_listening_c1', 'general', 'Vishnu Sahasranama & Ragas', 'विष्णु सहस्रनाम और राग', 
'Listening to sacred chants like Vishnu Sahasranama, or Vedic Indian Classical ragas like Raga Malkauns or Raga Bhairavi, provides harmonic frequencies that aid deep relaxation and brain development.', 
'विष्णु सहस्रनाम, या वैदिक भारतीय शास्त्रीय राग जैसे राग मालकौंस या राग भैरवी जैसे पवित्र मंत्रों को सुनने से हार्मोनिक आवृत्तियां मिलती हैं जो गहरे विश्राम और मस्तिष्क के विकास में सहायता करती हैं।', 
'Listen to the audio track while reposing in a comfortable chair.', 'आरामदायक कुर्सी पर बैठते हुए ऑडियो ट्रैक सुनें।', 1),

-- t2_yoga_stretch
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't2_yoga_stretch', 't2_yoga_stretch_c1', 'general', 'Cat-Cow Stretch', 'मार्जरी और बिडालासन (कैट-काउ खिंचाव)', 
'This gentle stretch relieves the lower back pain common in the second trimester and shifts the baby into an optimal position by creating space in the pelvis.', 
'यह कोमल खिंचाव दूसरी तिमाही में आम तौर पर होने वाले पीठ के निचले हिस्से के दर्द से राहत देता है और श्रोणि में जगह बनाकर शिशु को इष्टतम स्थिति में लाता है।', 
'Get on all fours. Inhale, arch your back (Cow). Exhale, round your spine (Cat).', 'चारों पैरों पर आएं। सांस लेते हुए पीठ को झुकाएं (गाय)। सांस छोड़ते हुए रीढ़ को गोल करें (बिल्ली)।', 1),

-- t2_creativity_rasa
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't2_creativity_rasa', 't2_creativity_rasa_c1', 'general', 'Creative Expression (Rasa)', 'रचनात्मक अभिव्यक्ति (रस)', 
'Ayurveda teaches that a mother’s creative expression (Rasa) directly influences the baby’s intellect (Dhi) and creativity. Engaging in arts and crafts boosts serotonin for both of you.', 
'आयुर्वेद सिखाता है कि माँ की रचनात्मक अभिव्यक्ति (रस) सीधे शिशु की बुद्धि (धी) और रचनात्मकता को प्रभावित करती है। कला और शिल्प में संलग्न होना आप दोनों के लिए सेरोटोनिन (खुशी का हार्मोन) बढ़ाता है।', 
'Spend 10 minutes drawing, writing, or knitting with joy.', '10 मिनट खुशी के साथ ड्राइंग, लेखन, या बुनाई में बिताएं।', 1),

-- t3_birth_prep_meditation
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't3_birth_prep_meditation', 't3_birth_prep_meditation_c1', 'general', 'Pranayama & Apana Vayu', 'अपान वायु और श्वास ध्यान', 
'Apana Vayu is the downward and outward-moving energy required for childbirth. Focus on long exhales. Visualize the pelvic floor softening and opening with total surrender.', 
'अपान वायु नीचे और बाहर की ओर बहने वाली ऊर्जा है जो प्रसव के लिए आवश्यक है। लंबी सांस छोड़ने पर ध्यान दें। पूरी तरह समर्पण के साथ श्रोണി तल (पेल्विक फ्लोर) को नरम होने और खुलने की कल्पना करें।', 
'Repeat these affirmations with each exhale: My body is wise. I yield to the flow.', 'हर साँस छोड़ते समय दोहराएं: मेरा शरीर बुद्धिमान है। मैं खुद को प्रसव के प्रवाह को सौंपती हूँ।', 1),

-- t3_hip_opening
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't3_hip_opening', 't3_hip_opening_c1', 'general', 'Malasana & Pelvic Prep', 'मलासन और पेल्विक योग', 
'Squatting helps open the pelvic floor, relax the perineum, and prepares the physical body for smooth delivery. It releases tight hip flexors.', 
'उकड़ूँ बैठने से पैल्विक फ्लोर खोलने में मदद मिलती है, पेरिनेम को आराम मिलता है, और यह शारीर को सुचारू प्रसव के लिए तैयार करता है। यह कड़े हिप फ्लेक्सर्स को मुक्त करता है।', 
'SAFETY: Keep a wall behind you. Do not go too deep if uncomfortable. Hold for up to 30 seconds.', 'सुरक्षा: अपने पीछे एक दीवार रखें। अगर असुविधा हो ক্যাম जाने में। 30 सेकंड तक रुकें।', 1),

-- t3_calming_lullaby
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't3_calming_lullaby', 't3_calming_lullaby_c1', 'general', 'Night Lullaby & Dhanvantari', 'रात्रि लोरी और धन्वंतरि मंत्र', 
'Lullabies sting in the final trimester are often recognized by the baby after birth. The Dhanvantari Mantra invokes the cosmic healer for a safe delivery.', 
'अंतिम तिमाही में गाई जाने वाली लोरियां अक्सर जन्म के बाद शिशु द्वारा पहचानी जाती हैं। धन्वंतरि मंत्र सुरक्षित प्रसव के लिए ब्रह्मांडीय चिकित्सक का आह्वान करता है।', 
'Chant "Om Namo Bhagavate Vasudevaya Dhanvantaraye" softly to your belly.', 'अपने पेट पर हाथ रखकर धीरे-धीरे "ॐ नमो भगवते वासुदेवाय धन्वंतरये" का जाप करें।', 1),

-- nb_mother_healing
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'nb_mother_healing', 'nb_mother_healing_c1', 'general', 'Jata Karma / Sutika Rest', 'जातकर्म / सूतिका विश्राम', 
'The Sutika (postpartum) phase requires absolute Vata pacification. You must rest to heal the cavern left in your womb. Binding the belly with a soft muslin cloth gently supports organs.', 
'सूतिका (पोस्टपार्टम) चरण में पूर्ण वात शांति की आवश्यकता होती है। आपके गर्भ में खाली हुए स्थान को भरने के लिए आपको आराम करना चाहिए। एक नरम मलमल के कपड़े से पेट को बांधना अंगों को सहारा देता है।', 
'Lie down while the baby is sleeping. Do not look at your phone. Just breathe.', 'जब शिशु सो रहा हो तब लेट जाएं। फोन न देखें। बस सांस लें।', 1),

-- nb_ajwain_water
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'nb_ajwain_water', 'nb_ajwain_water_c1', 'general', 'Healing Ajwain Water', 'उपचारात्मक अजवायन जल', 
'Ajwain (carom seeds) water cleanses the uterus, aids digestion, and prevents colic in the breastfed newborn.', 
'अजवायन का पानी गर्भाशय को साफ करता है, पाचन में सहायता करता है, और स्तनपान करने वाले नवजात शिशु में पेट के दर्द को रोकता है।', 
'Boil 1 tsp ajwain in 1 liter of water until it reduces slightly. Sip warm.', '1 चम्मच अजवायन को 1 लीटर पानी में तब तक उबालें जब तक कि यह थोड़ा कम न हो जाए। गुनगुना पिएं।', 1),

-- nb_lullaby_time
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'nb_lullaby_time', 'nb_lullaby_time_c1', 'general', 'First Om Chanting', 'पहला ॐ उच्चारण', 
'The sound of Om closely mimics the rhythmic sounds the baby heard inside the womb. It instantly calms a crying or fussy newborn.', 
'ॐ की ध्वनि उन लयबद्ध ध्वनियों की नकल करती है जो शिशु ने गर्भ के अंदर सुनी थीं। यह रोते या चिड़चिड़े नवजात शिशु को तुरंत शांत करता है।', 
'Hold baby close to your chest and chant a long, deep Om.', 'शिशु को अपनी छाती के करीब रखें और एक लंबा, गहरा ॐ जपें।', 1),

-- m1_3_abhyanga
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'm1_3_abhyanga', 'm1_3_abhyanga_c1', 'general', 'Ayurvedic Baby Massage', 'आयुर्वेदिक शिशु मालिश', 
'Daily massage with warm almond or sesame oil deeply nourishes the baby’s tissues (dhatus), improves immunity, and deepens the parent-child bond.', 
'गर्म बादाम या तिल के तेल से दैनिक मालिश शिशु के ऊतकों (धातुओं) को गहराई से पोषण देती है, रोग प्रतिरोधक क्षमता में सुधार करती है, और माता-पिता-बच्चे के बंधन को गहरा करती है।', 
'Use smooth, upward strokes on the limbs and circular motions on the chest and belly.', 'अंगों पर चिकने, ऊपर की ओर स्ट्रोक और छाती और पेट पर गोलाकार गति का प्रयोग करें।', 1),

-- m1_3_sun_time
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'm1_3_sun_time', 'm1_3_sun_time_c1', 'general', 'Greeting the Sun God', 'सूर्य देव का अभिवादन', 
'Mild early morning sunlight (during the first hour of sunrise) provides essential Vitamin D and regulates the baby’s circadian rhythm for better sleep.', 
'सुबह की हल्की धूप (सूर्योदय के पहले घंटे के दौरान) आवश्यक विटामिन डी प्रदान करती है और बेहतर नींद के लिए शिशु की सर्कैडियन लय को नियंत्रित करती है।', 
'Expose baby’s arms and legs to mild sunlight for 10 minutes.', 'शिशु के हाथ-पैरों को 10 मिनट के लिए हल्की धूप में रखें।', 1),

-- m3_6_sensory_play
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'm3_6_sensory_play', 'm3_6_sensory_play_c1', 'general', 'Rhythmic Clapping and Chanting', 'लयबद्ध ताली और मंत्र', 
'At this age, babies begin to recognize rhythms. Clapping gently to the rhythm of simple mantras develops their auditory and motor neural pathways.', 
'इस उम्र में, शिशु लय को पहचानना शुरू कर देते हैं। सरल मंत्रों की लय पर धीरे-धीरे ताली बजाने से उनके श्रवण और मोटर तंत्रिका मार्ग विकसित होते हैं।', 
'Sing short mantras and clap baby’s hands together playfully.', 'छोटे मंत्र गाएं और खेल-खेल में शिशु के हाथों से ताली बजवाएं।', 1),

-- m3_6_tummy_time
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'm3_6_tummy_time', 'm3_6_tummy_time_c1', 'general', 'Exploring the Floor', 'फर्श की खोज', 
'Tummy time is crucial for developing strong neck, shoulder, and arm muscles, paving the way for crawling. Place colorful spiritual toys in front of them.', 
'गर्दन, कंधे और बांह की मजबूत मांसपेशियों को विकसित करने के लिए टमी टाइम महत्वपूर्ण है, जो रेंगने का मार्ग प्रशस्त करता है। उनके सामने रंगीन आध्यात्मिक खिलौने रखें।', 
'Aim for 3-5 minutes per session, closely interacting with your baby.', 'प्रत्येक सत्र के लिए 3-5 मिनट का लक्ष्य रखें, अपने शिशु के साथ निकटता से बातचीत करें।', 1),

-- m6_12_solid_food
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'm6_12_solid_food', 'm6_12_solid_food_c1', 'general', 'Annaprashana Blessing', 'अन्नप्राशन आशीर्वाद', 
'The transition to solid food is a major milestone. Food is considered Brahman (divine). Begin each meal by offering gratitude, so the baby absorbs both physical and spiritual nourishment.', 
'ठोस भोजन में संक्रमण एक प्रमुख मील का पत्थर है। भोजन को ब्रह्म (दिव्य) माना जाता है। कृतज्ञता अर्पित करके प्रत्येक भोजन की शुरुआत करें, ताकि शिशु शारीरिक और आध्यात्मिक दोनों प्रकार का पोषण ग्रहण करे।', 
'Chant "Om Annapurnayai Namah" before feeding.', 'खिलाने से पहले "ॐ अन्नपूर्णायै नमः" का जाप करें।', 1),

-- m6_12_story_time
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'm6_12_story_time', 'm6_12_story_time_c1', 'general', 'Tales of Little Krishna', 'नन्हें कृष्ण की कहानियाँ', 
'Hearing stories of courage, love, and divine play (Leela) at this receptive age plants the seeds of strong character and moral values.', 
'इस ग्रहणशील उम्र में साहस, प्रेम और दिव्य खेल (लीला) की कहानियां सुनने से मजबूत चरित्र और नैतिक मूल्यों के बीज बोए जाते हैं।', 
'Use animated facial expressions and voices while narrating.', 'कहानी सुनाते समय एनिमेटेड चेहरे के भाव और आवाज़ का प्रयोग करें।', 1),

-- y1_night_gratitude
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'y1_night_gratitude', 'y1_night_gratitude_c1', 'general', 'Counting Blessings', 'आशीर्वाद की गिनती', 
'A gratitude practice before sleep wires the toddler’s brain for positivity and peace, reducing night terrors and anxiety.', 
'सोने से पहले एक कृतज्ञता अभ्यास टॉडलर के मस्तिष्क को सकारात्मकता और शांति के लिए तैयार करता है, जिससे रात का डर और चिंता कम होती है।', 
'Ask: "What made you smile today?" Share your own joyful moment too.', 'पूछें: "आज आपको किस बात ने हँसाया?" अपना खुशी का पल भी साझा करें।', 1);

-- Optionally add rotation data
INSERT INTO journey_content_pool (journey_type_id, task_slug, slug, category, title, title_hindi, content, content_hindi, instruction, instruction_hindi, display_order) VALUES
-- Second option for t1_morning_mantra
('11b628c4-07d5-408f-8fe1-d570bac8a799', 't1_morning_mantra', 't1_morning_mantra_c2', 'general', 'Ganesha Mantra', 'गणेश मंत्र', 
'Om Gam Ganapataye Namah', 
'ॐ गं गणपतये नमः', 
'Chant for removing obstacles in early pregnancy.', 'प्रारंभिक गर्भावस्था में बाधाओं को दूर करने के लिए जपें।', 2),

-- plan_yoga_asana
('11b628c4-07d5-408f-8fe1-d570bac8a799', 'plan_yoga_asana', 'plan_yoga_asana_c1', 'general', 'Fertility Yoga (Baddha Konasana)', 'प्रजनन योग (बद्ध कोणासन)', 
'Baddha Konasana (Butterfly Pose) stimulates the reproductive organs and improves blood circulation to the pelvic region. This prepares the body beautifully for conception.', 
'बद्ध कोणासन (तितली मुद्रा) प्रजनन अंगों को उत्तेजित करता है और श्रोणि क्षेत्र में रक्त परिसंचरण में सुधार करता है। यह शरीर को गर्भधारण के लिए खूबसूरती से तैयार करता है।', 
'Sit with a straight spine, join the soles of your feet together, and gently flap your knees like butterfly wings.', 'सीधी रीढ़ के साथ बैठें, अपने पैरों के तलवों को एक साथ मिलाएं, और धीरे-धीरे अपने घुटनों को तितली के पंखों की तरह फड़फड़ाएं।', 1);
