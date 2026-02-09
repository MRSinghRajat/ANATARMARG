import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Glass-morphism container with animated shimmer ripple effect.
class GlassShimmerBox extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassShimmerBox({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
  });

  @override
  State<GlassShimmerBox> createState() => _GlassShimmerBoxState();
}

class _GlassShimmerBoxState extends State<GlassShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    return Container(
      margin: widget.margin ?? const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.matteGold.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: AppColors.charcoalCard.withOpacity(0.7),
              border: Border.all(
                color: AppColors.matteGold.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child,
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: radius,
                    child: AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, _) {
                        final t = (_shimmerAnimation.value + 1) / 2;
                        return IgnorePointer(
                          child: CustomPaint(
                            painter: _ShimmerPainter(
                              progress: t,
                              color: AppColors.matteGold.withOpacity(0.15),
                            ),
                            size: Size.infinite,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final dx = -1.5 + progress * 2.5;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(dx - 0.25, 0),
        end: Alignment(dx + 0.25, 0),
        colors: [
          Colors.transparent,
          color.withOpacity(0.3),
          color,
          color.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
