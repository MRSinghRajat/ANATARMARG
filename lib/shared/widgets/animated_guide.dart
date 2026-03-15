import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../services/guide_animation_service.dart';
import '../services/avatar_growth_service.dart';
import '../../core/theme/app_colors.dart';

/// Animated guide character (sadhu) using CustomPainter.
/// States: idle/sitting, speaking, praying, pointing (from GuideAnimationService).
class AnimatedGuide extends ConsumerStatefulWidget {
  final double? width;
  final double? height;
  final Alignment alignment;
  /// When true, character uses walk-style state (e.g. on Yatra tab).
  final bool isOnYatraPage;

  const AnimatedGuide({
    super.key,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.isOnYatraPage = false,
  });

  @override
  ConsumerState<AnimatedGuide> createState() => _AnimatedGuideState();
}

class _AnimatedGuideState extends ConsumerState<AnimatedGuide>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _wisdomLevel = 1;

  final GuideAnimationService _guideService = GuideAnimationService();
  final AvatarGrowthService _avatarGrowthService = AvatarGrowthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GuideState>(
      stream: _guideService.stateStream,
      initialData: GuideState.sitting,
      builder: (context, stateSnapshot) {
        final state = stateSnapshot.data ?? GuideState.sitting;
        return StreamBuilder(
          stream: _avatarGrowthService.avatarStream,
          initialData: _avatarGrowthService.currentAvatar,
          builder: (context, avatarSnapshot) {
            final avatar =
                avatarSnapshot.data ?? _avatarGrowthService.currentAvatar;
            _wisdomLevel = avatar.wisdomLevel;

            return Align(
              alignment: widget.alignment,
              child: _buildSadhuCharacter(state),
            );
          },
        );
      },
    );
  }

  Widget _buildSadhuCharacter(GuideState state) {
    final size = widget.width ?? widget.height ?? 600.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _SadhuPainter(state, _animationController.value),
              );
            },
          ),
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: size * 0.6,
                  height: size * 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the sadhu character
class _SadhuPainter extends CustomPainter {
  final GuideState state;
  final double animationValue;

  _SadhuPainter(this.state, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const bodyColor = AppColors.saffron;
    const robeColor = AppColors.earthBrown;

    final breathingOffset =
        state == GuideState.sitting || state == GuideState.idle
            ? math.sin(animationValue * 2 * math.pi) * 2
            : 0.0;

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

    final headPaint = Paint()
      ..color = const Color(0xFFFFE0B2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.6 + breathingOffset),
      radius * 0.35,
      headPaint,
    );

    final eyePaint = Paint()
      ..color = AppColors.primaryText
      ..style = PaintingStyle.fill;

    if (state == GuideState.speaking) {
      final mouthOffset = math.sin(animationValue * 4 * math.pi) * 3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx,
              center.dy - radius * 0.4 + breathingOffset + mouthOffset),
          width: 8,
          height: 4 + mouthOffset.abs(),
        ),
        eyePaint,
      );
    } else if (state == GuideState.praying) {
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
      final pointingPaint = Paint()
        ..color = const Color(0xFFFFE0B2)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(center.dx + radius * 0.3,
            center.dy - radius * 0.2 + breathingOffset),
        Offset(center.dx + radius * 0.5,
            center.dy - radius * 0.4 + breathingOffset),
        pointingPaint,
      );
    }

    canvas.drawCircle(
      Offset(center.dx - radius * 0.15,
          center.dy - radius * 0.65 + breathingOffset),
      3,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.15,
          center.dy - radius * 0.65 + breathingOffset),
      3,
      eyePaint,
    );

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
