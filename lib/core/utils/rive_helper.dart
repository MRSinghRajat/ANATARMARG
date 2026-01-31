// Helper class for Rive integration
// This file will be used when Rive animation file is available

import '../../shared/services/guide_animation_service.dart';

class RiveHelper {
  // State machine input names (to be configured when Rive file is available)
  static const String stateMachineName = 'State Machine';

  // State names in Rive
  static const Map<GuideState, String> stateNames = {
    GuideState.idle: 'idle',
    GuideState.sitting: 'sitting',
    GuideState.speaking: 'speaking',
    GuideState.welcoming: 'welcoming',
    GuideState.pointing: 'pointing',
    GuideState.thinking: 'thinking',
    GuideState.praying: 'praying',
    GuideState.drinking: 'drinking',
    GuideState.eating: 'eating',
  };

  // Input names for Rive state machine
  static const String wisdomLevelInput = 'wisdomLevel';
  static const String colorInput = 'color';

  /// Get Rive file path for character
  static const String riveFilePath = 'assets/rive/sadhu_character.riv';

  /// Get Rive file path for room background (Aangan, Ashram)
  /// Place your room Rive file at: assets/rive/room.riv
  static const String roomRiveFilePath = 'assets/rive/room.riv';

  /// Check if Rive file exists
  /// This will be used to conditionally load Rive or use placeholder
  /// The app will automatically detect if the file exists at runtime
  static bool get hasRiveFile => true; // File will be checked at runtime

  /// Instructions for adding Rive file:
  /// 1. Create your old sadhu character animation in Rive
  /// 2. Add states: idle, sitting, speaking, welcoming, pointing, thinking, praying, drinking, eating
  /// 3. Create a state machine with these states
  /// 4. Add inputs for wisdomLevel (number) and color (number) for visual evolution
  /// 5. Export as .riv file
  /// 6. Place in assets/rive/sadhu_character.riv
  /// 7. Update hasRiveFile to true
  /// 8. Update AnimatedGuide widget to use Rive widget instead of CustomPainter
}
