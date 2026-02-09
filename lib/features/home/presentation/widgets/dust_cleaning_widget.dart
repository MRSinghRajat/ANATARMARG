import 'package:flutter/material.dart';
import 'dart:ui'; // Required for BackdropFilter
import 'package:confetti/confetti.dart';
import 'package:scratcher/scratcher.dart';
import '../../data/services/user_presence_service.dart';

class DustCleaningWidget extends StatefulWidget {
  final VoidCallback? onCleaned;

  const DustCleaningWidget({
    super.key,
    this.onCleaned,
  });

  @override
  State<DustCleaningWidget> createState() => _DustCleaningWidgetState();
}

class _DustCleaningWidgetState extends State<DustCleaningWidget> {
  final UserPresenceService _presenceService = UserPresenceService();
  late ConfettiController _confettiController;
  
  // State
  bool _isDusty = false; // Is the dust layer active?
  bool _showCleanMePrompt = true; // Show "Clean Me" text?
  bool _showCompletionMessage = false; // Show the spiritual message?
  bool _widgetVisible = false; // Is the whole widget visible in the tree?

  final GlobalKey<ScratcherState> _scratcherKey = GlobalKey<ScratcherState>();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _checkDustStatus();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _checkDustStatus() async {
    final dusty = await _presenceService.isRoomDusty();
    if (dusty) {
      if (mounted) {
        setState(() {
          _isDusty = true;
          _widgetVisible = true;
          _showCleanMePrompt = true;
          _showCompletionMessage = false;
        });
      }
    }
  }

  Future<void> _handleCleaningComplete() async {
    // 1. Mark as clean in database
    await _presenceService.cleanRoom();
    
    // 2. Play Sound (Placeholder)
    debugPrint("✨ Room Cleaned! ✨");

    // 3. Trigger Parent Callback (e.g., Sadhu Jump)
    widget.onCleaned?.call();

    // 4. UI Updates: Fade Dust, Show Message, Blast Confetti
    if (mounted) {
      setState(() {
        _isDusty = false; // Triggers Scratcher Fade Out
        _showCompletionMessage = true; // Triggers Message Fade In
      });
      _confettiController.play();
    }

    // 4. Wait, then hide everything
    await Future.delayed(const Duration(seconds: 6));
    if (mounted) {
      setState(() {
        _showCompletionMessage = false;
      });
    }

    // 5. Final cleanup
    await Future.delayed(const Duration(seconds: 1)); // Allow text fade out
    if (mounted) {
      setState(() {
        _widgetVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_widgetVisible) return const SizedBox();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 0: Blur Background
        if (_isDusty)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2), // Slight dark overlay
              ),
            ),
          ),

        // Layer 1: Dust & Scratcher (Fades out when clean)
        AnimatedOpacity(
          opacity: _isDusty ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: Scratcher(
            key: _scratcherKey,
            brushSize: 60,
            threshold: 50,
            image: Image.asset(
              "assets/images/dust_texture.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF8D6E63).withOpacity(0.95),
              ),
            ), 
            onChange: (value) {
              if (_showCleanMePrompt) {
                setState(() {
                  _showCleanMePrompt = false;
                });
              }
            },
            onThreshold: () {
              _scratcherKey.currentState?.reveal(duration: const Duration(milliseconds: 500));
              _handleCleaningComplete();
            },
            child: const SizedBox.expand(),
          ),
        ),

        // Layer 2: "Clean Me" Prompt (Only when dusty)
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: (_isDusty && _showCleanMePrompt) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: const Alignment(0, -0.3), // Slightly above center (above Sadhu's head)
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cleaning_services, color: Colors.white.withOpacity(0.9), size: 48), // Increased Size
                  const SizedBox(height: 16),
                  Text(
                    "Clean Your Aangan Daily",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28, // Bigger
                      fontWeight: FontWeight.bold, // Bold
                      letterSpacing: 1.2,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Layer 3: Sparkles (Confetti) - Only after cleaning
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.white, Colors.yellow, Colors.orangeAccent],
            gravity: 0.2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
          ),
        ),
      ],
    );
  }
}
