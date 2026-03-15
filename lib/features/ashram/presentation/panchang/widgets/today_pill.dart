import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../data/panchang/panchang_models.dart';

/// Today pill: tithi/details on left, date/day on right, calendar icon. Tap pill → details; tap icon → month view.
class TodayPill extends StatelessWidget {
  const TodayPill({
    super.key,
    required this.day,
    required this.onTapDetails,
    required this.onTapCalendar,
  });

  final PanchangDay day;
  final VoidCallback onTapDetails;
  final VoidCallback onTapCalendar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTapDetails,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.panchangGlass2,
                    border: Border.all(color: AppColors.panchangBorder2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [AppColors.panchangGold2, AppColors.panchangSaffron2],
                                    ).createShader(bounds),
                                    child: Text(
                                      day.tithiHi,
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${day.tithiEn} · ${day.pakshaHi}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: AppColors.panchangMuted,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 4,
                                    children: [
                                      _chip(day.nakshatraEn),
                                      _chip(day.masaEn),
                                      if (day.festivals.isNotEmpty)
                                        _chip('✦ ${day.festivals.first.name}', fest: true)
                                      else if (day.tithiType.isNotEmpty)
                                        _chip(
                                          day.tithiType == 'ekadashi'
                                              ? 'Ekadashi'
                                              : day.tithiType == 'purnima'
                                                  ? 'Purnima'
                                                  : 'Amavasya',
                                          fest: true,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [AppColors.panchangGold2, AppColors.panchangSaffron2],
                                  ).createShader(bounds),
                                  child: Text(
                                    '${day.date.day}',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  day.varaEn.substring(0, 3).toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    letterSpacing: 2,
                                    color: AppColors.panchangMuted2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TAP · DETAILS ↓',
                                  style: GoogleFonts.outfit(
                                    fontSize: 7,
                                    letterSpacing: 2,
                                    color: AppColors.panchangMuted2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.panchangGlass,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onTapCalendar,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.panchangBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.panchangGold,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {bool fest = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: fest
            ? AppColors.panchangSaffron2.withValues(alpha: 0.12)
            : AppColors.panchangGold.withValues(alpha: 0.08),
        border: Border.all(
          color: fest
              ? AppColors.panchangSaffron2.withValues(alpha: 0.25)
              : AppColors.panchangBorder,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 8.5,
          letterSpacing: 0.5,
          color: fest ? const Color(0xFFE88844) : AppColors.panchangText2,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
