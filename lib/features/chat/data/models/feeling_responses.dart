// Static responses for "How are you feeling today?" — meaningful options for Indian users.

class FeelingResponses {
  FeelingResponses._();

  static const Map<String, _FeelingEntry> _byId = {
    'calm': _FeelingEntry(
      title: 'Calm (शांत)',
      emoji: '🧘',
      response:
          'Your shanti is a blessing. Use it well: sit in dhyana for 10–15 minutes, repeat Om or your ishta mantra, or do a few rounds of anulom-vilom. Note one thing you are grateful for. This peace will stay with you through the day.',
    ),
    'inspired': _FeelingEntry(
      title: 'Inspired (प्रेरित)',
      emoji: '✨',
      response:
          'Let this inspiration become sankalpa. Do one small spiritual act today—read a few shlokas, do 5 minutes of japa, or one act of seva. As our shastras say, a small step on the path is better than standing still. Let today be that step.',
    ),
    'anxious': _FeelingEntry(
      title: 'Anxious (चिंतित)',
      emoji: '⚡',
      response:
          'Chinta is natural; don’t fight it. First, ground yourself: 5 deep breaths (4 in, 6 out), then name three things you see and hear. Do 5–10 minutes of pranayama or repeat a calming mantra like Om Shanti. The Gita reminds us—equanimity comes with practice. Take no big decisions until you feel steadier.',
    ),
    'healing': _FeelingEntry(
      title: 'Healing (स्वस्थ हो रहे)',
      emoji: '🍃',
      response:
          'Honour your body’s healing with gentleness. Rest when needed; light movement—a short walk, gentle stretch—supports recovery. A few minutes of meditation or a soothing bhajan can calm the mind. Let the pace be slow; arogya comes with patience.',
    ),
    'lost': _FeelingEntry(
      title: 'Lost (भटके हुए)',
      emoji: '🌑',
      response:
          'When the path is unclear, simplify. Sit quietly and ask: "What is one dharmic step I can take today?" It might be a short prayer, a verse from the Gita, or a kind word to someone. You don’t need to see the whole path—only the next step. Even the greatest yogis walked one step at a time.',
    ),
    'joyful': _FeelingEntry(
      title: 'Joyful (आनंदित)',
      emoji: '☀️',
      response:
          'Your ananda is meant to be shared. Offer it as seva—a kind word, a small help, or a few minutes of gratitude to the Divine. Sit briefly in meditation and wish well for all beings. As our traditions say, joy multiplies when we share it.',
    ),
    'grateful': _FeelingEntry(
      title: 'Grateful (कृतज्ञ)',
      emoji: '🙏',
      response:
          'Kritajnata deepens presence. Name three things you are grateful for—family, health, or simple blessings. Offer a short thanks in prayer or write one line in a journal. Let this gratitude anchor your day and open your heart.',
    ),
    'peaceful': _FeelingEntry(
      title: 'Peaceful (शांतचित्त)',
      emoji: '🕊️',
      response:
          'Your inner shanti is precious. Honour it: sit in maun for 10 minutes, listen to a calming chant or bhajan, or take a mindful walk. This calm can become the refuge you return to whenever life feels heavy.',
    ),
    'devotional': _FeelingEntry(
      title: 'Devotional (भक्ति भाव)',
      emoji: '🪷',
      response:
          'Bhakti is a beautiful state. Nurture it: offer a short prayer or stotra, listen to a bhajan, or do a few rounds of japa with your ishta mantra. You can also read a few lines from the Gita or Ramayana. Let this devotion fill your heart and guide your actions today.',
    ),
  };

  /// Returns the response text for a feeling id (e.g. 'calm', 'anxious').
  /// Returns null if id is unknown.
  static String? getResponseForFeeling(String id) {
    return _byId[id]?.response;
  }

  /// Returns title for display (e.g. 'Calm' or 'Calm (शांत)').
  static String? getTitleForFeeling(String id) {
    return _byId[id]?.title;
  }

  /// Returns title for UI: only English when [languageCode] != 'hi', full "English (Hindi)" when Hindi is selected.
  static String getTitleForFeelingDisplay(String id, String languageCode) {
    final full = getTitleForFeeling(id) ?? id;
    if (languageCode == 'hi') return full;
    final idx = full.indexOf(' (');
    return idx >= 0 ? full.substring(0, idx).trim() : full;
  }

  /// Returns emoji for the feeling.
  static String? getEmojiForFeeling(String id) {
    return _byId[id]?.emoji;
  }

  /// All feeling ids in display order.
  static List<String> get allIds =>
      ['calm', 'inspired', 'anxious', 'healing', 'lost', 'joyful', 'grateful', 'peaceful', 'devotional'];
}

class _FeelingEntry {
  const _FeelingEntry({
    required this.title,
    required this.emoji,
    required this.response,
  });
  final String title;
  final String emoji;
  final String response;
}
