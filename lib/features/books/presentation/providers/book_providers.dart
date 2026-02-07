import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/datasources/supabase_granthalaya_datasource.dart';
import '../../data/models/granthalaya_models.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

/// True = Read mode (show book resume bar). False = Listen mode (audio player only).
final granthalayaReadModeProvider = StateProvider<bool>((ref) => true);

final _granthalayaDataSourceProvider = Provider<SupabaseGranthalayaDataSource>((ref) {
  return SupabaseGranthalayaDataSource();
});

final deitiesProvider = FutureProvider<List<DeityModel>>((ref) async {
  return ref.read(_granthalayaDataSourceProvider).getDeities();
});

final resourceCardsProvider = FutureProvider<List<ResourceCardModel>>((ref) async {
  return ref.read(_granthalayaDataSourceProvider).getResourceCards();
});

final deepDiveProvider = FutureProvider<List<DeepDiveModel>>((ref) async {
  return ref.read(_granthalayaDataSourceProvider).getDeepDiveArticles();
});

final audioCategoriesProvider = FutureProvider<List<AudioCategoryModel>>((ref) async {
  return ref.read(_granthalayaDataSourceProvider).getAudioCategories();
});

final audioWisdomCardsProvider = FutureProvider.family<List<AudioWisdomCardModel>, String?>((ref, categorySlug) async {
  return ref.read(_granthalayaDataSourceProvider).getAudioWisdomCards(categorySlug: categorySlug);
});

final audioInProgressProvider = FutureProvider<List<AudioInProgressModel>>((ref) async {
  return ref.read(_granthalayaDataSourceProvider).getAudioInProgress();
});
