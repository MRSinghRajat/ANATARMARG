import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'dart:math' as math;
import '../services/guide_animation_service.dart';
import '../services/avatar_growth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/rive_helper.dart';

// Rive-powered animated guide character
// Uses Rive animation if file is available, otherwise falls back to CustomPainter
// Animations: idle (default), jump (on tap), walk (when isOnYatraPage)
class AnimatedGuide extends ConsumerStatefulWidget {
  final double? width;
  final double? height;
  final Alignment alignment;
  /// When true, character plays walk animation (e.g. on Yatra tab)
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
  StateMachineController? _riveController;
  SimpleAnimation?
      _simpleAnimationController; // For animations without state machine
  Artboard? _riveArtboard;
  bool _isRiveLoaded = false;
  bool _isPlayingJump = false;

  // Store service instances (initialized at declaration - safe for IndexedStack)
  final GuideAnimationService _guideService = GuideAnimationService();
  final AvatarGrowthService _avatarGrowthService = AvatarGrowthService();

  String get _baseAnimation =>
      widget.isOnYatraPage ? 'walk' : 'idle';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _loadRiveFile();

    // Listen to state changes and update Rive outside of build()
    _guideService.stateStream.listen((state) {
      if (mounted) {
        _updateRiveState(state);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedGuide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOnYatraPage != widget.isOnYatraPage &&
        _simpleAnimationController != null &&
        _riveArtboard != null &&
        !_isPlayingJump) {
      _switchToAnimation(_baseAnimation);
    }
  }

  Future<void> _loadRiveFile() async {
    try {
      final file = await RiveFile.asset(RiveHelper.riveFilePath);
      final artboard = file.mainArtboard;

      // Try to create controller with the specified state machine name
      StateMachineController? controller;
      try {
        controller = StateMachineController.fromArtboard(
          artboard,
          RiveHelper.stateMachineName,
        );
      } catch (e) {
        // If that fails, try the first available state machine
        if (artboard.stateMachines.isNotEmpty) {
          try {
            controller = StateMachineController.fromArtboard(
              artboard,
              artboard.stateMachines.first.name,
            );
          } catch (e2) {
            debugPrint('Rive: Could not create controller: $e2');
          }
        }
      }

      if (controller != null) {
        // CRITICAL: Add controller BEFORE setState to ensure it's active
        artboard.addController(controller);

        // The state machine automatically starts in its entry state
        // and begins playing the animation for that state
        // The Rive widget will call artboard.advance() each frame to play animations

        debugPrint('Rive: ✅ State machine controller added');
        debugPrint(
            'Rive: Available inputs: ${controller.inputs.map((i) => "${i.name} (${i.runtimeType})").join(", ")}');
        debugPrint('Rive: ✅ Animations should now be playing automatically');
      } else {
        // No state machine - add SimpleAnimation controller to play animations
        debugPrint('Rive: ⚠️ No state machine found');
        debugPrint('Rive: Artboard animations: ${artboard.animations.length}');
        if (artboard.animations.isNotEmpty) {
          debugPrint(
              'Rive: Available animations: ${artboard.animations.map((a) => a.name).join(", ")}');
          // Use idle, walk, jump from new Rive file
          final baseAnim = _baseAnimation;
          final animationToPlay = artboard.animations
                  .where((a) => a.name.toLowerCase() == baseAnim.toLowerCase())
                  .firstOrNull ??
              artboard.animations
                  .where((a) => a.name.toLowerCase() == 'idle')
                  .firstOrNull ??
              artboard.animations.first;
          debugPrint('Rive: Playing animation: ${animationToPlay.name}');

          try {
            final simpleController = SimpleAnimation(animationToPlay.name);
            artboard.addController(simpleController);
            _simpleAnimationController = simpleController;
            debugPrint(
                'Rive: ✅ SimpleAnimation controller added - ${animationToPlay.name}');
          } catch (e) {
            debugPrint('Rive: ❌ Could not add SimpleAnimation controller: $e');
          }
        } else {
          debugPrint('Rive: ⚠️ No animations found on artboard');
        }
      }

      setState(() {
        _riveArtboard = artboard;
        _riveController = controller;
        _isRiveLoaded = true;
      });

      debugPrint(
          'Rive: ✅ Loaded successfully - animations should play automatically');
    } catch (e) {
      debugPrint('Rive: ❌ Load failed: $e');
      setState(() => _isRiveLoaded = false);
    }
  }

  void _updateRiveState(GuideState state) {
    if (_riveController == null || !mounted) return;

    // Update wisdom level input if available (NumberInput)
    try {
      final wisdomInput =
          _riveController!.findInput<double>(RiveHelper.wisdomLevelInput);
      if (wisdomInput != null) {
        wisdomInput.value = _wisdomLevel.toDouble();
      }
    } catch (e) {
      // Input not found - that's okay
    }

    // Update color input if available (NumberInput)
    try {
      final colorInput =
          _riveController!.findInput<double>(RiveHelper.colorInput);
      if (colorInput != null) {
        colorInput.value = (_wisdomLevel / 10.0).clamp(0.0, 1.0);
      }
    } catch (e) {
      // Input not found - that's okay
    }

    // IMPORTANT: Rive state machines work differently
    // State transitions happen automatically based on:
    // 1. Trigger inputs (boolean inputs that fire transitions)
    // 2. Number inputs (that control which state is active)
    // 3. State machine conditions

    // Try to find a trigger input that matches the state name
    final stateName = RiveHelper.stateNames[state] ?? state.name.toLowerCase();

    // Try different trigger input patterns
    final triggerPatterns = [
      stateName, // Direct match: 'sitting', 'speaking', etc.
      '${stateName}Trigger', // With 'Trigger' suffix
      'goTo$stateName', // With 'goTo' prefix
      'set$stateName', // With 'set' prefix
    ];

    for (final pattern in triggerPatterns) {
      try {
        // Try bool input (most common for trigger inputs)
        final trigger = _riveController!.findInput<bool>(pattern);
        if (trigger != null) {
          // Fire the trigger - this will cause state machine to transition
          trigger.value = true;
          debugPrint('Rive: ✅ Triggered state transition: $pattern');
          // Reset after a short delay to allow retriggering
          // Note: Some triggers auto-reset, but we reset manually to be safe
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted && _riveController != null) {
              try {
                trigger.value = false;
              } catch (e) {
                // Ignore - trigger may have auto-reset
              }
            }
          });
          return;
        }
      } catch (e) {
        // Continue to next pattern
      }
    }

    // Debug: Show what inputs are actually available
    debugPrint(
        'Rive: Available inputs for state change: ${_riveController!.inputs.map((i) => "${i.name} (${i.runtimeType})").join(", ")}');

    // If no trigger found, try number input for state index
    try {
      final stateInput = _riveController!.findInput<double>('state');
      if (stateInput != null) {
        stateInput.value = state.index.toDouble();
        debugPrint('Rive: ✅ Set state number: ${state.index}');
      }
    } catch (e) {
      // No state number input - that's okay
    }

    // Note: If your Rive file has animations but no state machine,
    // the animations should play automatically. The state machine
    // controller just allows you to control which animation plays.
  }

  @override
  void dispose() {
    _riveController?.dispose();
    _simpleAnimationController?.dispose();
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

            // Update Rive state after build completes (not during build)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateRiveState(state);
            });

            return Align(
              alignment: widget.alignment,
              child: _isRiveLoaded && _riveArtboard != null
                  ? _buildRiveCharacter()
                  : _buildSadhuCharacter(state),
            );
          },
        );
      },
    );
  }

  void _onCharacterTapped() {
    // On tap: play jump animation
    if (_riveController != null && mounted) {
      _triggerTapAnimation();
    } else if (_simpleAnimationController != null &&
        _riveArtboard != null &&
        mounted &&
        !_isPlayingJump) {
      _playJumpAnimation();
    }
  }

  void _switchToAnimation(String animationName) {
    if (_riveArtboard == null) return;
    final anim = _riveArtboard!.animations
        .where((a) => a.name.toLowerCase() == animationName.toLowerCase())
        .firstOrNull;
    if (anim == null) return;
    _riveArtboard!.removeController(_simpleAnimationController!);
    _simpleAnimationController!.dispose();
    _simpleAnimationController = SimpleAnimation(anim.name);
    _riveArtboard!.addController(_simpleAnimationController!);
  }

  void _playJumpAnimation() {
    if (_riveArtboard == null || _simpleAnimationController == null) return;
    final jumpAnim = _riveArtboard!.animations
        .where((a) => a.name.toLowerCase() == 'jump')
        .firstOrNull;
    if (jumpAnim == null) return;
    _isPlayingJump = true;
    _riveArtboard!.removeController(_simpleAnimationController!);
    _simpleAnimationController!.dispose();
    _simpleAnimationController = SimpleAnimation(jumpAnim.name);
    _riveArtboard!.addController(_simpleAnimationController!);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _riveArtboard != null) {
        _isPlayingJump = false;
        _switchToAnimation(_baseAnimation);
      }
    });
  }

  void _triggerTapAnimation() {
    // If we have a state machine controller, try jump trigger
    if (_riveController != null) {
      final triggerNames = ['jump', 'tap', 'click', 'interact'];
      for (final name in triggerNames) {
        try {
          final boolTrigger = _riveController!.findInput<bool>(name);
          if (boolTrigger != null) {
            boolTrigger.value = true;
            debugPrint('Rive: ✅ Fired trigger: $name');
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted && _riveController != null) {
                try {
                  boolTrigger.value = false;
                } catch (e) {}
              }
            });
            return;
          }
        } catch (e) {}
      }
    }
    // SimpleAnimation: play jump on tap
    if (_simpleAnimationController != null &&
        _riveArtboard != null &&
        !_isPlayingJump) {
      _playJumpAnimation();
    }
  }

  Widget _buildRiveCharacter() {
    final size = widget.width ?? 200.0;

    if (_riveArtboard == null) {
      // Fallback if artboard is null
      return _buildSadhuCharacter(GuideState.sitting);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rive animation - full size for display
          SizedBox(
            width: size,
            height: size,
            child: Rive(
              artboard: _riveArtboard!,
              fit: BoxFit.contain,
              antialiasing: true,
            ),
          ),
          // Tap target: only the center (sadhu) triggers jump, not the surrounding area
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: _onCharacterTapped,
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

  Widget _buildSadhuCharacter(GuideState state) {
    final size = widget.width ?? 600.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Character body (fallback CustomPainter)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _SadhuPainter(state, _animationController.value),
              );
            },
          ),
          // Tap target: only the center (sadhu) triggers jump
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: _onCharacterTapped,
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

// Custom painter for the old sadhu character
class _SadhuPainter extends CustomPainter {
  final GuideState state;
  final double animationValue;

  _SadhuPainter(this.state, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Body color (saffron/orange)
    const bodyColor = AppColors.saffron;
    const robeColor = AppColors.earthBrown;

    // Breathing animation for sitting/idle
    final breathingOffset =
        state == GuideState.sitting || state == GuideState.idle
            ? math.sin(animationValue * 2 * math.pi) * 2
            : 0.0;

    // Draw robe (lower body)
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

    // Draw body (upper)
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

    // Draw head
    final headPaint = Paint()
      ..color = const Color(0xFFFFE0B2) // Light skin tone
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.6 + breathingOffset),
      radius * 0.35,
      headPaint,
    );

    // Draw eyes based on state
    final eyePaint = Paint()
      ..color = AppColors.primaryText
      ..style = PaintingStyle.fill;

    if (state == GuideState.speaking) {
      // Animated mouth for speaking
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
      // Hands in prayer position
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
      // Pointing gesture
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

    // Draw eyes
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

    // Draw beard (old sadhu characteristic)
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
