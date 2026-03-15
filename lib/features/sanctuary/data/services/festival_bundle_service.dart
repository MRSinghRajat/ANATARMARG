import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/festival_bundle_model.dart';

/// Persists which festival bundle is active in Aangan (Premium bundles).
class FestivalBundleService {
  /// When true, all bundles are usable without purchase (for testing).
  static const bool unlockAllBundlesForTesting = true;
  static const String _activeBundleIdKey = 'aangan_active_festival_bundle_id';
  static const String _ownedBundleIdsKey = 'aangan_owned_festival_bundle_ids';

  static final FestivalBundleService _instance = FestivalBundleService._internal();
  factory FestivalBundleService() => _instance;
  FestivalBundleService._internal();

  /// Currently active bundle id; null = use default Aangan (no festival theme).
  Future<String?> getActiveBundleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeBundleIdKey);
  }

  Future<void> setActiveBundleId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await prefs.remove(_activeBundleIdKey);
    } else {
      await prefs.setString(_activeBundleIdKey, id);
    }
  }

  /// Ids of bundles the user has unlocked (e.g. via premium or purchase).
  Future<Set<String>> getOwnedBundleIds() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_ownedBundleIdsKey);
    if (json == null || json.isEmpty) return {};
    try {
      final list = json.split(',');
      return list.where((e) => e.isNotEmpty).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> addOwnedBundleId(String id) async {
    final owned = await getOwnedBundleIds();
    owned.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownedBundleIdsKey, owned.join(','));
  }

  /// Returns the active bundle if set and valid.
  Future<FestivalBundle?> getActiveBundle() async {
    final id = await getActiveBundleId();
    if (id == null) return null;
    return FestivalBundles.byId(id);
  }

  /// Whether user can use this bundle (owned or not premium).
  /// When [unlockAllBundlesForTesting] is true, all bundles are allowed for testing.
  Future<bool> canUseBundle(FestivalBundle bundle) async {
    if (unlockAllBundlesForTesting && kDebugMode) return true;
    if (!bundle.isPremium) return true;
    final owned = await getOwnedBundleIds();
    return owned.contains(bundle.id);
  }
}
