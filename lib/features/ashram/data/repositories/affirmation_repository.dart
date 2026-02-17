import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_clock.dart';
import '../models/affirmation_model.dart';

/// Provides daily affirmations for the Ashram stream.
/// Tracks completed affirmations per day (strikethrough + reorder).
class AffirmationRepository {
  static final AffirmationRepository _instance = AffirmationRepository._internal();
  factory AffirmationRepository() => _instance;
  AffirmationRepository._internal();

  static const String _completedKeyPrefix = 'ashram_affirmation_completed_';

  /// Get completed affirmation IDs for today
  Future<Set<String>> getCompletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_completedKeyPrefix${_todayString()}';
    final list = prefs.getStringList(key);
    return list != null ? list.toSet() : {};
  }

  /// Toggle completion for an affirmation
  Future<void> toggleCompleted(String id) async {
    final completed = await getCompletedIds();
    final prefs = await SharedPreferences.getInstance();
    final key = '$_completedKeyPrefix${_todayString()}';

    if (completed.contains(id)) {
      completed.remove(id);
    } else {
      completed.add(id);
    }
    await prefs.setStringList(key, completed.toList());
  }

  String _todayString() {
    final n = AppClock.now();
    return '${n.year}_${n.month}_${n.day}';
  }

  static const List<AffirmationModel> _affirmations = [
    AffirmationModel(id: '1', text: 'Embrace inner peace today', iconName: 'auto_awesome'),
    AffirmationModel(id: '2', text: 'Recall three blessings', iconName: 'favorite_border'),
    AffirmationModel(id: '3', text: 'I am a vessel of light', iconName: 'wb_sunny'),
    AffirmationModel(id: '4', text: 'Take five deep breaths', iconName: 'air'),
    AffirmationModel(id: '5', text: 'My mind is still and calm', iconName: 'psychology'),
    AffirmationModel(id: '6', text: 'Forgive a past grievance', iconName: 'spa'),
    AffirmationModel(id: '7', text: 'I walk the path of truth', iconName: 'self_improvement'),
  ];

  Future<List<AffirmationModel>> getDailyAffirmations() async {
    return List.from(_affirmations);
  }
}
