/// Centralized app strings with Hindi (Devanagari) and Hinglish translations.
///
/// Usage: `AppStrings.get('key', lang)` where lang is 'en' (Hinglish) or 'hi' (Devanagari).
/// Default is Hinglish when key is missing for a language.
class AppStrings {
  AppStrings._();

  static String get(String key, String lang) {
    final map = lang == 'hi' ? _hi : _en;
    return map[key] ?? _en[key] ?? key;
  }

  // ───── Hinglish (English alphabet, Hindi pronunciation) ─────
  static const _en = <String, String>{
    // Nav
    'nav_aangan': 'AANGAN',
    'nav_ai_guru': 'AI GURU',
    'nav_ashram': 'ASHRAM',
    'nav_granthalya': 'GRANTHALYA',
    'nav_profile': 'PROFILE',

    // Ashram
    'todays_tasks': "Today's Tasks",
    'completed': 'completed',
    'all_tasks_complete': 'All Tasks Complete!',
    'all_tasks_complete_sub': 'Great work! Come back tomorrow for new tasks.',
    'my_habits': 'My Habits',
    'today': 'today',
    'add': '+ Add',
    'completed_today': 'Completed Today',
    'items': 'items',
    'level': 'Level',
    'beginner': 'Beginner',
    'no_verse_available': 'No verse available today',
    'no_stories_available': 'No stories available',
    'failed_to_load_story': 'Failed to load story',

    // Gratitude
    'gratitude_practice': 'Gratitude Practice',
    'krutajnata': 'Krutajnata — Gratitude',
    'gratitude_intro':
        'The Vedas teach that gratitude (Krutajnata) is the foundation of dharmic living. '
        'By acknowledging the gifts we receive daily — from Ishvara, nature, and fellow beings — '
        'we cultivate contentment (Santosha) and dissolve the ego\'s tendency toward complaint.',
    'what_grateful_for': 'What are you grateful for today?',
    'fill_all_three': 'Fill all three to complete. Take a moment to truly feel it.',
    'grateful_for': 'Grateful for',
    'a_person': 'A person',
    'a_blessing': 'A blessing',
    'prompt_grateful': 'Something you are grateful for today...',
    'prompt_person': 'A person who made a difference...',
    'prompt_blessing': 'A small blessing you noticed...',
    'save_complete': 'Save & Complete',
    'failed_to_save': 'Failed to save',

    // Habit Sheet
    'create_new_habit': 'Create New Habit',
    'edit_habit': 'Edit Habit',
    'habit_name': 'Habit Name',
    'habit_name_hint': 'e.g., Drink 8 glasses of water',
    'description_optional': 'Description (optional)',
    'description_hint': 'Add more details about this habit',
    'choose_icon': 'Choose Icon',
    'frequency': 'Frequency',
    'target_streak': 'Target Streak (optional)',
    'quick_add': 'Quick Add',
    'create_habit': 'Create Habit',
    'save_changes': 'Save Changes',
    'enter_habit_name': 'Please enter a habit name',
    'failed_to_save_habit': 'Failed to save habit',

    // Login
    'welcome_back': 'Welcome Back',
    'sign_in_subtitle': 'Sign in to continue your spiritual journey',
    'continue_with_google': 'Continue with Google',
    'continue_with_apple': 'Continue with Apple',
    'continue_with_email': 'Continue with Email',
    'or': 'or',
    'skip_for_now': 'Skip for now',

    // Profile
    'profile': 'Profile',
    'settings': 'Settings',
    'language': 'Language',
    'notifications': 'Notifications',
    'sign_out': 'Sign Out',
    'sign_in': 'Sign In',
    'guest_user': 'Guest User',
    'spiritual_journey': 'Your Spiritual Journey',
    'streaks': 'Streaks',
    'coins': 'Coins',
    'days': 'days',

    // Aangan / Home
    'aangan': 'Aangan',
    'your_sacred_space': 'Your Sacred Space',
    'preview_mode': 'PREVIEW MODE',

    // Chat / AI Guru
    'ai_guru': 'AI Guru',
    'new_consultation': 'New Consultation',
    'delete_conversation': 'Delete Conversation?',
    'delete': 'Delete',
    'cancel': 'Cancel',
    'type_message': 'Type a message...',
    'clear_history': 'Clear History',

    // Books / Granthalya
    'granthalya': 'Granthalya',
    'sacred_library': 'Sacred Library',
    'sacred_texts': 'Sacred Texts',
    'sacred_stories': 'Sacred Stories',
    'continue_reading': 'Continue Reading',
    'start_reading': 'Start Reading',

    // Meditation
    'meditation_guide': 'Meditation Guide',
    'minutes': 'minutes',
    'start': 'Start',
    'pause': 'Pause',
    'resume': 'Resume',

    // Japa
    'japa_counter': 'Japa Counter',
    'mala': 'Mala',
    'reset': 'Reset',

    // Chant
    'chant_player': 'Chant Player',
    'now_playing': 'Now Playing',

    // Dana
    'dana_practice': 'Dana Practice',

    // Seva
    'seva_help': 'Seva & Help',

    // Language Settings
    'language_settings': 'Language',
    'hinglish': 'Hinglish',
    'hindi_devanagari': 'Hindi (देवनागरी)',

    // General
    'continue_btn': 'Continue',
    'done': 'Done',
    'ok': 'OK',
    'error': 'Error',
    'loading': 'Loading...',
    'retry': 'Retry',
    'not_signed_in': 'Not signed in',
    'search': 'Search',
  };

  // ───── Hindi Devanagari ─────
  static const _hi = <String, String>{
    // Nav
    'nav_aangan': 'आँगन',
    'nav_ai_guru': 'AI गुरु',
    'nav_ashram': 'आश्रम',
    'nav_granthalya': 'ग्रंथालय',
    'nav_profile': 'प्रोफ़ाइल',

    // Ashram
    'todays_tasks': 'आज के कार्य',
    'completed': 'पूरे हुए',
    'all_tasks_complete': 'सभी कार्य पूरे!',
    'all_tasks_complete_sub': 'बहुत बढ़िया! कल नए कार्य आएंगे।',
    'my_habits': 'मेरी आदतें',
    'today': 'आज',
    'add': '+ जोड़ें',
    'completed_today': 'आज पूरे हुए',
    'items': 'कार्य',
    'level': 'स्तर',
    'beginner': 'नवसिखुआ',
    'no_verse_available': 'आज कोई श्लोक उपलब्ध नहीं',
    'no_stories_available': 'कोई कथा उपलब्ध नहीं',
    'failed_to_load_story': 'कथा लोड करने में विफल',

    // Gratitude
    'gratitude_practice': 'कृतज्ञता अभ्यास',
    'krutajnata': 'कृतज्ञता',
    'gratitude_intro':
        'वेद सिखाते हैं कि कृतज्ञता धार्मिक जीवन की नींव है। '
        'ईश्वर, प्रकृति और साथी प्राणियों से प्रतिदिन मिलने वाले उपहारों को स्वीकार करके '
        'हम संतोष विकसित करते हैं और अहंकार की शिकायत की प्रवृत्ति को दूर करते हैं।',
    'what_grateful_for': 'आज आप किसके लिए कृतज्ञ हैं?',
    'fill_all_three': 'तीनों भरें। एक पल रुककर अनुभव करें।',
    'grateful_for': 'कृतज्ञ हूँ',
    'a_person': 'एक व्यक्ति',
    'a_blessing': 'एक आशीर्वाद',
    'prompt_grateful': 'आज किसके लिए आभारी हैं...',
    'prompt_person': 'किसने आपका जीवन बेहतर बनाया...',
    'prompt_blessing': 'एक छोटा सा आशीर्वाद जो आपने देखा...',
    'save_complete': 'सहेजें और पूरा करें',
    'failed_to_save': 'सहेजने में विफल',

    // Habit Sheet
    'create_new_habit': 'नई आदत बनाएं',
    'edit_habit': 'आदत संपादित करें',
    'habit_name': 'आदत का नाम',
    'habit_name_hint': 'जैसे, 8 गिलास पानी पिएं',
    'description_optional': 'विवरण (वैकल्पिक)',
    'description_hint': 'इस आदत के बारे में और जानकारी जोड़ें',
    'choose_icon': 'आइकन चुनें',
    'frequency': 'आवृत्ति',
    'target_streak': 'लक्ष्य स्ट्रीक (वैकल्पिक)',
    'quick_add': 'जल्दी जोड़ें',
    'create_habit': 'आदत बनाएं',
    'save_changes': 'बदलाव सहेजें',
    'enter_habit_name': 'कृपया आदत का नाम दर्ज करें',
    'failed_to_save_habit': 'आदत सहेजने में विफल',

    // Login
    'welcome_back': 'वापसी पर स्वागत',
    'sign_in_subtitle': 'अपनी आध्यात्मिक यात्रा जारी रखने के लिए साइन इन करें',
    'continue_with_google': 'Google से जारी रखें',
    'continue_with_apple': 'Apple से जारी रखें',
    'continue_with_email': 'ईमेल से जारी रखें',
    'or': 'या',
    'skip_for_now': 'अभी छोड़ें',

    // Profile
    'profile': 'प्रोफ़ाइल',
    'settings': 'सेटिंग्स',
    'language': 'भाषा',
    'notifications': 'सूचनाएं',
    'sign_out': 'साइन आउट',
    'sign_in': 'साइन इन',
    'guest_user': 'अतिथि उपयोगकर्ता',
    'spiritual_journey': 'आपकी आध्यात्मिक यात्रा',
    'streaks': 'स्ट्रीक्स',
    'coins': 'सिक्के',
    'days': 'दिन',

    // Aangan / Home
    'aangan': 'आँगन',
    'your_sacred_space': 'आपका पवित्र स्थान',
    'preview_mode': 'पूर्वावलोकन',

    // Chat / AI Guru
    'ai_guru': 'AI गुरु',
    'new_consultation': 'नया परामर्श',
    'delete_conversation': 'बातचीत हटाएं?',
    'delete': 'हटाएं',
    'cancel': 'रद्द करें',
    'type_message': 'संदेश लिखें...',
    'clear_history': 'इतिहास साफ़ करें',

    // Books / Granthalya
    'granthalya': 'ग्रंथालय',
    'sacred_library': 'पवित्र पुस्तकालय',
    'sacred_texts': 'पवित्र ग्रंथ',
    'sacred_stories': 'पवित्र कथाएं',
    'continue_reading': 'पढ़ना जारी रखें',
    'start_reading': 'पढ़ना शुरू करें',

    // Meditation
    'meditation_guide': 'ध्यान मार्गदर्शिका',
    'minutes': 'मिनट',
    'start': 'शुरू',
    'pause': 'रुकें',
    'resume': 'जारी रखें',

    // Japa
    'japa_counter': 'जप गणना',
    'mala': 'माला',
    'reset': 'रीसेट',

    // Chant
    'chant_player': 'मंत्र प्लेयर',
    'now_playing': 'अभी बज रहा है',

    // Dana
    'dana_practice': 'दान अभ्यास',

    // Seva
    'seva_help': 'सेवा और सहायता',

    // Language Settings
    'language_settings': 'भाषा',
    'hinglish': 'Hinglish',
    'hindi_devanagari': 'हिन्दी (देवनागरी)',

    // General
    'continue_btn': 'आगे बढ़ें',
    'done': 'हो गया',
    'ok': 'ठीक',
    'error': 'त्रुटि',
    'loading': 'लोड हो रहा है...',
    'retry': 'पुनः प्रयास',
    'not_signed_in': 'साइन इन नहीं है',
    'search': 'खोजें',
  };
}
