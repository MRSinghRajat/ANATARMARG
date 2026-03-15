import 'panchang_models.dart';

/// Lunar and Panchang computation + static data (festivals, deities, vrat, muhurta, wisdom).
/// Ported from reference HTML/JS. Static only; later can be backed by Supabase.
class PanchangEngine {
  PanchangEngine._();

  static const int _refNmMs = 1738154160000; // 2025-01-29T12:36:00Z
  static const double _synodicDays = 29.53058867;
  static const double _synMs = _synodicDays * 86400000;

  static const _tithiEn = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami', 'Shashti',
    'Saptami', 'Ashtami', 'Navami', 'Dashami', 'Ekadashi', 'Dwadashi',
    'Trayodashi', 'Chaturdashi',
  ];
  static const _tithiHi = [
    'प्रतिपदा', 'द्वितीया', 'तृतीया', 'चतुर्थी', 'पञ्चमी', 'षष्ठी',
    'सप्तमी', 'अष्टमी', 'नवमी', 'दशमी', 'एकादशी', 'द्वादशी',
    'त्रयोदशी', 'चतुर्दशी',
  ];
  static const _nk = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula',
    'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
  ];
  static const _nkHi = [
    'अश्विनी', 'भरणी', 'कृत्तिका', 'रोहिणी', 'मृगशिरा', 'आर्द्रा',
    'पुनर्वसु', 'पुष्य', 'आश्लेषा', 'मघा', 'पू.फाल्गुनी', 'उ.फाल्गुनी',
    'हस्त', 'चित्रा', 'स्वाती', 'विशाखा', 'अनुराधा', 'ज्येष्ठा', 'मूल',
    'पू.आषाढ़', 'उ.आषाढ़', 'श्रवण', 'धनिष्ठा', 'शतभिषा', 'पू.भाद्र', 'उ.भाद्र', 'रेवती',
  ];
  static const _ms = [
    'Chaitra', 'Vaishakha', 'Jyeshtha', 'Ashadha', 'Shravana', 'Bhadrapada',
    'Ashwin', 'Kartika', 'Margashirsha', 'Pausha', 'Magha', 'Phalguna',
  ];
  static const _msHi = [
    'चैत्र', 'वैशाख', 'ज्येष्ठ', 'आषाढ़', 'श्रावण', 'भाद्रपद',
    'आश्विन', 'कार्तिक', 'मार्गशीर्ष', 'पौष', 'माघ', 'फाल्गुन',
  ];
  static const _vr = [
    'Ravivara', 'Somavara', 'Mangalavara', 'Budhavara', 'Guruvara', 'Shukravara', 'Shanivara',
  ];
  static const _vrHi = [
    'रविवार', 'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार',
  ];
  static const _yg = [
    'Vishkambha', 'Preeti', 'Ayushman', 'Saubhagya', 'Shobhana', 'Atiganda', 'Sukarma',
    'Dhriti', 'Shula', 'Ganda', 'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva', 'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma', 'Indra', 'Vaidhriti',
  ];
  static const _kr = [
    'Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara', 'Vanija', 'Vishti',
    'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna',
  ];
  static const _rashiSigns = [
    'Capricorn', 'Aquarius', 'Pisces', 'Aries', 'Taurus', 'Gemini',
    'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius',
  ];

  static double _lunarAge(DateTime date) {
    final t = date.millisecondsSinceEpoch;
    final elapsed = ((t - _refNmMs) % _synMs + _synMs) % _synMs;
    return (elapsed / _synMs) * 30;
  }

  static ({String n, String h, String type}) _tithi(double a) {
    if (a < 0.5 || a >= 29.5) {
      return (n: 'Amavasya', h: 'अमावस्या', type: 'amavasya');
    }
    if (a >= 14.5 && a < 15.5) {
      return (n: 'Purnima', h: 'पूर्णिमा', type: 'purnima');
    }
    final idx = a < 15 ? (a.floor() - 1) : (a.floor() - 16);
    final i = (idx).clamp(0, 13);
    final type = i == 10 ? 'ekadashi' : '';
    return (n: _tithiEn[i], h: _tithiHi[i], type: type);
  }

  static ({String n, String h, String en}) _paksha(double a) {
    if (a < 15) {
      return (n: 'Shukla Paksha', h: 'शुक्ल पक्ष', en: 'Waxing');
    }
    return (n: 'Krishna Paksha', h: 'कृष्ण पक्ष', en: 'Waning');
  }

  static int _nakshatraIndex(DateTime d) {
    return ((d.millisecondsSinceEpoch / 86400000 + 7) % 27).floor();
  }

  static ({String n, String h}) _masa(int month) {
    final i = (month + 9) % 12;
    return (n: _ms[i], h: _msHi[i]);
  }

  static int _vikramSamvatYear(DateTime d) {
    return d.month < 3 || (d.month == 3 && d.day < 14)
        ? d.year + 56
        : d.year + 57;
  }

  static String _yoga(DateTime d) {
    final i = ((d.millisecondsSinceEpoch / 86400000 + 5) % 27).floor();
    return _yg[i];
  }

  static String _karana(double a) {
    final i = (a * 2).floor() % 11;
    return _kr[i];
  }

  static String _rashi(DateTime d) {
    final m = (d.month + (d.day > 14 ? 1 : 0)) % 12;
    return _rashiSigns[m];
  }

  static final Map<String, List<PanchangFestival>> _fests = {
    '2026-3-3': [
      PanchangFestival(
        icon: '🔥',
        name: 'Holika Dahan',
        nameHi: 'होलिका दहन',
        major: true,
        type: 'major',
        desc: 'Burn your ego in Holika\'s fire. Circumambulate with devotion. Prahlada\'s love for Vishnu could not be burned. Tomorrow — colour everything with pure love and joy.',
      ),
    ],
    '2026-3-4': [
      PanchangFestival(
        icon: '🌈',
        name: 'Holi',
        nameHi: 'होली',
        major: true,
        type: 'major',
        deity: 'Krishna',
        desc: 'Divine play of colours. Natural gulal. Dance like nobody\'s watching. Forgive everything. Today every heart is Krishna\'s, every colour is the colour of His love.',
      ),
    ],
    '2026-3-9': [],
    '2026-3-15': [
      PanchangFestival(
        icon: '🪷',
        name: 'Ekadashi',
        nameHi: 'एकादशी',
        major: false,
        type: 'ekadashi',
        desc: 'The 11th lunar day — most sacred to Vishnu. Fast from grains. Stay awake, recite Vishnu Sahasranama.',
      ),
    ],
    '2026-3-19': [
      PanchangFestival(
        icon: '🏮',
        name: 'Ugadi / Gudi Padwa',
        nameHi: 'गुड़ी पड़वा',
        major: true,
        type: 'major',
        desc: 'Hindu New Year. Samvat 2083. Fresh slate. Hoist the Gudi, eat the bitter-sweet neem-jaggery mix — that is life itself. Begin again. Begin well.',
      ),
    ],
    '2026-3-26': [
      PanchangFestival(
        icon: '🏹',
        name: 'Rama Navami',
        nameHi: 'राम नवमी',
        major: true,
        type: 'major',
        deity: 'Rama',
        desc: 'The ideal being — Rama — born at noon in Ayodhya. Ramayana recitation fills the day. Sita-Ram puja. Two syllables carry infinite grace: Jai Shri Ram!',
      ),
    ],
    '2026-3-30': [
      PanchangFestival(
        icon: '🪷',
        name: 'Ekadashi',
        nameHi: 'एकादशी',
        major: false,
        type: 'ekadashi',
        desc: 'The 11th lunar day — most sacred to Vishnu. Fast from grains.',
      ),
    ],
  };

  static const _deities = [
    [
      const PanchangDeity(emoji: '☀️', nameEn: 'Surya', nameHi: 'सूर्य'),
      const PanchangDeity(emoji: '🐒', nameEn: 'Hanuman', nameHi: 'हनुमान'),
      const PanchangDeity(emoji: '🏹', nameEn: 'Rama', nameHi: 'श्रीराम'),
    ],
    [
      const PanchangDeity(emoji: '🔱', nameEn: 'Shiva', nameHi: 'शिव'),
      const PanchangDeity(emoji: '🌙', nameEn: 'Chandra', nameHi: 'चन्द्र'),
      const PanchangDeity(emoji: '🌺', nameEn: 'Parvati', nameHi: 'पार्वती'),
    ],
    [
      const PanchangDeity(emoji: '🐒', nameEn: 'Hanuman', nameHi: 'हनुमान'),
      const PanchangDeity(emoji: '⚔️', nameEn: 'Kartikeya', nameHi: 'कार्तिकेय'),
      const PanchangDeity(emoji: '🔴', nameEn: 'Devi', nameHi: 'देवी'),
    ],
    [
      const PanchangDeity(emoji: '🪷', nameEn: 'Vishnu', nameHi: 'विष्णु'),
      const PanchangDeity(emoji: '🦚', nameEn: 'Krishna', nameHi: 'कृष्ण'),
      const PanchangDeity(emoji: '💚', nameEn: 'Budha', nameHi: 'बुध'),
    ],
    [
      const PanchangDeity(emoji: '🌟', nameEn: 'Vishnu', nameHi: 'विष्णु'),
      const PanchangDeity(emoji: '🙏', nameEn: 'Dattatreya', nameHi: 'दत्तात्रेय'),
      const PanchangDeity(emoji: '🟡', nameEn: 'Brihaspati', nameHi: 'बृहस्पति'),
    ],
    [
      const PanchangDeity(emoji: '🌸', nameEn: 'Lakshmi', nameHi: 'लक्ष्मी'),
      const PanchangDeity(emoji: '🎵', nameEn: 'Saraswati', nameHi: 'सरस्वती'),
      const PanchangDeity(emoji: '💛', nameEn: 'Santoshi', nameHi: 'संतोषी'),
    ],
    [
      const PanchangDeity(emoji: '🪐', nameEn: 'Shani', nameHi: 'शनि'),
      const PanchangDeity(emoji: '🔵', nameEn: 'Bhairav', nameHi: 'भैरव'),
      const PanchangDeity(emoji: '🐒', nameEn: 'Hanuman', nameHi: 'हनुमान'),
    ],
  ];

  static const _vrat = [
    ['Surya Vrat — fast in honour of the Sun God. Offer red flowers at sunrise.', 'Single meal only, before sunset. Recite Aditya Hridayam. Offer water to the rising sun.'],
    ['Somvar Vrat — Shiva fast observed. Single meal after sunset.', 'Offer bilva leaves, milk to Shivalinga. Chant Om Namah Shivaya 108×. Wear white.'],
    ['Mangalvar Vrat — Hanuman fast. Single meal.', 'Offer sindoor, jasmine, laddoos to Hanumanji. Recite Hanuman Chalisa 3×. Wear red.'],
    ['Budhvar Vrat — Vishnu fast. Wear green.', 'Offer tulsi and yellow flowers. Chant Vishnu Sahasranama. Eat green vegetables.'],
    ['Guruvar Vrat — Vishnu / Brihaspati fast. Wear yellow.', 'Offer yellow flowers and fruits. Give dakshina to a teacher or elder. Eat yellow foods.'],
    ['Shukravar Vrat — Lakshmi fast. Wear white or pink.', 'Offer lotus flowers. Sing Lakshmi Aarti. Light ghee diya in the northeast. Donate rice.'],
    ['Shanivar Vrat — Saturn fast. Wear black or navy.', 'Light mustard oil lamp. Feed sesame to birds and crows. Recite Shani Chalisa.'],
  ];

  static const _muhurta = [
    [('Brahma Muhurta', '4:24–5:12', true), ('Abhijit', '11:48–12:36', true), ('Rahu Kaal', '16:30–18:00', false)],
    [('Brahma Muhurta', '4:24–5:12', true), ('Amrit Kaal', '14:00–15:30', true), ('Rahu Kaal', '7:30–9:00', false)],
    [('Brahma Muhurta', '4:24–5:12', true), ('Abhijit', '11:48–12:36', true), ('Rahu Kaal', '15:00–16:30', false)],
    [('Brahma Muhurta', '4:24–5:12', true), ('Amrit Kaal', '9:00–10:30', true), ('Rahu Kaal', '12:00–13:30', false)],
    [('Brahma Muhurta', '4:24–5:12', true), ('Abhijit', '11:48–12:36', true), ('Rahu Kaal', '13:30–15:00', false)],
    [('Brahma Muhurta', '4:24–5:12', true), ('Amrit Kaal', '7:00–8:30', true), ('Rahu Kaal', '10:30–12:00', false)],
    [('Brahma Muhurta', '4:24–5:12', true), ('Abhijit', '11:48–12:36', true), ('Rahu Kaal', '9:00–10:30', false)],
  ];

  static const _sunTimes = [
    ('7:15', '5:45'), ('6:50', '6:05'), ('6:15', '6:25'), ('5:45', '6:45'),
    ('5:20', '7:05'), ('5:10', '7:20'), ('5:20', '7:20'), ('5:40', '7:05'),
    ('6:00', '6:35'), ('6:20', '5:55'), ('6:45', '5:25'), ('7:10', '5:25'),
  ];

  static const _wisdom = [
    (text: 'Even the gods bow down to those who walk their path with courage and faith.', src: '— Atharva Veda'),
    (text: 'The soul is neither born, nor dies at any time. It has not come into being and will not come into being.', src: '— Bhagavad Gita 2.20'),
    (text: 'The fire of knowledge burns all karmas to ashes.', src: '— Bhagavad Gita 4.37'),
    (text: 'Let your actions be your legacy — they are your most honest biography.', src: '— Panchatantra'),
    (text: 'He who sees all beings in himself, and himself in all beings — loses all fear.', src: '— Isha Upanishad 6'),
    (text: 'The truth is one — the wise call it by many names.', src: '— Rig Veda 1.164.46'),
    (text: 'Where there is dharma, there is victory.', src: '— Mahabharata 6.43.60'),
    (text: 'A mind at peace, a mind focused on the Supreme — this is the highest yoga.', src: '— Bhagavad Gita 6.7'),
    (text: 'By devotion alone can I be seen, known, and entered.', src: '— Bhagavad Gita 11.54'),
    (text: 'The lord of all wisdom dwells in the lotus of your heart.', src: '— Mundaka Upanishad'),
    (text: 'On Ekadashi, the mind cleansed of food becomes filled with the Divine.', src: '— Skanda Purana'),
    (text: 'Give up all varieties of religion and just surrender unto Me — I shall deliver you.', src: '— Bhagavad Gita 18.66'),
    (text: 'Contentment is the highest gain. Good company the highest course.', src: '— Chanakya Niti'),
    (text: 'The whole world is the family of one God.', src: '— Maha Upanishad 6.72'),
    (text: 'Water that cleanses also flows — be always moving, always pure.', src: '— Bhagavata Purana'),
    (text: 'Act always as if the future of the universe depended on what you do right now.', src: '— Karma Yoga'),
    (text: 'The wise see everywhere the same divine essence shining through all beings.', src: '— Bhagavad Gita 5.18'),
    (text: 'Even a flower offered in devotion reaches the Divine, if given with pure love.', src: '— Bhagavad Gita 9.26'),
    (text: 'When the root of all sorrow — desire — is pulled out, true joy springs eternally.', src: '— Vivekachudamani'),
    (text: 'Arise! Awake! Stop not till the goal is reached.', src: '— Swami Vivekananda / Katha Upanishad'),
    (text: 'In the last analysis, only love is the supreme teacher.', src: '— Ramana Maharshi'),
    (text: 'Listen to the silence — it knows every secret of the universe.', src: '— Upanishadic tradition'),
    (text: 'Your task is not to seek love but merely to seek and find all barriers to love.', src: '— Sufi wisdom / Rumi'),
    (text: 'The Guru is not the body. The Guru is the awakening itself.', src: '— Yogavasishtha'),
    (text: 'Where compassion lives, there too lives God.', src: '— Narada Bhakti Sutras'),
    (text: 'The greatest mantra is OM — it contains the past, present and future.', src: '— Mandukya Upanishad'),
    (text: 'Even the journey of a thousand miles begins with one sincere prayer.', src: '— Bhakti tradition'),
  ];

  static String _festKey(int y, int m, int d) => '$y-$m-$d';

  static PanchangDay getPanchangDay(int y, int m, int d) {
    final date = DateTime(y, m, d, 6);
    final a = _lunarAge(date);
    final ti = _tithi(a);
    final pk = _paksha(a);
    final ni = _nakshatraIndex(date);
    final masa = _masa(m);
    final dow = date.weekday % 7; // 0=Sun .. 6=Sat
    final st = _sunTimes[(m - 1).clamp(0, 11)];
    final key = _festKey(y, m, d);
    var festivals = _fests[key] ?? [];

    if (festivals.isEmpty && ti.type.isNotEmpty) {
      if (ti.type == 'purnima') {
        festivals = [
          PanchangFestival(
            icon: '🌕',
            name: 'Purnima',
            nameHi: 'पूर्णिमा',
            major: false,
            type: 'purnima',
            desc: 'Full moon — the Soma is at its peak. Sacred for Satyanarayan Puja, charity, ancestral rites. Fast until moonrise. The moon carries divine nectar. Meditate on the lunar light.',
          ),
        ];
      } else if (ti.type == 'amavasya') {
        festivals = [
          PanchangFestival(
            icon: '🌑',
            name: 'Amavasya',
            nameHi: 'अमावस्या',
            major: false,
            type: 'amavasya',
            desc: 'No-moon night — the veil between worlds is thin. Sacred for Pitru Tarpan. Light a diya facing south, offer sesame and water to your ancestors with love and gratitude.',
          ),
        ];
      } else if (ti.type == 'ekadashi') {
        festivals = [
          PanchangFestival(
            icon: '🪷',
            name: 'Ekadashi',
            nameHi: 'एकादशी',
            major: false,
            type: 'ekadashi',
            desc: 'The 11th lunar day — most sacred to Vishnu. Fast from grains. Stay awake, recite Vishnu Sahasranama. The mind, freed from the burden of digestion, rises toward the Divine.',
          ),
        ];
      }
    }

    final vratLines = _vrat[dow];
    final muRaw = _muhurta[dow];
    final muhurtas = muRaw
        .map((e) => PanchangMuhurta(name: e.$1, time: e.$2, auspicious: e.$3))
        .toList();
    final wisdom = _wisdom[ni.clamp(0, _wisdom.length - 1)];

    return PanchangDay(
      date: DateTime(y, m, d),
      tithiEn: ti.n,
      tithiHi: ti.h,
      tithiType: ti.type,
      pakshaEn: pk.n,
      pakshaHi: pk.h,
      nakshatraEn: _nk[ni],
      nakshatraHi: _nkHi[ni],
      nakshatraIdx: ni,
      masaEn: masa.n,
      masaHi: masa.h,
      yoga: _yoga(date),
      karana: _karana(a),
      varaEn: _vr[dow],
      varaHi: _vrHi[dow],
      rashi: _rashi(date),
      sunrise: '${st.$1} AM',
      sunset: '${st.$2} PM',
      festivals: festivals,
      dayOfWeek: dow,
      deities: List.from(_deities[dow]),
      vratLines: List.from(vratLines),
      muhurtas: muhurtas,
      wisdomText: wisdom.text,
      wisdomSrc: wisdom.src,
    );
  }

  static int vikramSamvatYear(DateTime d) => _vikramSamvatYear(d);

  /// Lunar month name pair for display (e.g. "Phalguna–Chaitra"). Month is 1-based.
  static String masaRangeLabel(int month) {
    const msp = [
      'Pausha–Magha', 'Magha–Phalguna', 'Phalguna–Chaitra', 'Chaitra–Vaishakha',
      'Vaishakha–Jyeshtha', 'Jyeshtha–Ashadha', 'Ashadha–Shravana', 'Shravana–Bhadra',
      'Bhadra–Ashwin', 'Ashwin–Kartika', 'Kartika–Marga', 'Marga–Pausha',
    ];
    return msp[(month - 1).clamp(0, 11)];
  }

  static const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
}
