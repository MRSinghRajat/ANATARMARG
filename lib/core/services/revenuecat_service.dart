import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat service for managing in-app purchases and subscriptions.
/// 
/// This service handles:
/// - SDK initialization
/// - User identification
/// - Entitlement checking
/// - Purchase management
/// - Customer info retrieval
/// - Offering and product management
class RevenueCatService {
  static RevenueCatService? _instance;
  static RevenueCatService get instance => _instance ??= RevenueCatService._();
  RevenueCatService._();

  // Stream controller for subscription status changes
  final _subscriptionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get subscriptionStatusStream => _subscriptionStatusController.stream;

  // Stream controller for customer info changes
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  // Cached customer info
  CustomerInfo? _customerInfo;
  CustomerInfo? get customerInfo => _customerInfo;

  // Cached offerings
  Offerings? _offerings;
  Offerings? get offerings => _offerings;

  // Configuration
  String get _apiKey => dotenv.env['REVENUECAT_API_KEY'] ?? '';
  String get _entitlementId => dotenv.env['REVENUECAT_ENTITLEMENT_ID'] ?? 'Antar marg Pro';
  bool get _debugMode => dotenv.env['REVENUECAT_DEBUG_MODE']?.toLowerCase() == 'true';

  // Product identifiers (configure in RevenueCat dashboard)
  static const String productMonthly = 'monthly';
  static const String productYearly = 'yearly';
  static const String productLifetime = 'lifetime';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat SDK.
  /// Call this once during app startup.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('RevenueCat: Already initialized');
      return;
    }

    if (_apiKey.isEmpty) {
      debugPrint('RevenueCat: API key not configured. Skipping initialization.');
      return;
    }

    try {
      // Enable debug logs in development
      if (_debugMode || kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
        debugPrint('RevenueCat: Debug logging enabled');
      }

      // Configure RevenueCat
      final configuration = PurchasesConfiguration(_apiKey);
      
      // Optional: Set app user ID if you have your own user system
      // configuration.appUserID = 'your_app_user_id';
      
      await Purchases.configure(configuration);
      
      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Fetch initial customer info
      await refreshCustomerInfo();

      // Fetch offerings
      await refreshOfferings();

      _isInitialized = true;
      debugPrint('RevenueCat: Initialized successfully');
      debugPrint('RevenueCat: Entitlement ID: $_entitlementId');
    } catch (e) {
      debugPrint('RevenueCat: Initialization failed: $e');
      rethrow;
    }
  }

  /// Callback when customer info is updated
  void _onCustomerInfoUpdated(CustomerInfo info) {
    _customerInfo = info;
    _customerInfoController.add(info);
    
    final isSubscribed = _checkEntitlement(info);
    _subscriptionStatusController.add(isSubscribed);
    
    debugPrint('RevenueCat: Customer info updated. Subscribed: $isSubscribed');
  }

  /// Check if user has the premium entitlement
  bool _checkEntitlement(CustomerInfo info) {
    final entitlement = info.entitlements.all[_entitlementId];
    return entitlement?.isActive ?? false;
  }

  /// Check if user has an active premium subscription
  Future<bool> isPremium() async {
    if (!_isInitialized) {
      debugPrint('RevenueCat: Not initialized. Returning false for isPremium.');
      return false;
    }

    try {
      final info = await Purchases.getCustomerInfo();
      _customerInfo = info;
      return _checkEntitlement(info);
    } catch (e) {
      debugPrint('RevenueCat: Error checking premium status: $e');
      return false;
    }
  }

  /// Refresh customer info from RevenueCat
  Future<CustomerInfo?> refreshCustomerInfo() async {
    if (!_isInitialized && _apiKey.isEmpty) return null;

    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _customerInfoController.add(_customerInfo!);
      _subscriptionStatusController.add(_checkEntitlement(_customerInfo!));
      return _customerInfo;
    } catch (e) {
      debugPrint('RevenueCat: Error refreshing customer info: $e');
      return null;
    }
  }

  /// Refresh offerings from RevenueCat
  Future<Offerings?> refreshOfferings() async {
    if (!_isInitialized && _apiKey.isEmpty) return null;

    try {
      _offerings = await Purchases.getOfferings();
      debugPrint('RevenueCat: Offerings fetched. Current: ${_offerings?.current?.identifier}');
      return _offerings;
    } catch (e) {
      debugPrint('RevenueCat: Error fetching offerings: $e');
      return null;
    }
  }

  /// Get the current offering
  Offering? get currentOffering => _offerings?.current;

  /// Get available packages from current offering
  List<Package> get availablePackages => currentOffering?.availablePackages ?? [];

  /// Get a specific package by type
  Package? getPackage(PackageType type) {
    return currentOffering?.availablePackages.firstWhere(
      (p) => p.packageType == type,
      orElse: () => currentOffering!.availablePackages.first,
    );
  }

  /// Get monthly package
  Package? get monthlyPackage => currentOffering?.monthly;

  /// Get annual package
  Package? get annualPackage => currentOffering?.annual;

  /// Get lifetime package
  Package? get lifetimePackage => currentOffering?.lifetime;

  /// Purchase a package
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      debugPrint('RevenueCat: Purchasing package: ${package.identifier}');
      
      // Use purchasePackage method (correct API for purchases_flutter 8.x)
      _customerInfo = await Purchases.purchasePackage(package);
      _customerInfoController.add(_customerInfo!);
      
      final isNowPremium = _checkEntitlement(_customerInfo!);
      _subscriptionStatusController.add(isNowPremium);
      
      debugPrint('RevenueCat: Purchase successful. Premium: $isNowPremium');
      
      return PurchaseResult(
        success: true,
        customerInfo: _customerInfo!,
        isPremium: isNowPremium,
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: Purchase cancelled by user');
        return PurchaseResult(
          success: false,
          cancelled: true,
          errorMessage: 'Purchase cancelled',
        );
      }
      
      debugPrint('RevenueCat: Purchase error: $errorCode - ${e.message}');
      return PurchaseResult(
        success: false,
        errorCode: errorCode,
        errorMessage: e.message ?? 'Purchase failed',
      );
    } catch (e) {
      debugPrint('RevenueCat: Unexpected purchase error: $e');
      return PurchaseResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Restore previous purchases
  Future<RestoreResult> restorePurchases() async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      debugPrint('RevenueCat: Restoring purchases...');
      
      _customerInfo = await Purchases.restorePurchases();
      _customerInfoController.add(_customerInfo!);
      
      final isNowPremium = _checkEntitlement(_customerInfo!);
      _subscriptionStatusController.add(isNowPremium);
      
      debugPrint('RevenueCat: Restore successful. Premium: $isNowPremium');
      
      return RestoreResult(
        success: true,
        customerInfo: _customerInfo!,
        isPremium: isNowPremium,
        restoredPurchases: isNowPremium,
      );
    } on PlatformException catch (e) {
      debugPrint('RevenueCat: Restore error: ${e.message}');
      return RestoreResult(
        success: false,
        errorMessage: e.message ?? 'Restore failed',
      );
    } catch (e) {
      debugPrint('RevenueCat: Unexpected restore error: $e');
      return RestoreResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Identify user with a custom app user ID
  /// Call this after user logs in with your auth system
  Future<CustomerInfo?> identifyUser(String userId) async {
    if (!_isInitialized) return null;

    try {
      debugPrint('RevenueCat: Identifying user: $userId');
      final loginResult = await Purchases.logIn(userId);
      _customerInfo = loginResult.customerInfo;
      _customerInfoController.add(_customerInfo!);
      _subscriptionStatusController.add(_checkEntitlement(_customerInfo!));
      return _customerInfo;
    } catch (e) {
      debugPrint('RevenueCat: Error identifying user: $e');
      return null;
    }
  }

  /// Log out current user (switch to anonymous)
  Future<CustomerInfo?> logOut() async {
    if (!_isInitialized) return null;

    try {
      debugPrint('RevenueCat: Logging out user');
      _customerInfo = await Purchases.logOut();
      _customerInfoController.add(_customerInfo!);
      _subscriptionStatusController.add(_checkEntitlement(_customerInfo!));
      return _customerInfo;
    } catch (e) {
      debugPrint('RevenueCat: Error logging out: $e');
      return null;
    }
  }

  /// Get the current app user ID
  Future<String?> getAppUserId() async {
    if (!_isInitialized) return null;
    return await Purchases.appUserID;
  }

  /// Check if user is anonymous
  Future<bool> isAnonymous() async {
    if (!_isInitialized) return true;
    return await Purchases.isAnonymous;
  }

  /// Get subscription management URL (for managing subscription externally)
  String? get managementUrl {
    return _customerInfo?.managementURL;
  }

  /// Get active subscription expiration date
  DateTime? get expirationDate {
    final entitlement = _customerInfo?.entitlements.all[_entitlementId];
    if (entitlement?.expirationDate != null) {
      return DateTime.parse(entitlement!.expirationDate!);
    }
    return null;
  }

  /// Check if subscription is in trial period
  bool get isInTrialPeriod {
    final entitlement = _customerInfo?.entitlements.all[_entitlementId];
    return entitlement?.periodType == PeriodType.trial;
  }

  /// Check if subscription will renew
  bool get willRenew {
    final entitlement = _customerInfo?.entitlements.all[_entitlementId];
    return entitlement?.willRenew ?? false;
  }

  /// Get the product identifier of the active subscription
  String? get activeProductIdentifier {
    final entitlement = _customerInfo?.entitlements.all[_entitlementId];
    return entitlement?.productIdentifier;
  }

  /// Set user attributes (for analytics and targeting)
  Future<void> setUserAttributes({
    String? email,
    String? displayName,
    String? phoneNumber,
    Map<String, String>? customAttributes,
  }) async {
    if (!_isInitialized) return;

    try {
      if (email != null) {
        await Purchases.setEmail(email);
      }
      if (displayName != null) {
        await Purchases.setDisplayName(displayName);
      }
      if (phoneNumber != null) {
        await Purchases.setPhoneNumber(phoneNumber);
      }
      if (customAttributes != null) {
        for (final entry in customAttributes.entries) {
          await Purchases.setAttributes({entry.key: entry.value});
        }
      }
      debugPrint('RevenueCat: User attributes set');
    } catch (e) {
      debugPrint('RevenueCat: Error setting user attributes: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _subscriptionStatusController.close();
    _customerInfoController.close();
    _instance = null;
  }
}

/// Result of a purchase attempt
class PurchaseResult {
  final bool success;
  final bool cancelled;
  final CustomerInfo? customerInfo;
  final bool isPremium;
  final PurchasesErrorCode? errorCode;
  final String? errorMessage;

  PurchaseResult({
    required this.success,
    this.cancelled = false,
    this.customerInfo,
    this.isPremium = false,
    this.errorCode,
    this.errorMessage,
  });
}

/// Result of a restore attempt
class RestoreResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final bool isPremium;
  final bool restoredPurchases;
  final String? errorMessage;

  RestoreResult({
    required this.success,
    this.customerInfo,
    this.isPremium = false,
    this.restoredPurchases = false,
    this.errorMessage,
  });
}
