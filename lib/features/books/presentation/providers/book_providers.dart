import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/datasources/supabase_granthalaya_datasource.dart';
import '../../data/models/granthalaya_models.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

/// True = Read mode (show book resume bar). False = Listen mode (audio player only).
final granthalayaReadModeProvider = StateProvider<bool>((ref) => true);

final granthalayaDataSourceProvider = Provider<SupabaseGranthalayaDataSource>((ref) {
  return SupabaseGranthalayaDataSource();
});

final deitiesProvider = FutureProvider<List<DeityModel>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getDeities();
});

final resourceCardsProvider = FutureProvider<List<ResourceCardModel>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getResourceCards();
});

final deepDiveProvider = FutureProvider<List<DeepDiveModel>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getDeepDiveArticles();
});

final audioCategoriesProvider = FutureProvider<List<AudioCategoryModel>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getAudioCategories();
});

final audioWisdomCardsProvider = FutureProvider.family<List<AudioWisdomCardModel>, String?>((ref, categorySlug) async {
  return ref.read(granthalayaDataSourceProvider).getAudioWisdomCards(categorySlug: categorySlug);
});

final audioInProgressProvider = FutureProvider<List<AudioInProgressModel>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getAudioInProgress();
});

/// User's audio in-progress from DB (dynamic, no hardcoded).
final userAudioProgressProvider = FutureProvider<List<UserAudioProgressModel>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getUserAudioProgress();
});

final chantsProvider = FutureProvider<List<ChantModel>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getChants();
});

/// Chants filtered by deity slug - for Divine Presence deity→track relationship
final chantsByDeityProvider = FutureProvider.family<List<ChantModel>, String>((ref, deitySlug) async {
  final chants = await ref.watch(chantsProvider.future);
  return chants.where((c) => (c.deitySlug ?? '').toLowerCase() == deitySlug.toLowerCase()).toList();
});
