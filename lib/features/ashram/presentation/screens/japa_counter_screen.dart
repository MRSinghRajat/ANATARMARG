import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// One floating label animation (balloon up + fade).
class _Floater {
  _Floater({
    required this.text,
    required this.controller,
    required this.horizontalShift,
  });

  final String text;
  final AnimationController controller;
  final double horizontalShift;
}

class JapaCounterScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const JapaCounterScreen({super.key, this.onComplete});

  @override
  State<JapaCounterScreen> createState() => _JapaCounterScreenState();
}

enum _MantraPickKind { preset, savedCustom, draftCustom }

class _JapaCounterScreenState extends State<JapaCounterScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  int _target = 108;
  bool _sessionStarted = false;
  bool _sessionComplete = false;
  _MantraPickKind _pickKind = _MantraPickKind.preset;
  int _presetMantraIndex = 0;
  int _savedMantraListIndex = 0;
  final List<String> _savedCustomMantras = [];
  int _entranceSessionId = 0;

  final TextEditingController _customMantraController = TextEditingController();
  final TextEditingController _targetController =
      TextEditingController(text: '108');

  final List<_Floater> _floaters = [];
  final math.Random _rand = math.Random();

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
      name: 'Jai Shri Ram',
      sanskrit: 'जय श्री राम',
      meaning: 'Victory and praise to Lord Ram',
    ),
    _Mantra(
      name: 'Jai Hanuman',
      sanskrit: 'जय हनुमान',
      meaning: 'Glory to Hanuman, the devoted servant of Ram',
    ),
    _Mantra(
      name: 'Radhe Radhe',
      sanskrit: 'राधे राधे',
      meaning: 'Invocation of Radha and divine love',
    ),
    _Mantra(
      name: 'Om Gan Ganapataye Namaha',
      sanskrit: 'ॐ गं गणपतये नमः',
      meaning: 'Prayer to Lord Ganesha, remover of obstacles',
    ),
  ];

  static const int _maxSavedCustomMantras = 40;

  String _japaSavedMantrasPrefsKey() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    return 'japa_saved_custom_mantras_v1_${uid ?? 'guest'}';
  }

  Future<void> _loadSavedMantras() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_japaSavedMantrasPrefsKey());
    if (!mounted || list == null) return;
    setState(() {
      _savedCustomMantras
        ..clear()
        ..addAll(list);
      if (_pickKind == _MantraPickKind.savedCustom &&
          (_savedMantraListIndex >= _savedCustomMantras.length)) {
        _pickKind = _MantraPickKind.draftCustom;
        _savedMantraListIndex = 0;
      }
    });
  }

  Future<void> _persistSavedMantras() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_japaSavedMantrasPrefsKey(), _savedCustomMantras);
  }

  /// Remember a non-empty custom mantra (new row, or move duplicate to top).
  void _rememberCustomMantraIfNew(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;
    if (_savedCustomMantras.contains(t)) {
      setState(() {
        _savedCustomMantras.remove(t);
        _savedCustomMantras.insert(0, t);
        _savedMantraListIndex = 0;
      });
      _persistSavedMantras();
      return;
    }
    setState(() {
      _savedCustomMantras.insert(0, t);
      while (_savedCustomMantras.length > _maxSavedCustomMantras) {
        _savedCustomMantras.removeLast();
      }
      _savedMantraListIndex = 0;
    });
    _persistSavedMantras();
  }

  void _onSaveMantraPressed() {
    final t = _customMantraController.text.trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Type your mantra first, then tap Save.',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _rememberCustomMantraIfNew(t);
    setState(() => _pickKind = _MantraPickKind.savedCustom);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mantra saved for next time.',
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeSavedMantra(int i) {
    if (i < 0 || i >= _savedCustomMantras.length) return;
    setState(() {
      _savedCustomMantras.removeAt(i);
      if (_pickKind == _MantraPickKind.savedCustom) {
        if (_savedMantraListIndex == i) {
          _pickKind = _MantraPickKind.draftCustom;
          _customMantraController.clear();
        } else if (_savedMantraListIndex > i) {
          _savedMantraListIndex--;
        }
      }
    });
    _persistSavedMantras();
  }

  bool get _isCustomChant =>
      _pickKind == _MantraPickKind.savedCustom ||
      _pickKind == _MantraPickKind.draftCustom;

  String get _activeCustomOrSavedText {
    if (_pickKind == _MantraPickKind.savedCustom) {
      if (_savedMantraListIndex >= 0 &&
          _savedMantraListIndex < _savedCustomMantras.length) {
        return _savedCustomMantras[_savedMantraListIndex];
      }
      return '';
    }
    return _customMantraController.text.trim();
  }

  String get _chantTextForAnimation {
    if (_pickKind == _MantraPickKind.preset) {
      return _mantras[_presetMantraIndex].name;
    }
    final t = _activeCustomOrSavedText;
    if (t.isNotEmpty) return t;
    return 'Japa';
  }

  String get _chantSubtitle {
    if (_pickKind == _MantraPickKind.preset) {
      return _mantras[_presetMantraIndex].name;
    }
    final t = _activeCustomOrSavedText;
    return t.isNotEmpty ? t : 'Custom mantra';
  }

  String get _chantSanskritOrPrimary {
    if (_pickKind == _MantraPickKind.preset) {
      return _mantras[_presetMantraIndex].sanskrit;
    }
    final t = _activeCustomOrSavedText;
    return t.isNotEmpty ? t : '…';
  }

  String _leadingGrapheme(String s) {
    if (s.isEmpty) return '✦';
    return Characters(s).first;
  }

  int _parseTarget() {
    final n = int.tryParse(_targetController.text.trim());
    if (n == null || n < 1) return 108;
    return n.clamp(1, 99999);
  }

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedMantras());
  }

  @override
  void dispose() {
    for (final f in _floaters) {
      f.controller.dispose();
    }
    _floaters.clear();
    _customMantraController.dispose();
    _targetController.dispose();
    _tapController.dispose();
    _progressController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _spawnFloater(String text) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    final shift = (_rand.nextDouble() * 80) - 40;
    final floater = _Floater(
      text: text,
      controller: controller,
      horizontalShift: shift,
    );

    setState(() {
      _floaters.add(floater);
      while (_floaters.length > 12) {
        final old = _floaters.removeAt(0);
        old.controller.dispose();
      }
    });

    controller.forward().then((_) {
      if (!mounted) return;
      setState(() {
        _floaters.remove(floater);
      });
      controller.dispose();
    });
  }

  void _beginSession() {
    final t = _parseTarget();
    if (_isCustomChant && _activeCustomOrSavedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter your mantra below, pick a saved one, or choose a preset.',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_pickKind == _MantraPickKind.draftCustom) {
      _rememberCustomMantraIfNew(_customMantraController.text);
    }
    setState(() {
      _target = t;
      _count = 0;
      _sessionStarted = true;
      _sessionComplete = false;
      _entranceSessionId++;
      _progressController.value = 0;
    });
  }

  void _onTap() {
    if (_count >= _target) return;

    HapticFeedback.lightImpact();
    _tapController.forward().then((_) => _tapController.reverse());
    _spawnFloater(_chantTextForAnimation);

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
                          '108 is traditional — you can choose any count below.',
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
                  'How many repetitions?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g. 108',
                    hintStyle: GoogleFonts.poppins(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF1A1D23),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['5', '8', '11', '16', '27', '54', '108', '1008']
                      .map((v) {
                    return ActionChip(
                      label: Text(v, style: GoogleFonts.poppins(fontSize: 13)),
                      onPressed: () {
                        setState(() => _targetController.text = v);
                      },
                      backgroundColor: const Color(0xFF1A1D23),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      labelStyle: const TextStyle(color: Colors.white70),
                    );
                  }).toList(),
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
                  'Select a preset or your own words',
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(
                        () => _pickKind = _MantraPickKind.draftCustom,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _pickKind == _MantraPickKind.draftCustom
                              ? Colors.orange.withValues(alpha: 0.1)
                              : const Color(0xFF1A1D23),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _pickKind == _MantraPickKind.draftCustom
                                ? Colors.orange.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.06),
                            width:
                                _pickKind == _MantraPickKind.draftCustom ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _pickKind ==
                                            _MantraPickKind.draftCustom
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.edit_outlined,
                                    color: _pickKind ==
                                            _MantraPickKind.draftCustom
                                        ? Colors.orange
                                        : Colors.white54,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'My own mantra',
                                    style: GoogleFonts.poppins(
                                      color: _pickKind ==
                                              _MantraPickKind.draftCustom
                                          ? Colors.orange.shade200
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (_pickKind == _MantraPickKind.draftCustom)
                                  Icon(Icons.check_circle,
                                      color: Colors.orange, size: 22),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _customMantraController,
                              onChanged: (_) => setState(
                                () => _pickKind = _MantraPickKind.draftCustom,
                              ),
                              maxLines: 2,
                              maxLength: 200,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.35,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. Om Namah Shivaya — what you will chant',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.white30,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.25),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                counterStyle: GoogleFonts.poppins(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _onSaveMantraPressed,
                                icon: Icon(
                                  Icons.bookmark_add_outlined,
                                  size: 18,
                                  color: Colors.orange.shade200,
                                ),
                                label: Text(
                                  'Save mantra',
                                  style: GoogleFonts.poppins(
                                    color: Colors.orange.shade200,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (_savedCustomMantras.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      'Your saved mantras',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...List.generate(_savedCustomMantras.length, (i) {
                    final text = _savedCustomMantras[i];
                    final selected = _pickKind == _MantraPickKind.savedCustom &&
                        _savedMantraListIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() {
                            _pickKind = _MantraPickKind.savedCustom;
                            _savedMantraListIndex = i;
                            _customMantraController.text = text;
                          }),
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
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _leadingGrapheme(text),
                                    style: GoogleFonts.notoSerifDevanagari(
                                      color: selected
                                          ? Colors.orange
                                          : Colors.white54,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    text,
                                    style: GoogleFonts.poppins(
                                      color: selected
                                          ? Colors.orange.shade200
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (selected)
                                  Icon(Icons.check_circle,
                                      color: Colors.orange, size: 22),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () => _removeSavedMantra(i),
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white.withValues(alpha: 0.35),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Presets',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                ...List.generate(_mantras.length, (i) {
                  final m = _mantras[i];
                  final selected = _pickKind == _MantraPickKind.preset &&
                      _presetMantraIndex == i;
                  return _mantraTile(
                    selected: selected,
                    onTap: () => setState(() {
                      _pickKind = _MantraPickKind.preset;
                      _presetMantraIndex = i;
                    }),
                    leading: m.sanskrit.isNotEmpty
                        ? Characters(m.sanskrit).first
                        : 'ॐ',
                    title: m.name,
                    subtitle: m.meaning,
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _beginSession,
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

  Widget _mantraTile({
    required bool selected,
    required VoidCallback onTap,
    required String leading,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    leading,
                    style: GoogleFonts.notoSerifDevanagari(
                      color: selected ? Colors.orange : Colors.white54,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: Colors.orange, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Counter Screen ──
  Widget _buildCounter() {
    final progress = _target > 0 ? _count / _target : 0.0;

    return Column(
      children: [
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
                _chantSubtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey(_entranceSessionId),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, child) {
                      return Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 28 * (1 - v)),
                          child: Transform.scale(
                            scale: 0.85 + 0.15 * v,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      _chantSanskritOrPrimary,
                      style: GoogleFonts.notoSerifDevanagari(
                        color: Colors.orange.withValues(alpha: 0.75),
                        fontSize: _isCustomChant ? 20 : 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

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
                          clipBehavior: Clip.none,
                          children: [
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

              // Balloon texts — rise from bead, fade out
              ..._floaters.map(_buildFloaterLayer),
            ],
          ),
        ),

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

  Widget _buildFloaterLayer(_Floater f) {
    return AnimatedBuilder(
      animation: f.controller,
      builder: (context, child) {
        final t = Curves.easeOut.transform(f.controller.value);
        final sway = math.sin(t * math.pi * 2) * 10.0 * (1 - t);
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        final scale = 1.0 + 0.1 * math.sin(t * math.pi);
        final align = Alignment.lerp(
          const Alignment(0, 0.15),
          const Alignment(0, -0.72),
          t,
        )!;

        return IgnorePointer(
          child: Align(
            alignment: align,
            child: Transform.translate(
              offset: Offset(f.horizontalShift + sway, 0),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      f.text,
                      style: GoogleFonts.poppins(
                        color: Colors.orange.shade100,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

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
