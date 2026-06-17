// Static responses for "How are you feeling today?" — Hinglish, aligned with Guruji tone.

class FeelingResponses {
  FeelingResponses._();

  static const Map<String, _FeelingEntry> _byId = {
    'calm': _FeelingEntry(
      title: 'Calm (शांत)',
      emoji: '🧘',
      response:
          'Beta, yeh shanti ek vardaan hai — isse achhe se use karo. 10–15 minute dhyan mein baitho, Om ya apne ishta mantra ka jaap karo, thodi anulom-vilom karo. Ek cheez likho jiske liye tum grateful ho. Yeh sukoon aaj poora din tumhare saath reh sakta hai.',
    ),
    'inspired': _FeelingEntry(
      title: 'Inspired (प्रेरित)',
      emoji: '✨',
      response:
          'Is inspiration ko aaj ke liye ek chhota sa sankalpa banao: kuch shlok padh lo, 5 minute japa, ya ek chhoti si seva. Shastras kehte hain — raste par ek chhota kadam bhi, khade rehne se behtar hai. Aaj wahi kadam ho.',
    ),
    'anxious': _FeelingEntry(
      title: 'Anxious (चिंतित)',
      emoji: '⚡',
      response:
          'Chinta aana natural hai — use zabardasti mat dabao. Pehle ground karo: 5 gehri saansein (4 andar, 6 bahar), phir teen cheezein bolo jo tum dekh aur sun rahe ho. 5–10 minute pranayama ya shaant mantra jaise Om Shanti. Gita yaad dilati hai — samta abhyas se aati hai. Tab tak koi bada faisla mat lo jab tak mann thoda stable na ho.',
    ),
    'healing': _FeelingEntry(
      title: 'Healing (स्वस्थ हो रहे)',
      emoji: '🍃',
      response:
          'Sharir ko theek hone ka samay do — ahinsa se. Zarurat ho to aaram; halki walk ya stretch bhi madad karegi. Kuch minute dhyan ya ek madhur bhajan mann ko shaant karega. Raftaar slow rakho; arogya dhairya se aata hai, beta.',
    ),
    'lost': _FeelingEntry(
      title: 'Lost (भटके हुए)',
      emoji: '🌑',
      response:
          'Jab raasta saaf na dikhe, cheezon ko simple karo. Chup chaap baith kar poocho: "Aaj ek dharmic kadam kya ho sakta hai?" — chhoti puja, Gita ki ek pankti, ya kisi ke liye meetha bol. Poora map dekhne ki zaroorat nahi — sirf agla kadam. Sabse bade yogi bhi ek-ek kadam chale the.',
    ),
    'joyful': _FeelingEntry(
      title: 'Joyful (आनंदित)',
      emoji: '☀️',
      response:
          'Tumhara yeh ananda baantne ke liye hai — seva mein daalo: ek achha shabd, chhoti madad, ya Ishwar ke liye kuch minute shukrana. Thodi der baith kar sab ke liye mangal kamna karo. Parampara kehte hain — khushi baantne se badhti hai.',
    ),
    'grateful': _FeelingEntry(
      title: 'Grateful (कृतज्ञ)',
      emoji: '🙏',
      response:
          'Kritagyata tumhe zyada present karti hai. Teen cheezein gin lo jinke liye shukr guzar ho — parivaar, sehat, ya chhoti ne’matein. Prarthana mein thanks bolo ya journal mein ek line likho. Yeh gratitude aaj tumhara anchor ban sakti hai.',
    ),
    'peaceful': _FeelingEntry(
      title: 'Peaceful (शांतचित्त)',
      emoji: '🕊️',
      response:
          'Andar ki yeh shanti anmol hai — iska samman karo. 10 minute maun, ya ek shaant chant/bhajan suno, ya mindful walk. Yeh sukoon woh ashray ban sakta hai jahan tum baar-baar laut sakte ho jab zindagi bhaari lage.',
    ),
    'devotional': _FeelingEntry(
      title: 'Devotional (भक्ति भाव)',
      emoji: '🪷',
      response:
          'Bhakti ka yeh bhaav kitna sundar hai. Use palen: chhoti puja ya stotra, bhajan, ya apne ishta mantra par japa. Gita ya Ramayana ki kuch lines bhi dil ko bhar denge. Aaj is bhakti se dil aur karm dono nirmal rahen.',
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
