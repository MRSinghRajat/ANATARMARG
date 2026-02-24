import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../profile/presentation/providers/language_provider.dart';

class DanaPracticeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const DanaPracticeScreen({super.key, this.onComplete});

  @override
  ConsumerState<DanaPracticeScreen> createState() =>
      _DanaPracticeScreenState();
}

class _DanaPracticeScreenState extends ConsumerState<DanaPracticeScreen>
    with TickerProviderStateMixin {
  int? _selectedTypeIndex;
  bool _completed = false;

  late final AnimationController _staggerController;
  late final AnimationController _buttonController;
  late final AnimationController _completionController;
  late final AnimationController _outlinePulseController;
  late final List<Animation<double>> _cardAnimations;
  late final Animation<double> _buttonScale;
  late final Animation<double> _completionScale;
  late final Animation<double> _outlinePulse;

  static const _danaTypes = [
    _DanaType(
      name: 'Vidya Dana',
      nameHindi: 'विद्या दान',
      icon: Icons.school_outlined,
      color: Colors.blue,
      shortDesc: 'Gift of Knowledge',
      description:
          'Sharing knowledge, skills, and wisdom with others. Teaching a child, '
          'mentoring a colleague, or sharing spiritual insights.',
      shloka: 'न हि ज्ञानेन सदृशं पवित्रमिह विद्यते',
      shlokaTranslation:
          '"There is nothing as purifying as knowledge" — BG 4.38',
    ),
    _DanaType(
      name: 'Anna Dana',
      nameHindi: 'अन्न दान',
      icon: Icons.restaurant_outlined,
      color: Colors.orange,
      shortDesc: 'Gift of Food',
      description:
          'Feeding the hungry is considered the highest form of charity. '
          'Offering food to guests, animals, or those in need.',
      shloka: 'अन्नदानं महादानम्',
      shlokaTranslation:
          '"Giving food is the greatest gift" — Taittiriya Upanishad',
    ),
    _DanaType(
      name: 'Abhaya Dana',
      nameHindi: 'अभय दान',
      icon: Icons.shield_outlined,
      color: Colors.green,
      shortDesc: 'Gift of Fearlessness',
      description:
          'Protecting others from fear, offering emotional support, '
          'standing up for the vulnerable, giving comfort to the anxious.',
      shloka: 'अभयं सर्वभूतानाम्',
      shlokaTranslation: '"Fearlessness towards all beings" — BG 10.4',
    ),
    _DanaType(
      name: 'Vastra Dana',
      nameHindi: 'वस्त्र दान',
      icon: Icons.checkroom_outlined,
      color: Colors.purple,
      shortDesc: 'Gift of Clothing / Material',
      description:
          'Donating clothes, blankets, or material resources to those in need. '
          'This includes any material giving — money, supplies, or possessions.',
      shloka: 'दातव्यमिति यद्दानम्',
      shlokaTranslation: '"That gift which is given as a duty" — BG 17.20',
    ),
    _DanaType(
      name: 'Shram Dana',
      nameHindi: 'श्रम दान',
      icon: Icons.construction_outlined,
      color: Colors.teal,
      shortDesc: 'Gift of Labour',
      description:
          'Offering your time, energy, and physical effort — volunteering, '
          'helping with chores, building something for the community.',
      shloka: 'कर्मण्येवाधिकारस्ते',
      shlokaTranslation: '"You have the right to work" — BG 2.47',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _cardAnimations = List.generate(_danaTypes.length, (i) {
      final start = i * 0.15;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });
    _staggerController.forward();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _completionScale = CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    );

    _outlinePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _outlinePulse = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ],
    ).animate(_outlinePulseController);
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _buttonController.dispose();
    _completionController.dispose();
    _outlinePulseController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _selectedTypeIndex != null && !_completed;

  void _showDanaInfoPopup(BuildContext context, int index) {
    final dana = _danaTypes[index];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dana.name,
              style: GoogleFonts.poppins(
                color: dana.color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dana.nameHindi,
              style: GoogleFonts.notoSerifDevanagari(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dana.shloka,
                style: GoogleFonts.notoSerifDevanagari(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                dana.shlokaTranslation,
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                dana.shortDesc,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dana.description,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_canSubmit) return;
    setState(() => _completed = true);
    _completionController.forward();
    widget.onComplete?.call();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: _completed ? _buildCompletion() : _buildMain(),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        // App bar
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
                'Dana — The Art of Giving',
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                // Short intro: Sanskrit + explanation of types (in a subtle card)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'श्रद्धया देयम्',
                        style: GoogleFonts.notoSerifDevanagari(
                          color: Colors.amber.shade200,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Give with faith and sincerity. Dana is giving with a pure heart. '
                        'The five main types are: Vidya (knowledge), Anna (food), '
                        'Abhaya (fearlessness), Vastra (clothing or material), and Shram (labour).',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose your Dana today',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.22,
                  ),
                  itemCount: _danaTypes.length,
                  itemBuilder: (context, index) {
                    final isHindi = ref.watch(languageProvider) == 'hi';
                    return AnimatedBuilder(
                      animation: _cardAnimations[index],
                      builder: (context, child) {
                        final value = _cardAnimations[index].value;
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value.clamp(0.0, 1.0))),
                            child: child,
                          ),
                        );
                      },
                      child: _buildDanaCard(index, isHindi),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Complete dana button (highlighted when a type is selected)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GestureDetector(
            onTapDown: _canSubmit
                ? (_) {
                    HapticFeedback.lightImpact();
                    _buttonController.forward();
                  }
                : null,
            onTapUp: _canSubmit
                ? (_) {
                    _buttonController.reverse();
                    _submit();
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
                          Colors.amber.shade700,
                          Colors.orange.shade700,
                        ])
                      : null,
                  color: _canSubmit ? null : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _canSubmit
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Complete Dana',
                  style: GoogleFonts.poppins(
                    color: _canSubmit ? Colors.white : Colors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDanaCard(int index, bool isHindi) {
    final dana = _danaTypes[index];
    final selected = _selectedTypeIndex == index;
    final displayName = isHindi ? dana.nameHindi : dana.name;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedTypeIndex = _selectedTypeIndex == index ? null : index;
        });
        if (index == _selectedTypeIndex) {
          _outlinePulseController.forward(from: 0);
        }
      },
      child: AnimatedBuilder(
        animation: _outlinePulse,
        builder: (context, child) {
          final pulse = selected ? _outlinePulse.value : 0.0;
          final borderWidth = selected ? 1.5 + (pulse * 1.0) : 1.0;
          final borderAlpha = selected ? 0.6 + (pulse * 0.25) : 0.15;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? [
                        dana.color.withValues(alpha: 0.35),
                        dana.color.withValues(alpha: 0.12),
                      ]
                    : [
                        dana.color.withValues(alpha: 0.12),
                        const Color(0xFF1A1D23),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dana.color.withValues(alpha: borderAlpha),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: dana.color
                      .withValues(alpha: (selected ? 0.2 : 0.08) + (pulse * 0.1)),
                  blurRadius: selected ? 12.0 + (pulse * 4) : 6,
                  spreadRadius: pulse * 0.5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? Icons.check_circle : dana.icon,
                          color: selected ? dana.color : Colors.white54,
                          size: selected ? 22 : 18,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          displayName,
                          style: isHindi
                              ? GoogleFonts.notoSerifDevanagari(
                                  color: selected ? dana.color : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                )
                              : GoogleFonts.poppins(
                                  color: selected ? dana.color : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dana.shloka,
                          style: GoogleFonts.notoSerifDevanagari(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _showDanaInfoPopup(context, index);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
                    Colors.amber.withValues(alpha: 0.3),
                    Colors.amber.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const Icon(Icons.card_giftcard,
                  color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Dana is Noted',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '"श्रद्धया देयम्"\nGive with faith and sincerity.',
              style: GoogleFonts.crimsonPro(
                color: Colors.amber.shade200,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Every act of Dana, no matter how small, purifies the heart '
              'and creates positive karma.',
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

class _DanaType {
  final String name;
  final String nameHindi;
  final IconData icon;
  final Color color;
  final String shortDesc;
  final String description;
  final String shloka;
  final String shlokaTranslation;

  const _DanaType({
    required this.name,
    required this.nameHindi,
    required this.icon,
    required this.color,
    required this.shortDesc,
    required this.description,
    required this.shloka,
    required this.shlokaTranslation,
  });
}
