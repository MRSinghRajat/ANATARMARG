import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/sanctuary_customization_model.dart';
import '../../data/services/sanctuary_customization_service.dart';

/// A fully customizable Om Sanctuary widget.
/// Used in both Aangan (customization mode) and Ashram (display mode).
class CustomizableOmSanctuary extends StatefulWidget {
  final double size;
  final SanctuaryCustomization? customization;
  final bool showPreview; // If true, shows preview mode (used in shop)
  
  const CustomizableOmSanctuary({
    super.key,
    this.size = 340,
    this.customization,
    this.showPreview = false,
  });

  @override
  State<CustomizableOmSanctuary> createState() => _CustomizableOmSanctuaryState();
}

class _CustomizableOmSanctuaryState extends State<CustomizableOmSanctuary>
    with TickerProviderStateMixin {
  static const String _om = 'ॐ';
  
  late AnimationController _ringController1;
  late AnimationController _ringController2;
  late AnimationController _ringController3;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _breatheController;
  
  final SanctuaryCustomizationService _customizationService = SanctuaryCustomizationService();
  late SanctuaryCustomization _customization;

  @override
  void initState() {
    super.initState();
    _customization = widget.customization ?? 
        _customizationService.currentCustomization;
    
    // Initialize animation controllers based on animation style
    _initializeAnimations();
    
    // Listen to customization changes
    if (widget.customization == null) {
      _customizationService.customizationStream.listen((customization) {
        if (mounted) {
          setState(() {
            _customization = customization;
            _updateAnimationSpeeds();
          });
        }
      });
    }
  }

  void _initializeAnimations() {
    // Ring rotation controllers
    _ringController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    
    _ringController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();
    
    _ringController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    
    // Glow pulse controller
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Particle controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    
    // Breathe controller
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _updateAnimationSpeeds();
  }

  void _updateAnimationSpeeds() {
    // Adjust animation speeds based on animation style
    switch (_customization.animationStyle) {
      case SanctuaryAnimationStyle.gentle:
        _ringController1.duration = const Duration(seconds: 60);
        _ringController2.duration = const Duration(seconds: 45);
        _glowController.duration = const Duration(seconds: 3);
        _breatheController.duration = const Duration(seconds: 4);
        break;
      case SanctuaryAnimationStyle.pulse:
        _ringController1.duration = const Duration(seconds: 40);
        _ringController2.duration = const Duration(seconds: 30);
        _glowController.duration = const Duration(seconds: 1);
        _breatheController.duration = const Duration(seconds: 2);
        break;
      case SanctuaryAnimationStyle.breathe:
        _ringController1.duration = const Duration(seconds: 80);
        _ringController2.duration = const Duration(seconds: 60);
        _glowController.duration = const Duration(seconds: 4);
        _breatheController.duration = const Duration(seconds: 6);
        break;
      case SanctuaryAnimationStyle.meditative:
        _ringController1.duration = const Duration(seconds: 120);
        _ringController2.duration = const Duration(seconds: 90);
        _glowController.duration = const Duration(seconds: 5);
        _breatheController.duration = const Duration(seconds: 8);
        break;
      case SanctuaryAnimationStyle.energetic:
        _ringController1.duration = const Duration(seconds: 20);
        _ringController2.duration = const Duration(seconds: 15);
        _glowController.duration = const Duration(milliseconds: 800);
        _breatheController.duration = const Duration(seconds: 1);
        break;
      case SanctuaryAnimationStyle.particles:
        _ringController1.duration = const Duration(seconds: 50);
        _ringController2.duration = const Duration(seconds: 40);
        _glowController.duration = const Duration(seconds: 2);
        _particleController.duration = const Duration(seconds: 3);
        break;
      case SanctuaryAnimationStyle.stillness:
        _ringController1.stop();
        _ringController2.stop();
        _ringController3.stop();
        _glowController.stop();
        _particleController.stop();
        _breatheController.stop();
        return;
    }
    
    // Restart animations with new durations
    if (_customization.animationStyle != SanctuaryAnimationStyle.stillness) {
      if (!_ringController1.isAnimating) _ringController1.repeat();
      if (!_ringController2.isAnimating) _ringController2.repeat();
      if (!_glowController.isAnimating) _glowController.repeat();
      if (!_particleController.isAnimating) _particleController.repeat();
      if (!_breatheController.isAnimating) _breatheController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CustomizableOmSanctuary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customization != oldWidget.customization && widget.customization != null) {
      setState(() {
        _customization = widget.customization!;
        _updateAnimationSpeeds();
      });
    }
  }

  @override
  void dispose() {
    _ringController1.dispose();
    _ringController2.dispose();
    _ringController3.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background
          if (_customization.backgroundStyle != BackgroundStyle.plain)
            Positioned.fill(
              child: _buildBackground(),
            ),
          
          // Particles layer (new particle system)
          if (_customization.particleStyle != ParticleStyle.none)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ParticleSystemPainter(
                    progress: _particleController.value,
                    style: _customization.particleStyle,
                    color: _customization.glowColor.color,
                  ),
                );
              },
            ),
          
          // Legacy particles (if animation style is particles)
          if (_customization.animationStyle == SanctuaryAnimationStyle.particles)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ParticlesPainter(
                    progress: _particleController.value,
                    color: _customization.ringColor.primaryColor,
                  ),
                );
              },
            ),
          
          // Frame style (behind rings)
          if (_customization.frameStyle != FrameStyle.none)
            _buildFrame(),
          
          // Special effects (behind rings)
          if (_customization.specialEffect != SpecialEffect.none)
            _buildSpecialEffect(),
          
          // Rings
          _buildRings(),
          
          // Center content (Om or Deity)
          _buildCenterContent(),
          
          // Special effects overlay (in front of everything)
          if (_customization.specialEffect != SpecialEffect.none)
            _buildSpecialEffectOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    switch (_customization.backgroundStyle) {
      case BackgroundStyle.geometricLines:
        return CustomPaint(
          painter: _GeometricLinesPainter(
            color: _customization.ringColor.primaryColor,
            opacity: 0.05,
          ),
        );
      case BackgroundStyle.stars:
        return AnimatedBuilder(
          animation: _glowController,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarfieldPainter(
                progress: _glowController.value,
                color: _customization.ringColor.primaryColor,
              ),
            );
          },
        );
      case BackgroundStyle.lotusPattern:
        return CustomPaint(
          painter: _LotusPatternPainter(
            color: _customization.ringColor.primaryColor,
          ),
        );
      case BackgroundStyle.cosmicGradient:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _customization.ringColor.primaryColor.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        );
      case BackgroundStyle.templeArch:
        return CustomPaint(
          painter: _TempleArchPainter(
            color: _customization.ringColor.primaryColor,
          ),
        );
      case BackgroundStyle.sacredGeometry:
        return CustomPaint(
          painter: _SacredGeometryPainter(
            color: _customization.ringColor.primaryColor,
          ),
        );
      case BackgroundStyle.mountains:
        return CustomPaint(
          painter: _MountainsPainter(
            color: _customization.ringColor.primaryColor,
          ),
        );
      case BackgroundStyle.plain:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRings() {
    final ringColor = _customization.ringColor;
    final ringStyle = _customization.ringStyle;
    
    if (ringStyle == RingStyle.none) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _ringController1,
        _ringController2,
        _ringController3,
        _breatheController,
      ]),
      builder: (context, _) {
        final breatheScale = _customization.animationStyle == SanctuaryAnimationStyle.breathe
            ? 1.0 + 0.05 * _breatheController.value
            : 1.0;
        final pulseScale = _customization.animationStyle == SanctuaryAnimationStyle.pulse
            ? 1.0 + 0.08 * (0.5 + 0.5 * math.sin(_glowController.value * 2 * math.pi))
            : 1.0;
        
        return Transform.scale(
          scale: breatheScale * pulseScale,
          child: Stack(
            alignment: Alignment.center,
            children: _buildRingsByStyle(ringStyle, ringColor),
          ),
        );
      },
    );
  }

  List<Widget> _buildRingsByStyle(RingStyle style, RingColor ringColor) {
    final color1 = ringColor.primaryColor;
    final color2 = ringColor.secondaryColor;
    final isRainbow = ringColor == RingColor.rainbow;
    
    switch (style) {
      case RingStyle.singleRing:
        return [
          Transform.rotate(
            angle: _ringController1.value * 2 * math.pi,
            child: _buildRing(widget.size * 0.95, color1, 1.5),
          ),
        ];
      
      case RingStyle.doubleRing:
        return [
          Transform.rotate(
            angle: _ringController1.value * 2 * math.pi,
            child: _buildRing(widget.size * 0.95, color1, 1.5),
          ),
          Transform.rotate(
            angle: -_ringController2.value * 2 * math.pi,
            child: _buildRing(widget.size * 0.80, color2.withOpacity(0.7), 1),
          ),
        ];
      
      case RingStyle.tripleRing:
        return [
          Transform.rotate(
            angle: _ringController1.value * 2 * math.pi,
            child: _buildRing(widget.size * 0.95, color1, 1.5),
          ),
          Transform.rotate(
            angle: -_ringController2.value * 2 * math.pi,
            child: _buildRing(widget.size * 0.80, color2.withOpacity(0.6), 1),
          ),
          Transform.rotate(
            angle: _ringController3.value * 2 * math.pi,
            child: _buildRing(widget.size * 0.65, color1.withOpacity(0.4), 0.8),
          ),
        ];
      
      case RingStyle.mandala:
        return [
          Transform.rotate(
            angle: _ringController1.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _MandalaPainter(
                color: color1,
                progress: _ringController1.value,
              ),
            ),
          ),
        ];
      
      case RingStyle.lotus:
        return [
          Transform.rotate(
            angle: _ringController1.value * 0.5 * math.pi,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _LotusPetalsPainter(
                color: color1,
                secondaryColor: color2,
              ),
            ),
          ),
        ];
      
      case RingStyle.cosmic:
        return [
          Transform.rotate(
            angle: _ringController1.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CosmicDotsPainter(
                color: color1,
                secondaryColor: color2,
                isRainbow: isRainbow,
                rainbowColors: ringColor.gradientColors,
              ),
            ),
          ),
        ];
      
      case RingStyle.chakra:
        return [
          Transform.rotate(
            angle: _ringController1.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ChakraRingPainter(
                color: color1,
                secondaryColor: color2,
              ),
            ),
          ),
        ];
      
      case RingStyle.none:
        return [];
    }
  }

  Widget _buildRing(double size, Color color, double strokeWidth) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.6),
          width: strokeWidth,
        ),
      ),
    );
  }

  Widget _buildCenterContent() {
    // Check if deity image is selected
    if (_customization.deityImage != null) {
      return _buildDeityImage(_customization.deityImage!);
    }
    
    // Otherwise show Om symbol
    return _buildOmSymbol();
  }

  Widget _buildOmSymbol() {
    final glowColor = _customization.glowColor;
    final omStyle = _customization.omStyle;
    
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final t = _glowController.value;
        double glowIntensity = 0.6;
        double blurRadius = 30;
        
        if (_customization.animationStyle != SanctuaryAnimationStyle.stillness) {
          glowIntensity = 0.4 + 0.4 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
          blurRadius = 20 + 20 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
        }
        
        return Text(
          _om,
          style: _getOmTextStyle(omStyle, glowColor, glowIntensity, blurRadius),
        );
      },
    );
  }

  TextStyle _getOmTextStyle(OmStyle style, GlowColor glowColor, double glowIntensity, double blurRadius) {
    final baseSize = widget.size * 0.38;
    final color = _customization.ringColor.primaryColor;
    final glow = glowColor.color;
    
    switch (style) {
      case OmStyle.classic:
        return GoogleFonts.cormorantGaramond(
          fontSize: baseSize,
          height: 1,
          fontWeight: FontWeight.w300,
          color: color,
          shadows: [
            Shadow(
              color: glow.withOpacity(glowIntensity),
              blurRadius: blurRadius,
            ),
          ],
        );
      
      case OmStyle.satvik:
        return GoogleFonts.notoSerifDevanagari(
          fontSize: baseSize * 0.9,
          height: 1,
          fontWeight: FontWeight.w200,
          color: color.withOpacity(0.9),
          shadows: [
            Shadow(
              color: glow.withOpacity(glowIntensity * 0.7),
              blurRadius: blurRadius * 0.8,
            ),
          ],
        );
      
      case OmStyle.divine:
        return GoogleFonts.cormorantGaramond(
          fontSize: baseSize,
          height: 1,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          shadows: [
            Shadow(
              color: glow.withOpacity(glowIntensity),
              blurRadius: blurRadius * 1.5,
            ),
            Shadow(
              color: color.withOpacity(glowIntensity * 0.8),
              blurRadius: blurRadius * 0.5,
            ),
          ],
        );
      
      case OmStyle.minimalist:
        return GoogleFonts.notoSansDevanagari(
          fontSize: baseSize * 0.85,
          height: 1,
          fontWeight: FontWeight.w100,
          color: color.withOpacity(0.8),
        );
      
      case OmStyle.ornate:
        return GoogleFonts.cormorantGaramond(
          fontSize: baseSize * 1.1,
          height: 1,
          fontWeight: FontWeight.w600,
          color: color,
          shadows: [
            Shadow(
              color: glow.withOpacity(glowIntensity),
              blurRadius: blurRadius,
            ),
            Shadow(
              color: _customization.ringColor.secondaryColor.withOpacity(glowIntensity * 0.5),
              blurRadius: blurRadius * 2,
            ),
          ],
        );
    }
  }

  Widget _buildDeityImage(DeityImage deity) {
    // For now, show emoji representation
    // In production, this would load actual deity images
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final t = _glowController.value;
        final glowIntensity = _customization.animationStyle != SanctuaryAnimationStyle.stillness
            ? 0.3 + 0.3 * (0.5 + 0.5 * math.sin(t * 2 * math.pi))
            : 0.4;
        
        return Container(
          width: widget.size * 0.4,
          height: widget.size * 0.4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _customization.ringColor.primaryColor.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: _customization.glowColor.color.withOpacity(glowIntensity),
                blurRadius: 30,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deity.emoji,
                  style: TextStyle(fontSize: widget.size * 0.15),
                ),
                const SizedBox(height: 4),
                Text(
                  deity.displayName,
                  style: GoogleFonts.tenorSans(
                    fontSize: widget.size * 0.035,
                    color: _customization.ringColor.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrame() {
    final frameStyle = _customization.frameStyle;
    final color = _customization.ringColor.primaryColor;
    
    return AnimatedBuilder(
      animation: _ringController1,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _FramePainter(
            style: frameStyle,
            color: color,
            progress: _ringController1.value,
          ),
        );
      },
    );
  }

  Widget _buildSpecialEffect() {
    final effect = _customization.specialEffect;
    final color = _customization.glowColor.color;
    
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SpecialEffectPainter(
            effect: effect,
            color: color,
            progress: _glowController.value,
          ),
        );
      },
    );
  }

  Widget _buildSpecialEffectOverlay() {
    final effect = _customization.specialEffect;
    final color = _customization.glowColor.color;
    
    // Only some effects have overlays
    if (effect != SpecialEffect.divineLight && 
        effect != SpecialEffect.auraWaves &&
        effect != SpecialEffect.goldenShower) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SpecialEffectOverlayPainter(
            effect: effect,
            color: color,
            progress: _particleController.value,
          ),
        );
      },
    );
  }
}

// ============ CUSTOM PAINTERS ============

class _GeometricLinesPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _GeometricLinesPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1;

    const spacing = 40.0;
    // Diagonal lines
    for (var i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(i.toDouble(), size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarfieldPainter extends CustomPainter {
  final double progress;
  final Color color;

  _StarfieldPainter({required this.progress, required this.color});

  static final List<({double x, double y, double size, double twinkleOffset})> _stars = () {
    final list = <({double x, double y, double size, double twinkleOffset})>[];
    final random = math.Random(123);
    for (var i = 0; i < 50; i++) {
      list.add((
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * 2,
        twinkleOffset: random.nextDouble(),
      ));
    }
    return list;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final twinkle = 0.3 + 0.7 * (0.5 + 0.5 * math.sin((progress + star.twinkleOffset) * 2 * math.pi));
      final paint = Paint()
        ..color = color.withOpacity(twinkle * 0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * twinkle,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LotusPatternPainter extends CustomPainter {
  final Color color;

  _LotusPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw lotus pattern
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final path = Path();
      
      // Petal shape
      path.moveTo(center.dx, center.dy);
      final controlDist = size.width * 0.3;
      final endDist = size.width * 0.45;
      
      final cp1 = Offset(
        center.dx + controlDist * math.cos(angle - 0.3),
        center.dy + controlDist * math.sin(angle - 0.3),
      );
      final cp2 = Offset(
        center.dx + controlDist * math.cos(angle + 0.3),
        center.dy + controlDist * math.sin(angle + 0.3),
      );
      final end = Offset(
        center.dx + endDist * math.cos(angle),
        center.dy + endDist * math.sin(angle),
      );
      
      path.quadraticBezierTo(cp1.dx, cp1.dy, end.dx, end.dy);
      path.quadraticBezierTo(cp2.dx, cp2.dy, center.dx, center.dy);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TempleArchPainter extends CustomPainter {
  final Color color;

  _TempleArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = size.width / 2;
    
    // Draw temple arch outline
    final path = Path();
    path.moveTo(size.width * 0.2, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.quadraticBezierTo(center, size.height * 0.1, size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height);
    
    canvas.drawPath(path, paint);
    
    // Inner arch
    final innerPath = Path();
    innerPath.moveTo(size.width * 0.3, size.height);
    innerPath.lineTo(size.width * 0.3, size.height * 0.55);
    innerPath.quadraticBezierTo(center, size.height * 0.2, size.width * 0.7, size.height * 0.55);
    innerPath.lineTo(size.width * 0.7, size.height);
    
    canvas.drawPath(innerPath, paint..color = color.withOpacity(0.06));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SacredGeometryPainter extends CustomPainter {
  final Color color;

  _SacredGeometryPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final radius = size.width * 0.4;
    
    // Flower of life pattern - draw overlapping circles
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final offset = Offset(
        center.dx + radius * 0.5 * math.cos(angle),
        center.dy + radius * 0.5 * math.sin(angle),
      );
      canvas.drawCircle(offset, radius * 0.5, paint);
    }
    
    // Center circle
    canvas.drawCircle(center, radius * 0.5, paint);
    
    // Outer circle
    canvas.drawCircle(center, radius, paint..color = color.withOpacity(0.05));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MountainsPainter extends CustomPainter {
  final Color color;

  _MountainsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Mountain range silhouette
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.15, size.height * 0.7);
    path.lineTo(size.width * 0.25, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.35); // Peak
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width * 0.75, size.height * 0.8);
    path.lineTo(size.width * 0.85, size.height * 0.65);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Snow cap
    final snowPath = Path();
    snowPath.moveTo(size.width * 0.45, size.height * 0.45);
    snowPath.lineTo(size.width * 0.5, size.height * 0.35);
    snowPath.lineTo(size.width * 0.55, size.height * 0.45);
    snowPath.close();
    
    canvas.drawPath(snowPath, paint..color = color.withOpacity(0.12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MandalaPainter extends CustomPainter {
  final Color color;
  final double progress;

  _MandalaPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Outer mandala ring with decorative elements
    final outerRadius = size.width * 0.45;
    canvas.drawCircle(center, outerRadius, paint);
    
    // Decorative dots around the ring
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi / 12;
      final dotPos = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawCircle(dotPos, 2, paint..style = PaintingStyle.fill);
    }
    
    paint.style = PaintingStyle.stroke;
    
    // Inner mandala patterns
    final innerRadius = size.width * 0.35;
    canvas.drawCircle(center, innerRadius, paint..color = color.withOpacity(0.35));
    
    // Petal shapes
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final path = Path();
      
      final tipDist = size.width * 0.42;
      final tip = Offset(
        center.dx + tipDist * math.cos(angle),
        center.dy + tipDist * math.sin(angle),
      );
      
      path.moveTo(center.dx + innerRadius * 0.5 * math.cos(angle - 0.15), 
                  center.dy + innerRadius * 0.5 * math.sin(angle - 0.15));
      path.quadraticBezierTo(tip.dx, tip.dy,
                  center.dx + innerRadius * 0.5 * math.cos(angle + 0.15),
                  center.dy + innerRadius * 0.5 * math.sin(angle + 0.15));
      
      canvas.drawPath(path, paint..color = color.withOpacity(0.25));
    }
  }

  @override
  bool shouldRepaint(covariant _MandalaPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LotusPetalsPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;

  _LotusPetalsPainter({required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw lotus petals
    for (var layer = 0; layer < 2; layer++) {
      final petalCount = layer == 0 ? 8 : 8;
      final radius = size.width * (layer == 0 ? 0.45 : 0.35);
      final angleOffset = layer == 0 ? 0.0 : math.pi / 8;
      
      for (var i = 0; i < petalCount; i++) {
        final angle = angleOffset + i * 2 * math.pi / petalCount;
        final petalColor = layer == 0 ? color : secondaryColor;
        
        final path = Path();
        final tip = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        
        final startRadius = radius * 0.3;
        final start1 = Offset(
          center.dx + startRadius * math.cos(angle - 0.2),
          center.dy + startRadius * math.sin(angle - 0.2),
        );
        final start2 = Offset(
          center.dx + startRadius * math.cos(angle + 0.2),
          center.dy + startRadius * math.sin(angle + 0.2),
        );
        
        path.moveTo(start1.dx, start1.dy);
        path.quadraticBezierTo(
          center.dx + radius * 0.7 * math.cos(angle - 0.15),
          center.dy + radius * 0.7 * math.sin(angle - 0.15),
          tip.dx, tip.dy,
        );
        path.quadraticBezierTo(
          center.dx + radius * 0.7 * math.cos(angle + 0.15),
          center.dy + radius * 0.7 * math.sin(angle + 0.15),
          start2.dx, start2.dy,
        );
        
        final paint = Paint()
          ..color = petalColor.withOpacity(layer == 0 ? 0.4 : 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CosmicDotsPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;
  final bool isRainbow;
  final List<Color> rainbowColors;

  _CosmicDotsPainter({
    required this.color,
    required this.secondaryColor,
    required this.isRainbow,
    required this.rainbowColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw cosmic dots in circular patterns
    for (var ring = 0; ring < 3; ring++) {
      final radius = size.width * (0.35 + ring * 0.08);
      final dotCount = 12 + ring * 6;
      
      for (var i = 0; i < dotCount; i++) {
        final angle = i * 2 * math.pi / dotCount;
        final dotPos = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        
        Color dotColor;
        if (isRainbow) {
          dotColor = rainbowColors[i % rainbowColors.length];
        } else {
          dotColor = i % 2 == 0 ? color : secondaryColor;
        }
        
        final paint = Paint()
          ..color = dotColor.withOpacity(0.6 - ring * 0.15)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(dotPos, 2 - ring * 0.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChakraRingPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;

  _ChakraRingPainter({required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    
    // Chakra wheel with 8 spokes
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Outer ring
    canvas.drawCircle(center, radius, paint);
    
    // Inner ring
    canvas.drawCircle(center, radius * 0.7, paint..color = color.withOpacity(0.35));
    
    // Spokes
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(center.dx + radius * 0.7 * math.cos(angle),
               center.dy + radius * 0.7 * math.sin(angle)),
        Offset(center.dx + radius * math.cos(angle),
               center.dy + radius * math.sin(angle)),
        paint..color = color.withOpacity(0.4),
      );
    }
    
    // Curved elements between spokes
    for (var i = 0; i < 8; i++) {
      final startAngle = i * math.pi / 4;
      final endAngle = (i + 1) * math.pi / 4;
      
      final path = Path();
      path.moveTo(
        center.dx + radius * 0.85 * math.cos(startAngle + 0.1),
        center.dy + radius * 0.85 * math.sin(startAngle + 0.1),
      );
      path.arcToPoint(
        Offset(
          center.dx + radius * 0.85 * math.cos(endAngle - 0.1),
          center.dy + radius * 0.85 * math.sin(endAngle - 0.1),
        ),
        radius: Radius.circular(radius * 0.3),
        clockwise: false,
      );
      
      canvas.drawPath(path, paint..color = secondaryColor.withOpacity(0.3));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlesPainter({required this.progress, required this.color});

  static final List<({double angle, double radius, double size, double speed, double delay})> _particles = () {
    final list = <({double angle, double radius, double size, double speed, double delay})>[];
    final random = math.Random(42);
    for (var i = 0; i < 30; i++) {
      list.add((
        angle: random.nextDouble() * 2 * math.pi,
        radius: 50 + random.nextDouble() * 100,
        size: 1 + random.nextDouble() * 2,
        speed: 0.2 + random.nextDouble() * 0.3,
        delay: random.nextDouble(),
      ));
    }
    return list;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final p in _particles) {
      final t = (progress + p.delay) % 1.0;
      
      // Particles float upward
      final startY = centerY + p.radius * math.sin(p.angle);
      final startX = centerX + p.radius * math.cos(p.angle);
      final endY = startY - 200 * t * p.speed;
      final endX = startX + math.sin(t * math.pi * 2) * 10;
      
      // Fade
      double alpha;
      if (t < 0.1) {
        alpha = t / 0.1;
      } else if (t > 0.8) {
        alpha = (1.0 - t) / 0.2;
      } else {
        alpha = 0.6;
      }
      
      if (endY < 0 || endY > size.height) continue;
      
      final paint = Paint()
        ..color = color.withOpacity(alpha * 0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(endX, endY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ============ FRAME PAINTER ============

class _FramePainter extends CustomPainter {
  final FrameStyle style;
  final Color color;
  final double progress;

  _FramePainter({
    required this.style,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.48;
    
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (style) {
      case FrameStyle.none:
        break;
      
      case FrameStyle.hexagon:
        _drawPolygon(canvas, center, radius, 6, paint);
        _drawPolygon(canvas, center, radius * 0.85, 6, paint..color = color.withOpacity(0.2));
        break;
      
      case FrameStyle.octagon:
        _drawPolygon(canvas, center, radius, 8, paint);
        _drawPolygon(canvas, center, radius * 0.9, 8, paint..color = color.withOpacity(0.15));
        break;
      
      case FrameStyle.diamond:
        _drawPolygon(canvas, center, radius, 4, paint);
        _drawPolygon(canvas, center, radius * 0.75, 4, paint..color = color.withOpacity(0.2));
        break;
      
      case FrameStyle.lotus:
        _drawLotusFrame(canvas, center, radius, paint);
        break;
      
      case FrameStyle.yantra:
        _drawYantraFrame(canvas, center, radius, paint);
        break;
      
      case FrameStyle.sun:
        _drawSunFrame(canvas, center, radius, paint);
        break;
      
      case FrameStyle.moon:
        _drawMoonFrame(canvas, center, radius, paint);
        break;
      
      case FrameStyle.temple:
        _drawTempleFrame(canvas, center, radius, paint);
        break;
      
      case FrameStyle.tribal:
        _drawTribalFrame(canvas, center, radius, paint);
        break;
    }
  }

  void _drawPolygon(Canvas canvas, Offset center, double radius, int sides, Paint paint) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLotusFrame(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw lotus petals as frame
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + progress * 0.1;
      final path = Path();
      
      final baseLeft = Offset(
        center.dx + radius * 0.6 * math.cos(angle - 0.15),
        center.dy + radius * 0.6 * math.sin(angle - 0.15),
      );
      final baseRight = Offset(
        center.dx + radius * 0.6 * math.cos(angle + 0.15),
        center.dy + radius * 0.6 * math.sin(angle + 0.15),
      );
      final tip = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      path.moveTo(baseLeft.dx, baseLeft.dy);
      path.quadraticBezierTo(
        center.dx + radius * 0.85 * math.cos(angle - 0.2),
        center.dy + radius * 0.85 * math.sin(angle - 0.2),
        tip.dx, tip.dy,
      );
      path.quadraticBezierTo(
        center.dx + radius * 0.85 * math.cos(angle + 0.2),
        center.dy + radius * 0.85 * math.sin(angle + 0.2),
        baseRight.dx, baseRight.dy,
      );
      
      canvas.drawPath(path, paint..color = color.withOpacity(0.25));
    }
  }

  void _drawYantraFrame(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw interlocking triangles (Star of David / Sri Yantra inspired)
    final path1 = Path();
    final path2 = Path();
    
    // Upward triangle
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path1.moveTo(point.dx, point.dy);
      } else {
        path1.lineTo(point.dx, point.dy);
      }
    }
    path1.close();
    
    // Downward triangle
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) + math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path2.moveTo(point.dx, point.dy);
      } else {
        path2.lineTo(point.dx, point.dy);
      }
    }
    path2.close();
    
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint..color = color.withOpacity(0.25));
    
    // Inner circle
    canvas.drawCircle(center, radius * 0.5, paint..color = color.withOpacity(0.2));
  }

  void _drawSunFrame(Canvas canvas, Offset center, double radius, Paint paint) {
    // Sun with rays
    canvas.drawCircle(center, radius * 0.6, paint);
    
    // Rays
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      canvas.drawLine(
        Offset(
          center.dx + radius * 0.65 * math.cos(angle),
          center.dy + radius * 0.65 * math.sin(angle),
        ),
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        paint..color = color.withOpacity(0.3 - (i % 2) * 0.1),
      );
    }
  }

  void _drawMoonFrame(Canvas canvas, Offset center, double radius, Paint paint) {
    // Crescent moon shape
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.7,
      math.pi * 1.4,
    );
    path.arcTo(
      Rect.fromCircle(center: Offset(center.dx + radius * 0.3, center.dy), radius: radius * 0.85),
      math.pi * 0.7,
      -math.pi * 1.4,
      false,
    );
    path.close();
    
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawTempleFrame(Canvas canvas, Offset center, double radius, Paint paint) {
    // Temple arch shape
    final path = Path();
    
    // Main arch
    path.moveTo(center.dx - radius * 0.7, center.dy + radius);
    path.lineTo(center.dx - radius * 0.7, center.dy);
    path.quadraticBezierTo(
      center.dx - radius * 0.7, center.dy - radius * 0.7,
      center.dx, center.dy - radius,
    );
    path.quadraticBezierTo(
      center.dx + radius * 0.7, center.dy - radius * 0.7,
      center.dx + radius * 0.7, center.dy,
    );
    path.lineTo(center.dx + radius * 0.7, center.dy + radius);
    
    canvas.drawPath(path, paint);
    
    // Kalash (top ornament)
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 1.05), radius * 0.08, paint);
  }

  void _drawTribalFrame(Canvas canvas, Offset center, double radius, Paint paint) {
    // Tribal pattern with zigzag
    final outerPath = Path();
    final innerPath = Path();
    
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi / 12;
      final r = i % 2 == 0 ? radius : radius * 0.85;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        outerPath.moveTo(point.dx, point.dy);
      } else {
        outerPath.lineTo(point.dx, point.dy);
      }
    }
    outerPath.close();
    
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi / 12;
      final r = i % 2 == 0 ? radius * 0.7 : radius * 0.55;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        innerPath.moveTo(point.dx, point.dy);
      } else {
        innerPath.lineTo(point.dx, point.dy);
      }
    }
    innerPath.close();
    
    canvas.drawPath(outerPath, paint);
    canvas.drawPath(innerPath, paint..color = color.withOpacity(0.2));
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.style != style;
}

// ============ SPECIAL EFFECT PAINTER ============

class _SpecialEffectPainter extends CustomPainter {
  final SpecialEffect effect;
  final Color color;
  final double progress;

  _SpecialEffectPainter({
    required this.effect,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    switch (effect) {
      case SpecialEffect.none:
        break;
      
      case SpecialEffect.fireAura:
        _drawFireAura(canvas, center, radius);
        break;
      
      case SpecialEffect.waterRipples:
        _drawWaterRipples(canvas, center, radius);
        break;
      
      case SpecialEffect.lightningBolts:
        _drawLightningBolts(canvas, center, radius);
        break;
      
      case SpecialEffect.divineLight:
        _drawDivineLight(canvas, center, radius);
        break;
      
      case SpecialEffect.cosmicSwirl:
        _drawCosmicSwirl(canvas, center, radius);
        break;
      
      case SpecialEffect.floatingPetals:
        _drawFloatingPetals(canvas, size);
        break;
      
      case SpecialEffect.holySmoke:
        _drawHolySmoke(canvas, center, radius);
        break;
      
      case SpecialEffect.chakraGlow:
        _drawChakraGlow(canvas, center, radius);
        break;
      
      case SpecialEffect.goldenShower:
        // Handled in overlay painter
        break;
      
      case SpecialEffect.auraWaves:
        _drawAuraWaves(canvas, center, radius);
        break;
    }
  }

  void _drawFireAura(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.orange.withOpacity(0.0),
          Colors.orange.withOpacity(0.2 + 0.1 * math.sin(progress * math.pi * 2)),
          Colors.red.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));
    
    canvas.drawCircle(center, radius * 1.5, paint);
    
    // Flame tips
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + progress * 2;
      final flameHeight = radius * (0.3 + 0.1 * math.sin(progress * 4 * math.pi + i));
      
      final path = Path();
      final base = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      path.moveTo(base.dx - 5, base.dy);
      path.quadraticBezierTo(
        base.dx + flameHeight * 0.5 * math.cos(angle),
        base.dy + flameHeight * 0.5 * math.sin(angle),
        base.dx + flameHeight * math.cos(angle),
        base.dy + flameHeight * math.sin(angle),
      );
      path.quadraticBezierTo(
        base.dx + flameHeight * 0.5 * math.cos(angle),
        base.dy + flameHeight * 0.5 * math.sin(angle),
        base.dx + 5, base.dy,
      );
      
      final flamePaint = Paint()
        ..color = Colors.orange.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, flamePaint);
    }
  }

  void _drawWaterRipples(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 3; i++) {
      final rippleProgress = (progress + i * 0.33) % 1.0;
      final rippleRadius = radius * 0.5 + radius * rippleProgress;
      final opacity = 0.3 * (1 - rippleProgress);
      
      final paint = Paint()
        ..color = Colors.cyan.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, rippleRadius, paint);
    }
  }

  void _drawLightningBolts(Canvas canvas, Offset center, double radius) {
    final random = math.Random(42);
    final boltCount = 4;
    
    for (var b = 0; b < boltCount; b++) {
      if ((progress * 10 + b) % 1.0 < 0.7) continue; // Intermittent flash
      
      final angle = b * math.pi / 2 + random.nextDouble() * 0.5;
      final path = Path();
      var currentPos = Offset(
        center.dx + radius * 0.3 * math.cos(angle),
        center.dy + radius * 0.3 * math.sin(angle),
      );
      path.moveTo(currentPos.dx, currentPos.dy);
      
      for (var i = 0; i < 4; i++) {
        final nextPos = Offset(
          currentPos.dx + (radius * 0.2) * math.cos(angle) + random.nextDouble() * 15 - 7.5,
          currentPos.dy + (radius * 0.2) * math.sin(angle) + random.nextDouble() * 15 - 7.5,
        );
        path.lineTo(nextPos.dx, nextPos.dy);
        currentPos = nextPos;
      }
      
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, paint);
    }
  }

  void _drawDivineLight(Canvas canvas, Offset center, double radius) {
    // Rays of light emanating from center
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final rayLength = radius * (1.2 + 0.3 * math.sin(progress * 2 * math.pi + i));
      
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.center,
          end: Alignment.topCenter,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: rayLength));
      
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + rayLength * math.cos(angle - 0.05),
        center.dy + rayLength * math.sin(angle - 0.05),
      );
      path.lineTo(
        center.dx + rayLength * math.cos(angle + 0.05),
        center.dy + rayLength * math.sin(angle + 0.05),
      );
      path.close();
      
      canvas.drawPath(path, paint..style = PaintingStyle.fill);
    }
  }

  void _drawCosmicSwirl(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    for (var arm = 0; arm < 2; arm++) {
      final path = Path();
      final armOffset = arm * math.pi;
      
      for (var t = 0.0; t < 1.0; t += 0.02) {
        final angle = t * 4 * math.pi + progress * 2 * math.pi + armOffset;
        final r = radius * 0.2 + radius * 0.8 * t;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        
        if (t == 0.0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      paint.color = color.withOpacity(0.2 - arm * 0.05);
      canvas.drawPath(path, paint);
    }
  }

  void _drawFloatingPetals(Canvas canvas, Size size) {
    final random = math.Random(99);
    
    for (var i = 0; i < 12; i++) {
      final startX = random.nextDouble() * size.width;
      final floatOffset = (progress + i * 0.08) % 1.0;
      final y = size.height * (1 - floatOffset);
      final x = startX + math.sin(floatOffset * 4 * math.pi) * 20;
      
      if (y < 0 || y > size.height) continue;
      
      final paint = Paint()
        ..color = Colors.pink.withOpacity(0.3 * (1 - floatOffset))
        ..style = PaintingStyle.fill;
      
      // Simple petal shape
      final path = Path();
      path.moveTo(x, y);
      path.quadraticBezierTo(x + 5, y - 3, x + 8, y);
      path.quadraticBezierTo(x + 5, y + 3, x, y);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(floatOffset * 2 * math.pi);
      canvas.translate(-x, -y);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _drawHolySmoke(Canvas canvas, Offset center, double radius) {
    final random = math.Random(77);
    
    for (var i = 0; i < 8; i++) {
      final smokeProgress = (progress + i * 0.125) % 1.0;
      final x = center.dx + random.nextDouble() * 40 - 20;
      final y = center.dy + radius - radius * 2 * smokeProgress;
      final smokeRadius = 10 + 20 * smokeProgress;
      
      final paint = Paint()
        ..color = Colors.grey.withOpacity(0.15 * (1 - smokeProgress))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(Offset(x, y), smokeRadius, paint);
    }
  }

  void _drawChakraGlow(Canvas canvas, Offset center, double radius) {
    final chakraColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];
    
    final colorIndex = ((progress * chakraColors.length) % chakraColors.length).floor();
    final currentColor = chakraColors[colorIndex];
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          currentColor.withOpacity(0.3),
          currentColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));
    
    canvas.drawCircle(center, radius * 1.2, paint);
  }

  void _drawAuraWaves(Canvas canvas, Offset center, double radius) {
    for (var wave = 0; wave < 4; wave++) {
      final waveProgress = (progress + wave * 0.25) % 1.0;
      final waveRadius = radius * (0.8 + 0.6 * waveProgress);
      final opacity = 0.25 * (1 - waveProgress);
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 - 2 * waveProgress;
      
      canvas.drawCircle(center, waveRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpecialEffectPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.effect != effect;
}

// ============ SPECIAL EFFECT OVERLAY PAINTER ============

class _SpecialEffectOverlayPainter extends CustomPainter {
  final SpecialEffect effect;
  final Color color;
  final double progress;

  _SpecialEffectOverlayPainter({
    required this.effect,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (effect) {
      case SpecialEffect.goldenShower:
        _drawGoldenShower(canvas, size);
        break;
      case SpecialEffect.divineLight:
        _drawDivineLightOverlay(canvas, size);
        break;
      case SpecialEffect.auraWaves:
        // No additional overlay needed
        break;
      default:
        break;
    }
  }

  void _drawGoldenShower(Canvas canvas, Size size) {
    final random = math.Random(55);
    
    for (var i = 0; i < 20; i++) {
      final startX = random.nextDouble() * size.width;
      final fallProgress = (progress + i * 0.05) % 1.0;
      final y = fallProgress * size.height;
      final x = startX + math.sin(fallProgress * 2 * math.pi) * 10;
      
      final paint = Paint()
        ..color = color.withOpacity(0.4 * (1 - fallProgress * 0.5))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 2, paint);
      
      // Trail
      if (fallProgress > 0.1) {
        final trailPaint = Paint()
          ..color = color.withOpacity(0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(x, y),
          Offset(x - math.sin((fallProgress - 0.1) * 2 * math.pi) * 10, y - 15),
          trailPaint,
        );
      }
    }
  }

  void _drawDivineLightOverlay(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glowOpacity = 0.1 + 0.05 * math.sin(progress * 2 * math.pi);
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(glowOpacity),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.3));
    
    canvas.drawCircle(center, size.width * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant _SpecialEffectOverlayPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.effect != effect;
}

// ============ PARTICLE SYSTEM PAINTER ============

class _ParticleSystemPainter extends CustomPainter {
  final double progress;
  final ParticleStyle style;
  final Color color;

  _ParticleSystemPainter({
    required this.progress,
    required this.style,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case ParticleStyle.none:
        break;
      case ParticleStyle.stars:
        _drawStars(canvas, size);
        break;
      case ParticleStyle.fireflies:
        _drawFireflies(canvas, size);
        break;
      case ParticleStyle.sakura:
        _drawSakura(canvas, size);
        break;
      case ParticleStyle.snow:
        _drawSnow(canvas, size);
        break;
      case ParticleStyle.embers:
        _drawEmbers(canvas, size);
        break;
      case ParticleStyle.bubbles:
        _drawBubbles(canvas, size);
        break;
      case ParticleStyle.leaves:
        _drawLeaves(canvas, size);
        break;
      case ParticleStyle.sparkles:
        _drawSparkles(canvas, size);
        break;
      case ParticleStyle.orbs:
        _drawOrbs(canvas, size);
        break;
      case ParticleStyle.feathers:
        _drawFeathers(canvas, size);
        break;
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final random = math.Random(11);
    for (var i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = 0.3 + 0.7 * math.sin((progress + i * 0.1) * 2 * math.pi);
      
      final paint = Paint()
        ..color = color.withOpacity(twinkle * 0.5)
        ..style = PaintingStyle.fill;
      
      _drawStar(canvas, Offset(x, y), 3 + random.nextDouble() * 2, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = i * 4 * math.pi / 5 - math.pi / 2;
      final point = Offset(
        center.dx + size * math.cos(angle),
        center.dy + size * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawFireflies(Canvas canvas, Size size) {
    final random = math.Random(22);
    for (var i = 0; i < 15; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final wobble = math.sin((progress + i * 0.15) * 4 * math.pi) * 10;
      final x = baseX + wobble;
      final y = baseY + math.cos((progress + i * 0.1) * 2 * math.pi) * 5;
      
      final glow = 0.2 + 0.8 * math.sin((progress + i * 0.2) * 2 * math.pi).abs();
      
      final paint = Paint()
        ..color = Colors.yellowAccent.withOpacity(glow * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(Offset(x, y), 4, paint);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white.withOpacity(glow));
    }
  }

  void _drawSakura(Canvas canvas, Size size) {
    final random = math.Random(33);
    for (var i = 0; i < 18; i++) {
      final startX = random.nextDouble() * size.width;
      final floatProgress = (progress + i * 0.055) % 1.0;
      final y = floatProgress * size.height * 1.2 - size.height * 0.1;
      final x = startX + math.sin(floatProgress * 6 * math.pi) * 30;
      final rotation = floatProgress * 4 * math.pi;
      
      if (y < 0 || y > size.height) continue;
      
      final opacity = floatProgress < 0.1 
          ? floatProgress / 0.1 
          : floatProgress > 0.9 
              ? (1 - floatProgress) / 0.1 
              : 1.0;
      
      final paint = Paint()
        ..color = Colors.pink.shade200.withOpacity(0.4 * opacity)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      // Draw petal
      final petalPath = Path();
      petalPath.moveTo(0, -6);
      petalPath.quadraticBezierTo(4, -3, 4, 0);
      petalPath.quadraticBezierTo(4, 3, 0, 6);
      petalPath.quadraticBezierTo(-4, 3, -4, 0);
      petalPath.quadraticBezierTo(-4, -3, 0, -6);
      canvas.drawPath(petalPath, paint);
      
      canvas.restore();
    }
  }

  void _drawSnow(Canvas canvas, Size size) {
    final random = math.Random(44);
    for (var i = 0; i < 30; i++) {
      final startX = random.nextDouble() * size.width;
      final fallProgress = (progress + i * 0.033) % 1.0;
      final y = fallProgress * size.height;
      final x = startX + math.sin(fallProgress * 4 * math.pi) * 15;
      final snowSize = 2 + random.nextDouble() * 3;
      
      final opacity = fallProgress < 0.05 ? fallProgress / 0.05 : 1.0;
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.6 * opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), snowSize, paint);
    }
  }

  void _drawEmbers(Canvas canvas, Size size) {
    final random = math.Random(55);
    final center = Offset(size.width / 2, size.height / 2);
    
    for (var i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final startRadius = random.nextDouble() * 30 + size.width * 0.15;
      final floatProgress = (progress + i * 0.05) % 1.0;
      
      final radius = startRadius + floatProgress * size.width * 0.3;
      final y = center.dy - floatProgress * size.height * 0.4;
      final x = center.dx + radius * math.cos(angle + floatProgress * math.pi);
      
      if (y < 0) continue;
      
      final opacity = (1 - floatProgress) * 0.7;
      
      final paint = Paint()
        ..color = Colors.orange.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(Offset(x, y), 3 - 2 * floatProgress, paint);
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    final random = math.Random(66);
    final center = Offset(size.width / 2, size.height / 2);
    
    for (var i = 0; i < 12; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final floatProgress = (progress + i * 0.08) % 1.0;
      final radius = size.width * 0.1 + floatProgress * size.width * 0.35;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy - floatProgress * size.height * 0.3;
      final bubbleSize = 5 + random.nextDouble() * 8;
      
      final opacity = floatProgress < 0.1 
          ? floatProgress / 0.1 
          : floatProgress > 0.8 
              ? (1 - floatProgress) / 0.2 
              : 0.4;
      
      final paint = Paint()
        ..color = Colors.lightBlue.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawCircle(Offset(x, y), bubbleSize, paint);
      
      // Highlight
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x - 2, y - 2), radius: bubbleSize * 0.5),
        -math.pi * 0.7,
        math.pi * 0.5,
        false,
        Paint()..color = Colors.white.withOpacity(opacity * 0.5)..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawLeaves(Canvas canvas, Size size) {
    final random = math.Random(77);
    final colors = [Colors.orange.shade700, Colors.red.shade700, Colors.brown.shade600];
    
    for (var i = 0; i < 15; i++) {
      final startX = random.nextDouble() * size.width;
      final floatProgress = (progress + i * 0.066) % 1.0;
      final y = floatProgress * size.height * 1.1;
      final x = startX + math.sin(floatProgress * 3 * math.pi) * 40;
      final rotation = floatProgress * 3 * math.pi + random.nextDouble() * math.pi;
      
      if (y > size.height) continue;
      
      final leafColor = colors[i % colors.length];
      final opacity = floatProgress > 0.9 ? (1 - floatProgress) * 10 : 0.6;
      
      final paint = Paint()
        ..color = leafColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      // Leaf shape
      final path = Path();
      path.moveTo(0, -8);
      path.quadraticBezierTo(6, -4, 6, 0);
      path.quadraticBezierTo(6, 4, 0, 8);
      path.quadraticBezierTo(-6, 4, -6, 0);
      path.quadraticBezierTo(-6, -4, 0, -8);
      canvas.drawPath(path, paint);
      
      canvas.restore();
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final random = math.Random(88);
    
    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sparklePhase = (progress + i * 0.1) % 1.0;
      
      // Sparkle appears, grows, then fades
      double scale, opacity;
      if (sparklePhase < 0.3) {
        scale = sparklePhase / 0.3;
        opacity = sparklePhase / 0.3;
      } else if (sparklePhase < 0.5) {
        scale = 1.0;
        opacity = 1.0;
      } else {
        scale = 1.0 - (sparklePhase - 0.5) / 0.5;
        opacity = 1.0 - (sparklePhase - 0.5) / 0.5;
      }
      
      if (opacity < 0.1) continue;
      
      final sparkleSize = (3 + random.nextDouble() * 3) * scale;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.8)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      // Draw 4-point sparkle
      canvas.drawLine(Offset(x - sparkleSize, y), Offset(x + sparkleSize, y), paint);
      canvas.drawLine(Offset(x, y - sparkleSize), Offset(x, y + sparkleSize), paint);
      
      // Small diamond center
      canvas.drawCircle(Offset(x, y), 1.5 * scale, Paint()..color = Colors.white.withOpacity(opacity));
    }
  }

  void _drawOrbs(Canvas canvas, Size size) {
    final random = math.Random(99);
    final center = Offset(size.width / 2, size.height / 2);
    
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + progress * 2 * math.pi;
      final radius = size.width * 0.25 + math.sin((progress + i * 0.125) * 2 * math.pi) * 20;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final orbSize = 8 + 4 * math.sin((progress + i * 0.1) * 4 * math.pi);
      
      // Outer glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), orbSize + 5, glowPaint);
      
      // Core
      final gradient = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          color.withOpacity(0.6),
        ],
      );
      final corePaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: Offset(x, y), radius: orbSize));
      canvas.drawCircle(Offset(x, y), orbSize, corePaint);
    }
  }

  void _drawFeathers(Canvas canvas, Size size) {
    final random = math.Random(111);
    
    for (var i = 0; i < 10; i++) {
      final startX = random.nextDouble() * size.width;
      final floatProgress = (progress + i * 0.1) % 1.0;
      final y = floatProgress * size.height * 1.2;
      final x = startX + math.sin(floatProgress * 2 * math.pi) * 50;
      final rotation = floatProgress * 2 * math.pi + random.nextDouble() * math.pi;
      
      if (y > size.height) continue;
      
      final opacity = floatProgress > 0.9 ? (1 - floatProgress) * 10 : 0.5;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      // Feather shape
      final path = Path();
      path.moveTo(0, -15);
      path.quadraticBezierTo(4, -5, 3, 0);
      path.quadraticBezierTo(2, 8, 0, 15);
      path.quadraticBezierTo(-2, 8, -3, 0);
      path.quadraticBezierTo(-4, -5, 0, -15);
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
      
      // Quill line
      canvas.drawLine(
        const Offset(0, -15),
        const Offset(0, 15),
        Paint()..color = Colors.grey.withOpacity(opacity * 0.5)..strokeWidth = 0.5,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleSystemPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.style != style;
}
