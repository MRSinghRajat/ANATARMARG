// Models for Hindu Panchang (calendar) data — tithi, nakshatra, festivals, etc.
// Used by the Ashram calendar UI (today pill, month grid, detail sheet).

class PanchangDay {
  const PanchangDay({
    required this.date,
    required this.tithiEn,
    required this.tithiHi,
    required this.tithiType,
    required this.pakshaEn,
    required this.pakshaHi,
    required this.nakshatraEn,
    required this.nakshatraHi,
    required this.nakshatraIdx,
    required this.masaEn,
    required this.masaHi,
    required this.yoga,
    required this.karana,
    required this.varaEn,
    required this.varaHi,
    required this.rashi,
    required this.sunrise,
    required this.sunset,
    required this.festivals,
    required this.dayOfWeek,
    required this.deities,
    required this.vratLines,
    required this.muhurtas,
    required this.wisdomText,
    required this.wisdomSrc,
  });

  final DateTime date;
  final String tithiEn;
  final String tithiHi;
  /// amavasya | purnima | ekadashi | ''
  final String tithiType;
  final String pakshaEn;
  final String pakshaHi;
  final String nakshatraEn;
  final String nakshatraHi;
  final int nakshatraIdx;
  final String masaEn;
  final String masaHi;
  final String yoga;
  final String karana;
  final String varaEn;
  final String varaHi;
  final String rashi;
  final String sunrise;
  final String sunset;
  final List<PanchangFestival> festivals;
  /// 0 = Sunday .. 6 = Saturday
  final int dayOfWeek;
  final List<PanchangDeity> deities;
  final List<String> vratLines;
  final List<PanchangMuhurta> muhurtas;
  final String wisdomText;
  final String wisdomSrc;
}

class PanchangFestival {
  const PanchangFestival({
    required this.icon,
    required this.name,
    required this.nameHi,
    required this.major,
    required this.type,
    this.deity,
    required this.desc,
  });

  final String icon;
  final String name;
  final String nameHi;
  final bool major;
  /// major | festival | ekadashi | purnima | amavasya
  final String type;
  final String? deity;
  final String desc;
}

class PanchangMuhurta {
  const PanchangMuhurta({
    required this.name,
    required this.time,
    required this.auspicious,
  });

  final String name;
  final String time;
  final bool auspicious;
}

class PanchangDeity {
  const PanchangDeity({
    required this.emoji,
    required this.nameEn,
    required this.nameHi,
  });

  final String emoji;
  final String nameEn;
  final String nameHi;
}
