import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/journey_models.dart';
import '../../../../core/theme/app_colors.dart';

class JourneyPhaseChips extends StatelessWidget {
  final List<JourneyPhase> phases;
  /// Phase determined by calendar / journey logic (today).
  final String? calendarPhaseId;
  /// Highlighted chip: browse selection, or calendar when not browsing.
  final String? selectedPhaseId;
  final Set<String> completedPhaseIds;
  final ValueChanged<String>? onPhaseTap;

  const JourneyPhaseChips({
    super.key,
    required this.phases,
    this.calendarPhaseId,
    this.selectedPhaseId,
    this.completedPhaseIds = const {},
    this.onPhaseTap,
  });

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final h = hex.replaceFirst('#', '');
    if (h.length == 6 || h.length == 8) {
      final v = int.tryParse('FF$h', radix: 16);
      if (v != null) return Color(v);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: phases.map((p) {
          final isSelected = p.id == selectedPhaseId;
          final isCalendarCurrent = p.id == calendarPhaseId;
          final isPast = completedPhaseIds.contains(p.id);
          final color = _colorFromHex(p.colorHex) ?? AppColors.primaryOrange;
          final borderW = isSelected ? 1.5 : 1.0;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPhaseTap != null ? () => onPhaseTap!(p.id) : null,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.35)
                        : isPast
                            ? color.withValues(alpha: 0.2)
                            : color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? color.withValues(alpha: 0.85)
                          : isCalendarCurrent && !isSelected
                              ? color.withValues(alpha: 0.45)
                              : color.withValues(alpha: 0.2),
                      width: borderW,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPast)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(Icons.check_rounded, size: 16, color: color.withValues(alpha: 0.9)),
                        ),
                      Text(
                        p.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected || isPast
                              ? AppColors.zinc100
                              : AppColors.zinc500,
                        ),
                      ),
                      if (isCalendarCurrent && !isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.today_rounded, size: 14, color: color.withValues(alpha: 0.75)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
