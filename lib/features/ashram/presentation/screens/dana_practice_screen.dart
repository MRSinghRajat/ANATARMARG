import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DanaPracticeScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const DanaPracticeScreen({super.key, this.onComplete});

  @override
  State<DanaPracticeScreen> createState() => _DanaPracticeScreenState();
}

class _DanaPracticeScreenState extends State<DanaPracticeScreen>
    with TickerProviderStateMixin {
  int? _selectedTypeIndex;
  final _descriptionController = TextEditingController();
  bool _completed = false;

  late final AnimationController _staggerController;
  late final AnimationController _buttonController;
  late final AnimationController _completionController;
  late final List<Animation<double>> _cardAnimations;
  late final Animation<double> _buttonScale;
  late final Animation<double> _completionScale;

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
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _buttonController.dispose();
    _completionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _descriptionController.text.trim().isNotEmpty && !_completed;

  void _showDanaDetail(int index) {
    final dana = _danaTypes[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1D23),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: dana.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(dana.icon, color: dana.color, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              dana.name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dana.nameHindi,
              style: GoogleFonts.notoSerifDevanagari(
                color: dana.color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              dana.description,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dana.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dana.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    dana.shloka,
                    style: GoogleFonts.notoSerifDevanagari(
                      color: dana.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dana.shlokaTranslation,
                    style: GoogleFonts.crimsonPro(
                      color: Colors.white54,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _selectedTypeIndex = index);
                },
                child: Text(
                  'I practiced this today',
                  style: GoogleFonts.poppins(
                    color: dana.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_canSubmit) return;
    setState(() => _completed = true);
    _completionController.forward();
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Dharmic intro with fade-in
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
                          Colors.amber.withValues(alpha: 0.15),
                          Colors.orange.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'दानं भोगो नाशस्तिस्रो गतयो भवन्ति वित्तस्य',
                          style: GoogleFonts.notoSerifDevanagari(
                            color: Colors.amber.shade200,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"Wealth has three destinations: charity, enjoyment, or destruction.\n'
                          'That which is not given or enjoyed is simply destroyed."',
                          style: GoogleFonts.crimsonPro(
                            color: Colors.white70,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dana is not just about money. In Sanatana Dharma, giving takes many forms — '
                          'knowledge, food, protection, material, and labor. Each type of Dana purifies '
                          'the giver and serves the world.',
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
                  '5 Types of Dana',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a type to learn more. Select what you practiced.',
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Staggered grid of Dana types
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: _danaTypes.length,
                  itemBuilder: (context, index) {
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
                      child: _buildDanaCard(index),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Description field
                Text(
                  'What did you give today?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  minLines: 3,
                  onChanged: (_) => setState(() {}),
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5),
                  cursorColor: Colors.amber,
                  decoration: InputDecoration(
                    hintText: 'Describe your act of giving...',
                    hintStyle: GoogleFonts.poppins(
                        color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF1A1D23),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Animated complete button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: GestureDetector(
            onTapDown: _canSubmit ? (_) => _buttonController.forward() : null,
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

  Widget _buildDanaCard(int index) {
    final dana = _danaTypes[index];
    final selected = _selectedTypeIndex == index;

    return GestureDetector(
      onTap: () => _showDanaDetail(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? dana.color.withValues(alpha: 0.15)
              : const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? dana.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: dana.color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: selected ? 38 : 34,
              height: selected ? 38 : 34,
              decoration: BoxDecoration(
                color: (selected ? dana.color : Colors.white24)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                selected ? Icons.check_circle : dana.icon,
                color: selected ? dana.color : Colors.white54,
                size: selected ? 22 : 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dana.name,
              style: GoogleFonts.poppins(
                color: selected ? dana.color : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              dana.shortDesc,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
