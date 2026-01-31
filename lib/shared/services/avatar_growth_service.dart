import 'dart:async';
import '../../features/gamification/data/models/avatar_model.dart';
import '../../features/gamification/data/repositories/avatar_repository.dart';
import 'guide_animation_service.dart';

/// Manages Inner Avatar growth through daily actions
/// No punishment, no shame - consistency over perfection
class AvatarGrowthService {
  static final AvatarGrowthService _instance = AvatarGrowthService._internal();
  factory AvatarGrowthService() => _instance;
  AvatarGrowthService._internal();

  final AvatarRepository _avatarRepository = AvatarRepository();
  final GuideAnimationService _guideService = GuideAnimationService();

  AvatarModel? _currentAvatar;
  bool _isInitialized = false;

  Stream<AvatarModel> get avatarStream => _avatarRepository.avatarStream;
  AvatarModel get currentAvatar => _currentAvatar ?? AvatarModel();
  bool get isInitialized => _isInitialized;

  /// Wisdom level for backward compatibility with GuideAnimationService
  int get wisdomLevel => currentAvatar.wisdomLevel;

  /// Initialize avatar - load from storage, sync with GuideAnimationService
  Future<void> initialize() async {
    if (_isInitialized) return;

    _currentAvatar = await _avatarRepository.getAvatar();
    _isInitialized = true;

    // Sync wisdom level to GuideAnimationService for Rive/AnimatedGuide
    _guideService.updateWisdomLevel(_currentAvatar!.wisdomLevel);

    // Listen for avatar changes and sync to GuideAnimationService
    _avatarRepository.avatarStream.listen((avatar) {
      _currentAvatar = avatar;
      _guideService.updateWisdomLevel(avatar.wisdomLevel);
    });
  }

  /// Record completion of a daily action (Seva, Dilemma, etc.)
  /// Avatar grows through consistency, not perfection
  Future<AvatarModel> completeAction({
    int wisdomGain = 1,
    int karmaGain = 5,
    bool extendsStreak = true,
  }) async {
    await initialize();

    final updated = await _avatarRepository.recordAction(
      wisdomGain: wisdomGain,
      karmaGain: karmaGain,
      extendsStreak: extendsStreak,
    );

    _currentAvatar = updated;
    _guideService.updateWisdomLevel(updated.wisdomLevel);

    return updated;
  }

  /// Record item received (from shop) - triggers animation
  void receiveItem(String itemType) {
    _guideService.receiveItem(itemType);
  }

  /// Set animation state (sitting, speaking, etc.)
  void setAnimationState(GuideState state) {
    _guideService.setState(state);
  }

  GuideState get animationState => _guideService.currentState;
  Stream<GuideState> get animationStateStream => _guideService.stateStream;
}
