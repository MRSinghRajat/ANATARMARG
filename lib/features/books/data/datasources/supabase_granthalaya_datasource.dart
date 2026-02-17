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

  String? _effectiveAudioUrl(Map<String, dynamic> map) {
    final audioUrl = map['audio_url'] as String?;
    if (audioUrl != null && audioUrl.isNotEmpty) return audioUrl;
    final bucket = map['storage_bucket'] as String? ?? 'granthalaya-chants';
    final path = map['storage_path'] as String?;
    if (path != null && path.isNotEmpty && _supabase.client != null) {
      return _supabase.client!.storage.from(bucket).getPublicUrl(path);
    }
    return null;
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
          .map((json) {
            final map = json as Map<String, dynamic>;
            return AudioWisdomCardModel.fromJson(
              map,
              effectiveAudioUrl: _effectiveAudioUrl(map),
            );
          })
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
          .map((json) {
            final map = json as Map<String, dynamic>;
            return AudioInProgressModel.fromJson(
              map,
              effectiveAudioUrl: _effectiveAudioUrl(map),
            );
          })
          .toList();
    } catch (e) {
      print('Error fetching audio in progress: $e');
      return [];
    }
  }

  /// Fetch chants (Shiva chant, etc.) - audio from Supabase Storage or audio_url.
  /// Constructs playable URL: audio_url if set, else storage.from(bucket).getPublicUrl(path).
  Future<List<ChantModel>> getChants() async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.granthalayaChantsTable)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final list = _toList(response);
      final client = _supabase.client!;
      return list.map((json) {
        final map = json as Map<String, dynamic>;
        String effectiveUrl;
        final audioUrl = map['audio_url'] as String?;
        if (audioUrl != null && audioUrl.isNotEmpty) {
          effectiveUrl = audioUrl;
        } else {
          final bucket = map['storage_bucket'] as String? ?? 'granthalaya-chants';
          final path = map['storage_path'] as String?;
          if (path != null && path.isNotEmpty) {
            effectiveUrl = client.storage.from(bucket).getPublicUrl(path);
          } else {
            effectiveUrl = '';
          }
        }
        return ChantModel.fromJson(map, effectiveAudioUrl: effectiveUrl);
      }).toList();
    } catch (e) {
      print('Error fetching chants: $e');
      return [];
    }
  }

  /// Fetch user's audio in-progress items (dynamic from user DB).
  Future<List<UserAudioProgressModel>> getUserAudioProgress() async {
    if (!_supabase.isInitialized) return [];
    final userId = _supabase.currentUserId;
    if (userId == null) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userAudioProgressTable)
          .select()
          .eq('user_id', userId)
          .order('last_played_at', ascending: false);

      final list = _toList(response);
      return list
          .map((json) => UserAudioProgressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user audio progress: $e');
      return [];
    }
  }

  /// Fetch a single deity by slug (for detail screen)
  Future<DeityModel?> getDeityBySlug(String slug) async {
    if (!_supabase.isInitialized) return null;
    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.deitiesTable)
          .select()
          .eq('slug', slug)
          .maybeSingle();
      if (response == null) return null;
      return DeityModel.fromJson(response);
    } catch (e) {
      print('Error fetching deity by slug: $e');
      return null;
    }
  }

  /// Fetch all sacred texts, optionally filtered by deity
  Future<List<SacredTextModel>> getSacredTexts({String? deitySlug}) async {
    if (!_supabase.isInitialized) return [];
    try {
      var query = _supabase.client!
          .from('sacred_texts')
          .select()
          .eq('is_active', true);
      if (deitySlug != null && deitySlug.isNotEmpty) {
        query = query.eq('deity_slug', deitySlug);
      }
      final response = await query.order('order_index', ascending: true);
      final list = _toList(response);
      return list
          .map((j) => SacredTextModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching sacred texts: $e');
      return [];
    }
  }

  /// Fetch a single sacred text by slug
  Future<SacredTextModel?> getSacredTextBySlug(String slug) async {
    if (!_supabase.isInitialized) return null;
    try {
      final response = await _supabase.client!
          .from('sacred_texts')
          .select()
          .eq('slug', slug)
          .maybeSingle();
      if (response == null) return null;
      return SacredTextModel.fromJson(response);
    } catch (e) {
      print('Error fetching sacred text: $e');
      return null;
    }
  }

  /// Fetch all sacred stories, optionally filtered by deity
  Future<List<SacredStoryModel>> getSacredStories({String? deitySlug}) async {
    if (!_supabase.isInitialized) return [];
    try {
      var query = _supabase.client!
          .from('sacred_stories')
          .select()
          .eq('is_active', true);
      if (deitySlug != null && deitySlug.isNotEmpty) {
        query = query.eq('deity_slug', deitySlug);
      }
      final response = await query.order('order_index', ascending: true);
      final list = _toList(response);
      return list
          .map((j) => SacredStoryModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching sacred stories: $e');
      return [];
    }
  }

  /// Fetch distinct categories from sacred_stories
  Future<List<String>> getSacredStoryCategories() async {
    if (!_supabase.isInitialized) return [];
    try {
      final response = await _supabase.client!
          .from('sacred_stories')
          .select('category')
          .eq('is_active', true);
      final list = _toList(response);
      final cats = list
          .map((j) => (j as Map<String, dynamic>)['category'] as String?)
          .where((c) => c != null && c.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      cats.sort();
      return cats;
    } catch (e) {
      print('Error fetching sacred story categories: $e');
      return [];
    }
  }

  /// Fetch books that are linked to a deity via deity_slugs array
  Future<List<Map<String, dynamic>>> getBooksByDeity(String deitySlug) async {
    if (!_supabase.isInitialized) return [];
    try {
      final response = await _supabase.client!
          .from('books')
          .select()
          .contains('deity_slugs', [deitySlug]);
      return _toList(response).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching books by deity: $e');
      return [];
    }
  }

  /// Upsert user audio progress (when playing or position changes).
  Future<void> upsertUserAudioProgress({
    required String title,
    String tag = '',
    String? subtitle,
    String? imageUrl,
    String? audioUrl,
    String sourceType = 'chant',
    String? sourceId,
    required int currentTimeSeconds,
    required int totalTimeSeconds,
  }) async {
    if (!_supabase.isInitialized) return;
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    try {
      final now = DateTime.now().toIso8601String();
      await _supabase.client!
          .from(SupabaseConfig.userAudioProgressTable)
          .upsert({
            'user_id': userId,
            'title': title,
            'tag': tag,
            'subtitle': subtitle,
            'image_url': imageUrl ?? '',
            'audio_url': audioUrl,
            'source_type': sourceType,
            'source_id': sourceId,
            'current_time_seconds': currentTimeSeconds,
            'total_time_seconds': totalTimeSeconds,
            'last_played_at': now,
            'updated_at': now,
          }, onConflict: 'user_id,title');
    } catch (e) {
      print('Error upserting user audio progress: $e');
    }
  }
}
