import 'package:flutter/material.dart';
import 'package:rive/rive.dart';


class NatureVisitorWidget extends StatefulWidget {
  const NatureVisitorWidget({super.key});

  @override
  State<NatureVisitorWidget> createState() => NatureVisitorWidgetState();
}

class NatureVisitorWidgetState extends State<NatureVisitorWidget> with SingleTickerProviderStateMixin {
  Artboard? _riveArtboard;
  // Controllers
  late AnimationController _slideController;
  late Animation<Offset> _offsetAnimation;
  
  // Rive Controllers
  OneShotAnimation? _flyController;
  OneShotAnimation? _landController;
  SimpleAnimation? _blinkController;
  
  bool _isVisible = false;
  bool _isFlipped = false; // False = Face Left (Enter), True = Face Right (Exit)

  // Animation Names
  static const String animLand = 'land';
  static const String animBlink = 'blink';
  static const String animFly = 'left'; // "Left" is the fly animation usage

  @override
  void initState() {
    super.initState();
    
    // Controller for Flying In/Out translation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2s flight time
    );

    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_isFlipped) {
           // 1. Arrival Complete -> Land
           _onArrived();
        } else {
           // 2. Departure Complete -> Hide
           if (mounted) {
             setState(() {
               _isVisible = false;
               _stopFlyAnimation(); // Ensure cleanup
             });
           }
        }
      }
    });

    // Default Tween (will be updated)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(300, 0), 
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _flyController?.dispose();
    _landController?.dispose();
    _blinkController?.dispose();
    super.dispose();
  }

  // --- Public Triggers ---

  void spawn() {
    // No delay - immediate start to prevent "holding/lag" perception
    if (!mounted) return;
    
    setState(() {
      _isVisible = true;
      _isFlipped = false; // Face LEFT (Incoming from right)
    });
    
    // Ensure Rive is initialized? 
    // If not yet initialized, _playFlyAnimation might fail. 
    // We can rely on _onRiveInit triggering later if needed, but usually asset loads fast.
    _startArrivalSequence();
  }

  // --- Sequences ---

  void _startArrivalSequence() {
     // 1. Setup Slide: Right (300) -> Center (0)
     _offsetAnimation = Tween<Offset>(
       begin: const Offset(300, 0),
       end: const Offset(0, 0),
     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

     // 2. Play Fly Animation
     _playFlyAnimation();

     // 3. Move
     _slideController.reset();
     _slideController.forward();
  }

  void _onArrived() {
    // 1. Stop Flying
    _stopFlyAnimation();

    // 2. Land
    if (_riveArtboard != null) {
      _landController = OneShotAnimation(animLand, onStop: () {
        // 3. On Land Finished -> Start Blinking
        if (mounted) {
           _blinkController = SimpleAnimation(animBlink);
           _riveArtboard?.addController(_blinkController!);
           
           // 4. Wait 3 Seconds then Leave
           Future.delayed(const Duration(seconds: 3), () {
             _startDepartureSequence();
           });
        }
      });
      _riveArtboard?.addController(_landController!);
    }
  }

  void _startDepartureSequence() {
    if (!mounted) return;

    // 1. Stop Idle/Blink
    if (_blinkController != null) {
      _blinkController!.isActive = false;
      _riveArtboard?.removeController(_blinkController!);
      _blinkController = null;
    }

    // 2. FLIP to Face Right
    setState(() {
      _isFlipped = true; 
    });

    // 3. Setup Slide: Center (0) -> Right (350)
    // Note: We use the same controller but different tween/direction concept
    // Actually, simpler to just animate forward again with a new Tween
    
    // We need to re-configure the controller/tween for the exit leg
    _slideController.reset();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(400, -50), // Fly Out Right & slightly Up
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));

    // 4. Play Fly Animation
    _playFlyAnimation();

    // 5. Go
    _slideController.forward(); 
    // Usage: Listen for 'completed' again? 
    // We need to distinguish Arrival completion vs Departure completion.
    // Hack: We can just use the status listener logic differently or just set a flag.
    // Simpler: Just rely on status listener acting on 'completed' again?
    // Wait, the StatusListener calls _onArrived again if I just use .forward().
    // I should probably remove the listener or change the handler.
    // Let's protect _onArrived with a flag or check.
  }
  
  // --- Animation Helpers ---

  void _playFlyAnimation() {
    if (_riveArtboard == null) return;
    // 'left' is the fly animation. 
    // When _isFlipped = false, it looks like flying Left.
    // When _isFlipped = true, it looks like flying Right.
    _flyController = OneShotAnimation(animFly, autoplay: true); 
    _riveArtboard!.addController(_flyController!);
  }

  void _stopFlyAnimation() {
    if (_flyController != null) {
      _flyController!.isActive = false;
      _riveArtboard?.removeController(_flyController!);
      _flyController = null;
    }
  }

  void _onRiveInit(Artboard artboard) {
    _riveArtboard = artboard;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox();

    return Positioned(
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          // If we are departing (Flipped), we want to ensure we don't re-trigger _onArrived
          // Logic check: The listener calls _onArrived when status is completed.
          // Problem: Both Arrival and Departure use forward().
          // Fix: Check _isFlipped in the listener? 
          // Better: Just handle logic here or in listener properly.
          // See updated listener below in initState (needs to be updated or guarded).
          
          return Transform.translate(
            offset: _offsetAnimation.value,
            child: Transform.scale(
              scaleX: _isFlipped ? -1 : 1, // Flip Horizontally if exiting
              child: child,
            ),
          );
        },
        child: SizedBox(
          width: 80, 
          height: 80,
          child: RiveAnimation.asset(
            'assets/rive/bird.riv',
            fit: BoxFit.contain,
            onInit: _onRiveInit,
          ),
        ),
      ),
    );
  }
}
