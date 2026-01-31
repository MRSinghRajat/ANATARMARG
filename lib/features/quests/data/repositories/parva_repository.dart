import '../models/parva_model.dart';
import '../datasources/supabase_parva_datasource.dart';
import '../../../../core/services/supabase_service.dart';

class ParvaRepository {
  static final ParvaRepository _instance = ParvaRepository._internal();
  factory ParvaRepository() => _instance;
  ParvaRepository._internal();

  final SupabaseParvaDataSource _supabaseDataSource = SupabaseParvaDataSource();
  final SupabaseService _supabase = SupabaseService();

  // Fallback: Hardcoded parvas if Supabase is not available
  List<ParvaModel> get _defaultParvas => [
        ParvaModel(
          id: 1,
          name: 'ADI PARVA',
          subtitle: 'The Beginning',
          status: ParvaStatus.completed,
        ),
        ParvaModel(
          id: 2,
          name: 'SABHA PARVA',
          subtitle: 'The Hall',
          status: ParvaStatus.completed,
        ),
        ParvaModel(
          id: 3,
          name: 'VANA PARVA',
          subtitle: 'The Forest Exile',
          status: ParvaStatus.active,
        ),
        ParvaModel(
          id: 4,
          name: 'VIRATA PARVA',
          subtitle: 'The Incognito',
          status: ParvaStatus.locked,
          requiredLevel: 5,
        ),
        ParvaModel(
          id: 5,
          name: 'UDYOGA PARVA',
          subtitle: 'The Effort',
          status: ParvaStatus.locked,
          requiredLevel: 6,
        ),
        ParvaModel(
          id: 6,
          name: 'BHISHMA PARVA',
          subtitle: 'The Bhagavad Gita',
          status: ParvaStatus.locked,
          requiredLevel: 7,
        ),
        ParvaModel(
          id: 7,
          name: 'DRONA PARVA',
          subtitle: 'The Command',
          status: ParvaStatus.locked,
          requiredLevel: 8,
        ),
        ParvaModel(
          id: 8,
          name: 'KARNA PARVA',
          subtitle: 'The Sun-Son',
          status: ParvaStatus.locked,
          requiredLevel: 9,
        ),
        ParvaModel(
          id: 9,
          name: 'SHALYA PARVA',
          subtitle: 'The Last Battle',
          status: ParvaStatus.locked,
          requiredLevel: 10,
        ),
        ParvaModel(
          id: 10,
          name: 'SAUPTIKA PARVA',
          subtitle: 'The Night Attack',
          status: ParvaStatus.locked,
          requiredLevel: 11,
        ),
        ParvaModel(
          id: 11,
          name: 'STRI PARVA',
          subtitle: 'The Women',
          status: ParvaStatus.locked,
          requiredLevel: 12,
        ),
        ParvaModel(
          id: 12,
          name: 'SHANTI PARVA',
          subtitle: 'The Peace',
          status: ParvaStatus.locked,
          requiredLevel: 13,
        ),
        ParvaModel(
          id: 13,
          name: 'ANUSHASANA PARVA',
          subtitle: 'The Instructions',
          status: ParvaStatus.locked,
          requiredLevel: 14,
        ),
        ParvaModel(
          id: 14,
          name: 'ASHVAMEDHIKA PARVA',
          subtitle: 'The Horse Sacrifice',
          status: ParvaStatus.locked,
          requiredLevel: 15,
        ),
        ParvaModel(
          id: 15,
          name: 'ASHRAMAVASIKA PARVA',
          subtitle: 'The Hermitage',
          status: ParvaStatus.locked,
          requiredLevel: 16,
        ),
        ParvaModel(
          id: 16,
          name: 'MOUSALA PARVA',
          subtitle: 'The Clubs',
          status: ParvaStatus.locked,
          requiredLevel: 17,
        ),
        ParvaModel(
          id: 17,
          name: 'MAHAPRASTHANIKA PARVA',
          subtitle: 'The Great Journey',
          status: ParvaStatus.locked,
          requiredLevel: 18,
        ),
        ParvaModel(
          id: 18,
          name: 'SVARGAROHANA PARVA',
          subtitle: 'The Ascent to Heaven',
          status: ParvaStatus.locked,
          requiredLevel: 19,
        ),
      ];

  /// Fetch all parvas - tries Supabase first, falls back to local data
  Future<List<ParvaModel>> getAllParvas() async {
    if (_supabase.isInitialized) {
      try {
        final parvas = await _supabaseDataSource.getAllParvas();
        // Update status based on user progress if authenticated
        if (_supabase.currentUserId != null) {
          for (var parva in parvas) {
            final userStatus = await _supabaseDataSource.getUserParvaStatus(
              parva.id,
              _supabase.currentUserId!,
            );
            if (userStatus != null) {
              parva = ParvaModel(
                id: parva.id,
                name: parva.name,
                subtitle: parva.subtitle,
                status: userStatus,
                requiredLevel: parva.requiredLevel,
                description: parva.description,
                imageUrl: parva.imageUrl,
              );
            }
          }
        }
        return parvas;
      } catch (e) {
        print('Error fetching from Supabase, using local data: $e');
        return _defaultParvas;
      }
    }
    return _defaultParvas;
  }

  List<ParvaModel> get allParvas => _defaultParvas; // For synchronous access

  ParvaModel? getActiveParva() {
    try {
      return allParvas.firstWhere((p) => p.status == ParvaStatus.active);
    } catch (e) {
      return null;
    }
  }

  List<ParvaModel> getCompletedParvas() {
    return allParvas.where((p) => p.status == ParvaStatus.completed).toList();
  }

  List<ParvaModel> getLockedParvas() {
    return allParvas.where((p) => p.status == ParvaStatus.locked).toList();
  }
}
