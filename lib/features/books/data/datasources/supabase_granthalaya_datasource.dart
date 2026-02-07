import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/granthalaya_models.dart';

class SupabaseGranthalayaDataSource {
  final SupabaseService _supabase = SupabaseService();

  List<dynamic> _toList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    final data = (response as dynamic).data;
    if (data is List) return data;
    return [];
  }

  /// Fetch deities for Explore Deities / Divine Presence
  Future<List<DeityModel>> getDeities() async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.deitiesTable)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final list = _toList(response);
      return list
          .map((json) => DeityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching deities: $e');
      return [];
    }
  }

  /// Fetch resource cards (Terminology, Pronunciation)
  Future<List<ResourceCardModel>> getResourceCards() async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.granthalayaResourceCardsTable)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final list = _toList(response);
      return list
          .map(
              (json) => ResourceCardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching resource cards: $e');
      return [];
    }
  }

  /// Fetch deep dive articles (Today's Reflection / Read mode Deep Dive)
  Future<List<DeepDiveModel>> getDeepDiveArticles() async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.granthalayaDeepDiveTable)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final list = _toList(response);
      return list
          .map((json) => DeepDiveModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching deep dive: $e');
      return [];
    }
  }

  /// Fetch audio categories (Audio Books, Chants, etc.)
  Future<List<AudioCategoryModel>> getAudioCategories() async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.granthalayaAudioCategoriesTable)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final list = _toList(response);
      return list
          .map((json) =>
              AudioCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching audio categories: $e');
      return [];
    }
  }

  /// Fetch wisdom cards for Listen Sacred Library
  Future<List<AudioWisdomCardModel>> getAudioWisdomCards(
      {String? categorySlug}) async {
    if (!_supabase.isInitialized) return [];

    try {
      var query = _supabase.client!
          .from(SupabaseConfig.granthalayaAudioWisdomCardsTable)
          .select()
          .eq('is_active', true);

      if (categorySlug != null && categorySlug.isNotEmpty) {
        query = query.eq('category_slug', categorySlug);
      }

      final response = await query.order('order_index', ascending: true);
      final list = _toList(response);
      return list
          .map((json) =>
              AudioWisdomCardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching wisdom cards: $e');
      return [];
    }
  }

  /// Fetch audio in progress items
  Future<List<AudioInProgressModel>> getAudioInProgress() async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.granthalayaAudioInProgressTable)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final list = _toList(response);
      return list
          .map((json) =>
              AudioInProgressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching audio in progress: $e');
      return [];
    }
  }
}
