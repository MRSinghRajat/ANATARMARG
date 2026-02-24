import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/sound_manager.dart';

/// Step model from meditation_guides JSONB
class _MeditationStep {
  final int stepNumber;
  final String stepTitle;
  final String instruction;
  final int durationSeconds;

  const _MeditationStep({
    required this.stepNumber,
    required this.stepTitle,
    required this.instruction,
    required this.durationSeconds,
  });

  factory _MeditationStep.fromJson(Map<String, dynamic> json) {
    return _MeditationStep(
      stepNumber: json['step_number'] as int? ?? 1,
      stepTitle: json['step_title'] as String? ?? 'Step',
      instruction: json['instruction'] as String? ?? '',
      durationSeconds: json['duration_seconds'] as int? ?? 60,
    );
  }
}

/// Guide model from meditation_guides table
class _MeditationGuide {
  final String id;
  final String guideName;
  final String meditationType;
  final int durationSeconds;
  final String difficulty;
  final int totalSteps;
  final List<_MeditationStep> steps;
  final String? description;
  final String? completionMessage;

  const _MeditationGuide({
    required this.id,
    required this.guideName,
    required this.meditationType,
    required this.durationSeconds,
    required this.difficulty,
    required this.totalSteps,
    required this.steps,
    this.description,
    this.completionMessage,
  });

  factory _MeditationGuide.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return _MeditationGuide(
      id: json['id'] as String,
      guideName: json['guide_name'] as String? ?? 'Meditation',
      meditationType: json['meditation_type'] as String? ?? 'breath',
      durationSeconds: json['duration_seconds'] as int? ?? 300,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      totalSteps: json['total_steps'] as int? ?? 1,
      steps: stepsJson
          .map((s) => _MeditationStep.fromJson(s as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber)),
      description: json['description'] as String?,
      completionMessage: json['completion_message'] as String?,
    );
  }
}

/// Built-in breathing patterns that work even without DB guides
class _BreathingPattern {
  final String name;
  final String nameHindi;
  final String description;
  final IconData icon;
  final Color color;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
  final int totalCycles;

  const _BreathingPattern({
    required this.name,
    required this.nameHindi,
    required this.description,
    required this.icon,
    required this.color,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    this.holdAfterExhaleSeconds = 0,
    this.totalCycles = 6,
  });

  int get cycleDuration =>
      inhaleSeconds + holdSeconds + exhaleSeconds + holdAfterExhaleSeconds;
}

class MeditationGuideScreen extends StatefulWidget {
  final String slug;
  final VoidCallback? onComplete;

  const MeditationGuideScreen({
    super.key,
    required this.slug,
    this.onComplete,
  });

  @override
  State<MeditationGuideScreen> createState() => _MeditationGuideScreenState();
}

class _MeditationGuideScreenState extends State<MeditationGuideScreen>
    with TickerProviderStateMixin {
  // DB guide state
  List<_MeditationGuide> _guides = [];
  _MeditationGuide? _selectedGuide;
  bool _loading = true;
  String? _error;

  // Session state
  bool _sessionStarted = false;
  bool _sessionComplete = false;
  int _currentStepIndex = 0;
  int _stepSecondsRemaining = 0;
  Timer? _timer;

  // Breathing pattern state (standalone mode)
  _BreathingPattern? _selectedPattern;
  bool _breathingMode = false;
  int _breathCycleCount = 0;
  String _breathPhase = 'Inhale';
  int _breathPhaseRemaining = 0;

  late AnimationController _breathController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _completionController;
  late Animation<double> _completionScale;

  static const _breathingPatterns = [
    _BreathingPattern(
      name: 'Sama Vritti',
      nameHindi: 'सम वृत्ति',
      description: 'Equal breathing — balanced inhale and exhale',
      icon: Icons.balance_outlined,
      color: Colors.blue,
      inhaleSeconds: 4,
      holdSeconds: 0,
      exhaleSeconds: 4,
      totalCycles: 8,
    ),
    _BreathingPattern(
      name: 'Box Breathing',
      nameHindi: 'चतुष्कोण प्राणायाम',
      description: '4-4-4-4 pattern for calm focus',
      icon: Icons.crop_square_outlined,
      color: Colors.teal,
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 4,
      holdAfterExhaleSeconds: 4,
      totalCycles: 6,
    ),
    _BreathingPattern(
      name: 'Vishama Vritti',
      nameHindi: 'विषम वृत्ति',
      description: '4-7-8 relaxation breath for deep calm',
      icon: Icons.nights_stay_outlined,
      color: Colors.indigo,
      inhaleSeconds: 4,
      holdSeconds: 7,
      exhaleSeconds: 8,
      totalCycles: 4,
    ),
    _BreathingPattern(
      name: 'Anulom Vilom',
      nameHindi: 'अनुलोम विलोम',
      description: 'Alternate nostril — calms the nervous system',
      icon: Icons.air_outlined,
      color: Colors.green,
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 4,
      totalCycles: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _completionScale = CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    );

    _fetchGuides();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  Future<void> _fetchGuides() async {
    try {
      final supabase = Supabase.instance.client;

      String? typeFilter;
      switch (widget.slug) {
        case 'pranayama':
          typeFilter = 'breath';
          break;
        case 'morning_meditation':
          typeFilter = 'body_scan';
          break;
        default:
          typeFilter = null;
      }

      dynamic query = supabase
          .from('meditation_guides')
          .select()
          .eq('is_active', true);

      if (typeFilter != null) {
        query = query.eq('meditation_type', typeFilter);
      }

      final data = await query.order('order_index', ascending: true);
      final list = data as List;

      setState(() {
        _guides = list
            .map((e) =>
                _MeditationGuide.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load guides: $e';
        _loading = false;
      });
    }
  }

  // ── Guided session ──
  void _startGuidedSession(_MeditationGuide guide) {
    setState(() {
      _selectedGuide = guide;
      _breathingMode = false;
      _sessionStarted = true;
      _currentStepIndex = 0;
      _stepSecondsRemaining = guide.steps.isNotEmpty
          ? guide.steps[0].durationSeconds
          : 60;
    });
    _breathController.repeat(reverse: true);
    _startTimer();
  }

  // ── Breathing pattern session ──
  void _startBreathingSession(_BreathingPattern pattern) {
    setState(() {
      _selectedPattern = pattern;
      _breathingMode = true;
      _sessionStarted = true;
      _breathCycleCount = 0;
      _breathPhase = 'Inhale';
      _breathPhaseRemaining = pattern.inhaleSeconds;
    });
    SoundManager().playOneShot('sounds/meditation_inhale.mp3');
    _breathController.duration =
        Duration(seconds: pattern.inhaleSeconds);
    _breathController.forward();
    _startBreathTimer();
  }

  void _startBreathTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_breathPhaseRemaining > 1) {
        setState(() => _breathPhaseRemaining--);
      } else {
        _advanceBreathPhase();
      }
    });
  }

  void _advanceBreathPhase() {
    final p = _selectedPattern!;
    String nextPhase;
    int nextDuration;

    switch (_breathPhase) {
      case 'Inhale':
        if (p.holdSeconds > 0) {
          nextPhase = 'Hold';
          nextDuration = p.holdSeconds;
          _breathController.stop();
        } else {
          nextPhase = 'Exhale';
          nextDuration = p.exhaleSeconds;
          _breathController.reverse();
        }
        break;
      case 'Hold':
        nextPhase = 'Exhale';
        nextDuration = p.exhaleSeconds;
        _breathController.reverse();
        break;
      case 'Exhale':
        if (p.holdAfterExhaleSeconds > 0) {
          nextPhase = 'Rest';
          nextDuration = p.holdAfterExhaleSeconds;
          _breathController.stop();
        } else {
          // New cycle
          final newCount = _breathCycleCount + 1;
          if (newCount >= p.totalCycles) {
            _timer?.cancel();
            _breathController.stop();
            setState(() => _sessionComplete = true);
            _completionController.forward();
            return;
          }
          nextPhase = 'Inhale';
          nextDuration = p.inhaleSeconds;
          _breathController.forward();
          setState(() => _breathCycleCount = newCount);
        }
        break;
      case 'Rest':
        final newCount = _breathCycleCount + 1;
        if (newCount >= p.totalCycles) {
          _timer?.cancel();
          _breathController.stop();
          setState(() => _sessionComplete = true);
          _completionController.forward();
          return;
        }
        nextPhase = 'Inhale';
        nextDuration = p.inhaleSeconds;
        _breathController.forward();
        setState(() => _breathCycleCount = newCount);
        break;
      default:
        return;
    }

    setState(() {
      _breathPhase = nextPhase;
      _breathPhaseRemaining = nextDuration;
    });
    if (nextPhase == 'Inhale') {
      SoundManager().playOneShot('sounds/meditation_inhale.mp3');
    } else if (nextPhase == 'Exhale') {
      SoundManager().playOneShot('sounds/meditation_exhale.mp3');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_stepSecondsRemaining > 1) {
        if (_stepSecondsRemaining == 10) {
          SoundManager().playOneShot('sounds/meditation_step.mp3');
        }
        setState(() => _stepSecondsRemaining--);
      } else {
        _advanceStep();
      }
    });
  }

  void _advanceStep() {
    _timer?.cancel();
    SoundManager().playOneShot('sounds/meditation_step.mp3');
    if (_currentStepIndex < _selectedGuide!.steps.length - 1) {
      _fadeController.forward(from: 0.0);
      setState(() {
        _currentStepIndex++;
        _stepSecondsRemaining =
            _selectedGuide!.steps[_currentStepIndex].durationSeconds;
      });
      _startTimer();
    } else {
      _breathController.stop();
      setState(() => _sessionComplete = true);
      _completionController.forward();
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryOrange))
            : _sessionComplete
                ? _buildCompletion()
                : _sessionStarted
                    ? (_breathingMode
                        ? _buildBreathingSession()
                        : _buildGuidedSession())
                    : _buildSelector(),
      ),
    );
  }

  // ── Type Selector ──
  Widget _buildSelector() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                widget.slug == 'pranayama'
                    ? 'Pranayama'
                    : 'Meditation',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Dharmic intro
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.withValues(alpha: 0.15),
                          Colors.indigo.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ध्यानं निर्विषयं मनः',
                          style: GoogleFonts.notoSerifDevanagari(
                            color: Colors.purple.shade200,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"Meditation is the mind free from objects"',
                          style: GoogleFonts.crimsonPro(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dhyana (ध्यान) is the seventh limb of Patanjali\'s Ashtanga Yoga. '
                          'Through meditation, we quiet the fluctuations of the mind '
                          'and connect with our true Self (Atman).',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Breathing Patterns section
                Text(
                  'Breathing Patterns',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a pranayama technique',
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 12),

                ...List.generate(
                  _breathingPatterns.length,
                  (i) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + i * 100),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: _buildPatternCard(_breathingPatterns[i]),
                  ),
                ),

                // Guided Meditations from DB
                if (_guides.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Guided Sessions',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Step-by-step meditation guides',
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _guides.length,
                    (i) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600 + i * 100),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: _buildGuideCard(_guides[i]),
                    ),
                  ),
                ],

                if (_error != null && _guides.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternCard(_BreathingPattern pattern) {
    final timingLabel = [
      '${pattern.inhaleSeconds}s in',
      if (pattern.holdSeconds > 0) '${pattern.holdSeconds}s hold',
      '${pattern.exhaleSeconds}s out',
      if (pattern.holdAfterExhaleSeconds > 0)
        '${pattern.holdAfterExhaleSeconds}s rest',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startBreathingSession(pattern),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: pattern.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: pattern.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(pattern.icon,
                      color: pattern.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pattern.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pattern.nameHindi,
                            style: GoogleFonts.notoSerifDevanagari(
                              color: pattern.color.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pattern.description,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timingLabel,
                        style: GoogleFonts.poppins(
                          color: pattern.color.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_circle_fill,
                    color: pattern.color.withValues(alpha: 0.6), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(_MeditationGuide guide) {
    final mins = guide.durationSeconds ~/ 60;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startGuidedSession(guide),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.self_improvement,
                      color: Colors.purple, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.guideName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (guide.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          guide.description!,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _miniChip(
                              Icons.timer_outlined, '$mins min'),
                          const SizedBox(width: 8),
                          _miniChip(Icons.format_list_numbered,
                              '${guide.totalSteps} steps'),
                          const SizedBox(width: 8),
                          _miniChip(
                              Icons.signal_cellular_alt,
                              guide.difficulty),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_circle_fill,
                    color: Colors.purple.withValues(alpha: 0.6), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: 11),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  // ── Breathing Session ──
  Widget _buildBreathingSession() {
    final pattern = _selectedPattern!;
    final progress = ((_breathCycleCount) / pattern.totalCycles)
        .clamp(0.0, 1.0);

    Color phaseColor;
    switch (_breathPhase) {
      case 'Inhale':
        phaseColor = Colors.blue.shade300;
        break;
      case 'Hold':
      case 'Rest':
        phaseColor = Colors.amber.shade300;
        break;
      case 'Exhale':
        phaseColor = Colors.green.shade300;
        break;
      default:
        phaseColor = pattern.color;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () {
                  _timer?.cancel();
                  _breathController.stop();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(pattern.color),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cycle ${_breathCycleCount + 1}/${pattern.totalCycles}',
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pattern.name,
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Breathing circle
              AnimatedBuilder(
                animation: _breathController,
                builder: (context, child) {
                  final scale = 0.5 + (_breathController.value * 0.5);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            phaseColor.withValues(alpha: 0.25),
                            phaseColor.withValues(alpha: 0.03),
                          ],
                        ),
                        border: Border.all(
                          color: phaseColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: phaseColor.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_breathPhaseRemaining',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Phase label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _breathPhase,
                  key: ValueKey(_breathPhase),
                  style: GoogleFonts.poppins(
                    color: phaseColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _breathPhaseHint(),
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: TextButton(
            onPressed: () {
              _timer?.cancel();
              _breathController.stop();
              setState(() => _sessionComplete = true);
              _completionController.forward();
            },
            child: Text(
              'End Early',
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _breathPhaseHint() {
    switch (_breathPhase) {
      case 'Inhale':
        return 'Breathe in slowly through your nose';
      case 'Hold':
        return 'Gently hold your breath';
      case 'Exhale':
        return 'Slowly release through your mouth';
      case 'Rest':
        return 'Pause before the next cycle';
      default:
        return '';
    }
  }

  // ── Guided Session ──
  Widget _buildGuidedSession() {
    final guide = _selectedGuide!;
    final step = guide.steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / guide.steps.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () {
                  _timer?.cancel();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.purple),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentStepIndex + 1}/${guide.steps.length}',
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Breathing circle with timer
                AnimatedBuilder(
                  animation: _breathController,
                  builder: (context, child) {
                    final scale = 0.6 + (_breathController.value * 0.4);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.purple.withValues(alpha: 0.3),
                              Colors.purple.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.purple.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(_stepSecondsRemaining),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                FadeTransition(
                  opacity: _fadeController,
                  child: Text(
                    step.stepTitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeController,
                  child: Text(
                    step.instruction,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: TextButton(
            onPressed: _advanceStep,
            child: Text(
              _currentStepIndex < guide.steps.length - 1
                  ? 'Next Step'
                  : 'Finish',
              style: GoogleFonts.poppins(
                color: Colors.purple.shade200,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Completion ──
  Widget _buildCompletion() {
    return ScaleTransition(
      scale: _completionScale,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.3),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child:
                  const Icon(Icons.check, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Namaste',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedGuide?.completionMessage ??
                  'Your meditation is complete. Carry this peace with you throughout the day.',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '"योगः कर्मसु कौशलम्"\nYoga is excellence in action.',
              style: GoogleFonts.crimsonPro(
                color: Colors.purple.shade200,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Complete Task',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
