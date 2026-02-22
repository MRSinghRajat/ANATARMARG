import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../providers/garbh_sanskar_providers.dart';
import 'garbh_sanskar_home_screen.dart';

/// Onboarding screen for new Garbh Sanskar users
/// Collects due date, mother's name, baby gender preference
class GarbhSanskarSetupScreen extends ConsumerStatefulWidget {
  const GarbhSanskarSetupScreen({super.key});

  @override
  ConsumerState<GarbhSanskarSetupScreen> createState() =>
      _GarbhSanskarSetupScreenState();
}

class _GarbhSanskarSetupScreenState
    extends ConsumerState<GarbhSanskarSetupScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Form state
  final _nameController = TextEditingController();
  DateTime? _dueDate;
  String _babyGender = 'surprise';
  bool _isPostnatal = false;
  DateTime? _birthDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _animController.reverse().then((_) {
      setState(() => _currentStep++);
      _animController.forward();
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 120)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 280)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF9933),
            onPrimary: Colors.black,
            surface: Color(0xFF1A1D23),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF9933),
            onPrimary: Colors.black,
            surface: Color(0xFF1A1D23),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    final notifier = ref.read(journeyNotifierProvider.notifier);

    final journey = UserPregnancyJourney(
      id: '',
      userId: '',
      dueDate: _isPostnatal ? null : _dueDate,
      birthDate: _isPostnatal ? _birthDate : null,
      babyGender: _babyGender,
      mode: _isPostnatal ? 'postnatal' : 'prenatal',
      motherName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      preferredLanguage: 'hi',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await notifier.saveJourney(journey);
    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const GarbhSanskarHomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildModeStep();
      case 2:
        return _isPostnatal ? _buildPostnatalStep() : _buildPrenatalStep();
      case 3:
        return _buildGenderStep();
      case 4:
        return _buildNameStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return _StepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤱', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'गर्भ संस्कार',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 42,
              color: const Color(0xFFFF9933),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Garbh Sanskar',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'The ancient science of nurturing your baby\'s body, mind, and soul from the very beginning.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white60,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          _GoldButton(
            label: 'Begin Your Journey',
            onTap: _nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildModeStep() {
    return _StepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Where are you in your journey?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _ModeCard(
            emoji: '🤰',
            title: 'I am pregnant',
            subtitle: 'Prenatal Garbh Sanskar',
            isSelected: !_isPostnatal,
            onTap: () => setState(() => _isPostnatal = false),
          ),
          const SizedBox(height: 16),
          _ModeCard(
            emoji: '👶',
            title: 'My baby is born',
            subtitle: 'Postnatal care & rituals',
            isSelected: _isPostnatal,
            onTap: () => setState(() => _isPostnatal = true),
          ),
          const SizedBox(height: 48),
          _GoldButton(label: 'Continue', onTap: _nextStep),
        ],
      ),
    );
  }

  Widget _buildPrenatalStep() {
    return _StepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'When is your baby due?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll personalise your daily mantras and meditations for each week of your pregnancy.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _pickDueDate,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _dueDate != null
                      ? const Color(0xFFFF9933)
                      : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dueDate == null
                            ? 'Tap to select'
                            : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: _dueDate != null
                              ? const Color(0xFFFF9933)
                              : Colors.white38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_dueDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D23),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Week ${_computeCurrentWeek(_dueDate!)} of 40 • ${_computeTrimester(_dueDate!)}',
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFFFF9933)),
              ),
            ),
          ],
          const SizedBox(height: 48),
          _GoldButton(
            label: 'Continue',
            onTap: _dueDate != null ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPostnatalStep() {
    return _StepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'When was your baby born?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _pickBirthDate,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _birthDate != null
                      ? const Color(0xFFFF9933)
                      : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  const Text('🎂', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Birth Date',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _birthDate == null
                            ? 'Tap to select'
                            : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: _birthDate != null
                              ? const Color(0xFFFF9933)
                              : Colors.white38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          _GoldButton(
            label: 'Continue',
            onTap: _birthDate != null ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return _StepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Do you know the gender?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us personalise lullabies and stories.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  emoji: '👦',
                  label: 'Boy',
                  isSelected: _babyGender == 'boy',
                  onTap: () => setState(() => _babyGender = 'boy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderCard(
                  emoji: '👧',
                  label: 'Girl',
                  isSelected: _babyGender == 'girl',
                  onTap: () => setState(() => _babyGender = 'girl'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderCard(
                  emoji: '🌟',
                  label: 'Surprise',
                  isSelected: _babyGender == 'surprise',
                  onTap: () => setState(() => _babyGender = 'surprise'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _GoldButton(label: 'Continue', onTap: _nextStep),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return _StepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What shall we call you?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Optional — your name will appear in personalised affirmations.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Your name (optional)',
              hintStyle: GoogleFonts.inter(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1A1D23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF9933)),
              ),
              prefixIcon: const Icon(Icons.person_outline, color: Colors.white38),
            ),
          ),
          const SizedBox(height: 48),
          _isSaving
              ? const CircularProgressIndicator(
                  color: Color(0xFFFF9933),
                )
              : _GoldButton(
                  label: 'Start My Journey 🙏',
                  onTap: _saveAndContinue,
                ),
        ],
      ),
    );
  }

  int _computeCurrentWeek(DateTime dueDate) {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    final week = 40 - (daysUntilDue / 7).ceil();
    return week.clamp(1, 42);
  }

  String _computeTrimester(DateTime dueDate) {
    final week = _computeCurrentWeek(dueDate);
    if (week <= 13) return 'First Trimester';
    if (week <= 27) return 'Second Trimester';
    return 'Third Trimester';
  }
}

// ============================================================
// HELPER WIDGETS
// ============================================================

class _StepContainer extends StatelessWidget {
  final Widget child;
  const _StepContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0A06), Color(0xFF1A1000)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: child,
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _GoldButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [Color(0xFFFF9933), Color(0xFFFFD700)],
                )
              : null,
          color: onTap == null ? Colors.white12 : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: onTap != null ? Colors.black : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2A1500)
              : const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF9933)
                : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFFF9933)
                          : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white54),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFFFF9933), size: 22),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A1500) : const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9933) : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isSelected ? const Color(0xFFFF9933) : Colors.white70,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
