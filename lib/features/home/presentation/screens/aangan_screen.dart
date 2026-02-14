import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../sanctuary/data/models/sanctuary_customization_model.dart';
import '../../../sanctuary/data/services/sanctuary_customization_service.dart';
import '../../../sanctuary/presentation/widgets/customizable_om_sanctuary.dart';
import '../../../sanctuary/presentation/widgets/sanctuary_shop_sheet.dart';

/// Redesigned Aangan Screen with Customizable Om Sanctuary
/// Features:
/// - Top 40%: Customizable Om Sanctuary with live preview
/// - Bottom 60%: Draggable shop UI for purchasing customizations
/// - One-way sync to Ashram screen
class AanganScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBeginTap;

  const AanganScreen({
    super.key,
    this.onBeginTap,
  });

  @override
  ConsumerState<AanganScreen> createState() => _AanganScreenState();
}

class _AanganScreenState extends ConsumerState<AanganScreen>
    with TickerProviderStateMixin {
  final CoinService _coinService = CoinService();
  final SanctuaryCustomizationService _customizationService =
      SanctuaryCustomizationService();
  // Avatar repository removed — stats shown in Profile tab only

  // The actual applied customization (nullable until loaded)
  SanctuaryCustomization? _appliedCustomization;
  // The preview customization (shown while browsing items)
  SanctuaryCustomization? _previewCustomization;
  // Whether we're in preview mode
  bool _isPreviewMode = false;
  // Stream subscription
  StreamSubscription<SanctuaryCustomization>? _customizationSubscription;
  // Loading state
  bool _customizationLoaded = false;

  SanctuaryCustomization get _displayCustomization =>
      _previewCustomization ??
      _appliedCustomization ??
      SanctuaryCustomization.defaultConfig;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _customizationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _coinService.initialize();

    // Cancel any existing subscription
    await _customizationSubscription?.cancel();

    // Subscribe to customization changes BEFORE initializing
    _customizationSubscription =
        _customizationService.customizationStream.listen((customization) {
      if (mounted) {
        setState(() {
          _appliedCustomization = customization;
          _customizationLoaded = true;
          // Clear preview when a new customization is applied
          _previewCustomization = null;
          _isPreviewMode = false;
        });
      }
    });

    // Wait for service to fully initialize (loads from Supabase)
    await _customizationService.ensureInitialized();

    // Set initial customization immediately
    if (mounted) {
      setState(() {
        _appliedCustomization = _customizationService.currentCustomization;
        _customizationLoaded = true;
      });
    }
  }

  void _onPreviewChange(SanctuaryCustomization preview) {
    setState(() {
      _previewCustomization = preview;
      _isPreviewMode = true;
    });
  }

  void _onPreviewClear() {
    setState(() {
      _previewCustomization = null;
      _isPreviewMode = false;
    });
  }

  void _onApplied(SanctuaryCustomization applied) {
    setState(() {
      _appliedCustomization = applied;
      _previewCustomization = null;
      _isPreviewMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight * 0.55; // 55% for sanctuary area — pushed down

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 0: Deep aurora / nebula background
            const Positioned.fill(child: _AuroraBackground()),

            // Layer 1: Animated sacred geometry grid
            const Positioned.fill(child: _AnimatedGeometryOverlay()),

            // Layer 2: Floating ambient particles (golden dust)
            const Positioned.fill(child: _AmbientParticles()),

            // Layer 3: Floating lotus petals
            const Positioned.fill(child: _FloatingLotusPetals()),

            // Top Section: Om Sanctuary + Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topHeight,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Header with stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHeader(),
                  ),

                  const SizedBox(height: 24),

                  // Om Sanctuary with god rays + pulse + touch ripple
                  Expanded(
                    child: _TouchRippleLayer(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // God rays behind the Om
                          const _GodRays(),

                          // Energy pulse waves
                          const _EnergyPulseWaves(),

                          // Om Sanctuary
                          if (_customizationLoaded)
                            CustomizableOmSanctuary(
                              size: 280,
                              customization: _displayCustomization,
                            ),

                          // Preview indicator
                          if (_isPreviewMode)
                            Positioned(
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9933)
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.visibility,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PREVIEW MODE',
                                      style: GoogleFonts.tenorSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Tagline
                  _buildTagline(),

                  const SizedBox(height: 6),
                ],
              ),
            ),

            // Bottom Section: Customization Shop Sheet
            Positioned.fill(
              child: NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) => false,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.40,
                  minChildSize: 0.12,
                  maxChildSize: 0.95,
                  snap: true,
                  snapSizes: const [0.12, 0.40, 0.65, 0.95],
                  builder: (context, scrollController) {
                    return SanctuaryShopSheet(
                      scrollController: scrollController,
                      onPreviewChange: _onPreviewChange,
                      onPreviewClear: _onPreviewClear,
                      onApplied: _onApplied,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<int>(
      stream: _coinService.coinStream,
      initialData: _coinService.currentBalance,
      builder: (context, coinSnapshot) {
        final coins = coinSnapshot.data ?? 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Only diamond balance
            _buildStatBubble('$coins', '💎'),
          ],
        );
      },
    );
  }

  Widget _buildStatBubble(String value, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2837).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.tenorSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: const Color(0xFFF4E4B6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Column(
      children: [
        Text(
          'YOUR SANCTUARY',
          style: GoogleFonts.tenorSans(
            fontSize: 11,
            letterSpacing: 3,
            color: const Color(0xFFF4E4B6).withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF4E4B6), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: Text(
            'Make it uniquely yours',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 0: AURORA / NEBULA BACKGROUND — Mesmerizing color-shifting backdrop
// ═══════════════════════════════════════════════════════════════════════════

class _AuroraBackground extends StatefulWidget {
  const _AuroraBackground();

  @override
  State<_AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<_AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AuroraPainter(progress: _ctrl.value),
          );
        },
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  _AuroraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.35;
    final t = progress * 2 * pi;

    // Nebula cloud 1 — deep indigo, shifts position slowly
    final offset1 = Offset(cx + sin(t) * 60, cy + cos(t * 0.7) * 40);
    final gradient1 = ui.Gradient.radial(
      offset1,
      size.width * 0.55,
      [
        const Color(0xFF1B0A3C).withOpacity(0.6),
        const Color(0xFF0D1B2A).withOpacity(0.0),
      ],
    );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..shader = gradient1
          ..blendMode = BlendMode.screen);

    // Nebula cloud 2 — warm saffron glow behind Om area
    final offset2 = Offset(cx + cos(t * 0.5) * 40, cy + sin(t * 0.3) * 30);
    final gradient2 = ui.Gradient.radial(
      offset2,
      size.width * 0.4,
      [
        const Color(0xFFD4AF37).withOpacity(0.06),
        const Color(0xFF0B1623).withOpacity(0.0),
      ],
    );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = gradient2);

    // Nebula cloud 3 — subtle teal accent, opposite motion
    final offset3 =
        Offset(cx + cos(t * 0.8 + 2) * 80, cy + sin(t * 0.6 + 1) * 50);
    final gradient3 = ui.Gradient.radial(
      offset3,
      size.width * 0.35,
      [
        const Color(0xFF0A4D68).withOpacity(0.15),
        const Color(0xFF0B1623).withOpacity(0.0),
      ],
    );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..shader = gradient3
          ..blendMode = BlendMode.screen);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 1: ANIMATED SACRED GEOMETRY — Slowly rotating golden grid
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedGeometryOverlay extends StatefulWidget {
  const _AnimatedGeometryOverlay();

  @override
  State<_AnimatedGeometryOverlay> createState() =>
      _AnimatedGeometryOverlayState();
}

class _AnimatedGeometryOverlayState extends State<_AnimatedGeometryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // Very slow rotation
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AnimatedGeometryPainter(
              rotation: _ctrl.value * 2 * pi,
              pulse: (sin(_ctrl.value * 2 * pi * 3) + 1) / 2,
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedGeometryPainter extends CustomPainter {
  final double rotation;
  final double pulse; // 0..1

  _AnimatedGeometryPainter({required this.rotation, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.35;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation * 0.1); // Very subtle rotation
    canvas.translate(-cx, -cy);

    // Diagonal lines — subtle golden grid
    final opacity = 0.02 + pulse * 0.015; // Pulses between 2% and 3.5%
    final paint = Paint()
      ..color = Color.fromRGBO(212, 175, 55, opacity)
      ..strokeWidth = 0.8;

    const spacing = 70.0;
    for (var i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }

    canvas.restore();

    // Concentric sacred circles around the Om area
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < 4; i++) {
      final radius = 100.0 + i * 50 + pulse * 8;
      circlePaint.color =
          Color.fromRGBO(212, 175, 55, 0.04 - i * 0.008);
      canvas.drawCircle(Offset(cx, cy), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedGeometryPainter old) =>
      old.rotation != rotation || old.pulse != pulse;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 2: AMBIENT GOLDEN PARTICLES — Floating dust motes across screen
// ═══════════════════════════════════════════════════════════════════════════

class _AmbientParticles extends StatefulWidget {
  const _AmbientParticles();

  @override
  State<_AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<_AmbientParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_DustParticle> _particles;
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(35, (_) => _DustParticle(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AmbientParticlePainter(
              particles: _particles,
              time: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _DustParticle {
  late double x, y, speed, size, phase, wobbleAmp, wobbleFreq;
  late double opacity;

  _DustParticle(Random rng) {
    x = rng.nextDouble();
    y = rng.nextDouble();
    speed = 0.02 + rng.nextDouble() * 0.04;
    size = 1.0 + rng.nextDouble() * 2.5;
    phase = rng.nextDouble() * 2 * pi;
    wobbleAmp = 0.005 + rng.nextDouble() * 0.015;
    wobbleFreq = 1 + rng.nextDouble() * 2;
    opacity = 0.15 + rng.nextDouble() * 0.4;
  }
}

class _AmbientParticlePainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double time;

  _AmbientParticlePainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = time * 2 * pi;
      // Move upward slowly, wrap around
      final py = (p.y - time * p.speed) % 1.0;
      final px = p.x + sin(t * p.wobbleFreq + p.phase) * p.wobbleAmp;

      // Fade near edges
      final edgeFade = (py < 0.1 ? py / 0.1 : py > 0.9 ? (1 - py) / 0.1 : 1.0);
      final alpha = p.opacity * edgeFade * (0.7 + 0.3 * sin(t * 0.5 + p.phase));

      final paint = Paint()
        ..color = Color.fromRGBO(244, 228, 182, alpha.clamp(0.0, 1.0));

      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        p.size,
        paint,
      );

      // Tiny glow around larger particles
      if (p.size > 2) {
        paint.color = Color.fromRGBO(212, 175, 55, (alpha * 0.3).clamp(0.0, 1.0));
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(
          Offset(px * size.width, py * size.height),
          p.size * 1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlePainter old) =>
      old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 3: FLOATING LOTUS PETALS — Delicate petals drifting across screen
// ═══════════════════════════════════════════════════════════════════════════

class _FloatingLotusPetals extends StatefulWidget {
  const _FloatingLotusPetals();

  @override
  State<_FloatingLotusPetals> createState() => _FloatingLotusPetalsState();
}

class _FloatingLotusPetalsState extends State<_FloatingLotusPetals>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_LotusPetal> _petals;
  final _rng = Random(99);

  @override
  void initState() {
    super.initState();
    _petals = List.generate(8, (_) => _LotusPetal(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _LotusPetalPainter(
              petals: _petals,
              time: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _LotusPetal {
  late double x, y, speed, rotSpeed, size, phase;

  _LotusPetal(Random rng) {
    x = rng.nextDouble();
    y = rng.nextDouble();
    speed = 0.015 + rng.nextDouble() * 0.03;
    rotSpeed = 0.5 + rng.nextDouble() * 1.5;
    size = 6 + rng.nextDouble() * 8;
    phase = rng.nextDouble() * 2 * pi;
  }
}

class _LotusPetalPainter extends CustomPainter {
  final List<_LotusPetal> petals;
  final double time;

  _LotusPetalPainter({required this.petals, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final t = time * 2 * pi;

      // Drift downward with gentle side-to-side sway
      final py = (p.y + time * p.speed) % 1.2 - 0.1;
      final px = p.x + sin(t * 0.3 + p.phase) * 0.04;

      // Fade in/out at edges
      final fade = py < 0
          ? 0.0
          : py > 1
              ? 0.0
              : (py < 0.1 ? py / 0.1 : py > 0.9 ? (1 - py) / 0.1 : 1.0);

      if (fade <= 0) continue;

      canvas.save();
      canvas.translate(px * size.width, py * size.height);
      canvas.rotate(t * p.rotSpeed + p.phase);

      // Draw a petal shape (two quadratic beziers)
      final petalPath = Path();
      final s = p.size;
      petalPath.moveTo(0, -s);
      petalPath.quadraticBezierTo(s * 0.6, -s * 0.3, 0, s * 0.5);
      petalPath.quadraticBezierTo(-s * 0.6, -s * 0.3, 0, -s);
      petalPath.close();

      final paint = Paint()
        ..color = Color.fromRGBO(255, 200, 160, 0.08 * fade)
        ..style = PaintingStyle.fill;

      canvas.drawPath(petalPath, paint);

      // Subtle petal outline
      paint
        ..color = Color.fromRGBO(212, 175, 55, 0.12 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawPath(petalPath, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LotusPetalPainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// GOD RAYS — Volumetric light rays emanating from behind the Om
// ═══════════════════════════════════════════════════════════════════════════

class _GodRays extends StatefulWidget {
  const _GodRays();

  @override
  State<_GodRays> createState() => _GodRaysState();
}

class _GodRaysState extends State<_GodRays>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _GodRaysPainter(time: _ctrl.value),
          );
        },
      ),
    );
  }
}

class _GodRaysPainter extends CustomPainter {
  final double time;
  _GodRaysPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final t = time * 2 * pi;
    final maxRadius = size.width * 0.8;

    // Draw 12 light rays rotating slowly
    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi + t * 0.2;
      final rayOpacity = 0.025 + 0.015 * sin(t * 2 + i * 0.8);
      final rayWidth = 0.08 + 0.03 * sin(t + i * 1.2);

      final path = Path();
      path.moveTo(cx, cy);
      path.lineTo(
        cx + cos(angle - rayWidth) * maxRadius,
        cy + sin(angle - rayWidth) * maxRadius,
      );
      path.lineTo(
        cx + cos(angle + rayWidth) * maxRadius,
        cy + sin(angle + rayWidth) * maxRadius,
      );
      path.close();

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          maxRadius,
          [
            Color.fromRGBO(244, 228, 182, rayOpacity),
            Color.fromRGBO(212, 175, 55, 0),
          ],
          [0.0, 1.0],
        );

      canvas.drawPath(path, paint);
    }

    // Central glow
    final glowIntensity = 0.08 + 0.04 * sin(t * 1.5);
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        80,
        [
          Color.fromRGBO(244, 228, 182, glowIntensity),
          Color.fromRGBO(212, 175, 55, 0),
        ],
      );
    canvas.drawCircle(Offset(cx, cy), 80, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GodRaysPainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// ENERGY PULSE WAVES — Concentric rings expanding from center
// ═══════════════════════════════════════════════════════════════════════════

class _EnergyPulseWaves extends StatefulWidget {
  const _EnergyPulseWaves();

  @override
  State<_EnergyPulseWaves> createState() => _EnergyPulseWavesState();
}

class _EnergyPulseWavesState extends State<_EnergyPulseWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _EnergyPulsePainter(time: _ctrl.value),
          );
        },
      ),
    );
  }
}

class _EnergyPulsePainter extends CustomPainter {
  final double time;
  _EnergyPulsePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.5;

    // 3 staggered expanding rings
    for (var i = 0; i < 3; i++) {
      final phase = (time + i / 3.0) % 1.0;
      final radius = phase * maxR;
      final opacity = (1 - phase) * 0.07;

      if (opacity <= 0) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * (1 - phase)
        ..color = Color.fromRGBO(212, 175, 55, opacity);

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyPulsePainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// TOUCH RIPPLE LAYER — Sparkle burst on tap
// ═══════════════════════════════════════════════════════════════════════════

class _TouchRippleLayer extends StatefulWidget {
  final Widget child;
  const _TouchRippleLayer({required this.child});

  @override
  State<_TouchRippleLayer> createState() => _TouchRippleLayerState();
}

class _TouchRippleLayerState extends State<_TouchRippleLayer>
    with TickerProviderStateMixin {
  final List<_RippleData> _ripples = [];

  void _addRipple(Offset position) {
    HapticFeedback.lightImpact();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final ripple = _RippleData(
      position: position,
      controller: ctrl,
      sparkleCount: 8 + Random().nextInt(6),
      sparkleAngles: List.generate(14, (i) => Random().nextDouble() * 2 * pi),
      sparkleSpeeds: List.generate(14, (i) => 30.0 + Random().nextDouble() * 60),
    );
    setState(() => _ripples.add(ripple));
    ctrl.forward().then((_) {
      ctrl.dispose();
      if (mounted) setState(() => _ripples.remove(ripple));
    });
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) => _addRipple(details.localPosition),
      child: Stack(
        children: [
          widget.child,
          if (_ripples.isNotEmpty)
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: Listenable.merge(
                      _ripples.map((r) => r.controller).toList()),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _TouchRipplePainter(ripples: _ripples),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RippleData {
  final Offset position;
  final AnimationController controller;
  final int sparkleCount;
  final List<double> sparkleAngles;
  final List<double> sparkleSpeeds;

  _RippleData({
    required this.position,
    required this.controller,
    required this.sparkleCount,
    required this.sparkleAngles,
    required this.sparkleSpeeds,
  });
}

class _TouchRipplePainter extends CustomPainter {
  final List<_RippleData> ripples;
  _TouchRipplePainter({required this.ripples});

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in ripples) {
      final t = r.controller.value;
      final pos = r.position;

      // Expanding ring
      final ringOpacity = (1 - t) * 0.3;
      if (ringOpacity > 0) {
        canvas.drawCircle(
          pos,
          t * 80,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * (1 - t)
            ..color = Color.fromRGBO(244, 228, 182, ringOpacity),
        );
        // Second ring delayed
        if (t > 0.15) {
          final t2 = (t - 0.15) / 0.85;
          canvas.drawCircle(
            pos,
            t2 * 60,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5 * (1 - t2)
              ..color = Color.fromRGBO(212, 175, 55, (1 - t2) * 0.2),
          );
        }
      }

      // Sparkle particles bursting outward
      for (var i = 0; i < r.sparkleCount; i++) {
        final angle = r.sparkleAngles[i];
        final speed = r.sparkleSpeeds[i];
        final sparkleT = Curves.easeOut.transform(t);
        final sx = pos.dx + cos(angle) * speed * sparkleT;
        final sy = pos.dy + sin(angle) * speed * sparkleT;
        final sparkleOpacity = (1 - t) * 0.6;
        final sparkleSize = (1 - t) * 2.5;

        if (sparkleOpacity > 0) {
          canvas.drawCircle(
            Offset(sx, sy),
            sparkleSize,
            Paint()..color = Color.fromRGBO(244, 228, 182, sparkleOpacity),
          );

          // Tiny glow
          canvas.drawCircle(
            Offset(sx, sy),
            sparkleSize * 2,
            Paint()
              ..color = Color.fromRGBO(212, 175, 55, sparkleOpacity * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      }

      // Central flash
      if (t < 0.3) {
        final flashT = t / 0.3;
        canvas.drawCircle(
          pos,
          12 * (1 - flashT),
          Paint()
            ..color = Color.fromRGBO(255, 255, 240, (1 - flashT) * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TouchRipplePainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
