import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../../core/config/app_config.dart';

class BellWidget extends StatefulWidget {
  const BellWidget({super.key});

  @override
  State<BellWidget> createState() => _BellWidgetState();
}

class _BellWidgetState extends State<BellWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Physics parameters
  final SpringDescription _spring = const SpringDescription(
    mass: 1.0, 
    stiffness: 100.0, 
    damping: 15.0
  );

  double _dragOffset = 0.0;
  final double _maxExtension = 150.0; // Max pull distance
  
  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  DateTime _lastRingTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this, 
       upperBound: 500 // Allow overshoot for bounce
    );
    
    // Default quiet state is 0
    _controller.value = 0;
    
    _controller.addListener(() {
      setState(() {
        _dragOffset = _controller.value;
      });
    });
  }
  
  void _startDrag(DragStartDetails details) {
    _controller.stop();
  }

  void _updateDrag(DragUpdateDetails details) {
    // Add delta, but limit max extension with some resistance (logarithmic/sqrt feel)
    double newOffset = _dragOffset + details.delta.dy;
    
    // Clamp to max
    if (newOffset > _maxExtension) newOffset = _maxExtension;
    if (newOffset < 0) newOffset = 0; // Don't push up
    
    setState(() {
      _dragOffset = newOffset;
      _controller.value = newOffset;
    });
  }

  void _endDrag(DragEndDetails details) {
    // Create spring simulation from current position back to 0
    final simulation = SpringSimulation(
      _spring,
      _dragOffset, // Start
      0.0,         // End
      details.velocity.pixelsPerSecond.dy, // Initial velocity from drag
    );
    
    _controller.animateWith(simulation);
    
    // Check if pull was significant enough to ring
    if (_dragOffset > 50) {
      _playBellSound();
    }
  }

  Future<void> _playBellSound() async {
     // Debounce rings (prevent spamming)
    if (DateTime.now().difference(_lastRingTime).inMilliseconds < 1000) return;
    _lastRingTime = DateTime.now();

    final url = AppConfig.aanganBellAudioUrl;
    if (url.isEmpty) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(UrlSource(url));
      _isPlaying = true;
      
      // Stop after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
           _audioPlayer.stop(); 
           _isPlaying = false;
        }
      });
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hit area needs to be large enough to grab
    return GestureDetector(
      onVerticalDragStart: _startDrag,
      onVerticalDragUpdate: _updateDrag,
      onVerticalDragEnd: _endDrag,
      onTap: () {
         // Small tap nudge
         setState(() {
           _dragOffset = 40; 
           _controller.value = 40;
         });
         // Trigger spring back immediately
         _endDrag(DragEndDetails(velocity: Velocity.zero));
      },
      child: SizedBox(
        width: 80,
        height: 300, // Long hit area for the rope path
        child: CustomPaint(
          painter: RopePainter(
            offset: _dragOffset,
            color: const Color(0xFF5D4037), // Dark Wood/Rope color
            accentColor: const Color(0xFFFFB300), // Gold tassel
          ),
        ),
      ),
    );
  }
}

class RopePainter extends CustomPainter {
  final double offset;
  final Color color;
  final Color accentColor;

  RopePainter({
    required this.offset,
    required this.color, 
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    // Origin is top center
    
    // 1. Draw The Rope
    final Paint ropePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Resting length of rope (how far down it hangs normally)
    const double restingLength = 80.0; 
    
    // Current end point y
    final double endY = restingLength + offset;
    
    // Draw line from top to endY
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, endY),
      ropePaint,
    );

    // 2. Draw Tassel / Grip at the bottom
    final Paint tasselPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
      
    // Decorative knot
    canvas.drawCircle(Offset(centerX, endY), 6.0, tasselPaint);
    
    // Tassel body (triangle/trapezoid)
    final Path tasselPath = Path();
    tasselPath.moveTo(centerX - 4, endY + 4);
    tasselPath.lineTo(centerX + 4, endY + 4);
    tasselPath.lineTo(centerX + 8, endY + 20); // Flare out
    tasselPath.lineTo(centerX - 8, endY + 20); // Flare out
    tasselPath.close();
    
    canvas.drawPath(tasselPath, tasselPaint..color = accentColor.withOpacity(0.9));
    
    // Tassel threads check
    final Paint threadPaint = Paint()
      ..color = accentColor.withOpacity(0.6)
      ..strokeWidth = 1;
      
    canvas.drawLine(Offset(centerX - 3, endY+4), Offset(centerX-5, endY+20), threadPaint);
    canvas.drawLine(Offset(centerX + 3, endY+4), Offset(centerX+5, endY+20), threadPaint);
    
  }

  @override
  bool shouldRepaint(covariant RopePainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
