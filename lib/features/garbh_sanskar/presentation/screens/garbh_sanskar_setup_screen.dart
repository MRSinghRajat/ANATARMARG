import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../providers/garbh_sanskar_providers.dart';
import 'garbh_sanskar_home_screen.dart';

/// Onboarding / edit screen for Garbh Sanskar journey.
/// Stages: Welcome → Mode (Planning / Prenatal / Postnatal) → Date → Gender → Name → Save.
class GarbhSanskarSetupScreen extends ConsumerStatefulWidget {
  const GarbhSanskarSetupScreen({super.key, this.initialJourney});

  final UserPregnancyJourney? initialJourney;

  @override
  ConsumerState<GarbhSanskarSetupScreen> createState() =>
      _GarbhSanskarSetupScreenState();
}

class _GarbhSanskarSetupScreenState
    extends ConsumerState<GarbhSanskarSetupScreen> {
  int _currentStep = 0;

  final _nameController = TextEditingController();
  DateTime? _dueDate;
  DateTime? _birthDate;
  String _babyGender = 'surprise';
  String _selectedMode = 'planning'; // planning | prenatal | postnatal
  bool _isSaving = false;

  bool get _isEditing => widget.initialJourney != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialJourney;
    if (initial != null) {
      _nameController.text = initial.motherName ?? '';
      _dueDate = initial.dueDate;
      _birthDate = initial.birthDate;
      _babyGender = initial.babyGender ?? 'surprise';
      _selectedMode = initial.mode;
      _currentStep = 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() => setState(() => _currentStep++);
  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 120)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 280)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.saffron,
            onPrimary: Colors.black,
            surface: AppColors.ashramCardDark,
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
      initialDate: _birthDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.saffron,
            onPrimary: Colors.black,
            surface: AppColors.ashramCardDark,
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
    final initial = widget.initialJourney;
    final name = _nameController.text.trim();

    final UserPregnancyJourney journey;
    if (initial != null) {
      journey = UserPregnancyJourney(
        id: initial.id,
        userId: initial.userId,
        dueDate: _selectedMode == 'prenatal' ? _dueDate : null,
        birthDate: _selectedMode == 'postnatal' ? _birthDate : null,
        babyGender: _babyGender,
        mode: _selectedMode,
        motherName: name.isEmpty ? null : name,
        preferredLanguage: initial.preferredLanguage,
        totalSessionsCompleted: initial.totalSessionsCompleted,
        totalMinutesListened: initial.totalMinutesListened,
        createdAt: initial.createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      journey = UserPregnancyJourney(
        id: '',
        userId: '',
        dueDate: _selectedMode == 'prenatal' ? _dueDate : null,
        birthDate: _selectedMode == 'postnatal' ? _birthDate : null,
        babyGender: _babyGender,
        mode: _selectedMode,
        motherName: name.isEmpty ? null : name,
        preferredLanguage: 'hi',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    await notifier.saveJourney(journey);
    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GarbhSanskarHomeScreen()),
      );
    }
  }

  // Step 0: Welcome
  // Step 1: Mode selection (Planning / Pregnant / Baby born)
  // Step 2: Date (prenatal → due date, postnatal → birth date, planning → skip)
  // Step 3: Gender
  // Step 4: Name + Save

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildModeStep();
      case 2:
        if (_selectedMode == 'planning') {
          // Skip date step for planning mode, go to gender
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _currentStep = 3);
          });
          return const SizedBox.shrink();
        }
        return _selectedMode == 'postnatal'
            ? _buildPostnatalDateStep()
            : _buildPrenatalDateStep();
      case 3:
        return _buildGenderStep();
      case 4:
        return _buildNameStep();
      default:
        return _buildWelcomeStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Back button + progress
            if (_currentStep > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white54, size: 20),
                      onPressed: _prevStep,
                    ),
                    Expanded(
                      child: _buildProgressBar(),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            Expanded(child: _buildStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final totalSteps = _selectedMode == 'planning' ? 4 : 5;
    final effectiveStep = _selectedMode == 'planning' && _currentStep >= 3
        ? _currentStep - 1
        : _currentStep;
    final progress = effectiveStep / (totalSteps - 1);
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: Colors.white12,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
        minHeight: 3,
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤱', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(
            'गर्भ संस्कार',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 38,
              color: AppColors.saffron,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Garbh Sanskar',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'The ancient science of nurturing your baby\'s body, mind, and soul — from planning to postnatal care.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          _GoldButton(
            label: _isEditing ? 'Edit Journey' : 'Begin Your Journey',
            onTap: _nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildModeStep() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Where are you in your journey?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _ModeCard(
            emoji: '🌸',
            title: 'Planning a baby',
            subtitle: 'Pre-conception mantras, diet & wellness',
            isSelected: _selectedMode == 'planning',
            onTap: () => setState(() => _selectedMode = 'planning'),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            emoji: '🤰',
            title: 'I am pregnant',
            subtitle: 'Week-by-week prenatal Garbh Sanskar',
            isSelected: _selectedMode == 'prenatal',
            onTap: () => setState(() => _selectedMode = 'prenatal'),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            emoji: '👶',
            title: 'My baby is born',
            subtitle: 'Postnatal samskaras & milestones',
            isSelected: _selectedMode == 'postnatal',
            onTap: () => setState(() => _selectedMode = 'postnatal'),
          ),
          const SizedBox(height: 40),
          _GoldButton(label: 'Continue', onTap: _nextStep),
        ],
      ),
    );
  }

  Widget _buildPrenatalDateStep() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'When is your baby due?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll personalise daily mantras and content for each week.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54, height: 1.5),
          ),
          const SizedBox(height: 32),
          _DatePickerTile(
            emoji: '📅',
            label: 'Due Date',
            date: _dueDate,
            onTap: _pickDueDate,
          ),
          if (_dueDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.ashramCardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Week ${_computeCurrentWeek(_dueDate!)} of 40  •  ${_computeTrimester(_dueDate!)}',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.saffron),
              ),
            ),
          ],
          const SizedBox(height: 40),
          _GoldButton(
            label: 'Continue',
            onTap: _dueDate != null ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPostnatalDateStep() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'When was your baby born?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _DatePickerTile(
            emoji: '🎂',
            label: 'Birth Date',
            date: _birthDate,
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: 40),
          _GoldButton(
            label: 'Continue',
            onTap: _birthDate != null ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _selectedMode == 'planning'
                ? 'Any preference?'
                : 'Do you know the gender?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Helps personalise tips for your journey.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  emoji: '👦', label: 'Boy',
                  isSelected: _babyGender == 'boy',
                  onTap: () => setState(() => _babyGender = 'boy'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GenderCard(
                  emoji: '👧', label: 'Girl',
                  isSelected: _babyGender == 'girl',
                  onTap: () => setState(() => _babyGender = 'girl'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GenderCard(
                  emoji: '🌟', label: 'Surprise',
                  isSelected: _babyGender == 'surprise',
                  onTap: () => setState(() => _babyGender = 'surprise'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _GoldButton(label: 'Continue', onTap: _nextStep),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What shall we call you?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional — appears in personalised affirmations.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Your name (optional)',
              hintStyle: GoogleFonts.inter(color: Colors.white30),
              filled: true,
              fillColor: AppColors.ashramCardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.saffron),
              ),
              prefixIcon: const Icon(Icons.person_outline, color: Colors.white30),
            ),
          ),
          const SizedBox(height: 40),
          _isSaving
              ? const CircularProgressIndicator(color: AppColors.saffron)
              : _GoldButton(
                  label: _isEditing ? 'Save Changes' : 'Start My Journey',
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

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _GoldButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(colors: [AppColors.saffron, Color(0xFFFFD700)])
              : null,
          color: enabled ? null : Colors.white12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.black : Colors.white30,
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A1500) : AppColors.ashramCardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.saffron : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.saffron : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.saffron, size: 20),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A1500) : AppColors.ashramCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.saffron : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? AppColors.saffron : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String emoji;
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.emoji,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.ashramCardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: date != null ? AppColors.saffron : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                const SizedBox(height: 2),
                Text(
                  date == null
                      ? 'Tap to select'
                      : '${date!.day}/${date!.month}/${date!.year}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: date != null ? AppColors.saffron : Colors.white30,
                    fontWeight: FontWeight.w600,
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
