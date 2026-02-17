import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _Mantra {
  final String name;
  final String sanskrit;
  final String meaning;

  const _Mantra({
    required this.name,
    required this.sanskrit,
    required this.meaning,
  });
}

class JapaCounterScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const JapaCounterScreen({super.key, this.onComplete});

  @override
  State<JapaCounterScreen> createState() => _JapaCounterScreenState();
}

class _JapaCounterScreenState extends State<JapaCounterScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  static const int _target = 108;
  bool _sessionStarted = false;
  bool _sessionComplete = false;
  int _selectedMantraIndex = 0;

  late AnimationController _tapController;
  late AnimationController _progressController;
  late AnimationController _completionController;
  late Animation<double> _tapScale;
  late Animation<double> _completionScale;

  static const _mantras = [
    _Mantra(
      name: 'Om',
      sanskrit: 'ॐ',
      meaning: 'The primordial sound of the universe',
    ),
    _Mantra(
      name: 'Om Namah Shivaya',
      sanskrit: 'ॐ नमः शिवाय',
      meaning: 'I bow to Lord Shiva, the supreme consciousness',
    ),
    _Mantra(
      name: 'Hare Krishna',
      sanskrit: 'हरे कृष्ण हरे कृष्ण',
      meaning: 'Invocation to Lord Krishna for divine love',
    ),
    _Mantra(
      name: 'Om Namo Narayanaya',
      sanskrit: 'ॐ नमो नारायणाय',
      meaning: 'I bow to Lord Narayana, the refuge of all',
    ),
    _Mantra(
      name: 'Gayatri Mantra',
      sanskrit: 'ॐ भूर्भुवः स्वः',
      meaning: 'Prayer to the divine light for wisdom',
    ),
    _Mantra(
      name: 'Om Gan Ganapataye Namaha',
      sanskrit: 'ॐ गं गणपतये नमः',
      meaning: 'Prayer to Lord Ganesha, remover of obstacles',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _completionScale = CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _progressController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_count >= _target) return;

    HapticFeedback.lightImpact();
    _tapController.forward().then((_) => _tapController.reverse());

    setState(() {
      _count++;
      _progressController.animateTo(
        _count / _target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });

    if (_count >= _target) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _sessionComplete = true);
          _completionController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: _sessionComplete
            ? _buildCompletion()
            : _sessionStarted
                ? _buildCounter()
                : _buildIntro(),
      ),
    );
  }

  // ── Intro / Mantra Picker ──
  Widget _buildIntro() {
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
                'Japa Meditation',
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
                          Colors.deepOrange.withValues(alpha: 0.15),
                          Colors.orange.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.deepOrange.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'जपयज्ञोऽस्मि',
                          style: GoogleFonts.notoSerifDevanagari(
                            color: Colors.orange.shade200,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"Among yajnas, I am the Japa yajna"\n— Bhagavad Gita 10.25',
                          style: GoogleFonts.crimsonPro(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Japa is the meditative repetition of a mantra. '
                          '108 is sacred — it represents the wholeness of the universe. '
                          'The Upanishads say there are 108 paths to the divine.',
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

                Text(
                  'Choose Your Mantra',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select one to chant 108 times',
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),

                ...List.generate(_mantras.length, (i) {
                  final m = _mantras[i];
                  final selected = _selectedMantraIndex == i;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + i * 80),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedMantraIndex = i),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : const Color(0xFF1A1D23),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? Colors.orange.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.06),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.orange
                                            .withValues(alpha: 0.15)
                                        : Colors.white
                                            .withValues(alpha: 0.05),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    m.sanskrit.substring(0, 1),
                                    style:
                                        GoogleFonts.notoSerifDevanagari(
                                      color: selected
                                          ? Colors.orange
                                          : Colors.white54,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: GoogleFonts.poppins(
                                          color: selected
                                              ? Colors.orange.shade200
                                              : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        m.meaning,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (selected)
                                  Icon(Icons.check_circle,
                                      color: Colors.orange, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Start button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => setState(() => _sessionStarted = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Begin Japa',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Counter Screen ──
  Widget _buildCounter() {
    final mantra = _mantras[_selectedMantraIndex];
    final progress = _count / _target;

    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                mantra.name,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mantra text
              Text(
                mantra.sanskrit,
                style: GoogleFonts.notoSerifDevanagari(
                  color: Colors.orange.withValues(alpha: 0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Circular counter with progress ring
              GestureDetector(
                onTap: _onTap,
                child: AnimatedBuilder(
                  animation: _tapScale,
                  builder: (context, child) => Transform.scale(
                    scale: _tapScale.value,
                    child: child,
                  ),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress ring
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _ProgressRingPainter(
                                  progress: _progressController.value,
                                  color: Colors.orange,
                                  bgColor:
                                      Colors.white.withValues(alpha: 0.06),
                                  strokeWidth: 6,
                                ),
                              );
                            },
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withValues(alpha: 0.06),
                            border: Border.all(
                              color:
                                  Colors.orange.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_count',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w200,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'of $_target',
                                style: GoogleFonts.poppins(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Tap to count',
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              // Percentage
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.poppins(
                  color: Colors.orange.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Reset / End early
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _count = 0;
                      _progressController.animateTo(0);
                    });
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (_count > 0)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _sessionComplete = true);
                      _completionController.forward();
                    },
                    child: Text(
                      'End Early',
                      style: GoogleFonts.poppins(
                        color: Colors.orange.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
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
                    Colors.orange.withValues(alpha: 0.3),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_count',
                    style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                  Text(
                    'japa',
                    style: GoogleFonts.poppins(
                      color: Colors.orange.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _count >= _target
                  ? 'Japa Complete!'
                  : 'Japa Session Ended',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '"हरे राम हरे राम, राम राम हरे हरे"\n'
              'The name of the Lord is the greatest purifier.',
              style: GoogleFonts.crimsonPro(
                color: Colors.orange.shade200,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Each repetition of the mantra brings you closer to the divine. '
              'May this practice bring peace to your mind and heart.',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 13,
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

/// Custom painter for the circular progress ring
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color;
}
