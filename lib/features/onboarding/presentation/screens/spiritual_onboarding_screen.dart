import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_router.dart';

/// Duolingo-style animated spiritual onboarding for Antar Marg.
/// Shows once on first launch, then never again.
///
/// Flow: Welcome(typewriter) → 5 Questions → Progression → Name → Summary → Auth
class SpiritualOnboardingScreen extends StatefulWidget {
  const SpiritualOnboardingScreen({super.key});

  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String onboardingUserNameKey = 'onboarding_user_name';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingCompleteKey) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompleteKey, true);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(onboardingUserNameKey, name.trim());
  }

  static Future<String?> getStoredUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getString(onboardingUserNameKey);
    return (n != null && n.trim().isNotEmpty) ? n.trim() : null;
  }

  @override
  State<SpiritualOnboardingScreen> createState() =>
      _SpiritualOnboardingScreenState();
}

class _SpiritualOnboardingScreenState extends State<SpiritualOnboardingScreen>
    with TickerProviderStateMixin {
  // ───── Theme colors ─────
  static const _bg = Color(0xFF0B1623);
  static const _gold = Color(0xFFD4AF37);
  static const _lightGold = Color(0xFFF4E4B6);
  static const _saffron = Color(0xFFF59E0B);
  static const _cardBg = Color(0xFF1A2837);

  // ───── Step indices ─────
  // 0=welcome, 1-5=questions, 6=progression, 7=name, 8=summary, 9=auth
  int _currentStep = 0;
  int? _selectedOption;
  bool _showResult = false;
  bool _resultAnimating = false;
  bool _optionsHiding = false;

  // Answers
  String? _ageAnswer;
  int _ageIndex = 0;
  String? _prayerAnswer;
  List<String> _booksAnswer = [];
  String? _meditationAnswer;
  String? _goalAnswer;
  String _userName = '';

  // Onboarding language (Hindi default)
  bool _onboardingHindi = true;

  // Typewriter
  Timer? _typewriterTimer;
  String _typewriterVisible = '';
  int _typewriterIdx = 0;
  bool _typewriterDone = false;
  static const _typewriterLines = [
    'In the chaos of the modern world...',
    'there is a path within.',
    '',
    'A path the ancient sages walked.',
    'A path meant for you.',
  ];
  static const _typewriterLinesHindi = [
    'आधुनिक दुनिया की भागदौड़ में...',
    'भीतर एक मार्ग है।',
    '',
    'वह मार्ग जो पुरातन ऋषियों ने चला।',
    'वह मार्ग आपके लिए।',
  ];
  late String _typewriterFull;
  bool _showWelcomeUI = false;

  // Progression animation
  int _progressionStage = 0; // 0,1,2 for dark→seeking→illuminated
  Timer? _progressionTimer;
  bool _progressionDone = false;

  // ───── Animation controllers ─────
  late AnimationController _omPulseController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _resultController; // fact/result reveal
  late AnimationController _rippleController;
  late AnimationController _lifeGridController; // life grid dot anim

  late Animation<double> _omPulse;
  late Animation<double> _fade;
  late Animation<double> _resultAnim;
  late Animation<double> _ripple;
  late Animation<double> _lifeGrid;

  @override
  void initState() {
    super.initState();

    _typewriterFull = (_onboardingHindi ? _typewriterLinesHindi : _typewriterLines).join('\n');

    _omPulseController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _omPulse = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _omPulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    _particleController = AnimationController(
      vsync: this, duration: const Duration(seconds: 8),
    )..repeat();

    _waveController = AnimationController(
      vsync: this, duration: const Duration(seconds: 6),
    )..repeat();

    _resultController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );
    _resultAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOutCubic),
    );

    _rippleController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800),
    );
    _ripple = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _lifeGridController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000),
    );
    _lifeGrid = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lifeGridController, curve: Curves.easeOutCubic),
    );

    // Start typewriter on welcome
    _startTypewriter();
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _progressionTimer?.cancel();
    _omPulseController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _resultController.dispose();
    _rippleController.dispose();
    _lifeGridController.dispose();
    super.dispose();
  }

  void _setOnboardingLanguage(bool hindi) {
    if (_currentStep == 0) {
      _typewriterTimer?.cancel();
      setState(() {
        _onboardingHindi = hindi;
        _typewriterFull = (hindi ? _typewriterLinesHindi : _typewriterLines).join('\n');
        _typewriterVisible = _typewriterFull;
        _typewriterDone = true;
        _typewriterIdx = _typewriterFull.length;
        _showWelcomeUI = true;
      });
    } else {
      setState(() => _onboardingHindi = hindi);
    }
  }

  Widget _buildLanguageToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: _onboardingHindi ? null : () => _setOnboardingLanguage(true),
          child: Text(
            'हिंदी',
            style: GoogleFonts.tenorSans(
              fontSize: 14,
              fontWeight: _onboardingHindi ? FontWeight.w700 : FontWeight.w500,
              color: _onboardingHindi ? _gold : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        Text(
          '|',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        TextButton(
          onPressed: !_onboardingHindi ? null : () => _setOnboardingLanguage(false),
          child: Text(
            'English',
            style: GoogleFonts.tenorSans(
              fontSize: 14,
              fontWeight: !_onboardingHindi ? FontWeight.w700 : FontWeight.w500,
              color: !_onboardingHindi ? _gold : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  // ───── Typewriter logic ─────
  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 55), (t) {
      if (_typewriterIdx < _typewriterFull.length) {
        setState(() {
          _typewriterIdx++;
          _typewriterVisible = _typewriterFull.substring(0, _typewriterIdx);
        });
        // Vibrate on non-space characters
        if (_typewriterFull[_typewriterIdx - 1] != ' ' &&
            _typewriterFull[_typewriterIdx - 1] != '\n') {
          HapticFeedback.lightImpact();
        }
      } else {
        t.cancel();
        setState(() => _typewriterDone = true);
        // Show welcome UI after a beat
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _showWelcomeUI = true);
        });
      }
    });
  }

  // ───── Question definitions ─────
  List<_QuestionData> get _questions => [
    _QuestionData(
      symbol: 'ॐ',
      symbolFontSize: 52,
      title: 'Which age group\nare you in?',
      subtitle: 'Your age helps us personalise',
      options: ['Under 18', '18–25', '26–35', '36–45', '46–55', '55+'],
      titleHindi: 'आप किस आयु वर्ग में हैं?',
      subtitleHindi: 'उम्र से हम अनुभव को व्यक्तिगत बनाते हैं',
      optionsHindi: ['18 से कम', '18–25', '26–35', '36–45', '46–55', '55+'],
      factBuilder: (idx) {
        final pcts = [92, 78, 65, 52, 38, 24];
        return _FactData(
          percentage: pcts[idx],
          text: "You're ahead of ${pcts[idx]}% of seekers\nwho started at your age!",
          subtext: 'The best time to begin is now.',
        );
      },
      factBuilderHindi: (idx) {
        final pcts = [92, 78, 65, 52, 38, 24];
        return _FactData(
          percentage: pcts[idx],
          text: 'आपकी उम्र में शुरू करने वालों में\nआप ${pcts[idx]}% से आगे हैं!',
          subtext: 'शुरू करने का सबसे अच्छा समय अभी है।',
        );
      },
    ),
    _QuestionData(
      symbol: '🪔',
      symbolFontSize: 52,
      title: 'How often do you\nconnect with the divine?',
      subtitle: 'Prayer, puja, or any spiritual practice',
      options: ['Daily', 'Few times a week', 'Occasionally', 'Rarely', 'Starting fresh today'],
      titleHindi: 'आप भगवान की पूजा\nकितनी बार करते हैं?',
      subtitleHindi: 'प्रार्थना, पूजा या कोई आध्यात्मिक अभ्यास',
      optionsHindi: ['रोज़', 'हफ़्ते में कुछ बार', 'कभी-कभी', 'बहुत कम', 'आज से शुरू'],
      factBuilder: (idx) {
        final pcts = [12, 28, 45, 68, 85];
        final msgs = [
          "Only 12% pray daily.\nYou're in an elite circle of devotion!",
          "You're more consistent than\n72% of spiritual seekers!",
          "You're already ahead of 55%.\nLet's make it a habit!",
          "32% of our most active users\nstarted right where you are!",
          "Every great journey begins\nwith a single step. Welcome!",
        ];
        return _FactData(percentage: pcts[idx], text: msgs[idx],
          subtext: 'Consistency is the path to inner peace.');
      },
      factBuilderHindi: (idx) {
        final pcts = [12, 28, 45, 68, 85];
        final msgs = [
          'केवल १२% रोज़ प्रार्थना करते हैं।\nआप भक्ति के विशेष समूह में हैं!',
          'आप ७२% आध्यात्मिक साधकों से\nअधिक नियमित हैं!',
          'आप पहले से ५५% से आगे।\nइसे आदत बनाएं!',
          'हमारे ३२% सक्रिय उपयोगकर्ता\nयहीं से शुरू हुए!',
          'हर बड़ी यात्रा एक कदम से शुरू होती है।\nस्वागत है!',
        ];
        return _FactData(percentage: pcts[idx], text: msgs[idx],
          subtext: 'नियमितता ही अंतरात्मा की शांति का मार्ग है।');
      },
    ),
    _QuestionData(
      symbol: '📖',
      symbolFontSize: 48,
      title: 'Which sacred texts\nhave you explored?',
      subtitle: 'Select all that apply',
      options: ['Bhagavad Gita', 'Ramayan', 'Mahabharata', 'Vedas', 'Upanishads', 'None yet'],
      titleHindi: 'आपने कौन-से पवित्र\nग्रंथ पढ़े हैं?',
      subtitleHindi: 'सभी लागू विकल्प चुनें',
      optionsHindi: ['भगवद् गीता', 'रामायण', 'महाभारत', 'वेद', 'उपनिषद', 'अभी कोई नहीं'],
      isMultiSelect: true,
      factBuilder: (_) => _FactData(percentage: 0, text: '', subtext: ''),
      factBuilderHindi: (_) => _FactData(percentage: 0, text: '', subtext: ''),
    ),
    _QuestionData(
      symbol: '🧘',
      symbolFontSize: 52,
      title: 'Do you meditate?',
      subtitle: 'Even a minute of stillness counts',
      options: ['Yes, daily', 'Sometimes', 'Tried but struggled', 'Never tried', 'Want to start'],
      titleHindi: 'क्या आप ध्यान करते हैं?',
      subtitleHindi: 'एक मिनट की शांति भी मायने रखती है',
      optionsHindi: ['हाँ, रोज़', 'कभी-कभी', 'किया पर मुश्किल लगा', 'कभी नहीं', 'शुरू करना चाहता हूँ'],
      factBuilder: (idx) {
        final pcts = [8, 22, 45, 60, 35];
        final msgs = [
          "Only 8% meditate daily.\nYou're truly disciplined!",
          "You're calmer than 78%\nof people your age!",
          "45% share your experience.\nWe'll make it easier!",
          "60% of our top users\nstarted with zero experience!",
          "Beautiful! We have guided\nsessions just for you.",
        ];
        return _FactData(percentage: pcts[idx], text: msgs[idx],
          subtext: 'Meditation transforms the mind.');
      },
      factBuilderHindi: (idx) {
        final pcts = [8, 22, 45, 60, 35];
        final msgs = [
          'केवल ८% रोज़ ध्यान करते हैं।\nआप सच में अनुशासित हैं!',
          'आप अपनी उम्र के ७८% लोगों से\nअधिक शांत हैं!',
          '४५% का अनुभव आप जैसा है।\nहम इसे आसान बनाएंगे!',
          'हमारे ६०% शीर्ष उपयोगकर्ता\nशून्य अनुभव से शुरू हुए!',
          'सुंदर! आपके लिए मार्गदर्शित सत्र हैं।',
        ];
        return _FactData(percentage: pcts[idx], text: msgs[idx],
          subtext: 'ध्यान मन को बदल देता है।');
      },
    ),
    _QuestionData(
      symbol: '✨',
      symbolFontSize: 48,
      title: 'What draws you\nto this path?',
      subtitle: 'Choose what resonates most',
      options: ['Inner peace', 'Understanding dharma', 'Daily discipline', 'Ancient wisdom', 'Personal growth'],
      titleHindi: 'इस मार्ग की ओर\nआपको क्या खींचता है?',
      subtitleHindi: 'जो सबसे ज़्यादा अनुकूल लगे चुनें',
      optionsHindi: ['अंतर शांति', 'धर्म की समझ', 'दैनिक अनुशासन', 'प्राचीन ज्ञान', 'व्यक्तिगत विकास'],
      factBuilder: (idx) {
        final msgs = [
          "Peace seekers find calm\n3x faster with daily practice!",
          "Dharma is the foundation.\nYou're building on solid ground!",
          "Discipline leads to freedom.\nLet's build your streak!",
          "The ancients knew secrets\nwe're still discovering!",
          "Growth is eternal.\nEvery verse brings a new insight!",
        ];
        return _FactData(percentage: 0, text: msgs[idx],
          subtext: 'Your path is uniquely yours.', hideBar: true);
      },
      factBuilderHindi: (idx) {
        final msgs = [
          'शांति चाहने वाले रोज़ अभ्यास से\n३ गुना तेज़ शांति पाते हैं!',
          'धर्म नींव है।\nआप मज़बूत ज़मीन पर खड़े हैं!',
          'अनुशासन से ही मुक्ति।\nअपनी लगन बढ़ाएं!',
          'प्राचीनों को वे रहस्य पता थे\nजो हम अभी खोज रहे हैं!',
          'विकास अनंत है।\nहर श्लोक नई दृष्टि लाता है!',
        ];
        return _FactData(percentage: 0, text: msgs[idx],
          subtext: 'आपका मार्ग सिर्फ आपका है।', hideBar: true);
      },
    ),
  ];

  String _qTitle(_QuestionData q) =>
      _onboardingHindi && q.titleHindi != null ? q.titleHindi! : q.title;
  String _qSubtitle(_QuestionData q) =>
      _onboardingHindi && q.subtitleHindi != null ? q.subtitleHindi! : q.subtitle;
  String _qOption(_QuestionData q, int i) =>
      _onboardingHindi && q.optionsHindi != null && i < q.optionsHindi!.length
          ? q.optionsHindi![i]
          : q.options[i];
  _FactData _qFact(_QuestionData q, int idx) =>
      _onboardingHindi && q.factBuilderHindi != null
          ? q.factBuilderHindi!(idx)
          : q.factBuilder(idx);

  String _optionDisplayLabel(int qIdx, String englishOption) {
    final q = _questions[qIdx];
    final i = q.options.indexOf(englishOption);
    return i >= 0 ? _qOption(q, i) : englishOption;
  }

  // ───── Selection handlers ─────
  void _onOptionSelected(int index) {
    if (_showResult || _optionsHiding) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _selectedOption = index;
      _optionsHiding = true;
    });

    // Store answer
    final q = _currentStep - 1;
    if (q == 0) { _ageAnswer = _questions[q].options[index]; _ageIndex = index; }
    if (q == 1) _prayerAnswer = _questions[q].options[index];
    if (q == 3) _meditationAnswer = _questions[q].options[index];
    if (q == 4) _goalAnswer = _questions[q].options[index];

    _rippleController.reset();
    _rippleController.forward();

    // Show result after brief delay (options fade handled by AnimatedSwitcher)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() { _showResult = true; _resultAnimating = true; });
      _resultController.reset();
      _resultController.forward().then((_) {
        if (mounted) setState(() => _resultAnimating = false);
      });
      // Start life grid animation for age question
      if (q == 0) {
        _lifeGridController.reset();
        _lifeGridController.forward();
      }
    });
  }

  void _onBookToggled(int index) {
    if (_showResult || _optionsHiding) return;
    final book = _questions[2].options[index];
    HapticFeedback.selectionClick();
    setState(() {
      if (book == 'None yet') {
        _booksAnswer = ['None yet'];
      } else {
        _booksAnswer.remove('None yet');
        if (_booksAnswer.contains(book)) {
          _booksAnswer.remove(book);
        } else {
          _booksAnswer.add(book);
        }
      }
    });
  }

  void _confirmBooks() {
    if (_booksAnswer.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _optionsHiding = true);
    _rippleController.reset();
    _rippleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() { _showResult = true; _resultAnimating = true; });
      _resultController.reset();
      _resultController.forward().then((_) {
        if (mounted) setState(() => _resultAnimating = false);
      });
    });
  }

  void _nextStep() async {
    HapticFeedback.lightImpact();
    // Save user name when leaving name step (7)
    if (_currentStep == _questions.length + 2 && _userName.trim().isNotEmpty) {
      await SpiritualOnboardingScreen.saveUserName(_userName);
    }
    _fadeController.reset();
    _rippleController.reset();
    _resultController.reset();
    setState(() {
      _currentStep++;
      _selectedOption = null;
      _showResult = false;
      _resultAnimating = false;
      _optionsHiding = false;
    });
    _fadeController.forward();

    // Start progression animation timer if entering progression step
    if (_currentStep == _questions.length + 1) {
      _startProgressionAnim();
    }
  }

  void _previousStep() {
    if (_currentStep <= 0) return;
    HapticFeedback.lightImpact();
    _fadeController.reset();
    _rippleController.reset();
    _resultController.reset();
    _progressionTimer?.cancel();
    setState(() {
      _currentStep--;
      _selectedOption = null;
      _showResult = false;
      _resultAnimating = false;
      _optionsHiding = false;
      _progressionDone = false;
      _progressionStage = 0;
    });
    _fadeController.forward();
  }

  void _startProgressionAnim() {
    _progressionStage = 0;
    _progressionDone = false;
    HapticFeedback.lightImpact();
    _progressionTimer = Timer.periodic(const Duration(milliseconds: 1200), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _progressionStage++);
      HapticFeedback.lightImpact();
      if (_progressionStage >= 3) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _progressionDone = true);
        });
      }
    });
  }

  void _goToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    SpiritualOnboardingScreen.markOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  void _skipToHome() {
    FocusManager.instance.primaryFocus?.unfocus();
    SpiritualOnboardingScreen.markOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  // ═══════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isQ = _currentStep >= 1 && _currentStep <= _questions.length;
    return PopScope(
      canPop: _currentStep > 0,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
        children: [
          // Water waves during questions
          if (isQ)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (_, __) => CustomPaint(
                  painter: _WaterWavePainter(
                    progress: _waveController.value,
                    intensity: _optionsHiding ? 1.0 : 0.3,
                  ),
                ),
              ),
            ),
          // Particles everywhere
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _FloatingParticlesPainter(progress: _particleController.value),
              ),
            ),
          ),
          // Ripple burst on selection
          if (_optionsHiding)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ripple,
                builder: (_, __) => CustomPaint(
                  painter: _RippleBurstPainter(progress: _ripple.value),
                ),
              ),
            ),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: _buildCurrentStep(),
            ),
          ),
          // Language toggle (Hindi / English) — always on top, right corner; never overridden by content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: _bg.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildLanguageToggle(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Back button (visible after step 0)
          if (_currentStep > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: SafeArea(
                child: GestureDetector(
                  onTap: _previousStep,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: _lightGold.withValues(alpha: 0.7), size: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_currentStep == 0) return _buildWelcome();
    if (_currentStep <= _questions.length) return _buildQuestion(_currentStep - 1);
    if (_currentStep == _questions.length + 1) return _buildProgression();
    if (_currentStep == _questions.length + 2) return _buildNameInput();
    if (_currentStep == _questions.length + 3) return _buildSummary();
    return _buildAuthChoice();
  }

  // ═══════════════════════════════════════════════════════════
  //  STEP 0: WELCOME — Typewriter + Vibration
  // ═══════════════════════════════════════════════════════════
  Widget _buildWelcome() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Logo in background — no fixed dimensions; scales to fit, content overlays it
        Positioned.fill(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedBuilder(
                animation: _omPulse,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.15 * _omPulse.value),
                        blurRadius: 40 * _omPulse.value,
                        spreadRadius: 10 * _omPulse.value,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppConfig.appLogoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text('ॐ',
                        style: GoogleFonts.notoSerifDevanagari(
                          fontSize: 80, fontWeight: FontWeight.w300,
                          color: _gold, height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Content overlays the logo — typewriter; button at bottom (reserve top space so toggle never overlaps)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // Reserve space for language toggle (top-right) so first-page text never overlaps it
              const SizedBox(height: 60),
              // Typewriter text
              SizedBox(
                height: 130,
                child: Text(
                  _typewriterVisible,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: _lightGold.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
                ),
              ),
              if (!_typewriterDone)
                AnimatedBuilder(
                  animation: _omPulseController,
                  builder: (_, __) => Opacity(
                    opacity: (_omPulseController.value > 0.5) ? 1.0 : 0.0,
                    child: Container(
                      width: 2,
                      height: 24,
                      color: _gold,
                    ),
                  ),
                ),
              const Spacer(flex: 5),
              // Button close to bottom
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showWelcomeUI ? 1.0 : 0.0,
                child: Column(
                  children: [
                    _GoldButton(
                      label: _onboardingHindi ? 'अपनी यात्रा शुरू करें' : 'Begin Your Journey',
                      onTap: _nextStep,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _onboardingHindi ? 'केवल २ मिनट' : 'Takes only 2 minutes',
                      style: GoogleFonts.tenorSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  STEPS 1–5: QUESTIONS — Each with unique result visual
  // ═══════════════════════════════════════════════════════════
  Widget _buildQuestion(int qIdx) {
    final q = _questions[qIdx];
    final isBooks = q.isMultiSelect;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildProgressBar(qIdx),
          const SizedBox(height: 20),
          // Symbol + Title
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: Column(
              children: [
                Center(child: Text(q.symbol,
                  style: TextStyle(fontSize: _showResult ? 32 : q.symbolFontSize),
                )),
                SizedBox(height: _showResult ? 8 : 20),
                if (!_showResult)
                  Center(child: Text(_qTitle(q),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26, fontWeight: FontWeight.w600,
                      color: _lightGold, height: 1.3,
                    ),
                  )),
                if (_showResult)
                  Center(child: Text(_qTitle(q).replaceAll('\n', ' '),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18, fontWeight: FontWeight.w600,
                      color: _lightGold.withValues(alpha: 0.6), height: 1.2,
                    ),
                  )),
                if (!_showResult) ...[
                  const SizedBox(height: 6),
                  Center(child: Text(_qSubtitle(q),
                    style: GoogleFonts.tenorSans(
                      fontSize: 13, color: Colors.white.withValues(alpha: 0.4),
                    ),
                  )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Content area: options OR result
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                );
              },
              child: _showResult
                  ? _buildResultForQuestion(qIdx, key: const ValueKey('result'))
                  : _buildOptionsForQuestion(qIdx, isBooks, key: const ValueKey('options')),
            ),
          ),
          // Continue button after result
          if (_showResult && !_resultAnimating)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _GoldButton(
                label: _currentStep == _questions.length
                    ? (_onboardingHindi ? 'अपनी यात्रा देखें' : 'See Your Journey')
                    : (_onboardingHindi ? 'आगे बढ़ें' : 'Continue'),
                onTap: _nextStep,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsForQuestion(int qIdx, bool isBooks, {Key? key}) {
    final q = _questions[qIdx];
    return SingleChildScrollView(
      key: key,
      child: Column(
        children: [
          ...List.generate(q.options.length, (i) {
            if (isBooks) return _buildMultiChip(q.options[i], i, qIdx);
            return _buildOptionTile(_qOption(q, i), i, qIdx);
          }),
          if (isBooks && !_optionsHiding && _booksAnswer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _GoldButton(
                label: _onboardingHindi ? 'आगे बढ़ें' : 'Continue',
                onTap: _confirmBooks,
                compact: true,
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Dispatches to unique result widget per question ──
  Widget _buildResultForQuestion(int qIdx, {Key? key}) {
    return SingleChildScrollView(
      key: key,
      child: AnimatedBuilder(
        animation: _resultAnim,
        builder: (_, __) {
          final t = _resultAnim.value;
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Selected answer badge
                if (_selectedOption != null || _booksAnswer.isNotEmpty)
                  _buildSelectedBadge(qIdx),
                const SizedBox(height: 16),
                // Unique result per question
                if (qIdx == 0) _buildLifeGrid(),
                if (qIdx == 1) _buildPrayerResult(),
                if (qIdx == 2) _buildBooksResult(),
                if (qIdx == 3) _buildMeditationResult(),
                if (qIdx == 4) _buildGoalResult(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedBadge(int qIdx) {
    final q = _questions[qIdx];
    final label = q.isMultiSelect
        ? _booksAnswer.map((opt) => _optionDisplayLabel(qIdx, opt)).join(', ')
        : (_selectedOption != null ? _qOption(q, _selectedOption!) : '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _gold.withValues(alpha: 0.18),
          _saffron.withValues(alpha: 0.08),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: _gold.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: _gold, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(label,
              style: GoogleFonts.tenorSans(
                fontSize: 14, color: _lightGold, fontWeight: FontWeight.w600,
              ),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Q1 RESULT: Journey grid (wisdom / path — no fixed “remaining years”)
  // ═══════════════════════════════════════════════════════════
  Widget _buildLifeGrid() {
    final ages = [15, 22, 30, 40, 50, 60];
    final userAge = ages[_ageIndex.clamp(0, ages.length - 1)];
    const totalDots = 60; // “Steps on the path” — metaphorical, not years left

    return AnimatedBuilder(
      animation: _lifeGrid,
      builder: (_, __) {
        final revealCount = (totalDots * _lifeGrid.value).round();
        return Column(
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [_lightGold, _gold],
              ).createShader(b),
              child: Text(_onboardingHindi ? 'अब तक की आपकी यात्रा' : 'Your journey so far',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8, runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(totalDots, (i) {
                final isLived = i < userAge;
                final isRevealed = i < revealCount;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200 + (i % 10) * 30),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !isRevealed
                        ? Colors.transparent
                        : isLived
                            ? _gold.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.08),
                    boxShadow: isRevealed && isLived ? [
                      BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 6),
                    ] : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(_gold), const SizedBox(width: 6),
                Text(_onboardingHindi ? 'अब तक का आपका मार्ग' : 'Your path so far', style: _legendStyle()),
                const SizedBox(width: 20),
                _dot(Colors.white.withValues(alpha: 0.15)), const SizedBox(width: 6),
                Text(_onboardingHindi ? 'आगे का रास्ता' : 'The road ahead', style: _legendStyle()),
              ],
            ),
            const SizedBox(height: 16),
            Text(_onboardingHindi ? 'हर कदम मायने रखता है।' : 'Make every step count.',
              style: GoogleFonts.tenorSans(
                fontSize: 13, color: _lightGold.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dot(Color c) => Container(width: 10, height: 10,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c));
  TextStyle _legendStyle() => GoogleFonts.tenorSans(
    fontSize: 12, color: Colors.white.withValues(alpha: 0.5));

  // ═══════════════════════════════════════════════════════════
  //  Q2 RESULT: Prayer — Animated flame gauge
  // ═══════════════════════════════════════════════════════════
  Widget _buildPrayerResult() {
    final fact = _qFact(_questions[1], _selectedOption ?? 0);
    return AnimatedBuilder(
      animation: _resultAnim,
      builder: (_, __) {
        final t = _resultAnim.value;
        return Column(
          children: [
            // Animated diya flame
            SizedBox(
              width: 120, height: 140,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (_, __) => CustomPaint(
                  painter: _DiyaFlamePainter(
                    time: _waveController.value,
                    intensity: t,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatCard(fact, t),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Q3 RESULT: Books — Stacked knowledge visual
  // ═══════════════════════════════════════════════════════════
  Widget _buildBooksResult() {
    final count = _booksAnswer.where((b) => b != 'None yet').length;
    final pct = count == 0 ? 85 : (100 - count * 15).clamp(10, 90);
    final text = _onboardingHindi
        ? (count == 0
            ? 'हमारे ८५% पसंदीदा उपयोगकर्ताओं ने\nशून्य ज्ञान से शुरुआत की!'
            : 'आपने $count पवित्र ग्रंथ पढ़े हैं!\nआप ${100 - pct}% साधकों से आगे हैं।')
        : (count == 0
            ? "85% of our most loved users\nstarted with zero knowledge!"
            : "You've explored $count sacred text${count > 1 ? 's' : ''}!\nThat puts you ahead of ${100 - pct}% of seekers.");
    final subtext = _onboardingHindi ? 'हमारे पुस्तकालय में ये सब और भी बहुत कुछ है।' : 'Our library has all of these and more.';
    final fact = _FactData(percentage: pct, text: text, subtext: subtext);

    return AnimatedBuilder(
      animation: _resultAnim,
      builder: (_, __) {
        final t = _resultAnim.value;
        return Column(
          children: [
            // Book stack visual
            SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(math.min(count == 0 ? 1 : count, 5), (i) {
                  final offset = (i - 2.0) * 14;
                  return Transform.translate(
                    offset: Offset(offset * t, -i * 4.0 * t),
                    child: Transform.rotate(
                      angle: (i - 2) * 0.08 * t,
                      child: Container(
                        width: 50, height: 65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              _gold.withValues(alpha: 0.3 + i * 0.1),
                              _saffron.withValues(alpha: 0.2 + i * 0.1),
                            ],
                          ),
                          border: Border.all(color: _gold.withValues(alpha: 0.4)),
                        ),
                        child: const Center(child: Text('📖', style: TextStyle(fontSize: 20))),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            _buildStatCard(fact, t),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Q4 RESULT: Meditation — Breathing circle
  // ═══════════════════════════════════════════════════════════
  Widget _buildMeditationResult() {
    final fact = _qFact(_questions[3], _selectedOption ?? 0);
    return AnimatedBuilder(
      animation: _resultAnim,
      builder: (_, __) {
        final t = _resultAnim.value;
        // Pulsing breath effect using wave controller
        return AnimatedBuilder(
          animation: _waveController,
          builder: (_, __) {
            final breath = 0.85 + 0.15 * math.sin(_waveController.value * math.pi * 2);
            return Column(
              children: [
                // Breathing circle
                Transform.scale(
                  scale: breath * t.clamp(0.3, 1.0),
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        _gold.withValues(alpha: 0.25),
                        _gold.withValues(alpha: 0.05),
                        Colors.transparent,
                      ]),
                      border: Border.all(color: _gold.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Center(child: Text('🧘', style: TextStyle(fontSize: 40))),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_onboardingHindi ? 'साँस लें...' : 'breathe...',
                  style: GoogleFonts.tenorSans(
                    fontSize: 12, color: _lightGold.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic, letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatCard(fact, t),
              ],
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Q5 RESULT: Goal — Sparkle path
  // ═══════════════════════════════════════════════════════════
  Widget _buildGoalResult() {
    final fact = _qFact(_questions[4], _selectedOption ?? 0);
    return AnimatedBuilder(
      animation: _resultAnim,
      builder: (_, __) {
        final t = _resultAnim.value;
        return Column(
          children: [
            // Sparkle ring
            SizedBox(
              width: 120, height: 120,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _SparklePainter(
                      progress: _waveController.value,
                      intensity: t,
                    ),
                    child: const Center(child: Text('✨', style: TextStyle(fontSize: 48))),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildStatCard(fact, t),
          ],
        );
      },
    );
  }

  // ── Reusable stat card ──
  Widget _buildStatCard(_FactData fact, double t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _gold.withValues(alpha: 0.10), _saffron.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          if (!fact.hideBar && fact.percentage > 0) ...[
            Row(children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [_gold, _lightGold],
                ).createShader(b),
                child: Text('${(fact.percentage * t).round()}%',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (fact.percentage / 100) * t,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(_gold),
                    minHeight: 8,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 14),
          ],
          Text(fact.text, textAlign: TextAlign.center,
            style: GoogleFonts.tenorSans(
              fontSize: 15, color: _lightGold, height: 1.5, fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(fact.subtext, textAlign: TextAlign.center,
            style: GoogleFonts.tenorSans(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  PROGRESS BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildProgressBar(int qIdx) {
    return Row(
      children: List.generate(_questions.length, (i) {
        final isActive = i <= qIdx;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: isActive
                  ? const LinearGradient(colors: [_gold, _lightGold])
                  : null,
              color: isActive ? null : Colors.white.withValues(alpha: 0.08),
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  OPTION TILES
  // ═══════════════════════════════════════════════════════════
  Widget _buildOptionTile(String label, int index, int qIdx) {
    final isSelected = _selectedOption == index;
    // Different leading icons per question for variety
    final icons = [
      null, // Q1: no icon
      ['🕯️', '🔥', '☀️', '🌙', '🌅'], // Q2: prayer icons
      null, // Q3: multi-select
      ['🧘', '😌', '🤔', '🌱', '💫'], // Q4: meditation icons
      ['☮️', '⚖️', '💪', '📿', '🌿'], // Q5: goal icons
    ];
    final iconList = qIdx < icons.length ? icons[qIdx] : null;
    final leading = (iconList != null && index < iconList.length) ? iconList[index] : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: (_optionsHiding) ? null : () => _onOptionSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [
                    _gold.withValues(alpha: 0.20),
                    _saffron.withValues(alpha: 0.10),
                  ])
                : null,
            color: isSelected ? null : _cardBg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _gold.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                Text(leading, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(label,
                  style: GoogleFonts.tenorSans(
                    fontSize: 15,
                    color: isSelected ? _lightGold : Colors.white.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: isSelected
                    ? const Icon(Icons.check_circle, color: _gold, size: 22, key: ValueKey('c'))
                    : const SizedBox(width: 22, key: ValueKey('e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiChip(String optionKey, int index, int qIdx) {
    final isSelected = _booksAnswer.contains(optionKey);
    final displayLabel = _qOption(_questions[qIdx], index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: _optionsHiding ? null : () => _onBookToggled(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [
                    _gold.withValues(alpha: 0.20), _saffron.withValues(alpha: 0.10),
                  ])
                : null,
            color: isSelected ? null : _cardBg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _gold.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(displayLabel,
                  style: GoogleFonts.tenorSans(
                    fontSize: 15,
                    color: isSelected ? _lightGold : Colors.white.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: isSelected
                    ? const Icon(Icons.check_circle, color: _gold, size: 22, key: ValueKey('c'))
                    : Icon(Icons.circle_outlined, color: Colors.white.withValues(alpha: 0.2),
                        size: 22, key: const ValueKey('e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  STEP 6: PROGRESSION — Dark → Light transformation
  // ═══════════════════════════════════════════════════════════
  Widget _buildProgression() {
    final stagesEn = [
      ('Darkness', '🌑', 'Where most begin...', Colors.white.withValues(alpha: 0.3)),
      ('Seeking', '🌅', 'The journey inward starts...', _saffron),
      ('Illumination', '☀️', 'The light was always within you.', _gold),
    ];
    final stagesHi = [
      ('अंधकार', '🌑', 'जहाँ अधिकतर शुरू करते हैं...', Colors.white.withValues(alpha: 0.3)),
      ('खोज', '🌅', 'भीतर की यात्रा शुरू होती है...', _saffron),
      ('प्रकाश', '☀️', 'प्रकाश हमेशा आपके भीतर था।', _gold),
    ];
    final stages = _onboardingHindi ? stagesHi : stagesEn;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(flex: 2),
            ShaderMask(
              shaderCallback: (b) => LinearGradient(
                colors: _progressionStage >= 2
                    ? [_lightGold, _gold]
                    : [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.3)],
              ).createShader(b),
              child: Text(_onboardingHindi ? 'आपका रूपांतरण' : 'Your Transformation',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Three stage nodes
            ...List.generate(3, (i) {
              final isReached = i <= _progressionStage;
              final isCurrent = i == _progressionStage;
              final (name, emoji, desc, color) = stages[i];
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: isReached ? 1.0 : 0.2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      // Node
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: isCurrent ? 64 : 48,
                        height: isCurrent ? 64 : 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isReached ? color.withValues(alpha: 0.15) : Colors.transparent,
                          border: Border.all(
                            color: isReached ? color : Colors.white.withValues(alpha: 0.1),
                            width: isCurrent ? 2.5 : 1,
                          ),
                          boxShadow: isCurrent ? [
                            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20),
                          ] : null,
                        ),
                        child: Center(child: Text(emoji,
                          style: TextStyle(fontSize: isCurrent ? 28 : 22))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20, fontWeight: FontWeight.w600,
                                color: isReached ? color : Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(desc,
                              style: GoogleFonts.tenorSans(
                                fontSize: 12,
                                color: isReached
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            if (_progressionDone) ...[
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [_lightGold, _gold],
                ).createShader(b),
                child: Text(_onboardingHindi
                    ? '${AppConfig.appDisplayName} आपके\nभीतरी मार्ग को रोशन करता है'
                    : '${AppConfig.appDisplayName} illuminates\nyour inner path',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22, fontWeight: FontWeight.w600,
                    color: Colors.white, height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _GoldButton(label: _onboardingHindi ? 'आगे बढ़ें' : 'Continue', onTap: _nextStep),
            ],
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  STEP 7: NAME INPUT
  // ═══════════════════════════════════════════════════════════
  Widget _buildNameInput() {
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 0.8,
      maxScaleFactor: 1.2,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(flex: 2),
              const Text('🙏', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [_lightGold, _gold],
              ).createShader(b),
              child: Text(_onboardingHindi ? 'हम आपको क्या\nबुलाएँ, साधक?' : 'What shall we\ncall you, seeker?',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 30, fontWeight: FontWeight.w600,
                  color: Colors.white, height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(_onboardingHindi ? 'आपका नाम अनुभव को व्यक्तिगत बनाता है' : 'Your name helps personalise the experience',
              style: GoogleFonts.tenorSans(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 36),
            // Name field — light background so typed text is clearly visible in black
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withValues(alpha: 0.4)),
                color: const Color(0xFFF5F0E8),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _userName = v.trim()),
                textAlign: TextAlign.center,
                cursorColor: const Color(0xFF0B1623),
                style: GoogleFonts.tenorSans(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: _onboardingHindi ? 'अपना नाम लिखें' : 'Enter your name',
                  hintStyle: GoogleFonts.tenorSans(
                    fontSize: 16,
                    color: Colors.black45,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _userName.isNotEmpty ? 1.0 : 0.3,
              child: _GoldButton(
                label: _userName.isNotEmpty
                    ? (_onboardingHindi ? 'स्वागत है, $_userName!' : 'Welcome, $_userName!')
                    : (_onboardingHindi ? 'आगे बढ़ें' : 'Continue'),
                onTap: _userName.isNotEmpty ? _nextStep : () {},
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  STEP 8: SUMMARY
  // ═══════════════════════════════════════════════════════════
  Widget _buildSummary() {
    final greeting = _userName.isNotEmpty ? ', $_userName' : '';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [_lightGold, _gold],
              ).createShader(b),
              child: Text(_onboardingHindi ? 'नमस्ते$greeting!\nआपकी प्रोफ़ाइल तैयार है' : 'Namaste$greeting!\nYour Profile is Ready',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 30, fontWeight: FontWeight.w600,
                  color: Colors.white, height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_ageAnswer != null) _summaryTile('🕉️', _onboardingHindi ? 'उम्र' : 'Age', _optionDisplayLabel(0, _ageAnswer!)),
            if (_prayerAnswer != null) _summaryTile('🪔', _onboardingHindi ? 'प्रार्थना' : 'Prayer', _optionDisplayLabel(1, _prayerAnswer!)),
            if (_booksAnswer.isNotEmpty) _summaryTile('📖', _onboardingHindi ? 'ग्रंथ' : 'Texts', _booksAnswer.map((o) => _optionDisplayLabel(2, o)).join(', ')),
            if (_meditationAnswer != null) _summaryTile('🧘', _onboardingHindi ? 'ध्यान' : 'Meditation', _optionDisplayLabel(3, _meditationAnswer!)),
            if (_goalAnswer != null) _summaryTile('✨', _onboardingHindi ? 'लक्ष्य' : 'Goal', _optionDisplayLabel(4, _goalAnswer!)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _gold.withValues(alpha: 0.1), _saffron.withValues(alpha: 0.05),
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withValues(alpha: 0.15)),
              ),
              child: Text(
                _onboardingHindi
                    ? 'आपके जवाबों के आधार पर हम आपकी यात्रा को व्यक्तिगत बनाएंगे। '
                      'दैनिक कार्य, श्लोक और मार्गदर्शित अभ्यास आपका इंतज़ार कर रहे हैं।'
                    : 'We\'ll personalise your journey based on your answers. '
                        'Daily tasks, verses, and guided practices await you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.tenorSans(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.6), height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _GoldButton(label: _onboardingHindi ? 'चलें!' : "Let's Go!", onTap: _goToLogin),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.tenorSans(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 1,
              )),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.tenorSans(
                fontSize: 14, color: _lightGold, fontWeight: FontWeight.w500,
              ), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          )),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  STEP 9: AUTH CHOICE
  // ═══════════════════════════════════════════════════════════
  Widget _buildAuthChoice() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              AppConfig.appLogoPath,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [_gold, _lightGold],
                ).createShader(b),
                child: Text('ॐ',
                  style: GoogleFonts.notoSerifDevanagari(
                    fontSize: 80, fontWeight: FontWeight.w300, color: Colors.white, height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            _GoldButton(label: _onboardingHindi ? 'साइन इन / खाता बनाएं' : 'Sign In / Create Account', onTap: _goToLogin),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _skipToHome,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(_onboardingHindi ? 'अभी छोड़ें' : 'Skip for now',
                  style: GoogleFonts.tenorSans(
                    fontSize: 15, color: Colors.white.withValues(alpha: 0.5),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 12),
            Text(_onboardingHindi ? 'बाद में प्रोफ़ाइल से साइन इन कर सकते हैं' : 'You can sign in later from Profile',
              style: GoogleFonts.tenorSans(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════
class _QuestionData {
  final String symbol;
  final double symbolFontSize;
  final String title;
  final String subtitle;
  final List<String> options;
  final bool isMultiSelect;
  final _FactData Function(int selectedIndex) factBuilder;
  final String? titleHindi;
  final String? subtitleHindi;
  final List<String>? optionsHindi;
  final _FactData Function(int selectedIndex)? factBuilderHindi;

  _QuestionData({
    required this.symbol,
    this.symbolFontSize = 52,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.factBuilder,
    this.isMultiSelect = false,
    this.titleHindi,
    this.subtitleHindi,
    this.optionsHindi,
    this.factBuilderHindi,
  });
}

class _FactData {
  final int percentage;
  final String text;
  final String subtext;
  final bool hideBar;

  _FactData({
    required this.percentage,
    required this.text,
    required this.subtext,
    this.hideBar = false,
  });
}

// ═══════════════════════════════════════════════════════════
//  GOLD BUTTON
// ═══════════════════════════════════════════════════════════
class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool compact;

  const _GoldButton({required this.label, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: compact ? 14 : 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            _SpiritualOnboardingScreenState._gold,
            _SpiritualOnboardingScreenState._saffron,
          ]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _SpiritualOnboardingScreenState._gold.withValues(alpha: 0.3),
              blurRadius: 20, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(label,
            style: GoogleFonts.tenorSans(
              fontSize: compact ? 14 : 16, fontWeight: FontWeight.w600,
              color: const Color(0xFF0B1623), letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════════

class _FloatingParticlesPainter extends CustomPainter {
  final double progress;
  _FloatingParticlesPainter({required this.progress});

  static final _particles = List.generate(20, (i) {
    final rng = math.Random(i * 42);
    return (x: rng.nextDouble(), y: rng.nextDouble(),
      size: 1.0 + rng.nextDouble() * 2.0, speed: 0.3 + rng.nextDouble() * 0.7);
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress * p.speed + p.y) % 1.0;
      final y = size.height * (1.0 - t);
      final x = size.width * p.x + math.sin(t * math.pi * 2) * 20;
      double a;
      if (t < 0.1) { a = t / 0.1; }
      else if (t > 0.9) { a = (1.0 - t) / 0.1; }
      else { a = 0.3; }
      canvas.drawCircle(Offset(x, y), p.size,
        Paint()..color = const Color(0xFFD4AF37).withValues(alpha: a * 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter o) => o.progress != progress;
}

class _WaterWavePainter extends CustomPainter {
  final double progress;
  final double intensity;
  _WaterWavePainter({required this.progress, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (int layer = 0; layer < 3; layer++) {
      final path = Path();
      final a = (0.04 + layer * 0.02) * intensity;
      final yBase = h * (0.70 - layer * 0.08);
      final amp = 12.0 + layer * 6.0;
      final freq = 2.0 + layer * 0.5;
      final phase = progress * math.pi * 2 + layer * 1.2;
      path.moveTo(0, h);
      path.lineTo(0, yBase);
      for (double x = 0; x <= w; x += 4) {
        path.lineTo(x, yBase +
            amp * math.sin(freq * (x / w) * math.pi * 2 + phase) +
            amp * 0.5 * math.sin(freq * 1.5 * (x / w) * math.pi * 2 + phase * 0.7));
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: a),
            const Color(0xFF0B1623).withValues(alpha: a * 0.2),
          ],
        ).createShader(Rect.fromLTWH(0, yBase, w, h - yBase)));
    }
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter o) =>
      o.progress != progress || o.intensity != intensity;
}

class _RippleBurstPainter extends CustomPainter {
  final double progress;
  _RippleBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final maxR = size.longestSide * 0.8;
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.15;
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      canvas.drawCircle(center, maxR * t, Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: (1.0 - t) * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1.0 - t) + 0.5);
    }
    final ga = (1.0 - progress) * 0.08;
    if (ga > 0) {
      canvas.drawCircle(center, maxR * 0.3, Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFD4AF37).withValues(alpha: ga),
          const Color(0xFFD4AF37).withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: center, radius: maxR * 0.3)));
    }
  }

  @override
  bool shouldRepaint(covariant _RippleBurstPainter o) => o.progress != progress;
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final double intensity;
  _SparklePainter({required this.progress, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.6 * intensity)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2 + progress * math.pi * 2;
      final dist = r * (0.7 + 0.3 * math.sin(progress * math.pi * 4 + i));
      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist;
      final sz = 2.0 + math.sin(progress * math.pi * 3 + i) * 1.5;
      canvas.drawCircle(Offset(x, y), sz * intensity, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter o) =>
      o.progress != progress || o.intensity != intensity;
}

class _DiyaFlamePainter extends CustomPainter {
  final double time;
  final double intensity;
  _DiyaFlamePainter({required this.time, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.75;
    final t = time * math.pi * 2;

    // Diya bowl
    final bowlPath = Path()
      ..moveTo(cx - 28, baseY)
      ..quadraticBezierTo(cx - 32, baseY + 20, cx - 18, baseY + 28)
      ..lineTo(cx + 18, baseY + 28)
      ..quadraticBezierTo(cx + 32, baseY + 20, cx + 28, baseY)
      ..close();
    canvas.drawPath(bowlPath, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFCD853F), Color(0xFF8B4513)],
      ).createShader(Rect.fromLTWH(cx - 32, baseY, 64, 30)));

    // Wick
    canvas.drawLine(Offset(cx, baseY), Offset(cx, baseY - 8),
      Paint()..color = const Color(0xFF4A3728)..strokeWidth = 2.5..strokeCap = StrokeCap.round);

    // Flame layers - outer glow
    final glowR = 35.0 + 5 * math.sin(t * 3) * intensity;
    canvas.drawCircle(Offset(cx, baseY - 30), glowR * intensity,
      Paint()..shader = RadialGradient(colors: [
        const Color(0xFFF59E0B).withValues(alpha: 0.15 * intensity),
        const Color(0xFFF59E0B).withValues(alpha: 0.0),
      ]).createShader(Rect.fromCircle(center: Offset(cx, baseY - 30), radius: glowR)));

    // Outer flame (red-orange)
    _drawFlameLayer(canvas, cx, baseY - 6, t, intensity,
      height: 52, width: 16, color1: const Color(0xFFFF6B00), color2: const Color(0xFFFF4500),
      wobbleAmt: 3.0, wobbleFreq: 4.0);

    // Middle flame (orange-yellow)
    _drawFlameLayer(canvas, cx, baseY - 6, t, intensity,
      height: 42, width: 11, color1: const Color(0xFFFFA500), color2: const Color(0xFFFFD700),
      wobbleAmt: 2.0, wobbleFreq: 5.5);

    // Inner flame (white-yellow core)
    _drawFlameLayer(canvas, cx, baseY - 6, t, intensity,
      height: 28, width: 6, color1: const Color(0xFFFFE4B5), color2: const Color(0xFFFFFFE0),
      wobbleAmt: 1.0, wobbleFreq: 7.0);
  }

  void _drawFlameLayer(Canvas canvas, double cx, double baseY, double t, double intensity, {
    required double height, required double width,
    required Color color1, required Color color2,
    required double wobbleAmt, required double wobbleFreq,
  }) {
    final h = height * intensity;
    final w = width * intensity;
    final wobbleX = wobbleAmt * math.sin(t * wobbleFreq) * intensity;
    final wobbleH = h * (0.9 + 0.1 * math.sin(t * wobbleFreq * 1.3));

    final path = Path()
      ..moveTo(cx - w * 0.4, baseY)
      ..quadraticBezierTo(
        cx - w * 0.8 + wobbleX * 0.5, baseY - wobbleH * 0.4,
        cx + wobbleX, baseY - wobbleH)
      ..quadraticBezierTo(
        cx + w * 0.8 + wobbleX * 0.5, baseY - wobbleH * 0.4,
        cx + w * 0.4, baseY)
      ..close();

    canvas.drawPath(path, Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter, end: Alignment.topCenter,
        colors: [color1.withValues(alpha: 0.9 * intensity), color2.withValues(alpha: 0.4 * intensity)],
      ).createShader(Rect.fromLTWH(cx - w, baseY - h, w * 2, h)));
  }

  @override
  bool shouldRepaint(covariant _DiyaFlamePainter o) =>
      o.time != time || o.intensity != intensity;
}
