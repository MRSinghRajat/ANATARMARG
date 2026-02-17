import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_clock.dart';

class GratitudePracticeScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const GratitudePracticeScreen({super.key, this.onComplete});

  @override
  State<GratitudePracticeScreen> createState() =>
      _GratitudePracticeScreenState();
}

class _GratitudePracticeScreenState extends State<GratitudePracticeScreen>
    with TickerProviderStateMixin {
  final _controllers = List.generate(3, (_) => TextEditingController());
  final _focusNodes = List.generate(3, (_) => FocusNode());
  bool _saving = false;
  final _startTime = AppClock.now();

  late AnimationController _staggerController;
  late AnimationController _buttonController;
  late List<Animation<double>> _fieldAnimations;
  late Animation<double> _introAnimation;
  late Animation<double> _buttonScale;

  static const _prompts = [
    'Something you are grateful for today...',
    'A person who made a difference...',
    'A small blessing you noticed...',
  ];

  static const _labels = [
    'Grateful for',
    'A person',
    'A blessing',
  ];

  static const _icons = [
    Icons.favorite_outline,
    Icons.people_outline,
    Icons.spa_outlined,
  ];

  static const _colors = [
    Colors.pink,
    Colors.amber,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _introAnimation = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
    );

    _fieldAnimations = List.generate(3, (i) {
      final start = 0.2 + i * 0.15;
      final end = (start + 0.3).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    _staggerController.forward();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _buttonController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit =>
      _controllers.any((c) => c.text.trim().isNotEmpty) && !_saving;

  Future<void> _save() async {
    if (!_canSubmit) return;
    setState(() => _saving = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not signed in');

      final items = <Map<String, dynamic>>[];
      for (var i = 0; i < _controllers.length; i++) {
        final text = _controllers[i].text.trim();
        if (text.isNotEmpty) {
          items.add({'index': i, 'text': text});
        }
      }

      final elapsed = AppClock.now().difference(_startTime).inSeconds;

      await supabase.from('user_gratitude_entries').upsert({
        'user_id': userId,
        'entry_date': AppClock.now().toIso8601String().split('T')[0],
        'gratitude_items': items,
        'time_spent_seconds': elapsed,
      }, onConflict: 'user_id,entry_date');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Gratitude Practice',
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

                    // Dharmic intro with animation
                    AnimatedBuilder(
                      animation: _introAnimation,
                      builder: (context, child) {
                        final v = _introAnimation.value;
                        return Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - v)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.teal.withValues(alpha: 0.15),
                              Colors.green.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.teal.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'कृतज्ञता',
                              style: GoogleFonts.notoSerifDevanagari(
                                color: Colors.teal.shade200,
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Krutajnata — Gratitude',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The Vedas teach that gratitude (Krutajnata) is the foundation of dharmic living. '
                              'By acknowledging the gifts we receive daily — from Ishvara, nature, and fellow beings — '
                              'we cultivate contentment (Santosha) and dissolve the ego\'s tendency toward complaint.',
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

                    const SizedBox(height: 24),

                    Text(
                      'What are you grateful for today?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Write at least one. Take a moment to truly feel it.',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3 animated gratitude fields
                    for (var i = 0; i < 3; i++) ...[
                      AnimatedBuilder(
                        animation: _fieldAnimations[i],
                        builder: (context, child) {
                          final v = _fieldAnimations[i].value;
                          return Opacity(
                            opacity: v.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset:
                                  Offset(0, 24 * (1 - v.clamp(0.0, 1.0))),
                              child: child,
                            ),
                          );
                        },
                        child: _buildGratitudeField(i),
                      ),
                      if (i < 2) const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Animated save button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GestureDetector(
                onTapDown:
                    _canSubmit ? (_) => _buttonController.forward() : null,
                onTapUp: _canSubmit
                    ? (_) {
                        _buttonController.reverse();
                        _save();
                      }
                    : null,
                onTapCancel:
                    _canSubmit ? () => _buttonController.reverse() : null,
                child: AnimatedBuilder(
                  animation: _buttonScale,
                  builder: (context, child) => Transform.scale(
                    scale: _buttonScale.value,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _canSubmit
                          ? LinearGradient(colors: [
                              Colors.teal.shade600,
                              Colors.green.shade700,
                            ])
                          : null,
                      color: _canSubmit
                          ? null
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _canSubmit
                          ? [
                              BoxShadow(
                                color:
                                    Colors.teal.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save & Complete',
                            style: GoogleFonts.poppins(
                              color: _canSubmit
                                  ? Colors.white
                                  : Colors.white38,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGratitudeField(int index) {
    final color = _colors[index];
    final isFocused = _focusNodes[index].hasFocus;

    return GestureDetector(
      onTap: () => _focusNodes[index].requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: isFocused ? 1.5 : 1,
          ),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icons[index],
                      color: color.withValues(alpha: 0.8), size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  _labels[index],
                  style: GoogleFonts.poppins(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              maxLines: 5,
              minLines: 3,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 14, height: 1.5),
              cursorColor: color,
              decoration: InputDecoration(
                hintText: _prompts[index],
                hintStyle: GoogleFonts.poppins(
                    color: Colors.white24, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF1A1D23),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: color.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
