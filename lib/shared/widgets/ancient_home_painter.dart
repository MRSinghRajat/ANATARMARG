import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Enhanced 2D painter for ancient Indian home architecture
/// Draws wooden planks, beams, floor, and furniture elements
class AncientHomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background - warm earth tone
    final backgroundPaint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw wooden floor planks (horizontal lines)
    final floorPaint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (double y = size.height * 0.6; y < size.height; y += 30) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        floorPaint,
      );
    }

    // Draw vertical wall planks (left wall)
    final wallPaint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (double x = 0; x < size.width * 0.3; x += 25) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * 0.6),
        wallPaint,
      );
    }

    // Draw wooden beam in top-left corner
    final beamPaint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final beamRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width * 0.15, size.height * 0.08),
      const Radius.circular(4),
    );
    canvas.drawRRect(beamRect, beamPaint);

    // Draw simple window frame (right side)
    final windowPaint = Paint()
      ..color = AppColors.lightGreen.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.1,
        size.width * 0.25,
        size.height * 0.2,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(windowRect, windowPaint);
    
    // Window cross frame
    final windowFramePaint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(size.width * 0.825, size.height * 0.1),
      Offset(size.width * 0.825, size.height * 0.3),
      windowFramePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.95, size.height * 0.2),
      windowFramePaint,
    );

    // Draw simple table/shelf (right side, behind character area)
    final tablePaint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final tableRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.65,
        size.height * 0.45,
        size.width * 0.3,
        size.height * 0.08,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(tableRect, tablePaint);

    // Draw simple books on table (stacked rectangles)
    final bookPaint = Paint()
      ..color = AppColors.warmOrange.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    // Book 1
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.68, size.height * 0.43, 20, 25),
      bookPaint,
    );
    // Book 2
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.72, size.height * 0.42, 20, 25),
      Paint()..color = AppColors.lightGreen.withOpacity(0.6)..style = PaintingStyle.fill,
    );
    // Book 3
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.76, size.height * 0.44, 20, 25),
      Paint()..color = AppColors.saffron.withOpacity(0.6)..style = PaintingStyle.fill,
    );

    // Draw subtle texture lines on floor
    final texturePaint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (double y = size.height * 0.6; y < size.height; y += 30) {
      for (double x = 0; x < size.width; x += 50) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + 30, y),
          texturePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
