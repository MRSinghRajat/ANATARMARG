import '../models/journey_models.dart';

/// Free 7-day starter journey slug (Assignment E / L08).
const String kStarterJourneySlug = 'daily-practice-7';

/// Deterministic local IDs so the app can function even when the CMS rows are not imported yet.
///
/// If/when Supabase content is imported, it should reuse these IDs for idempotency.
const String kStarterJourneyTypeId = '00000000-0000-4000-8000-000000000701';
const String kStarterJourneyPhaseId = '00000000-0000-4000-8000-000000000702';
const String kStarterJourneyTaskId = '00000000-0000-4000-8000-000000000703';

/// Single daily task slug. Day 1–7 copy is delivered via a rotating content-pool.
const String kStarterJourneyDailyTaskSlug = 'starter_daily_practice';

JourneyType starterJourneyType() {
  return const JourneyType(
    id: kStarterJourneyTypeId,
    slug: kStarterJourneySlug,
    title: 'Free 7-Day Starter Journey',
    titleHindi: 'मुफ़्त ७-दिन का आरंभिक अभ्यास',
    subtitle: 'A simple daily Hindu practice, 5–10 min',
    subtitleHindi: 'दैनिक सरल हिंदू अभ्यास, ५–१० मिनट',
    description:
        'Start with one small practice each day. No promises, no pressure—just a gentle week to begin.',
    descriptionHindi:
        'हर दिन एक छोटा अभ्यास। कोई वादा नहीं, कोई दबाव नहीं—बस शुरुआत के लिए एक शांत सप्ताह।',
    icon: '🪔',
    colorPrimary: '#F59E0B',
    category: 'starter',
    targetAudience: 'all',
    isPremium: false,
    requiredPlan: null,
    setupType: 'day_based',
    setupSchema: null, // No questions; start immediately.
    durationDays: 7,
    canRepeat: true,
    isSeasonal: false,
    seasonalKey: null,
    isActive: true,
    isComingSoon: false,
    displayOrder: 1,
  );
}

List<JourneyTask> starterJourneyTasks() {
  return const [
    JourneyTask(
      id: kStarterJourneyTaskId,
      journeyTypeId: kStarterJourneyTypeId,
      slug: kStarterJourneyDailyTaskSlug,
      title: 'Today’s practice',
      titleHindi: 'आज का अभ्यास',
      description: 'One small, optional practice for today.',
      instruction: null,
      taskType: 'ritual',
      frequency: 'daily',
      durationMinutes: 7,
      displayOrder: 1,
      icon: '🪔',
      coinReward: 0,
      isPremium: false,
      phaseId: kStarterJourneyPhaseId,
      phaseSlug: 'starter_week',
      phaseTitle: 'Starter week',
      phaseTitleHindi: 'आरंभिक सप्ताह',
      triggerType: 'immediate',
      triggerValue: null,
      phaseOrder: 1,
      phaseDurationLabel: '7 days',
      phaseIcon: '🗓️',
      phaseColorHex: '#F59E0B',
    ),
  ];
}

/// Bundled fallback content pool for the starter.
///
/// Use [instruction]/[instruction_hindi] for the daily copy so the UI renders it as guidance,
/// not as a mantra block.
List<Map<String, dynamic>> starterContentPoolForTaskSlug(String taskSlug) {
  if (taskSlug != kStarterJourneyDailyTaskSlug) return const [];

  // Editorial packet (EN/HI) — do not invent additional content here.
  const days = <Map<String, String>>[
    {
      'title': 'Day 1 — Make a little space',
      'title_hindi': 'दिन १ — अपने लिए थोड़ा समय निकालें',
      'instruction':
          'Choose a comfortable place to sit. Keep your eyes open or closed, as you prefer. '
              'Take a moment to notice your surroundings. Ask yourself: what would I like to bring to today\'s practice? '
              'Stay for up to five minutes.',
      'instruction_hindi':
          'बैठने के लिए आरामदायक जगह चुनें। अपनी सुविधा के अनुसार आँखें खुली रखें या बंद करें। '
              'कुछ पल अपने आसपास ध्यान दें। स्वयं से पूछें: आज के अभ्यास में मैं किस भाव के साथ आना चाहता हूँ? '
              'अपनी सुविधा के अनुसार पाँच मिनट तक बैठें।',
    },
    {
      'title': 'Day 2 — Remember gratitude',
      'title_hindi': 'दिन २ — कृतज्ञता याद करें',
      'instruction':
          'Think of one person, experience or everyday kindness for which you are grateful. '
              'If prayer is part of your tradition, you may offer a short prayer in your own words. '
              'Spend a few quiet moments with that memory.',
      'instruction_hindi':
          'किसी व्यक्ति, अनुभव या छोटी-सी सहायता को याद करें जिसके लिए आप आभारी हैं। '
              'यदि प्रार्थना आपकी परंपरा का हिस्सा है, तो अपने शब्दों में छोटी-सी प्रार्थना कर सकते हैं। '
              'उस स्मृति के साथ कुछ शांत पल बिताएँ।',
    },
    {
      'title': 'Day 3 — Read with attention',
      'title_hindi': 'दिन ३ — ध्यान से पढ़ें',
      'instruction':
          'Choose a short passage from a sacred text you know, or a reading available to you in the library. '
              'Read at your own pace. Which word or idea would you like to think about today? '
              'There is no quiz or required answer.',
      'instruction_hindi':
          'किसी परिचित पवित्र ग्रंथ का छोटा अंश चुनें, या ग्रंथालय में उपलब्ध पाठ पढ़ें। '
              'अपनी गति से पढ़ें। आज किस शब्द या विचार पर मनन करना चाहेंगे? '
              'कोई परीक्षा या अनिवार्य उत्तर नहीं है।',
    },
    {
      'title': 'Day 4 — Pause before an action',
      'title_hindi': 'दिन ४ — काम शुरू करने से पहले ठहरें',
      'instruction':
          'Choose one ordinary task today. Before starting, pause briefly and decide how you would like to approach it: '
              'with care, patience or honesty. Afterward, notice what you experienced without judging yourself.',
      'instruction_hindi':
          'आज का कोई साधारण काम चुनें। शुरू करने से पहले कुछ पल ठहरें और तय करें कि उसे किस भाव से करना चाहेंगे: '
              'सावधानी, धैर्य या ईमानदारी से। काम के बाद, स्वयं को परखे बिना अपने अनुभव पर ध्यान दें।',
    },
    {
      'title': 'Day 5 — Practice kindness',
      'title_hindi': 'दिन ५ — दयालुता का अभ्यास करें',
      'instruction':
          'Choose one small act of kindness that fits your circumstances. You might listen attentively, share a helpful word '
              'or offer practical help. Keep it within your time and resources. Reflect on the experience for a moment.',
      'instruction_hindi':
          'अपनी परिस्थिति के अनुसार दयालुता का एक छोटा काम चुनें। आप ध्यान से सुन सकते हैं, कोई सहायक बात कह सकते हैं '
              'या व्यावहारिक मदद दे सकते हैं। अपने समय और साधनों की सीमा का ध्यान रखें। अनुभव पर कुछ पल मनन करें।',
    },
    {
      'title': 'Day 6 — Return to your practice',
      'title_hindi': 'दिन ६ — अपने अभ्यास पर लौटें',
      'instruction':
          'Repeat the activity from this week that felt most approachable. A brief practice is enough. '
              'If you missed a day, you can simply begin again today.',
      'instruction_hindi':
          'इस सप्ताह का वह अभ्यास दोहराएँ जो आपको सबसे सहज लगा। थोड़ा समय भी पर्याप्त है। '
              'यदि कोई दिन छूट गया हो, तो आज फिर से शुरू कर सकते हैं।',
    },
    {
      'title': 'Day 7 — Choose your next week',
      'title_hindi': 'दिन ७ — अगला सप्ताह चुनें',
      'instruction':
          'Look back at the week. What did you enjoy? What was difficult to fit into your day? '
              'Choose one practice and a convenient time to return to it next week. '
              'You can continue these activities without buying a program.',
      'instruction_hindi':
          'बीते सप्ताह पर विचार करें। क्या अच्छा लगा? दिनचर्या में किस अभ्यास के लिए समय निकालना कठिन था? '
              'अगले सप्ताह के लिए एक अभ्यास और सुविधाजनक समय चुनें। '
              'इन अभ्यासों को जारी रखने के लिए कोई कार्यक्रम खरीदना आवश्यक नहीं है।',
    },
  ];

  final pool = <Map<String, dynamic>>[];
  for (var i = 0; i < days.length; i++) {
    final d = days[i];
    pool.add({
      'journey_type_id': kStarterJourneyTypeId,
      'task_slug': kStarterJourneyDailyTaskSlug,
      'slug': 'starter_day_${i + 1}',
      'category': 'ritual',
      'title': d['title'],
      'title_hindi': d['title_hindi'],
      'content': null,
      'content_hindi': null,
      'instruction': d['instruction'],
      'instruction_hindi': d['instruction_hindi'],
      'transliteration': null,
      'translation': null,
      'benefits': const [],
      'ref_type': null,
      'ref_id': null,
      'ref_slug': null,
      'display_order': i + 1,
      'rotation_type': 'sequential',
      'duration_seconds': 5 * 60,
    });
  }
  return pool;
}

