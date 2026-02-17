import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/datasources/supabase_granthalaya_datasource.dart';
import '../../data/models/granthalaya_models.dart';
import '../../data/models/book_model.dart';

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

// ── Sacred Texts (Chalisas, Stotras, Mantras) ──

/// All sacred texts, optionally filtered by deity
final sacredTextsProvider = FutureProvider.family<List<SacredTextModel>, String?>((ref, deitySlug) async {
  return ref.read(granthalayaDataSourceProvider).getSacredTexts(deitySlug: deitySlug);
});

/// Featured sacred texts (for home page)
final featuredSacredTextsProvider = FutureProvider<List<SacredTextModel>>((ref) async {
  final all = await ref.read(granthalayaDataSourceProvider).getSacredTexts();
  return all.where((t) => t.isFeatured).toList();
});

// ── Sacred Stories (Granthalaya collection, separate from daily_stories) ──

/// All sacred stories from dedicated table, optionally by deity
final sacredStoriesCollectionProvider = FutureProvider.family<List<SacredStoryModel>, String?>((ref, deitySlug) async {
  return ref.read(granthalayaDataSourceProvider).getSacredStories(deitySlug: deitySlug);
});

/// Distinct categories from sacred_stories table
final sacredStoryCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return ref.read(granthalayaDataSourceProvider).getSacredStoryCategories();
});

/// Currently selected sacred story category (null = All).
final selectedSacredStoryCategoryProvider = StateProvider<String?>((ref) => null);

// ── Books by Deity ──

/// Books linked to a deity via deity_slugs array
final booksByDeityProvider = FutureProvider.family<List<BookModel>, String>((ref, deitySlug) async {
  final ds = ref.read(granthalayaDataSourceProvider);
  final rows = await ds.getBooksByDeity(deitySlug);
  return rows.map((j) => BookModel.fromJson(j)).toList();
});

// ── Deity Detail ──

/// Fetch single deity by slug with full metadata
final deityDetailProvider = FutureProvider.family<DeityModel?, String>((ref, slug) async {
  return ref.read(granthalayaDataSourceProvider).getDeityBySlug(slug);
});
