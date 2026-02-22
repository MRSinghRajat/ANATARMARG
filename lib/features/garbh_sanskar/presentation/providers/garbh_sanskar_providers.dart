import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../../data/repositories/garbh_sanskar_repository.dart';

// ============================================================
// REPOSITORY PROVIDER
// ============================================================

final garbhSanskarRepositoryProvider = Provider<GarbhSanskarRepository>((ref) {
  return GarbhSanskarRepository();
});

// ============================================================
// JOURNEY PROVIDER
// ============================================================

final pregnancyJourneyProvider =
    FutureProvider<UserPregnancyJourney?>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getJourney();
});

// Notifier for journey state management
class JourneyNotifier extends StateNotifier<AsyncValue<UserPregnancyJourney?>> {
  final GarbhSanskarRepository _repo;

  JourneyNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final journey = await _repo.getJourney();
      state = AsyncValue.data(journey);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveJourney(UserPregnancyJourney journey) async {
    try {
      final saved = await _repo.upsertJourney(journey);
      if (saved != null) {
        state = AsyncValue.data(saved);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> switchToPostnatal(DateTime birthDate, {String? babyName}) async {
    final success =
        await _repo.switchToPostnatal(birthDate, babyName: babyName);
    if (success) await _load();
    return success;
  }

  Future<void> refresh() => _load();
}

final journeyNotifierProvider =
    StateNotifierProvider<JourneyNotifier, AsyncValue<UserPregnancyJourney?>>(
        (ref) {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return JourneyNotifier(repo);
});

// ============================================================
// CONTENT PROVIDERS
// ============================================================

final prenatalContentProvider =
    FutureProvider<List<GarbhSanskarContent>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getContentByPhase('prenatal');
});

final postnatalContentProvider =
    FutureProvider<List<GarbhSanskarContent>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getContentByPhase('postnatal');
});

final newbornContentProvider =
    FutureProvider<List<GarbhSanskarContent>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getContentByPhase('newborn');
});

final contentByTypeProvider =
    FutureProvider.family<List<GarbhSanskarContent>, ({String phase, String type})>(
        (ref, params) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getContentByType(params.phase, params.type);
});

// ============================================================
// SAMSKARAS PROVIDERS
// ============================================================

final prenatalSamskarasProvider =
    FutureProvider<List<GarbhSamskara>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getPrenatalSamskaras();
});

final postnatalSamskarasProvider =
    FutureProvider<List<GarbhSamskara>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getPostnatalSamskaras();
});

final completedSamskarasProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getCompletedSamskaras();
});

// ============================================================
// LULLABIES PROVIDER
// ============================================================

final lullabiesProvider = FutureProvider<List<Lullaby>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getLullabies();
});

// ============================================================
// PROGRESS PROVIDER
// ============================================================

final completedContentIdsProvider =
    FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getCompletedContentIds();
});

// ============================================================
// MILESTONES PROVIDER
// ============================================================

final babyMilestonesProvider =
    FutureProvider<List<BabyMilestone>>((ref) async {
  final repo = ref.watch(garbhSanskarRepositoryProvider);
  return repo.getMilestones();
});
