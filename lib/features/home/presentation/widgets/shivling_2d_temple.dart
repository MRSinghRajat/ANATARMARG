import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Simple 2D Shivlinga + yoni base — replaces the 3D WebView when user picks Shivling in Mandir.
class Shivling2DTemple extends StatefulWidget {
  const Shivling2DTemple({super.key});

  @override
  State<Shivling2DTemple> createState() => _Shivling2DTempleState();
}

class _Shivling2DTempleState extends State<Shivling2DTemple>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1623),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) {
              return CustomPaint(
                painter: _ShivlingBackdropPainter(t: _glow.value),
              );
            },
          ),
          Center(
            child: CustomPaint(
              size: const Size(220, 320),
              painter: _ShivlingPainter(),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 120,
            child: Text(
              'ॐ नमः शिवाय',
              textAlign: TextAlign.center,
              style: GoogleFonts.tenorSans(
                fontSize: 15,
                letterSpacing: 3,
                color: AppColors.ashramAccentGold.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShivlingBackdropPainter extends CustomPainter {
  _ShivlingBackdropPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.04 + 0.02 * math.sin(t * math.pi * 2);
    final rect = Offset.zero & size;
    final g = RadialGradient(
      center: const Alignment(0, -0.2),
      radius: 0.95,
      colors: [
        AppColors.ashramAccentGold.withValues(alpha: pulse),
        const Color(0xFF0B1623).withValues(alpha: 0),
      ],
      stops: const [0.0, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = g);
  }

  @override
  bool shouldRepaint(covariant _ShivlingBackdropPainter old) => old.t != t;
}

class _ShivlingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Yoni base (peetha) — flat ellipse
    final baseRect = Rect.fromCenter(
      center: Offset(cx, h * 0.78),
      width: w * 0.92,
      height: h * 0.14,
    );
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A4038),
          const Color(0xFF2A2420),
        ],
      ).createShader(baseRect);
    canvas.drawOval(baseRect, basePaint);
    canvas.drawOval(
      baseRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.ashramAccentGold.withValues(alpha: 0.35),
    );

    // Inner water ring (simplified)
    final inner = Rect.fromCenter(
      center: Offset(cx, h * 0.76),
      width: w * 0.38,
      height: h * 0.08,
    );
    canvas.drawOval(
      inner,
      Paint()
        ..color = const Color(0xFF1A3048).withValues(alpha: 0.85),
    );

    // Lingam body
    final lingW = w * 0.22;
    final lingTop = h * 0.22;
    final lingBottom = h * 0.72;
    final lingRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, (lingTop + lingBottom) / 2),
        width: lingW,
        height: lingBottom - lingTop,
      ),
      Radius.circular(lingW * 0.45),
    );
    final stone = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFF5C5854),
          Color(0xFF2E2C2A),
          Color(0xFF1E1C1B),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(lingRect.outerRect);
    canvas.drawRRect(lingRect, stone);
    canvas.drawRRect(
      lingRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.08),
    );

    // Tripundra (three horizontal lines)
    final tripY = lingTop + (lingBottom - lingTop) * 0.28;
    for (var i = 0; i < 3; i++) {
      final dy = tripY + i * 5.5;
      canvas.drawLine(
        Offset(cx - lingW * 0.28, dy),
        Offset(cx + lingW * 0.28, dy),
        Paint()
          ..strokeWidth = 2
          ..color = AppColors.ashramAccentGold.withValues(alpha: 0.55 - i * 0.08)
          ..strokeCap = StrokeCap.round,
      );
    }

    // Subtle bindu
    canvas.drawCircle(
      Offset(cx, tripY - 10),
      3,
      Paint()..color = AppColors.ashramAccentGold.withValues(alpha: 0.5),
    );

    // Soft ground shadow under lingam
    final shadow = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx, h * 0.74),
        width: w * 0.5,
        height: h * 0.06,
      ));
    canvas.drawShadow(shadow, Colors.black, 8, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
