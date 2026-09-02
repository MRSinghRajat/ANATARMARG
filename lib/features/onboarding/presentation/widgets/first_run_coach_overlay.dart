import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/app_intro_prefs.dart';
import '../../../navigation/presentation/providers/main_navigation_intent_provider.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

class MainTabTourStep {
  const MainTabTourStep({
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
    this.navigateTo,
  });

  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;
  final NavItem? navigateTo;
}

/// Ordered tour: bottom bar intro, then one stop per tab, then home wrap-up.
const List<MainTabTourStep> kMainTabTourSteps = [
  MainTabTourStep(
    titleEn: 'Your navigation bar',
    titleHi: 'आपकी नेविगेशन पट्टी',
    bodyEn:
        'Four tabs sit below. Each Next step opens one tab so you can see the real screen behind this card.',
    bodyHi:
        'नीचे चार टैब हैं। हर "आगे" पर एक टैब खुलेगा ताकि आप असली स्क्रीन देख सकें।',
  ),
  MainTabTourStep(
    titleEn: 'Aangan — your sacred home',
    titleHi: 'आँगन — आपका पवित्र घर',
    bodyEn:
        'Your daily return. Mandir, space to breathe, and karma from Ashram to decorate over time.',
    bodyHi:
        'रोज़ की जगह। मंदिर, शांति, और आश्रम के कर्म से धीरे-धीरे सजावट।',
    navigateTo: NavItem.home,
  ),
  MainTabTourStep(
    titleEn: 'Ashram — daily practice',
    titleHi: 'आश्रम — दैनिक अभ्यास',
    bodyEn:
        'Today’s small tasks and karma coins for your Aangan.',
    bodyHi:
        'आज के कार्य और आँगन के लिए कर्म सिक्के।',
    navigateTo: NavItem.ashram,
  ),
  MainTabTourStep(
    titleEn: 'Granthalaya — read and journey',
    titleHi: 'ग्रंथालय — पढ़ें और यात्रा करें',
    bodyEn:
        'Texts, stories, and journeys when you have a quiet moment. Listening is coming soon.',
    bodyHi:
        'ग्रंथ, कथाएँ, यात्राएँ — जब समय मिले। श्रवण शीघ्र आ रहा है।',
    navigateTo: NavItem.books,
  ),
  MainTabTourStep(
    titleEn: 'Profile — your settings',
    titleHi: 'प्रोफ़ाइल — सेटिंग',
    bodyEn:
        'Language, notifications, account — replay this tour here anytime.',
    bodyHi:
        'भाषा, सूचनाएँ, खाता — यह दौरा यहीं से दोबारा।',
    navigateTo: NavItem.profile,
  ),
  MainTabTourStep(
    titleEn: 'You are ready',
    titleHi: 'आप तैयार हैं',
    bodyEn:
        'Explore freely. Namaste.',
    bodyHi:
        'अपनी गति से। नमस्ते।',
    navigateTo: NavItem.home,
  ),
];

/// Full tab tour after first entry to the main shell (skippable). Not part of pre-login onboarding.
class FirstRunCoachOverlay {
  FirstRunCoachOverlay._();

  static OverlayEntry? _active;

  static Future<void> showIfNeeded({
    required BuildContext context,
    required GlobalKey bottomNavKey,
    required void Function(NavItem item) onNavigate,
    required bool hindi,
    bool force = false,
  }) async {
    if (!force && !await AppIntroPrefs.shouldShowPostLoginTabTour()) return;
    if (!context.mounted) return;
    if (_active != null) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _FirstRunCoachLayer(
        bottomNavKey: bottomNavKey,
        onNavigate: onNavigate,
        hindi: hindi,
        onFinished: () {
          _active = null;
          entry.remove();
        },
      ),
    );
    _active = entry;
    overlay.insert(entry);
  }

  static Future<void> showForced({
    required BuildContext context,
    required GlobalKey bottomNavKey,
    required void Function(NavItem item) onNavigate,
    required bool hindi,
  }) {
    return showIfNeeded(
      context: context,
      bottomNavKey: bottomNavKey,
      onNavigate: onNavigate,
      hindi: hindi,
      force: true,
    );
  }
}

class _FirstRunCoachLayer extends ConsumerStatefulWidget {
  const _FirstRunCoachLayer({
    required this.bottomNavKey,
    required this.onNavigate,
    required this.hindi,
    required this.onFinished,
  });

  final GlobalKey bottomNavKey;
  final void Function(NavItem item) onNavigate;
  final bool hindi;
  final VoidCallback onFinished;

  @override
  ConsumerState<_FirstRunCoachLayer> createState() => _FirstRunCoachLayerState();
}

class _FirstRunCoachLayerState extends ConsumerState<_FirstRunCoachLayer> {
  int _step = 0;
  Rect? _navRect;

  static const Color _bgDeep = Color(0xFF0B1623);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _lightGold = Color(0xFFF4E4B6);

  List<MainTabTourStep> get _steps => kMainTabTourSteps;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureNav();
      ref.read(tabTourHighlightProvider.notifier).state =
          _steps[_step].navigateTo;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureNav());
    });
  }

  @override
  void dispose() {
    try {
      ref.read(tabTourHighlightProvider.notifier).state = null;
    } catch (_) {}
    super.dispose();
  }

  void _measureNav() {
    final box =
        widget.bottomNavKey.currentContext?.findRenderObject() as RenderBox?;
    if (!mounted || box == null || !box.hasSize) return;
    final topLeft = box.localToGlobal(Offset.zero);
    setState(() {
      _navRect = topLeft & box.size;
    });
  }

  Future<void> _complete() async {
    ref.read(tabTourHighlightProvider.notifier).state = null;
    await AppIntroPrefs.markCoachDone();
    if (!mounted) return;
    widget.onFinished();
  }

  void _skip() {
    _complete();
  }

  void _next() {
    final steps = _steps;
    if (_step >= steps.length - 1) {
      _complete();
      return;
    }
    setState(() => _step++);
    final nav = steps[_step].navigateTo;
    if (nav != null) {
      widget.onNavigate(nav);
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureNav());
    }
    ref.read(tabTourHighlightProvider.notifier).state = steps[_step].navigateTo;
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final step = steps[_step];
    final title = widget.hindi ? step.titleHi : step.titleEn;
    final body = widget.hindi ? step.bodyHi : step.bodyEn;
    final skip = widget.hindi ? 'छोड़ें' : 'Skip tour';
    final next = widget.hindi
        ? (_step >= steps.length - 1 ? 'शुरू करें' : 'आगे')
        : (_step >= steps.length - 1 ? 'Start exploring' : 'Next');
    final progress = '${_step + 1} / ${steps.length}';

    final pad = MediaQuery.paddingOf(context);
    final screenH = MediaQuery.sizeOf(context).height;
    /// Gap between tour card and top edge of bottom bar.
    const gapAboveNav = 8.0;
    final cardBottomOffset = _navRect != null
        ? screenH - _navRect!.top + gapAboveNav
        : pad.bottom + 72 + gapAboveNav;
    const maxCardWidth = 320.0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CoachScrimPainter(
                cutout: _navRect?.inflate(8),
                scrim: Colors.black.withValues(alpha: 0.38),
              ),
            ),
          ),
          if (_navRect != null)
            Positioned(
              left: _navRect!.left,
              top: _navRect!.top,
              width: _navRect!.width,
              height: _navRect!.height,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: cardBottomOffset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxCardWidth),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: _TourGlassCard(
                      key: ValueKey<int>(_step),
                      progress: progress,
                      title: title,
                      body: body,
                      skipLabel: skip,
                      nextLabel: next,
                      lightGold: _lightGold,
                      gold: _gold,
                      bgDeep: _bgDeep,
                      onSkip: _skip,
                      onNext: _next,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourGlassCard extends StatelessWidget {
  const _TourGlassCard({
    super.key,
    required this.progress,
    required this.title,
    required this.body,
    required this.skipLabel,
    required this.nextLabel,
    required this.lightGold,
    required this.gold,
    required this.bgDeep,
    required this.onSkip,
    required this.onNext,
  });

  final String progress;
  final String title;
  final String body;
  final String skipLabel;
  final String nextLabel;
  final Color lightGold;
  final Color gold;
  final Color bgDeep;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgDeep.withValues(alpha: 0.52),
                const Color(0xFF1A2837).withValues(alpha: 0.42),
              ],
            ),
            border: Border.all(color: gold.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    progress,
                    style: GoogleFonts.tenorSans(
                      fontSize: 10,
                      color: gold.withValues(alpha: 0.9),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      skipLabel,
                      style: GoogleFonts.tenorSans(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              _TourGradientTitle(
                text: title,
                lightGold: lightGold,
                gold: gold,
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 52,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    body,
                    style: GoogleFonts.tenorSans(
                      fontSize: 12,
                      height: 1.38,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: bgDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onNext,
                  child: Text(
                    nextLabel,
                    style: GoogleFonts.tenorSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourGradientTitle extends StatefulWidget {
  const _TourGradientTitle({
    required this.text,
    required this.lightGold,
    required this.gold,
  });

  final String text;
  final Color lightGold;
  final Color gold;

  @override
  State<_TourGradientTitle> createState() => _TourGradientTitleState();
}

class _TourGradientTitleState extends State<_TourGradientTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 0.5;
      } else {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.lightGold,
                widget.gold,
                const Color(0xFFFFE8A8),
                widget.gold,
                widget.lightGold,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              begin: Alignment(-1.2 + 2.4 * t, 0),
              end: Alignment(-0.2 + 2.4 * t, 0),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.12,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _CoachScrimPainter extends CustomPainter {
  _CoachScrimPainter({required this.cutout, required this.scrim});

  final Rect? cutout;
  final Color scrim;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    if (cutout != null) {
      final hole = Path()
        ..addRRect(
          RRect.fromRectAndRadius(cutout!, const Radius.circular(16)),
        );
      final p = Path.combine(PathOperation.difference, full, hole);
      canvas.drawPath(p, Paint()..color = scrim);
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = scrim);
    }
  }

  @override
  bool shouldRepaint(covariant _CoachScrimPainter oldDelegate) =>
      oldDelegate.cutout != cutout || oldDelegate.scrim != scrim;
}
