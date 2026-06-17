import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../navigation/presentation/providers/main_navigation_intent_provider.dart';

/// Guidance for the daily Evening Aarti task: flexible timing, Mandir option, mark complete.
class EveningAartiScreen extends ConsumerWidget {
  const EveningAartiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.ashramBackgroundDark.withValues(alpha: 0.92),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Evening Aarti',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFF3E0),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryOrange.withValues(alpha: 0.35),
                          AppColors.ashramAccentGold.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.2),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.wb_twilight_rounded,
                      size: 48,
                      color: Colors.amber.shade100,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Take a quiet moment for aarti today',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: const Color(0xFFFFF8F0),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Whenever you have time this evening is perfect. Light a diya if you can, offer your heart, and simply be present.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 28),
                _infoCard(
                  icon: Icons.schedule_rounded,
                  title: 'Your pace',
                  accent: const Color(0xFFFFE0B2),
                  lines: const [
                    'No fixed clock — fit aarti into your evening when it feels right.',
                    'Even a few minutes of lamp, incense, or quiet prayer counts.',
                  ],
                ),
                const SizedBox(height: 16),
                _infoCard(
                  icon: Icons.temple_hindu_rounded,
                  title: 'If you are short on time',
                  accent: AppColors.ashramAccentGold,
                  lines: const [
                    'Open your Mandir in Aangan: walk in, start aarti in the scene, and hold your ishta (chosen form of the Divine) in mind.',
                    'Or sit quietly, recall their name, and read or listen to a Chalisa or Aarti from Granthalaya when you can.',
                  ],
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(mainNavIntentProvider.notifier).state =
                        const MainNavIntent(NavItem.home, aanganTabIndex: 1);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.temple_hindu_outlined, size: 22),
                  label: Text(
                    'Go to Mandir',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                  label: Text(
                    'I did aarti — mark complete',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFF3E0),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                SizedBox(height: 16 + bottom),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required Color accent,
    required List<String> lines,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2318).withValues(alpha: 0.95),
            const Color(0xFF1E1812).withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFF5E6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < lines.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lines[i],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ],
            ),
            if (i < lines.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
