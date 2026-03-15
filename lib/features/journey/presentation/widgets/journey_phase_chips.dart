import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/journey_models.dart';
import '../../../../core/theme/app_colors.dart';

class JourneyPhaseChips extends StatelessWidget {
  final List<JourneyPhase> phases;
  final String? currentPhaseId;
  final Set<String> completedPhaseIds;

  const JourneyPhaseChips({
    super.key,
    required this.phases,
    this.currentPhaseId,
    this.completedPhaseIds = const {},
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
          final isCurrent = p.id == currentPhaseId;
          final isPast = completedPhaseIds.contains(p.id);
          final color = _colorFromHex(p.colorHex) ?? AppColors.journeyGold;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrent
                    ? color.withValues(alpha: 0.35)
                    : isPast
                        ? color.withValues(alpha: 0.2)
                        : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent ? color.withValues(alpha: 0.6) : color.withValues(alpha: 0.2),
                  width: 1,
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
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                      color: isCurrent || isPast
                          ? const Color(0xFFF5F0E8)
                          : const Color(0xFFB8B2A8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
