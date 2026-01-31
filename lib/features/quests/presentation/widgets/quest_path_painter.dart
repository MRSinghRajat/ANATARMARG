import 'package:flutter/material.dart';

/// Paints a winding path connecting quest nodes.
/// [nodeCount] number of nodes; path winds left-right for each segment.
/// [segmentHeight] approximate height per segment.
class WindingPathPainter extends CustomPainter {
  final int nodeCount;
  final double segmentHeight;
  final double pathStrokeWidth;
  final double windOffset;

  WindingPathPainter({
    required this.nodeCount,
    this.segmentHeight = 120,
    this.pathStrokeWidth = 10,
    this.windOffset = 50,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCount < 2) return;

    final centerX = size.width / 2;
    final pathPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = pathStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(centerX + (0.isEven ? -windOffset : windOffset), 40);

    for (int i = 1; i < nodeCount; i++) {
      final y = 40.0 + i * segmentHeight;
      final x = centerX + (i.isEven ? -windOffset : windOffset);
      final prevY = 40.0 + (i - 1) * segmentHeight;
      final ctrlX = centerX + (i.isOdd ? windOffset : -windOffset);
      final ctrlY = (prevY + y) / 2;
      path.quadraticBezierTo(ctrlX, ctrlY, x, y);
    }

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant WindingPathPainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount ||
        oldDelegate.segmentHeight != segmentHeight;
  }
}
