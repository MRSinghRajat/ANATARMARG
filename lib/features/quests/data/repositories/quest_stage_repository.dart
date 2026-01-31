import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest_stage_model.dart';
import '../datasources/supabase_quest_stage_datasource.dart';
import '../../../../core/services/supabase_service.dart';

class QuestStageRepository {
  static final QuestStageRepository _instance =
      QuestStageRepository._internal();
  factory QuestStageRepository() => _instance;
  QuestStageRepository._internal();

  final SupabaseQuestStageDataSource _supabaseDataSource =
      SupabaseQuestStageDataSource();
  final SupabaseService _supabase = SupabaseService();

  static const String _completedStagesKey = 'quest_completed_stages';

  /// Mark a stage as completed (local persistence)
  /// [stageKey] should be "${parvaId}_${stageId}" or just stageId for uniqueness
  Future<void> markStageComplete(String stageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedStagesKey) ?? [];
    if (!completed.contains(stageKey)) {
      completed.add(stageKey);
      await prefs.setStringList(_completedStagesKey, completed);
    }
  }

  /// Get completed stage IDs
  Future<Set<String>> getCompletedStageIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_completedStagesKey) ?? [];
    return list.toSet();
  }

  /// Fetch quest stages for a parva - tries Supabase first, falls back to local data
  Future<List<QuestStageModel>> getStagesForParva(int parvaId) async {
    List<QuestStageModel> stages;
    if (_supabase.isInitialized) {
      try {
        stages = await _supabaseDataSource.getStagesForParva(parvaId);
        // Update status based on user progress if authenticated
        if (_supabase.currentUserId != null) {
          for (var i = 0; i < stages.length; i++) {
            final stage = stages[i];
            final userStatus = await _supabaseDataSource.getUserStageStatus(
              stage.id,
              _supabase.currentUserId!,
            );
            if (userStatus != null) {
              stages[i] = QuestStageModel(
                id: stage.id,
                parvaId: stage.parvaId,
                title: stage.title,
                description: stage.description,
                status: userStatus,
                orderIndex: stage.orderIndex,
                imageUrl: stage.imageUrl,
                content: stage.content,
              );
            }
          }
        }
      } catch (e) {
        print('Error fetching stages from Supabase, using local data: $e');
        stages = _getDefaultStages(parvaId);
      }
    } else {
      stages = _getDefaultStages(parvaId);
    }
    // Apply local completed status
    final completedIds = await getCompletedStageIds();
    return _applyLocalProgress(stages, completedIds);
  }

  List<QuestStageModel> _applyLocalProgress(
    List<QuestStageModel> stages,
    Set<String> completedIds,
  ) {
    final result = <QuestStageModel>[];
    var foundCurrent = false;
    for (var i = 0; i < stages.length; i++) {
      final stage = stages[i];
      QuestStageStatus status;
      if (completedIds.contains('${stage.parvaId}_${stage.id}') ||
          completedIds.contains(stage.id)) {
        status = QuestStageStatus.completed;
      } else if (!foundCurrent) {
        status = QuestStageStatus.current;
        foundCurrent = true;
      } else {
        status = QuestStageStatus.locked;
      }
      result.add(QuestStageModel(
        id: stage.id,
        parvaId: stage.parvaId,
        title: stage.title,
        description: stage.description,
        status: status,
        orderIndex: stage.orderIndex,
        imageUrl: stage.imageUrl,
        content: stage.content,
      ));
    }
    return result;
  }

  /// Synchronous method for fallback (used when Supabase fails)
  List<QuestStageModel> getStagesForParvaSync(int parvaId) {
    return _getDefaultStages(parvaId);
  }

  List<QuestStageModel> _getDefaultStages(int parvaId) {
    switch (parvaId) {
      case 3: // Vana Parva
        return [
          QuestStageModel(
            id: '1',
            parvaId: 3,
            title: 'KAMYAKA FOREST',
            description: 'The Pandavas enter the forest of Kamyaka.',
            status: QuestStageStatus.completed,
            orderIndex: 1,
          ),
          QuestStageModel(
            id: '2',
            parvaId: 3,
            title: 'DWAITA LAKE',
            description:
                'The sacred lake where the Pandavas spent time in reflection.',
            status: QuestStageStatus.completed,
            orderIndex: 2,
          ),
          QuestStageModel(
            id: '3',
            parvaId: 3,
            title: "INDRA'S HEAVEN",
            description:
                "Arjuna's quest for celestial weapons. Witness his divine test.",
            status: QuestStageStatus.current,
            orderIndex: 3,
          ),
          QuestStageModel(
            id: '4',
            parvaId: 3,
            title: 'YAKSHA PRASHNA',
            description: 'The Yaksha\'s questions test Yudhishthira\'s wisdom.',
            status: QuestStageStatus.locked,
            orderIndex: 4,
          ),
        ];
      case 1: // Adi Parva
        return [
          QuestStageModel(
            id: '1',
            parvaId: 1,
            title: 'BIRTH OF HEROES',
            description: 'The birth of the Pandavas and Kauravas.',
            status: QuestStageStatus.completed,
            orderIndex: 1,
          ),
          QuestStageModel(
            id: '2',
            parvaId: 1,
            title: 'CHILDHOOD',
            description: 'Growing up in Hastinapur.',
            status: QuestStageStatus.completed,
            orderIndex: 2,
          ),
          QuestStageModel(
            id: '3',
            parvaId: 1,
            title: 'HOUSE OF LAC',
            description: 'Escape from the burning house.',
            status: QuestStageStatus.current,
            orderIndex: 3,
          ),
          QuestStageModel(
            id: '4',
            parvaId: 1,
            title: 'DRAUPADI\'S SWAYAMVARA',
            description: 'Arjuna wins Draupadi.',
            status: QuestStageStatus.locked,
            orderIndex: 4,
          ),
        ];
      case 2: // Sabha Parva
        return [
          QuestStageModel(
            id: '1',
            parvaId: 2,
            title: 'THE ASSEMBLY HALL',
            description: 'The great hall built by the Pandavas.',
            status: QuestStageStatus.completed,
            orderIndex: 1,
          ),
          QuestStageModel(
            id: '2',
            parvaId: 2,
            title: 'THE DICE GAME',
            description: 'Yudhishthira loses everything.',
            status: QuestStageStatus.current,
            orderIndex: 2,
          ),
          QuestStageModel(
            id: '3',
            parvaId: 2,
            title: 'DRAUPADI\'S CRY',
            description: 'The attempt to disrobe Draupadi.',
            status: QuestStageStatus.locked,
            orderIndex: 3,
          ),
        ];
      default:
        return [
          QuestStageModel(
            id: '1',
            parvaId: parvaId,
            title: 'BEGINNING',
            description: 'Start of the journey.',
            status: QuestStageStatus.current,
            orderIndex: 1,
          ),
          QuestStageModel(
            id: '2',
            parvaId: parvaId,
            title: 'NEXT STAGE',
            description: 'Continue the path.',
            status: QuestStageStatus.locked,
            orderIndex: 2,
          ),
        ];
    }
  }
}
