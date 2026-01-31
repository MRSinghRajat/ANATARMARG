import 'dart:async';

enum GuideState {
  idle,
  sitting,
  speaking,
  welcoming,
  pointing,
  thinking,
  praying,
  drinking,
  eating,
}

class GuideAnimationService {
  static final GuideAnimationService _instance = GuideAnimationService._internal();
  factory GuideAnimationService() => _instance;
  GuideAnimationService._internal();

  final _stateController = StreamController<GuideState>.broadcast();
  GuideState _currentState = GuideState.sitting;
  int _wisdomLevel = 1;

  Stream<GuideState> get stateStream => _stateController.stream;
  GuideState get currentState => _currentState;
  int get wisdomLevel => _wisdomLevel;

  void setState(GuideState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void triggerAnimation(String animationName) {
    // Trigger specific animation by name
    // This will be connected to Rive controller
  }

  void updateWisdomLevel(int level) {
    _wisdomLevel = level.clamp(1, 10);
    // Wisdom level affects character color/aura
    // Level 1-3: No glow
    // Level 4-6: Subtle golden aura (10% opacity)
    // Level 7-9: Medium golden aura (20% opacity)
    // Level 10: Bright golden aura (30% opacity)
  }

  void receiveItem(String itemType) {
    // Trigger item-receive animation based on item type
    switch (itemType) {
      case 'food':
        setState(GuideState.eating);
        break;
      case 'water':
        setState(GuideState.drinking);
        break;
      case 'prayer':
        setState(GuideState.praying);
        break;
      default:
        setState(GuideState.welcoming);
    }
    
    // Return to sitting after animation
    Future.delayed(const Duration(seconds: 2), () {
      setState(GuideState.sitting);
    });
  }

  void dispose() {
    _stateController.close();
  }
}
