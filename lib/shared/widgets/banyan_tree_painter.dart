import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Paints a stylized banyan tree with sages and golden book motif for Sacred Epics UI.
class BanyanTreePainter extends CustomPainter {
  final Color treeColor;
  final Color accentColor;
  final Color figureColor;

  BanyanTreePainter({
    this.treeColor = const Color(0xFF2D5016),
    this.accentColor = AppColors.warmOrange,
    this.figureColor = const Color(0xFF8B7355),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // Golden border circle
    final borderPaint = Paint()
      ..color = accentColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Background gradient fill
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          treeColor.withOpacity(0.3),
          treeColor.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Draw stylized banyan tree trunk
    final trunkPath = Path();
    final trunkWidth = radius * 0.15;
    trunkPath.moveTo(center.dx - trunkWidth, center.dy + radius * 0.3);
    trunkPath.lineTo(center.dx - trunkWidth * 0.5, center.dy);
    trunkPath.lineTo(center.dx, center.dy - radius * 0.2);
    trunkPath.lineTo(center.dx + trunkWidth * 0.5, center.dy);
    trunkPath.lineTo(center.dx + trunkWidth, center.dy + radius * 0.3);
    trunkPath.close();
    canvas.drawPath(
      trunkPath,
      Paint()..color = treeColor.withOpacity(0.9),
    );

    // Draw hanging roots (banyan characteristic)
    for (var i = -1; i <= 1; i++) {
      final rootPath = Path();
      final x = center.dx + (i * radius * 0.25);
      rootPath.moveTo(x, center.dy - radius * 0.1);
      rootPath.quadraticBezierTo(
        x + 20,
        center.dy + radius * 0.2,
        x,
        center.dy + radius * 0.35,
      );
      canvas.drawPath(
        rootPath,
        Paint()
          ..color = treeColor.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Draw canopy (simplified foliage)
    final canopyPaint = Paint()
      ..color = treeColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.5),
      radius * 0.4,
      canopyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
      radius * 0.3,
      canopyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.2, center.dy - radius * 0.3),
      radius * 0.25,
      canopyPaint,
    );

    // Draw two figures (sages) - simplified circles for bodies
    final elderY = center.dy + radius * 0.15;
    final youngerY = center.dy + radius * 0.2;

    // Elder figure (orange robes)
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, elderY),
      radius * 0.08,
      Paint()..color = accentColor.withOpacity(0.8),
    );
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, elderY - radius * 0.12),
      radius * 0.05,
      Paint()..color = figureColor,
    );

    // Younger figure
    canvas.drawCircle(
      Offset(center.dx + radius * 0.15, youngerY),
      radius * 0.06,
      Paint()..color = figureColor.withOpacity(0.9),
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.15, youngerY - radius * 0.1),
      radius * 0.04,
      Paint()..color = figureColor,
    );

    // Golden book icon between roots
    final bookRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.1),
      width: radius * 0.2,
      height: radius * 0.15,
    );
    canvas.drawRect(
      bookRect,
      Paint()..color = accentColor.withOpacity(0.9),
    );
    canvas.drawLine(
      Offset(bookRect.center.dx - 2, bookRect.top),
      Offset(bookRect.center.dx - 2, bookRect.bottom),
      Paint()
        ..color = accentColor.withOpacity(0.5)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
