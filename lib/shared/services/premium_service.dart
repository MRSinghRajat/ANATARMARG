import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/revenuecat_service.dart';
import '../../features/subscription/data/models/subscription_models.dart';

/// Premium subscription service.
/// 
/// This service provides a unified interface for checking premium status.
/// It uses RevenueCat for production and supports local overrides for testing.
/// 
/// Features:
/// - Real-time subscription status via streams
/// - Caching for quick access
/// - Dev mode for testing without purchases
/// - Integration with RevenueCat entitlements
class PremiumService {
  static const String _keyIsPremiumOverride = 'is_premium_override';
  static const String _keyDevModeEnabled = 'premium_dev_mode';
  
  static PremiumService? _instance;
  static PremiumService get instance => _instance ??= PremiumService._();
  PremiumService._();

  final RevenueCatService _revenueCat = RevenueCatService.instance;
  
  // Stream controller for premium status changes
  final _premiumStatusController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  // Cached premium status
  bool? _cachedIsPremium;
  bool _devModeEnabled = false;

  // Subscription status for detailed info
  SubscriptionStatus? _subscriptionStatus;
  SubscriptionStatus? get subscriptionStatus => _subscriptionStatus;

  /// Initialize the premium service
  Future<void> initialize() async {
    // Check if dev mode is enabled
    final prefs = await SharedPreferences.getInstance();
    _devModeEnabled = prefs.getBool(_keyDevModeEnabled) ?? false;
    
    // Listen to RevenueCat subscription changes
    _revenueCat.subscriptionStatusStream.listen((isSubscribed) {
      _updatePremiumStatus(isSubscribed);
    });

    _revenueCat.customerInfoStream.listen((info) {
      _subscriptionStatus = SubscriptionStatus.fromCustomerInfo(
        info,
        'Antar marg Pro',
      );
    });

    // Get initial status
    await refreshPremiumStatus();
    
    debugPrint('PremiumService: Initialized. Premium: $_cachedIsPremium, DevMode: $_devModeEnabled');
  }

  /// Update cached premium status and notify listeners
  void _updatePremiumStatus(bool isPremium) {
    _cachedIsPremium = isPremium;
    _premiumStatusController.add(isPremium);
  }

  /// Check if user has premium access.
  /// 
  /// Priority:
  /// 1. Dev mode override (for testing)
  /// 2. Local override (for testing)
  /// 3. RevenueCat entitlement check
  Future<bool> get isPremium async {
    // Check dev mode override first
    if (_devModeEnabled) {
      final prefs = await SharedPreferences.getInstance();
      final override = prefs.getBool(_keyIsPremiumOverride);
      if (override != null) {
        debugPrint('PremiumService: Using dev mode override: $override');
        return override;
      }
    }

    // Return cached value if available
    if (_cachedIsPremium != null) {
      return _cachedIsPremium!;
    }

    // Check RevenueCat
    return await _revenueCat.isPremium();
  }

  /// Synchronous check using cached value.
  /// Returns false if not yet initialized.
  bool get isPremiumSync => _cachedIsPremium ?? false;

  /// Refresh premium status from RevenueCat
  Future<bool> refreshPremiumStatus() async {
    // Check dev mode override first
    if (_devModeEnabled) {
      final prefs = await SharedPreferences.getInstance();
      final override = prefs.getBool(_keyIsPremiumOverride);
      if (override != null) {
        _cachedIsPremium = override;
        _premiumStatusController.add(override);
        return override;
      }
    }

    final isPremium = await _revenueCat.isPremium();
    _cachedIsPremium = isPremium;
    _premiumStatusController.add(isPremium);
    return isPremium;
  }

  // ============ Dev Mode Methods (for testing) ============

  /// Enable dev mode for testing premium features
  Future<void> enableDevMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDevModeEnabled, true);
    _devModeEnabled = true;
    debugPrint('PremiumService: Dev mode enabled');
  }

  /// Disable dev mode
  Future<void> disableDevMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDevModeEnabled, false);
    await prefs.remove(_keyIsPremiumOverride);
    _devModeEnabled = false;
    await refreshPremiumStatus();
    debugPrint('PremiumService: Dev mode disabled');
  }

  /// Check if dev mode is enabled
  bool get isDevModeEnabled => _devModeEnabled;

  /// Set premium status override (dev mode only)
  /// This is useful for testing premium features without making actual purchases.
  Future<void> setPremiumOverride(bool value) async {
    if (!_devModeEnabled) {
      debugPrint('PremiumService: Dev mode not enabled, cannot set override');
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremiumOverride, value);
    _cachedIsPremium = value;
    _premiumStatusController.add(value);
    debugPrint('PremiumService: Premium override set to $value');
  }

  /// Clear premium override (dev mode only)
  Future<void> clearPremiumOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsPremiumOverride);
    await refreshPremiumStatus();
    debugPrint('PremiumService: Premium override cleared');
  }

  // ============ Subscription Info Methods ============

  /// Get subscription expiration date
  DateTime? get expirationDate => _revenueCat.expirationDate;

  /// Check if in trial period
  bool get isInTrial => _revenueCat.isInTrialPeriod;

  /// Check if subscription will auto-renew
  bool get willRenew => _revenueCat.willRenew;

  /// Get active product identifier
  String? get activeProductId => _revenueCat.activeProductIdentifier;

  /// Get subscription management URL
  String? get managementUrl => _revenueCat.managementUrl;

  /// Dispose resources
  void dispose() {
    _premiumStatusController.close();
    _instance = null;
  }
}

/// Extension for easy premium checking in widgets
extension PremiumContext on PremiumService {
  /// Show paywall if not premium, otherwise execute action
  Future<bool> requirePremium({
    required Future<void> Function() action,
    required Future<void> Function() showPaywall,
  }) async {
    if (await isPremium) {
      await action();
      return true;
    } else {
      await showPaywall();
      // Check again after paywall
      if (await isPremium) {
        await action();
        return true;
      }
      return false;
    }
  }
}
