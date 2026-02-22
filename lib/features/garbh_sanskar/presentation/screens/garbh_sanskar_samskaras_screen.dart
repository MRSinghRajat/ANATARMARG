import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../../data/repositories/garbh_sanskar_repository.dart';
import '../providers/garbh_sanskar_providers.dart';

/// Displays all Samskaras (prenatal or postnatal) with full ritual guides
class GarbhSanskarSamskarasScreen extends ConsumerWidget {
  final bool isPrenatal;

  const GarbhSanskarSamskarasScreen({super.key, required this.isPrenatal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samskarasAsync = isPrenatal
        ? ref.watch(prenatalSamskarasProvider)
        : ref.watch(postnatalSamskarasProvider);
    final completedAsync = ref.watch(completedSamskarasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A06),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPrenatal ? 'गर्भ संस्कार' : 'जन्म संस्कार',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                color: const Color(0xFFD97706),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isPrenatal ? 'Prenatal Samskaras' : 'Postnatal Samskaras',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: samskarasAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9933)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.white)),
        ),
        data: (samskaras) {
          final completedList =
              completedAsync.valueOrNull ?? [];
          final completedIds = completedList
              .where((c) =>
                  c['samskara_type'] ==
                  (isPrenatal ? 'prenatal' : 'postnatal'))
              .map((c) => c['samskara_id'] as int)
              .toSet();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Intro text
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1500).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFD97706).withOpacity(0.3)),
                ),
                child: Text(
                  isPrenatal
                      ? 'The three prenatal Samskaras sanctify the journey of bringing a new soul into the world. Each ceremony marks a sacred milestone in the baby\'s development.'
                      : 'The postnatal Samskaras celebrate the arrival of your baby and mark the sacred milestones of their early life. Each ceremony is a gift of divine blessings.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white60,
                    height: 1.6,
                  ),
                ),
              ),
              ...samskaras.map((s) => _SamskaraCard(
                    samskara: s,
                    isCompleted: completedIds.contains(s.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SamskaraDetailScreen(
                          samskara: s,
                          isCompleted: completedIds.contains(s.id),
                        ),
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _SamskaraCard extends StatelessWidget {
  final GarbhSamskara samskara;
  final bool isCompleted;
  final VoidCallback onTap;

  const _SamskaraCard({
    required this.samskara,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFFD97706).withOpacity(0.6)
                : Colors.white12,
            width: isCompleted ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '🪔',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        samskara.nameSanskrit,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        samskara.name,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle,
                      color: Color(0xFFD97706), size: 24)
                else
                  const Icon(Icons.chevron_right,
                      color: Colors.white38, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⏰  ${samskara.timing}',
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.white60),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              samskara.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.list_alt,
                    size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  '${samskara.ritualSteps.length} ritual steps',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white38),
                ),
                const Spacer(),
                Text(
                  '+25 🪙',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SAMSKARA DETAIL SCREEN
// ============================================================

class SamskaraDetailScreen extends ConsumerStatefulWidget {
  final GarbhSamskara samskara;
  final bool isCompleted;

  const SamskaraDetailScreen({
    super.key,
    required this.samskara,
    required this.isCompleted,
  });

  @override
  ConsumerState<SamskaraDetailScreen> createState() =>
      _SamskaraDetailScreenState();
}

class _SamskaraDetailScreenState extends ConsumerState<SamskaraDetailScreen> {
  int _currentStep = 0;
  bool _isCompleted = false;
  bool _isSaving = false;
  final GarbhSanskarRepository _repo = GarbhSanskarRepository();

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
  }

  Future<void> _markComplete() async {
    setState(() => _isSaving = true);
    final success = await _repo.completeSamskara(
      samskaraType: widget.samskara.type,
      samskaraId: widget.samskara.id,
      completedDate: DateTime.now(),
    );
    setState(() {
      _isSaving = false;
      if (success) _isCompleted = true;
    });
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2A1500),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                '+25 coins earned! Samskara completed 🙏',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final samskara = widget.samskara;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A06),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFFD97706), size: 26),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const Text('🪔', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(
                    samskara.nameSanskrit,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 32,
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    samskara.name,
                    style: GoogleFonts.inter(
                        fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1500),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⏰  ${samskara.timing}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              samskara.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
                height: 1.7,
              ),
            ),

            if (samskara.significance != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D23),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFD97706).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌟 Significance',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFFD97706),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      samskara.significance!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Ritual steps
            Text(
              'Ritual Steps',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...samskara.ritualSteps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isActive = i == _currentStep;
              final isDone = i < _currentStep;

              return GestureDetector(
                onTap: () => setState(() => _currentStep = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2A1500)
                        : const Color(0xFF1A1D23),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFD97706)
                          : isDone
                              ? const Color(0xFFD97706).withOpacity(0.3)
                              : Colors.white12,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? const Color(0xFFD97706)
                              : isActive
                                  ? const Color(0xFFD97706).withOpacity(0.2)
                                  : Colors.white12,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check,
                                  color: Colors.black, size: 16)
                              : Text(
                                  '${step.step}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isActive
                                        ? const Color(0xFFD97706)
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: isActive
                                    ? const Color(0xFFD97706)
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 6),
                              Text(
                                step.description,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                              if (step.mantra != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('🕉️',
                                          style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          step.mantra!,
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 14,
                                            color: const Color(0xFFFFD700),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (i < samskara.ritualSteps.length - 1)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _currentStep = i + 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Next Step →',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFFD97706),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Required items
            if (samskara.requiredItems.isNotEmpty) ...[
              Text(
                'What You Need',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: samskara.requiredItems
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D23),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white60),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Mantras list
            if (samskara.mantras.isNotEmpty) ...[
              Text(
                'Mantras Used',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...samskara.mantras.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Text('🕉️',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text(
                          m,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white60),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // Complete button
            if (!_isCompleted)
              _isSaving
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD97706)))
                  : GestureDetector(
                      onTap: _markComplete,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD97706),
                              Color(0xFFFF9933)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Mark Samskara as Completed  +25 🪙',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1500),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFD97706).withOpacity(0.5)),
                ),
                child: Center(
                  child: Text(
                    '✓ Samskara Completed 🙏',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
