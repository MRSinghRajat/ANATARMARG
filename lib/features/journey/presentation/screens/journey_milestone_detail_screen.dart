import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../profile/presentation/providers/language_provider.dart';
import '../../data/models/journey_models.dart';
import '../providers/journey_providers.dart';
class JourneyMilestoneDetailScreen extends ConsumerStatefulWidget {
  final String userJourneyId;
  final String milestoneId;

  const JourneyMilestoneDetailScreen({
    super.key,
    required this.userJourneyId,
    required this.milestoneId,
  });

  @override
  ConsumerState<JourneyMilestoneDetailScreen> createState() =>
      _JourneyMilestoneDetailScreenState();
}

class _JourneyMilestoneDetailScreenState
    extends ConsumerState<JourneyMilestoneDetailScreen> {
  JourneyMilestone? _milestone;
  bool _loading = true;
  bool _completed = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(journeyRepositoryProvider);
    final milestone = await repo.getMilestoneById(widget.milestoneId);
    setState(() {
      _milestone = milestone;
      _loading = false;
    });
  }

  Future<void> _complete() async {
    if (_milestone == null || _completed) return;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    setState(() => _completed = true);
    final repo = ref.read(journeyRepositoryProvider);
    await repo.completeMilestone(
      userId: uid,
      userJourneyId: widget.userJourneyId,
      milestoneId: widget.milestoneId,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      coinsEarned: _milestone!.coinReward ?? 0,
    );
    if ((_milestone!.coinReward ?? 0) > 0) {
      CoinService().addCoins(_milestone!.coinReward!);
    }
    ref.invalidate(activeJourneyProvider);
    ref.invalidate(activeJourneysProvider);
    ref.invalidate(completedMilestoneDatesProvider(widget.userJourneyId));
    ref.invalidate(journeyCompletedMilestoneIdsProvider(widget.userJourneyId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Milestone complete! +${_milestone!.coinReward ?? 0} coins')));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.ashramBackgroundDark,
        appBar: AppBar(
          title: Text('Milestone', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.zinc100,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }
    if (_milestone == null) {
      return Scaffold(
        backgroundColor: AppColors.ashramBackgroundDark,
        appBar: AppBar(
          title: Text('Milestone', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.zinc100,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Text(
            'Milestone not found',
            style: GoogleFonts.inter(color: AppColors.zinc500),
          ),
        ),
      );
    }
    final m = _milestone!;
    final title = localizedLang(lang, en: m.title, hi: m.titleHindi);
    final description = m.description == null && m.descriptionHindi == null
        ? null
        : localizedLang(lang, en: m.description ?? '', hi: m.descriptionHindi);
    final journeyAsync = ref.watch(userJourneyProvider(widget.userJourneyId));
    final userJourney = journeyAsync.valueOrNull;
    final journeyLocked =
        userJourney == null || userJourney.isCompleted || !userJourney.isActive;

    // Check optimistically AND from DB if already completed
    final completedMilestoneDatesAsync =
        ref.watch(completedMilestoneDatesProvider(widget.userJourneyId));
    final dbCompleted =
        completedMilestoneDatesAsync.valueOrNull?.containsKey(widget.milestoneId) ?? false;
    final isComplete = _completed || dbCompleted;
    final coinReward = m.coinReward ?? 0;

    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.zinc100),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.zinc100,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryOrange.withValues(alpha: 0.12),
                    AppColors.journeyDeepPurple.withValues(alpha: 0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  Text(m.icon ?? '🪔', style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 14),
                  // Milestone type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _milestoneTypeLabel(m.milestoneType),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.zinc100,
                    ),
                  ),
                  // Coin reward pill
                  if (coinReward > 0) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '+$coinReward on completion',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Description / Significance ─────────────────────────────
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'SIGNIFICANCE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ashramCardDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.65,
                    color: AppColors.zinc400,
                  ),
                ),
              ),
            ],

            // ── Notes field ────────────────────────────────────────────
            if (m.allowNotes && !journeyLocked) ...[
              const SizedBox(height: 20),
              Text(
                'YOUR NOTES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                style: GoogleFonts.inter(color: AppColors.zinc100, fontSize: 14),
                cursorColor: AppColors.primaryOrange,
                decoration: InputDecoration(
                  hintText: 'Write your reflections, memories, or intentions…',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.zinc500,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.ashramCardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
                  ),
                ),
                maxLines: 4,
              ),
            ],

            // ── Status messages ────────────────────────────────────────
            if (journeyLocked && userJourney != null && userJourney.isCompleted) ...[
              const SizedBox(height: 14),
              Text(
                'This journey is complete. Milestones are view-only.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: AppColors.zinc500),
              ),
            ],
            if (isComplete) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Samskara completed!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // ── Complete button ────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: (isComplete || journeyLocked) ? null : _complete,
              icon: Icon(
                isComplete ? Icons.check_rounded : Icons.celebration_rounded,
                size: 20,
              ),
              label: Text(
                isComplete
                    ? 'Samskara Complete'
                    : journeyLocked
                        ? 'Unavailable'
                        : coinReward > 0
                            ? 'Complete Samskara (+$coinReward 🪙)'
                            : 'Complete Samskara',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete ? AppColors.zinc600 : AppColors.primaryOrange,
                foregroundColor: isComplete ? AppColors.zinc400 : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _milestoneTypeLabel(String? type) {
    switch (type) {
      case 'samskara': return '✦ Samskara';
      case 'ceremony': return '🪔 Ceremony';
      case 'habit':    return '📅 Habit';
      case 'learning': return '📖 Learning';
      default:         return '✦ Milestone';
    }
  }
}
