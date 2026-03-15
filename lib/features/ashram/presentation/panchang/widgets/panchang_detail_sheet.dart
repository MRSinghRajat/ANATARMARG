import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../data/panchang/panchang_engine.dart';
import '../../../data/panchang/panchang_models.dart';

/// Full Panchang detail bottom sheet: hero, quick info, PANCHANG grid, significance, deities, vrat, muhurta, wisdom.
class PanchangDetailSheet extends StatelessWidget {
  const PanchangDetailSheet({
    super.key,
    required this.day,
    required this.onClose,
  });

  final PanchangDay day;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final monthName = PanchangEngine.monthNames[day.date.month - 1];
    final vs = PanchangEngine.vikramSamvatYear(day.date);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF110E08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: AppColors.panchangBorder2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.panchangGold,
                        AppColors.panchangGold2,
                        AppColors.panchangGold,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.panchangBorder2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 16,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18, color: AppColors.panchangMuted2),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.panchangGlass2,
                    side: BorderSide(color: AppColors.panchangBorder),
                    minimumSize: const Size(26, 26),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(monthName, vs),
                  _buildInfoScroll(),
                  const SizedBox(height: 16),
                  _buildSection('PANCHANG', _buildPanchangGrid()),
                  if (day.festivals.isNotEmpty)
                    _buildSection('SIGNIFICANCE', _buildFestivalCards()),
                  _buildSection('TODAY\'S DEITIES', _buildDeityRow()),
                  _buildSection('VRAT · OBSERVANCES', _buildVratRows()),
                  _buildSection('MUHURTA', _buildMuhurtaSection()),
                  _buildSection('WISDOM OF THE DAY', _buildWisdomCard()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(String monthName, int vs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.panchangText,
                        AppColors.panchangGold2,
                        AppColors.panchangSaffron2,
                      ],
                      stops: [0, 0.55, 1],
                    ).createShader(bounds),
                    child: Text(
                      '${day.date.day}',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 72,
                        height: 0.85,
                        letterSpacing: -3,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '$monthName ${day.date.year}',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: AppColors.panchangMuted2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.panchangGold2, AppColors.panchangSaffron2],
                    ).createShader(bounds),
                    child: Text(
                      day.varaHi,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    day.varaEn,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.panchangMuted,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'VS $vs',
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      letterSpacing: 3,
                      color: AppColors.panchangMuted2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.panchangGold, AppColors.panchangSaffron2],
                ).createShader(bounds),
                child: Text(
                  '${day.tithiHi} ',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '· ${day.tithiEn}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.panchangMuted,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          Text(
            '${day.pakshaEn} · ${day.pakshaHi}',
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: AppColors.panchangMuted2,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoScroll() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          _infoCard('Sunrise', day.sunrise),
          const SizedBox(width: 4),
          _infoCard('Sunset', day.sunset),
          const SizedBox(width: 4),
          _infoCard('Nakshatra', day.nakshatraEn),
          const SizedBox(width: 4),
          _infoCard('नक्षत्र', day.nakshatraHi, deva: true),
          const SizedBox(width: 4),
          _infoCard('Yoga', day.yoga),
          const SizedBox(width: 4),
          _infoCard('Karana', day.karana),
          const SizedBox(width: 4),
          _infoCard('Rashi', day.rashi),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, {bool deva = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      constraints: const BoxConstraints(minWidth: 70),
      decoration: BoxDecoration(
        color: AppColors.panchangGlass,
        border: Border.all(color: AppColors.panchangBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 6.5,
              letterSpacing: 2,
              color: AppColors.panchangMuted2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          if (deva)
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.panchangGold2, AppColors.panchangSaffron2],
              ).createShader(bounds),
              child: Text(
                value,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                color: AppColors.panchangText,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '✦',
                style: GoogleFonts.outfit(
                  fontSize: 7,
                  color: AppColors.panchangGold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 8,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.panchangMuted2,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.panchangBorder, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPanchangGrid() {
    final items = [
      ('Tithi', day.tithiEn, false),
      ('Nakshatra', day.nakshatraEn, false),
      ('Yoga', day.yoga, false),
      ('Karana', day.karana, false),
      ('Masa', day.masaHi, true),
      ('Paksha', day.pakshaEn, false),
      ('Vara', day.varaEn, false),
      ('Sun / Rashi', day.rashi, false),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 2.2,
      children: items.map((e) => _gridItem(e.$1, e.$2, deva: e.$3)).toList(),
    );
  }

  Widget _gridItem(String label, String value, {bool deva = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.panchangGlass,
        border: Border.all(color: AppColors.panchangBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 7,
              letterSpacing: 2,
              color: AppColors.panchangMuted2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          if (deva)
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.panchangGold2, AppColors.panchangSaffron2],
              ).createShader(bounds),
              child: Text(
                value,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.panchangText,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFestivalCards() {
    return Column(
      children: day.festivals.map((f) {
        final type = f.major ? 'major' : f.type;
        Color borderColor;
        Color bgColor;
        switch (type) {
          case 'major':
            borderColor = AppColors.panchangCrimson.withValues(alpha: 0.22);
            bgColor = AppColors.panchangCrimson.withValues(alpha: 0.07);
            break;
          case 'ekadashi':
            borderColor = AppColors.panchangJade.withValues(alpha: 0.18);
            bgColor = AppColors.panchangJade.withValues(alpha: 0.05);
            break;
          case 'purnima':
            borderColor = AppColors.panchangIce.withValues(alpha: 0.12);
            bgColor = AppColors.panchangIce.withValues(alpha: 0.04);
            break;
          case 'amavasya':
            borderColor = AppColors.panchangViolet.withValues(alpha: 0.2);
            bgColor = AppColors.panchangViolet.withValues(alpha: 0.07);
            break;
          default:
            borderColor = AppColors.panchangGold.withValues(alpha: 0.2);
            bgColor = AppColors.panchangGold.withValues(alpha: 0.07);
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.panchangText,
                      ),
                    ),
                    Text(
                      f.nameHi,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 11,
                        color: AppColors.panchangMuted2,
                      ),
                    ),
                    if (f.deity != null)
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.panchangGold.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.panchangBorder2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '✦ ${f.deity}',
                          style: GoogleFonts.outfit(
                            fontSize: 7.5,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.panchangGold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      f.desc,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.panchangMuted,
                        height: 1.65,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeityRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: day.deities.map((d) {
          return Container(
            width: 64,
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.panchangGlass,
              border: Border.all(color: AppColors.panchangBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 3),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.panchangGold2, AppColors.panchangSaffron2],
                  ).createShader(bounds),
                  child: Text(
                    d.nameHi,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  d.nameEn.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 6.5,
                    letterSpacing: 1,
                    color: AppColors.panchangMuted2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVratRows() {
    return Column(
      children: day.vratLines.map((line) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.panchangGold.withValues(alpha: 0.04),
            border: Border.all(color: AppColors.panchangBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.panchangGold, AppColors.panchangSaffron2],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  line,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.panchangMuted,
                    height: 1.65,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMuhurtaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sunCard('🌅', 'Sunrise', day.sunrise),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _sunCard('🌇', 'Sunset', day.sunset),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...day.muhurtas.map((m) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  m.name,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.panchangMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: m.auspicious
                            ? AppColors.panchangJade.withValues(alpha: 0.08)
                            : AppColors.panchangCrimson.withValues(alpha: 0.08),
                        border: Border.all(
                          color: m.auspicious
                              ? AppColors.panchangJade.withValues(alpha: 0.2)
                              : AppColors.panchangCrimson.withValues(alpha: 0.18),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        m.auspicious ? 'AUSPICIOUS' : 'AVOID',
                        style: GoogleFonts.outfit(
                          fontSize: 7,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                          color: m.auspicious
                              ? AppColors.panchangJade.withValues(alpha: 0.8)
                              : AppColors.panchangCrimson.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      m.time,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.panchangGold,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          '✦ Approximate for Northern India. Consult a local Panchang for precise timings.',
          style: GoogleFonts.outfit(
            fontSize: 8,
            color: AppColors.panchangMuted2,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _sunCard(String icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panchangGlass,
        border: Border.all(color: AppColors.panchangBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 7,
                    letterSpacing: 2,
                    color: AppColors.panchangMuted2,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.panchangGold2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWisdomCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.panchangGold.withValues(alpha: 0.07),
            AppColors.panchangSaffron2.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: AppColors.panchangBorder2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '"',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 30,
                  color: AppColors.panchangGold,
                  height: 0.6,
                ),
              ),
              Text(
                'NAKSHATRA · ${day.nakshatraEn.toUpperCase()}',
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  letterSpacing: 3,
                  color: AppColors.panchangGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            day.wisdomText,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: AppColors.panchangText2,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day.wisdomSrc,
            style: GoogleFonts.outfit(
              fontSize: 9,
              color: AppColors.panchangMuted2,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
