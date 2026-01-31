import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../shared/services/guide_animation_service.dart';
import '../../core/theme/app_colors.dart';

// Enhanced placeholder for Rive animation
// This will be replaced with actual Rive widget once Rive file is available
// For now, provides a visual representation of the old sadhu character
class AnimatedGuide extends ConsumerStatefulWidget {
  final double? width;
  final double? height;
  final Alignment alignment;

  const AnimatedGuide({
    super.key,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  @override
  ConsumerState<AnimatedGuide> createState() => _AnimatedGuideState();
}

class _AnimatedGuideState extends ConsumerState<AnimatedGuide>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _wisdomLevel = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    // Listen to wisdom level changes
    GuideAnimationService().stateStream.listen((state) {
      // Update wisdom level based on state or other factors
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GuideState>(
      stream: GuideAnimationService().stateStream,
      initialData: GuideState.sitting,
      builder: (context, snapshot) {
        final state = snapshot.data ?? GuideState.sitting;
        _wisdomLevel = GuideAnimationService().wisdomLevel;
        
        return Align(
          alignment: widget.alignment,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return _buildSadhuCharacter(state);
            },
          ),
        );
      },
    );
  }

  Widget _buildSadhuCharacter(GuideState state) {
    final size = widget.width ?? 120.0;
    final wisdomGlow = _getWisdomGlow();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: wisdomGlow,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wisdom aura glow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  wisdomGlow.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Character body
          CustomPaint(
            size: Size(size, size),
            painter: _SadhuPainter(state, _animationController.value),
          ),
        ],
      ),
    );
  }

  Color _getWisdomGlow() {
    if (_wisdomLevel >= 10) {
      return Colors.amber.withOpacity(0.3);
    } else if (_wisdomLevel >= 7) {
      return Colors.amber.withOpacity(0.2);
    } else if (_wisdomLevel >= 4) {
      return Colors.amber.withOpacity(0.1);
    }
    return Colors.transparent;
  }
}

// Custom painter for the old sadhu character
class _SadhuPainter extends CustomPainter {
  final GuideState state;
  final double animationValue;

  _SadhuPainter(this.state, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Body color (saffron/orange)
    const bodyColor = AppColors.saffron;
    const robeColor = AppColors.earthBrown;
    
    // Breathing animation for sitting/idle
    final breathingOffset = state == GuideState.sitting || state == GuideState.idle
        ? math.sin(animationValue * 2 * math.pi) * 2
        : 0.0;
    
    // Draw robe (lower body)
    final robePaint = Paint()
      ..color = robeColor
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 20 + breathingOffset),
        width: radius * 1.2,
        height: radius * 0.8,
      ),
      robePaint,
    );
    
    // Draw body (upper)
    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 10 + breathingOffset),
        width: radius * 0.9,
        height: radius * 0.9,
      ),
      bodyPaint,
    );
    
    // Draw head
    final headPaint = Paint()
      ..color = const Color(0xFFFFE0B2) // Light skin tone
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.6 + breathingOffset),
      radius * 0.35,
      headPaint,
    );
    
    // Draw eyes based on state
    final eyePaint = Paint()
      ..color = AppColors.primaryText
      ..style = PaintingStyle.fill;
    
    if (state == GuideState.speaking) {
      // Animated mouth for speaking
      final mouthOffset = math.sin(animationValue * 4 * math.pi) * 3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - radius * 0.4 + breathingOffset + mouthOffset),
          width: 8,
          height: 4 + mouthOffset.abs(),
        ),
        eyePaint,
      );
    } else if (state == GuideState.praying) {
      // Hands in prayer position
      final handPaint = Paint()
        ..color = const Color(0xFFFFE0B2)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(center.dx - 8, center.dy - radius * 0.3 + breathingOffset),
        6,
        handPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 8, center.dy - radius * 0.3 + breathingOffset),
        6,
        handPaint,
      );
    } else if (state == GuideState.pointing) {
      // Pointing gesture
      final pointingPaint = Paint()
        ..color = const Color(0xFFFFE0B2)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(center.dx + radius * 0.3, center.dy - radius * 0.2 + breathingOffset),
        Offset(center.dx + radius * 0.5, center.dy - radius * 0.4 + breathingOffset),
        pointingPaint,
      );
    }
    
    // Draw eyes
    canvas.drawCircle(
      Offset(center.dx - radius * 0.15, center.dy - radius * 0.65 + breathingOffset),
      3,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.65 + breathingOffset),
      3,
      eyePaint,
    );
    
    // Draw beard (old sadhu characteristic)
    final beardPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.3 + breathingOffset),
        width: radius * 0.5,
        height: radius * 0.3,
      ),
      beardPaint,
    );
  }

  @override
  bool shouldRepaint(_SadhuPainter oldDelegate) {
    return oldDelegate.state != state || 
           (oldDelegate.animationValue - animationValue).abs() > 0.01;
  }
}
