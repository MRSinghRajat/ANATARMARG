import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sanctuary_customization_model.dart';

/// Service for managing sanctuary customization.
/// Handles persistence to SharedPreferences (offline) and Supabase (sync).
/// 
/// Key features:
/// - Singleton pattern for consistent state across app
/// - Supabase sync for cross-device persistence
/// - Local storage for offline support
/// - Stream-based updates for reactive UI
class SanctuaryCustomizationService {
  static final SanctuaryCustomizationService _instance = SanctuaryCustomizationService._internal();
  factory SanctuaryCustomizationService() => _instance;
  SanctuaryCustomizationService._internal();

  static const String _localPrefsKey = 'sanctuary_customization_v2';
  static const String _purchasedItemsKey = 'sanctuary_purchased_items_v2';
  static const String _templeGroundKey = 'temple_ground_type';

  final _customizationController = StreamController<SanctuaryCustomization>.broadcast();
  SanctuaryCustomization _currentCustomization = SanctuaryCustomization.defaultConfig;
  Set<String> _purchasedItems = {};
  TempleGroundType _templeGroundType = TempleGroundType.mud;
  bool _isInitialized = false;
  bool _isLoading = false;
  Completer<void>? _initCompleter;

  Stream<SanctuaryCustomization> get customizationStream => _customizationController.stream;
  SanctuaryCustomization get currentCustomization => _currentCustomization;
  TempleGroundType get templeGroundType => _templeGroundType;
  Set<String> get purchasedItems => _purchasedItems;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Initialize the service - loads from Supabase first (source of truth), fallback to local
  /// Safe to call multiple times - uses completer to prevent race conditions
  Future<void> initialize() async {
    // If already initialized, just broadcast current state
    if (_isInitialized) {
      _customizationController.add(_currentCustomization);
      return;
    }
    
    // If currently initializing, wait for it
    if (_initCompleter != null) {
      await _initCompleter!.future;
      _customizationController.add(_currentCustomization);
      return;
    }
    
    // Start initialization
    _initCompleter = Completer<void>();
    _isLoading = true;
    
    try {
      // Check if user is logged in
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        // User is logged in - Supabase is source of truth
        final loaded = await _loadFromSupabase(userId);
        if (!loaded) {
          // No Supabase data, try local storage
          await _loadFromLocalStorage();
          // Push to Supabase for future syncs
          await _saveToSupabase(userId);
        }
      } else {
        // No user - use local storage only (but this shouldn't happen per requirements)
        await _loadFromLocalStorage();
      }
      
      _isInitialized = true;
      _isLoading = false;
      _customizationController.add(_currentCustomization);
      _initCompleter!.complete();
    } catch (e) {
      print('Error initializing sanctuary customization: $e');
      _currentCustomization = SanctuaryCustomization.defaultConfig;
      _purchasedItems = _getDefaultPurchasedItems();
      _isInitialized = true;
      _isLoading = false;
      _customizationController.add(_currentCustomization);
      _initCompleter!.complete();
    }
  }

  /// Wait for initialization to complete
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
    } else {
      await initialize();
    }
  }

  /// Force reload from Supabase (source of truth)
  Future<void> refresh() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId != null) {
      await _loadFromSupabase(userId);
    } else {
      await _loadFromLocalStorage();
    }
    
    _customizationController.add(_currentCustomization);
  }

  /// Load customization from Supabase
  Future<bool> _loadFromSupabase(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('sanctuary_customization')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        final customizationData = response['customization_data'];
        final purchasedData = response['purchased_items'] as List<dynamic>?;
        
        if (customizationData != null) {
          final Map<String, dynamic> jsonData;
          if (customizationData is String) {
            jsonData = jsonDecode(customizationData) as Map<String, dynamic>;
          } else {
            jsonData = customizationData as Map<String, dynamic>;
          }
          _currentCustomization = SanctuaryCustomization.fromJson(jsonData);
        }
        
        if (purchasedData != null) {
          _purchasedItems = purchasedData.map((e) => e.toString()).toSet();
        } else {
          _purchasedItems = _getDefaultPurchasedItems();
        }

        // Temple ground type is local-only; load from prefs
        final prefs = await SharedPreferences.getInstance();
        final groundName = prefs.getString(_templeGroundKey);
        if (groundName != null) {
          _templeGroundType = TempleGroundType.values.firstWhere(
            (e) => e.name == groundName,
            orElse: () => TempleGroundType.mud,
          );
        }

        // Cache locally for offline support
        await _saveToLocalStorage();
        return true;
      }

      return false;
    } catch (e) {
      print('Error loading sanctuary customization from Supabase: $e');
      return false;
    }
  }

  /// Load customization from SharedPreferences (offline fallback)
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load customization
      final customizationJson = prefs.getString(_localPrefsKey);
      if (customizationJson != null) {
        final decoded = jsonDecode(customizationJson) as Map<String, dynamic>;
        _currentCustomization = SanctuaryCustomization.fromJson(decoded);
      } else {
        _currentCustomization = SanctuaryCustomization.defaultConfig;
      }
      
      // Load purchased items
      final purchasedJson = prefs.getStringList(_purchasedItemsKey);
      if (purchasedJson != null) {
        _purchasedItems = purchasedJson.toSet();
      } else {
        _purchasedItems = _getDefaultPurchasedItems();
      }

      // Load temple ground type
      final groundName = prefs.getString(_templeGroundKey);
      if (groundName != null) {
        _templeGroundType = TempleGroundType.values.firstWhere(
          (e) => e.name == groundName,
          orElse: () => TempleGroundType.mud,
        );
      }
    } catch (e) {
      print('Error loading sanctuary customization from local storage: $e');
      _currentCustomization = SanctuaryCustomization.defaultConfig;
      _purchasedItems = _getDefaultPurchasedItems();
    }
  }

  /// Get default purchased items (all free/default items)
  Set<String> _getDefaultPurchasedItems() {
    return {
      'omStyle_${OmStyle.classic.name}',
      'ringStyle_${RingStyle.singleRing.name}',
      'ringColor_${RingColor.gold.name}',
      'animationStyle_${SanctuaryAnimationStyle.gentle.name}',
      'backgroundStyle_${BackgroundStyle.cosmicGradient.name}',
      'glowColor_${GlowColor.gold.name}',
      'frameStyle_${FrameStyle.none.name}',
      'specialEffect_${SpecialEffect.none.name}',
      'particleStyle_${ParticleStyle.none.name}',
    };
  }

  /// Save to local storage (cache)
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localPrefsKey, jsonEncode(_currentCustomization.toJson()));
      await prefs.setStringList(_purchasedItemsKey, _purchasedItems.toList());
      await prefs.setString(_templeGroundKey, _templeGroundType.name);
    } catch (e) {
      print('Error saving sanctuary customization to local storage: $e');
    }
  }

  /// Save to Supabase (source of truth)
  Future<bool> _saveToSupabase(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase.from('sanctuary_customization').upsert({
        'user_id': userId,
        'customization_data': _currentCustomization.toJson(),
        'purchased_items': _purchasedItems.toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
      
      return true;
    } catch (e) {
      print('Error saving sanctuary customization to Supabase: $e');
      return false;
    }
  }

  /// Check if an item is purchased
  bool isItemPurchased(String category, String itemName) {
    final key = '${category}_$itemName';
    return _purchasedItems.contains(key);
  }

  /// Check if an item is the current selection
  bool isItemSelected(String category, String itemName) {
    switch (category) {
      case 'omStyle':
        return _currentCustomization.omStyle.name == itemName;
      case 'ringStyle':
        return _currentCustomization.ringStyle.name == itemName;
      case 'ringColor':
        return _currentCustomization.ringColor.name == itemName;
      case 'animationStyle':
        return _currentCustomization.animationStyle.name == itemName;
      case 'backgroundStyle':
        return _currentCustomization.backgroundStyle.name == itemName;
      case 'glowColor':
        return _currentCustomization.glowColor.name == itemName;
      case 'deityImage':
        return _currentCustomization.deityImageId == itemName;
      case 'frameStyle':
        return _currentCustomization.frameStyle.name == itemName;
      case 'specialEffect':
        return _currentCustomization.specialEffect.name == itemName;
      case 'particleStyle':
        return _currentCustomization.particleStyle.name == itemName;
      case 'templeGround':
        return _templeGroundType.name == itemName;
      default:
        return false;
    }
  }

  /// Set temple ground type (persists locally)
  Future<void> setTempleGroundType(TempleGroundType type) async {
    if (_templeGroundType == type) return;
    _templeGroundType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_templeGroundKey, type.name);
  }

  /// Purchase an item (deducts coins via CoinService externally)
  Future<bool> purchaseItem(String category, String itemName) async {
    final key = '${category}_$itemName';
    
    if (_purchasedItems.contains(key)) {
      return true; // Already purchased
    }
    
    _purchasedItems.add(key);
    
    // Save to both local and Supabase
    await _saveToLocalStorage();
    
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await _saveToSupabase(userId);
    }
    
    return true;
  }

  /// Apply a customization option - this is the main method for changing customization
  Future<void> applyCustomization({
    OmStyle? omStyle,
    RingStyle? ringStyle,
    RingColor? ringColor,
    SanctuaryAnimationStyle? animationStyle,
    BackgroundStyle? backgroundStyle,
    GlowColor? glowColor,
    String? deityImageId,
    bool clearDeityImage = false,
    double? deityImageScale,
    BoxFit? deityImageFit,
    FrameStyle? frameStyle,
    SpecialEffect? specialEffect,
    ParticleStyle? particleStyle,
  }) async {
    // Update current customization
    _currentCustomization = _currentCustomization.copyWith(
      omStyle: omStyle,
      ringStyle: ringStyle,
      ringColor: ringColor,
      animationStyle: animationStyle,
      backgroundStyle: backgroundStyle,
      glowColor: glowColor,
      deityImageId: deityImageId,
      clearDeityImage: clearDeityImage,
      deityImageScale: deityImageScale,
      deityImageFit: deityImageFit,
      frameStyle: frameStyle,
      specialEffect: specialEffect,
      particleStyle: particleStyle,
    );
    
    // Broadcast change immediately for responsive UI
    _customizationController.add(_currentCustomization);
    
    // Save to local storage first (fast)
    await _saveToLocalStorage();
    
    // Then sync to Supabase (may be slow, but critical)
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      final success = await _saveToSupabase(userId);
      if (!success) {
        print('Warning: Failed to save customization to Supabase');
      }
    }
  }

  /// Reset to default customization
  Future<void> resetToDefault() async {
    _currentCustomization = SanctuaryCustomization.defaultConfig;
    _customizationController.add(_currentCustomization);
    
    await _saveToLocalStorage();
    
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await _saveToSupabase(userId);
    }
  }

  /// Get total cost to unlock all items
  int getTotalUnlockCost() {
    int total = 0;
    
    for (final style in OmStyle.values) {
      if (!isItemPurchased('omStyle', style.name)) {
        total += style.coinCost;
      }
    }
    for (final style in RingStyle.values) {
      if (!isItemPurchased('ringStyle', style.name)) {
        total += style.coinCost;
      }
    }
    for (final color in RingColor.values) {
      if (!isItemPurchased('ringColor', color.name)) {
        total += color.coinCost;
      }
    }
    for (final style in SanctuaryAnimationStyle.values) {
      if (!isItemPurchased('animationStyle', style.name)) {
        total += style.coinCost;
      }
    }
    for (final style in BackgroundStyle.values) {
      if (!isItemPurchased('backgroundStyle', style.name)) {
        total += style.coinCost;
      }
    }
    for (final color in GlowColor.values) {
      if (!isItemPurchased('glowColor', color.name)) {
        total += color.coinCost;
      }
    }
    for (final deity in deityConfigs) {
      if (!isItemPurchased('deityImage', deity.id)) {
        total += ItemRarity.legendary.karmaCost;
      }
    }
    
    return total;
  }

  void dispose() {
    _customizationController.close();
  }
}
