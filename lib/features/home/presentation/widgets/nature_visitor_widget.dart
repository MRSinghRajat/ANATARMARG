import 'package:flutter/material.dart';

/// Nature visitor (e.g. bird) placeholder. Shown with slide animation when spawned.
class NatureVisitorWidget extends StatefulWidget {
  const NatureVisitorWidget({super.key});

  @override
  State<NatureVisitorWidget> createState() => NatureVisitorWidgetState();
}

class NatureVisitorWidgetState extends State<NatureVisitorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _offsetAnimation;

  bool _isVisible = false;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_isFlipped) {
          _onArrived();
        } else {
          if (mounted) {
            setState(() => _isVisible = false);
          }
        }
      }
    });

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(300, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void spawn() {
    if (!mounted) return;
    setState(() {
      _isVisible = true;
      _isFlipped = false;
    });
    _startArrivalSequence();
  }

  void _startArrivalSequence() {
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(300, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.reset();
    _slideController.forward();
  }

  void _onArrived() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _startDepartureSequence();
    });
  }

  void _startDepartureSequence() {
    if (!mounted) return;
    setState(() => _isFlipped = true);
    _slideController.reset();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(400, -50),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return Transform.translate(
            offset: _offsetAnimation.value,
            child: Transform.scale(
              scaleX: _isFlipped ? -1 : 1,
              child: child,
            ),
          );
        },
        child: SizedBox(
          width: 80,
          height: 80,
          child: Icon(
            Icons.park,
            size: 64,
            color: Colors.green.shade400,
          ),
        ),
      ),
    );
  }
}
