import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/garbh_sanskar_providers.dart';
import '../screens/garbh_sanskar_setup_screen.dart';
import '../screens/garbh_sanskar_home_screen.dart';

/// Entry card for the Garbh Sanskar feature.
/// Shows a setup prompt if no journey exists, otherwise shows progress.
/// Drop this widget anywhere in the app to provide access to the feature.
class GarbhSanskarEntryCard extends ConsumerWidget {
  const GarbhSanskarEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyNotifierProvider);

    return journeyAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
              color: Color(0xFFFF9933), strokeWidth: 2),
        ),
      ),
      error: (_, __) => _buildEntryCard(context, null),
      data: (journey) => _buildEntryCard(context, journey != null),
    );
  }

  Widget _buildEntryCard(BuildContext context, bool? hasJourney) {
    final isSetup = hasJourney == null || hasJourney == false;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => isSetup
              ? const GarbhSanskarSetupScreen()
              : const GarbhSanskarHomeScreen(),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1500), Color(0xFF1A0A00)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFF9933).withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9933).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9933).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🤱', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'गर्भ संस्कार',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      color: const Color(0xFFFF9933),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isSetup
                        ? 'Plan, track & nurture your journey'
                        : 'Continue your Garbh Sanskar practice',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSetup
                        ? 'Planning • Prenatal • Postnatal • Samskaras'
                        : 'Mantras • Yoga • Rituals • Lullabies',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9933).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFFFF9933),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
