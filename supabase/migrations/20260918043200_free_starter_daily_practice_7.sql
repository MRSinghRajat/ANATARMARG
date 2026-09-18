-- ============================================================
-- Free starter journey: daily-practice-7 (7 days, non-premium)
--
-- Source: docs/MVP_CONTENT_EDITORIAL_REVIEW.md (English/Hindi draft)
-- Goal: allow fresh testers to complete Day 1 without Pro even if other
-- programs remain premium / deferred.
--
-- Idempotent: safe to re-run (ON CONFLICT).
-- ============================================================

DO $$
DECLARE
  starter_id UUID := '00000000-0000-4000-8000-000000000701';
  phase_id UUID := '00000000-0000-4000-8000-000000000702';
BEGIN

  -- Journey type
  INSERT INTO journey_types (
    id,
    slug,
    title,
    title_hindi,
    subtitle,
    subtitle_hindi,
    description,
    description_hindi,
    icon,
    color_primary,
    category,
    target_audience,
    setup_type,
    setup_schema,
    duration_days,
    can_repeat,
    is_seasonal,
    seasonal_key,
    is_premium,
    required_plan,
    is_active,
    is_coming_soon,
    display_order
  ) VALUES (
    starter_id,
    'daily-practice-7',
    'Free 7-Day Starter Journey',
    'मुफ़्त ७-दिन का आरंभिक अभ्यास',
    'A simple daily Hindu practice, 5–10 min',
    'दैनिक सरल हिंदू अभ्यास, ५–१० मिनट',
    'Start with one small practice each day. No promises, no pressure—just a gentle week to begin.',
    'हर दिन एक छोटा अभ्यास। कोई वादा नहीं, कोई दबाव नहीं—बस शुरुआत के लिए एक शांत सप्ताह।',
    '🪔',
    '#F59E0B',
    'starter',
    'all',
    'day_based',
    NULL,
    7,
    true,
    false,
    NULL,
    false,
    NULL,
    true,
    false,
    1
  )
  ON CONFLICT (slug) DO UPDATE SET
    title = EXCLUDED.title,
    title_hindi = EXCLUDED.title_hindi,
    subtitle = EXCLUDED.subtitle,
    subtitle_hindi = EXCLUDED.subtitle_hindi,
    description = EXCLUDED.description,
    description_hindi = EXCLUDED.description_hindi,
    icon = EXCLUDED.icon,
    color_primary = EXCLUDED.color_primary,
    category = EXCLUDED.category,
    target_audience = EXCLUDED.target_audience,
    setup_type = EXCLUDED.setup_type,
    setup_schema = EXCLUDED.setup_schema,
    duration_days = EXCLUDED.duration_days,
    can_repeat = EXCLUDED.can_repeat,
    is_seasonal = EXCLUDED.is_seasonal,
    seasonal_key = EXCLUDED.seasonal_key,
    is_premium = EXCLUDED.is_premium,
    required_plan = EXCLUDED.required_plan,
    is_active = EXCLUDED.is_active,
    is_coming_soon = EXCLUDED.is_coming_soon,
    display_order = EXCLUDED.display_order,
    updated_at = NOW();

  -- Phase (single 7-day week)
  INSERT INTO journey_phases (
    id,
    journey_type_id,
    slug,
    title,
    title_hindi,
    description,
    phase_order,
    trigger_type,
    trigger_value,
    duration_label,
    icon,
    color_hex
  ) VALUES (
    phase_id,
    starter_id,
    'starter_week',
    'Starter week',
    'आरंभिक सप्ताह',
    'Seven days of small, optional daily practice.',
    1,
    'immediate',
    NULL,
    '7 days',
    '🗓️',
    '#F59E0B'
  )
  ON CONFLICT (journey_type_id, slug) DO UPDATE SET
    title = EXCLUDED.title,
    title_hindi = EXCLUDED.title_hindi,
    description = EXCLUDED.description,
    phase_order = EXCLUDED.phase_order,
    trigger_type = EXCLUDED.trigger_type,
    trigger_value = EXCLUDED.trigger_value,
    duration_label = EXCLUDED.duration_label,
    icon = EXCLUDED.icon,
    color_hex = EXCLUDED.color_hex;

  -- If the phase already existed with a different UUID, use the existing ID for downstream inserts.
  SELECT id INTO phase_id FROM journey_phases WHERE journey_type_id = starter_id AND slug = 'starter_week';

  -- Single daily task: day content rotates via journey_content_pool rows.
  INSERT INTO journey_tasks (
    id,
    phase_id,
    slug,
    title,
    title_hindi,
    description,
    task_type,
    frequency,
    duration_minutes,
    display_order,
    icon,
    coin_reward,
    is_premium
  ) VALUES (
    '00000000-0000-4000-8000-000000000703',
    phase_id,
    'starter_daily_practice',
    'Today''s practice',
    'आज का अभ्यास',
    'One small, optional practice for today.',
    'ritual',
    'daily',
    7,
    1,
    '🪔',
    0,
    false
  )
  ON CONFLICT (phase_id, slug) DO UPDATE SET
    title = EXCLUDED.title,
    title_hindi = EXCLUDED.title_hindi,
    description = EXCLUDED.description,
    task_type = EXCLUDED.task_type,
    frequency = EXCLUDED.frequency,
    duration_minutes = EXCLUDED.duration_minutes,
    display_order = EXCLUDED.display_order,
    icon = EXCLUDED.icon,
    coin_reward = EXCLUDED.coin_reward,
    is_premium = EXCLUDED.is_premium,
    updated_at = NOW();

  -- Content pool (7 rows). Keep copy exactly aligned with the editorial packet.
  -- Use instruction/instruction_hindi so the app renders it as guidance.
  INSERT INTO journey_content_pool (task_slug, journey_type_id, title, title_hindi, instruction, instruction_hindi, duration_seconds, rotation_type, display_order)
  VALUES
    ('starter_daily_practice', starter_id,
      'Day 1 — Make a little space', 'दिन १ — अपने लिए थोड़ा समय निकालें',
      'Choose a comfortable place to sit. Keep your eyes open or closed, as you prefer. Take a moment to notice your surroundings. Ask yourself: what would I like to bring to today''s practice? Stay for up to five minutes.',
      'बैठने के लिए आरामदायक जगह चुनें। अपनी सुविधा के अनुसार आँखें खुली रखें या बंद करें। कुछ पल अपने आसपास ध्यान दें। स्वयं से पूछें: आज के अभ्यास में मैं किस भाव के साथ आना चाहता हूँ? अपनी सुविधा के अनुसार पाँच मिनट तक बैठें।',
      300, 'sequential', 1),
    ('starter_daily_practice', starter_id,
      'Day 2 — Remember gratitude', 'दिन २ — कृतज्ञता याद करें',
      'Think of one person, experience or everyday kindness for which you are grateful. If prayer is part of your tradition, you may offer a short prayer in your own words. Spend a few quiet moments with that memory.',
      'किसी व्यक्ति, अनुभव या छोटी-सी सहायता को याद करें जिसके लिए आप आभारी हैं। यदि प्रार्थना आपकी परंपरा का हिस्सा है, तो अपने शब्दों में छोटी-सी प्रार्थना कर सकते हैं। उस स्मृति के साथ कुछ शांत पल बिताएँ।',
      300, 'sequential', 2),
    ('starter_daily_practice', starter_id,
      'Day 3 — Read with attention', 'दिन ३ — ध्यान से पढ़ें',
      'Choose a short passage from a sacred text you know, or a reading available to you in the library. Read at your own pace. Which word or idea would you like to think about today? There is no quiz or required answer.',
      'किसी परिचित पवित्र ग्रंथ का छोटा अंश चुनें, या ग्रंथालय में उपलब्ध पाठ पढ़ें। अपनी गति से पढ़ें। आज किस शब्द या विचार पर मनन करना चाहेंगे? कोई परीक्षा या अनिवार्य उत्तर नहीं है।',
      300, 'sequential', 3),
    ('starter_daily_practice', starter_id,
      'Day 4 — Pause before an action', 'दिन ४ — काम शुरू करने से पहले ठहरें',
      'Choose one ordinary task today. Before starting, pause briefly and decide how you would like to approach it: with care, patience or honesty. Afterward, notice what you experienced without judging yourself.',
      'आज का कोई साधारण काम चुनें। शुरू करने से पहले कुछ पल ठहरें और तय करें कि उसे किस भाव से करना चाहेंगे: सावधानी, धैर्य या ईमानदारी से। काम के बाद, स्वयं को परखे बिना अपने अनुभव पर ध्यान दें।',
      300, 'sequential', 4),
    ('starter_daily_practice', starter_id,
      'Day 5 — Practice kindness', 'दिन ५ — दयालुता का अभ्यास करें',
      'Choose one small act of kindness that fits your circumstances. You might listen attentively, share a helpful word or offer practical help. Keep it within your time and resources. Reflect on the experience for a moment.',
      'अपनी परिस्थिति के अनुसार दयालुता का एक छोटा काम चुनें। आप ध्यान से सुन सकते हैं, कोई सहायक बात कह सकते हैं या व्यावहारिक मदद दे सकते हैं। अपने समय और साधनों की सीमा का ध्यान रखें। अनुभव पर कुछ पल मनन करें।',
      300, 'sequential', 5),
    ('starter_daily_practice', starter_id,
      'Day 6 — Return to your practice', 'दिन ६ — अपने अभ्यास पर लौटें',
      'Repeat the activity from this week that felt most approachable. A brief practice is enough. If you missed a day, you can simply begin again today.',
      'इस सप्ताह का वह अभ्यास दोहराएँ जो आपको सबसे सहज लगा। थोड़ा समय भी पर्याप्त है। यदि कोई दिन छूट गया हो, तो आज फिर से शुरू कर सकते हैं।',
      300, 'sequential', 6),
    ('starter_daily_practice', starter_id,
      'Day 7 — Choose your next week', 'दिन ७ — अगला सप्ताह चुनें',
      'Look back at the week. What did you enjoy? What was difficult to fit into your day? Choose one practice and a convenient time to return to it next week. You can continue these activities without buying a program.',
      'बीते सप्ताह पर विचार करें। क्या अच्छा लगा? दिनचर्या में किस अभ्यास के लिए समय निकालना कठिन था? अगले सप्ताह के लिए एक अभ्यास और सुविधाजनक समय चुनें। इन अभ्यासों को जारी रखने के लिए कोई कार्यक्रम खरीदना आवश्यक नहीं है।',
      300, 'sequential', 7)
  ON CONFLICT DO NOTHING;

END $$;

