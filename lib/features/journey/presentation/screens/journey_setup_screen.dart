import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/journey_models.dart';
import '../providers/journey_providers.dart';
import '../theme/journey_ashram_theme.dart';

/// Dynamic setup flow from journey_types.setup_schema. On complete: start journey and navigate to Journey Home.
class JourneySetupScreen extends ConsumerStatefulWidget {
  final String slug;

  const JourneySetupScreen({super.key, required this.slug});

  @override
  ConsumerState<JourneySetupScreen> createState() => _JourneySetupScreenState();
}

class _JourneySetupScreenState extends ConsumerState<JourneySetupScreen> {
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _duplicateCheckScheduled = false;
  /// Avoid re-parsing setup_schema on every rebuild when the same journey type is shown.
  String? _cachedSetupJourneyTypeId;

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<dynamic> _schemaList = [];

  bool _showQuestion(Map<String, dynamic> q) {
    // DB seed uses `show_when`; older drafts used `show_if` — support both.
    final condition =
        (q['show_if'] as Map<String, dynamic>?) ?? (q['show_when'] as Map<String, dynamic>?);
    if (condition == null) return true;
    final key = condition['key'] as String?;
    final value = condition['value'];
    if (key == null) return true;
    return _answers[key] == value;
  }

  void _clampStepToVisible() {
    final n = _visibleQuestions.length;
    if (n == 0) {
      _currentStep = 0;
      return;
    }
    if (_currentStep >= n) {
      _currentStep = n - 1;
    }
  }

  List<Map<String, dynamic>> get _visibleQuestions {
    if (_schemaList.isEmpty) return [];
    final list = _schemaList
        .where((e) => e is Map<String, dynamic> && _showQuestion(e as Map<String, dynamic>))
        .map((e) => e as Map<String, dynamic>)
        .toList();
    return list;
  }

  ThemeData _ashramJourneyTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      brightness: Brightness.dark,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: JourneyAshramTheme.accent,
        onPrimary: const Color(0xFF1A1208),
        surface: AppColors.ashramCardDark,
        onSurface: AppColors.zinc100,
        outline: Colors.white.withValues(alpha: 0.14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.zinc100,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.zinc100,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JourneyAshramTheme.accent,
          foregroundColor: const Color(0xFF1A1208),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.zinc100,
          side: BorderSide(color: JourneyAshramTheme.accent.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: JourneyAshramTheme.accent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ashramCardDark.withValues(alpha: 0.9),
        hintStyle: GoogleFonts.inter(color: AppColors.zinc500, fontSize: 15),
        labelStyle: GoogleFonts.inter(color: AppColors.zinc500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: JourneyAshramTheme.accent, width: 1.5),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme).apply(
        bodyColor: AppColors.zinc100,
        displayColor: AppColors.zinc100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeAsync = ref.watch(journeyTypeBySlugProvider(widget.slug));
    return Theme(
      data: _ashramJourneyTheme(context),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1428),
              AppColors.journeyBackgroundDark,
              AppColors.ashramBackgroundDark,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Start Journey', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          body: typeAsync.when(
          data: (journeyType) {
            if (journeyType == null) {
              return Center(
                child: Text(
                  'Journey not found',
                  style: GoogleFonts.inter(color: AppColors.zinc500),
                ),
              );
            }
            _scheduleDuplicateJourneyCheck(journeyType);
            if (_cachedSetupJourneyTypeId != journeyType.id) {
              _cachedSetupJourneyTypeId = journeyType.id;
              _schemaList = List<dynamic>.from(journeyType.setupSchema ?? []);
              _currentStep = 0;
            }
            if (_visibleQuestions.isEmpty) {
              return _buildSubmitSection(context, journeyType);
            }
            return _buildForm(context, journeyType);
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: JourneyAshramTheme.accent),
          ),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: AppColors.zinc500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _scheduleDuplicateJourneyCheck(JourneyType journeyType) {
    if (_duplicateCheckScheduled) return;
    _duplicateCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) return;
      final existing = await ref.read(journeyRepositoryProvider).getActiveOrPausedJourneyForType(
            userId: uid,
            journeyTypeId: journeyType.id,
          );
      if (!mounted || existing == null) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('This journey type is already in progress'),
          content: const Text(
            'You already have an active or paused path for this journey. Open it from Granthalaya or Ashram, or start a different journey type.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildForm(BuildContext context, JourneyType journeyType) {
    final visible = _visibleQuestions;
    if (_currentStep >= visible.length) {
      return _buildSubmitSection(context, journeyType);
    }
    final q = visible[_currentStep];
    final key = q['key'] as String? ?? '';
    final type = q['type'] ?? 'text';
    final typeStr = type is String ? type : 'text';
    final label = q['label'] as String? ?? key;
    final optional = q['optional'] as bool? ?? false;
    final stepIndex = _currentStep + 1;
    final stepTotal = visible.length;
    final progress = stepTotal > 0 ? stepIndex / stepTotal : 1.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              journeyType.title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.zinc100,
                height: 1.25,
              ),
            ),
            if (journeyType.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                journeyType.subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.zinc500,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step $stepIndex of $stepTotal',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: JourneyAshramTheme.accent.withValues(alpha: 0.95),
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.zinc500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(JourneyAshramTheme.accent),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              decoration: JourneyAshramTheme.darkCardDecoration(borderRadius: 18),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc100,
                      height: 1.35,
                    ),
                  ),
                  if (optional) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Optional',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.zinc500),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (typeStr == 'single_select') _buildSingleSelect(q, key),
                  if (typeStr == 'date') _buildDateField(key),
                  if (typeStr == 'text') _buildTextField(q, key, optional),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton.icon(
                    onPressed: () => setState(() => _currentStep--),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back'),
                  )
                else
                  const SizedBox(width: 72),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        if (typeStr == 'text' &&
                            !optional &&
                            (_answers[key] == null || (_answers[key] as String).trim().isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill this field')),
                          );
                          return;
                        }
                        if (typeStr == 'date' && !optional) {
                          final s = _answers[key] as String?;
                          if (s == null || s.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please pick a date')),
                            );
                            return;
                          }
                        }
                        if (_currentStep < visible.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          _submit(context, journeyType);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: JourneyAshramTheme.accent,
                        foregroundColor: const Color(0xFF1A1208),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentStep < visible.length - 1 ? 'Next' : 'Start Journey',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSelect(Map<String, dynamic> q, String key) {
    final options = q['options'] as List<dynamic>? ?? [];
    final current = _answers[key];
    return Column(
      children: options.map((opt) {
        final optMap = opt is Map<String, dynamic> ? opt : {};
        final value = optMap['value'];
        final optLabel = optMap['label'] as String? ?? value?.toString();
        final icon = optMap['icon'] as String?;
        final isSelected = current == value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() {
                final prev = _answers[key];
                _answers[key] = value;
                if (key == 'mode' && prev != value) {
                  _currentStep = 0;
                }
                _clampStepToVisible();
              }),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            JourneyAshramTheme.accent.withValues(alpha: 0.28),
                            AppColors.deepPurple.withValues(alpha: 0.22),
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.ashramCardDark.withValues(alpha: 0.5),
                  border: Border.all(
                    color: isSelected
                        ? JourneyAshramTheme.accent.withValues(alpha: 0.65)
                        : Colors.white.withValues(alpha: 0.1),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: JourneyAshramTheme.accent.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    if (icon != null && icon.isNotEmpty) ...[
                      Text(icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        optLabel ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.zinc100,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: JourneyAshramTheme.accent, size: 22),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField(String key) {
    final current = _answers[key] as String?;
    final date = current != null ? DateTime.tryParse(current) : null;
    final label = date != null
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : 'Choose date';
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _answers[key] = picked.toIso8601String().split('T').first);
        }
      },
      icon: Icon(Icons.calendar_today_rounded, size: 18, color: JourneyAshramTheme.accent),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.zinc100,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildTextField(Map<String, dynamic> q, String key, bool optional) {
    final initial = _answers[key] as String? ?? '';
    _textControllers[key] ??= TextEditingController(text: initial);
    return TextField(
      controller: _textControllers[key],
      style: GoogleFonts.inter(color: AppColors.zinc100, fontSize: 15),
      cursorColor: JourneyAshramTheme.accent,
      decoration: InputDecoration(
        hintText: q['placeholder'] as String?,
      ),
      onChanged: (v) => setState(() => _answers[key] = v),
    );
  }

  Widget _buildSubmitSection(BuildContext context, JourneyType journeyType) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: JourneyAshramTheme.darkCardDecoration(borderRadius: 18),
              child: Column(
                children: [
                  Icon(Icons.favorite_rounded, color: JourneyAshramTheme.accent, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'You\'re all set to begin',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.zinc500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    journeyType.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.zinc100,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (_isSubmitting)
              CircularProgressIndicator(color: JourneyAshramTheme.accent)
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _submit(context, journeyType),
                  style: FilledButton.styleFrom(
                    backgroundColor: JourneyAshramTheme.accent,
                    foregroundColor: const Color(0xFF1A1208),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Start Journey', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, JourneyType journeyType) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    setState(() => _isSubmitting = true);
    final repo = ref.read(journeyRepositoryProvider);
    DateTime? startDate = DateTime.now();
    DateTime? targetDate;
    if (_answers['due_date'] != null) {
      targetDate = DateTime.tryParse(_answers['due_date'] as String);
    }
    if (_answers['child_dob'] != null) {
      final dob = DateTime.tryParse(_answers['child_dob'] as String);
      if (dob != null) startDate = dob;
    }
    final metadata = Map<String, dynamic>.from(_answers);
    if (metadata['due_date'] != null && metadata['pregnancy_due_date'] == null) {
      metadata['pregnancy_due_date'] = metadata['due_date'];
    }
    if (targetDate != null) {
      metadata['mode'] = 'pregnant';
    } else if (metadata['child_dob'] != null) {
      metadata['mode'] = 'postnatal';
    } else {
      metadata['mode'] = 'planning';
    }
    final existing = await repo.getActiveOrPausedJourneyForType(
      userId: uid,
      journeyTypeId: journeyType.id,
    );
    if (existing != null) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('This journey type is already in progress'),
          content: const Text(
            'You already have an active or paused path for this journey. Open it from Granthalaya or Ashram, or start a different journey type.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    try {
      final userJourney = await repo.startJourney(
        userId: uid,
        journeyTypeId: journeyType.id,
        metadata: metadata,
        startDate: startDate,
        targetDate: targetDate,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (userJourney != null) {
        ref.invalidate(activeJourneyProvider);
        ref.invalidate(activeJourneysProvider);
        ref.invalidate(allUserJourneysProvider);
        Navigator.of(context).pushReplacementNamed(AppRouter.journeyHome, arguments: {'userJourneyId': userJourney.id});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not start journey')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
