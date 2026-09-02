import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;

import 'app_analytics.dart';

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
  String get _entitlementId => dotenv.env['REVENUECAT_ENTITLEMENT_ID'] ?? 'Antar marg Pro';

  /// Production SDK key: optional per-platform keys, else single [REVENUECAT_API_KEY].
  String _platformProductionApiKey() {
    final ios = dotenv.env['REVENUECAT_API_KEY_IOS']?.trim() ?? '';
    final android = dotenv.env['REVENUECAT_API_KEY_ANDROID']?.trim() ?? '';
    final fallback = dotenv.env['REVENUECAT_API_KEY']?.trim() ?? '';
    if (kIsWeb) return fallback;
    if (defaultTargetPlatform == TargetPlatform.iOS && ios.isNotEmpty) return ios;
    if (defaultTargetPlatform == TargetPlatform.android && android.isNotEmpty) {
      return android;
    }
    return fallback;
  }

  /// Test Store key (RevenueCat dashboard → Apps & providers → Test configuration).
  /// Used only in non-release builds when [REVENUECAT_USE_TEST_STORE]=true.
  ///
  /// Release builds **must** use the Apple/Google **public SDK** keys (`appl_...` /
  /// `goog_...`). Test Store keys (`test_...`) are rejected by the SDK on TestFlight
  /// and cause "wrong API key" / configuration errors.
  String get _resolvedApiKey {
    final testKey = dotenv.env['REVENUECAT_TEST_STORE_API_KEY']?.trim() ?? '';
    final useTest = dotenv.env['REVENUECAT_USE_TEST_STORE']?.toLowerCase() == 'true';
    if (!kReleaseMode && useTest && testKey.isNotEmpty) {
      debugPrint('RevenueCat: Using Test Store API key (debug/profile only)');
      return testKey;
    }

    final prod = _platformProductionApiKey();
    if (kReleaseMode && prod.isNotEmpty && prod.startsWith('test_')) {
      debugPrint(
        'RevenueCat: Release build cannot use a Test Store key (test_...). '
        'Set REVENUECAT_API_KEY_IOS (iOS) or REVENUECAT_API_KEY to the Apple '
        'public SDK key from RevenueCat (appl_...). See .env.example.',
      );
      return '';
    }
    if (kReleaseMode &&
        prod.isNotEmpty &&
        testKey.isNotEmpty &&
        prod == testKey) {
      debugPrint(
        'RevenueCat: REVENUECAT_API_KEY matches REVENUECAT_TEST_STORE_API_KEY. '
        'Use separate Apple public key (appl_...) for store builds.',
      );
      return '';
    }
    return prod;
  }

  /// Optional Plus tier (lower tier than Pro). If unset, only Pro applies.
  String? get _plusEntitlementId {
    final v = dotenv.env['REVENUECAT_PLUS_ENTITLEMENT_ID']?.trim();
    return (v != null && v.isNotEmpty) ? v : null;
  }

  /// Pro tier entitlement id; falls back to [REVENUECAT_ENTITLEMENT_ID] / default.
  String get _proEntitlementId {
    final v = dotenv.env['REVENUECAT_PRO_ENTITLEMENT_ID']?.trim();
    if (v != null && v.isNotEmpty) return v;
    return _entitlementId;
  }

  bool get _debugMode => dotenv.env['REVENUECAT_DEBUG_MODE']?.toLowerCase() == 'true';

  bool _entitlementActive(CustomerInfo? info, String id) {
    final i = info ?? _customerInfo;
    return i?.entitlements.all[id]?.isActive ?? false;
  }

  /// Plus subscription (not Pro).
  bool hasActivePlusEntitlement([CustomerInfo? info]) {
    final id = _plusEntitlementId;
    if (id == null) return false;
    return _entitlementActive(info, id);
  }

  /// Pro subscription (highest tier).
  bool hasActiveProEntitlement([CustomerInfo? info]) {
    return _entitlementActive(info, _proEntitlementId);
  }

  /// Any paid subscription (Plus or Pro) — unlocks app premium features.
  bool hasAnyPaidEntitlement([CustomerInfo? info]) {
    return hasActiveProEntitlement(info) || hasActivePlusEntitlement(info);
  }

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

    if (_resolvedApiKey.isEmpty) {
      debugPrint('RevenueCat: API key not configured. Skipping initialization.');
      return;
    }

    try {
      // Enable debug logs in development
      if (_debugMode || kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
        debugPrint('RevenueCat: Debug logging enabled');
      }

      // Configure RevenueCat (Test Store key or platform public key)
      final configuration = PurchasesConfiguration(_resolvedApiKey);
      
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
    
    final isSubscribed = _checkAnyPaid(info);
    _subscriptionStatusController.add(isSubscribed);
    
    debugPrint('RevenueCat: Customer info updated. Subscribed: $isSubscribed');
  }

  /// Pro-only check (legacy single-entitlement apps).
  bool _checkEntitlement(CustomerInfo info) {
    final entitlement = info.entitlements.all[_entitlementId];
    return entitlement?.isActive ?? false;
  }

  /// Plus or Pro — for books, journey, ashram, etc.
  bool _checkAnyPaid(CustomerInfo info) {
    if (_checkEntitlement(info)) return true;
    return hasAnyPaidEntitlement(info);
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
      return _checkAnyPaid(info);
    } catch (e) {
      debugPrint('RevenueCat: Error checking premium status: $e');
      return false;
    }
  }

  /// Refresh customer info from RevenueCat
  Future<CustomerInfo?> refreshCustomerInfo() async {
    if (!_isInitialized && _resolvedApiKey.isEmpty) return null;

    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _customerInfoController.add(_customerInfo!);
      _subscriptionStatusController.add(_checkAnyPaid(_customerInfo!));
      return _customerInfo;
    } catch (e) {
      debugPrint('RevenueCat: Error refreshing customer info: $e');
      return null;
    }
  }

  /// Refresh offerings from RevenueCat
  Future<Offerings?> refreshOfferings() async {
    if (!_isInitialized && _resolvedApiKey.isEmpty) return null;

    try {
      _offerings = await Purchases.getOfferings();
      final o = _offerings;
      debugPrint(
        'RevenueCat: Offerings fetched. current=${o?.current?.identifier} '
        'packages=${o?.current?.availablePackages.length ?? 0}',
      );
      if (o != null && o.all.isNotEmpty) {
        for (final e in o.all.entries) {
          debugPrint(
            'RevenueCat:   offering "${e.key}" → ${e.value.availablePackages.length} package(s)',
          );
        }
      }
      return _offerings;
    } catch (e) {
      debugPrint('RevenueCat: Error fetching offerings: $e');
      return null;
    }
  }

  /// Dashboard "current" offering (may exist but have zero packages if App Store products are missing).
  Offering? get currentOffering => _offerings?.current;

  /// Prefer [currentOffering] when it has packages; otherwise first offering in [Offerings.all] that does.
  /// Helps when "current" is unset or products only load on another offering after App Store setup.
  Offering? get effectiveOffering {
    final o = _offerings;
    if (o == null) return null;
    final cur = o.current;
    if (cur != null && cur.availablePackages.isNotEmpty) return cur;
    for (final offering in o.all.values) {
      if (offering.availablePackages.isNotEmpty) return offering;
    }
    return cur;
  }

  /// Packages from [effectiveOffering] (not only [currentOffering]).
  List<Package> get availablePackages => effectiveOffering?.availablePackages ?? [];

  /// Get a specific package by type
  Package? getPackage(PackageType type) {
    final o = effectiveOffering;
    if (o == null || o.availablePackages.isEmpty) return null;
    return o.availablePackages.firstWhere(
      (p) => p.packageType == type,
      orElse: () => o.availablePackages.first,
    );
  }

  /// Get monthly package
  Package? get monthlyPackage => effectiveOffering?.monthly;

  /// Get annual package
  Package? get annualPackage => effectiveOffering?.annual;

  /// Get lifetime package
  Package? get lifetimePackage => effectiveOffering?.lifetime;

  /// Purchase a package
  Future<SubscriptionPurchaseOutcome> purchasePackage(Package package) async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      debugPrint('RevenueCat: Purchasing package: ${package.identifier}');

      final sdkResult = await Purchases.purchase(PurchaseParams.package(package));
      _customerInfo = sdkResult.customerInfo;
      _customerInfoController.add(_customerInfo!);

      final isNowPremium = _checkAnyPaid(_customerInfo!);
      _subscriptionStatusController.add(isNowPremium);

      debugPrint('RevenueCat: Purchase successful. Premium: $isNowPremium');
      await AppAnalytics.logPurchaseCompleted(productId: package.identifier);

      return SubscriptionPurchaseOutcome(
        success: true,
        customerInfo: _customerInfo!,
        isPremium: isNowPremium,
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: Purchase cancelled by user');
        return SubscriptionPurchaseOutcome(
          success: false,
          cancelled: true,
          errorMessage: 'Purchase cancelled',
        );
      }

      debugPrint('RevenueCat: Purchase error: $errorCode - ${e.message}');
      return SubscriptionPurchaseOutcome(
        success: false,
        errorCode: errorCode,
        errorMessage: e.message ?? 'Purchase failed',
      );
    } catch (e) {
      debugPrint('RevenueCat: Unexpected purchase error: $e');
      return SubscriptionPurchaseOutcome(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Non-subscription products. [productIds] are App Store / Play product identifiers.
  Future<List<StoreProduct>> getStoreProducts(List<String> productIds) async {
    if (!_isInitialized || productIds.isEmpty) return [];
    try {
      return await Purchases.getProducts(productIds);
    } catch (e) {
      debugPrint('RevenueCat: getStoreProducts error: $e');
      return [];
    }
  }

  /// Purchase a consumable / non-subscription store product.
  Future<SubscriptionPurchaseOutcome> purchaseStoreProduct(StoreProduct product) async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }
    try {
      debugPrint('RevenueCat: Purchasing store product: ${product.identifier}');
      final sdkResult = await Purchases.purchase(PurchaseParams.storeProduct(product));
      _customerInfo = sdkResult.customerInfo;
      _customerInfoController.add(_customerInfo!);
      final isNowPremium = _checkAnyPaid(_customerInfo!);
      _subscriptionStatusController.add(isNowPremium);
      return SubscriptionPurchaseOutcome(
        success: true,
        customerInfo: _customerInfo!,
        isPremium: isNowPremium,
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return SubscriptionPurchaseOutcome(
          success: false,
          cancelled: true,
          errorMessage: 'Purchase cancelled',
        );
      }
      return SubscriptionPurchaseOutcome(
        success: false,
        errorCode: errorCode,
        errorMessage: e.message ?? 'Purchase failed',
      );
    } catch (e) {
      return SubscriptionPurchaseOutcome(
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
      
      final isNowPremium = _checkAnyPaid(_customerInfo!);
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
      final LogInResult loginResult = await Purchases.logIn(userId);
      _customerInfo = loginResult.customerInfo;
      _customerInfoController.add(_customerInfo!);
      _subscriptionStatusController.add(_checkAnyPaid(_customerInfo!));
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
      _subscriptionStatusController.add(_checkAnyPaid(_customerInfo!));
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

  /// Present the native offer code redemption sheet (iOS 14+).
  /// On Android this may no-op; users can use Restore or redeem via Play Store.
  Future<void> presentCodeRedemptionSheet() async {
    if (!_isInitialized) return;
    try {
      await Purchases.presentCodeRedemptionSheet();
      await syncPurchases();
    } catch (e) {
      debugPrint('RevenueCat: presentCodeRedemptionSheet error: $e');
      rethrow;
    }
  }

  /// Sync local purchases with RevenueCat (e.g. after redeeming a code outside the app).
  Future<CustomerInfo?> syncPurchases() async {
    if (!_isInitialized && _resolvedApiKey.isEmpty) return null;
    try {
      await Purchases.syncPurchases();
      return await refreshCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat: syncPurchases error: $e');
      return null;
    }
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

/// Result of a purchase attempt (app wrapper; SDK uses a different [PurchaseResult] type).
class SubscriptionPurchaseOutcome {
  final bool success;
  final bool cancelled;
  final CustomerInfo? customerInfo;
  final bool isPremium;
  final PurchasesErrorCode? errorCode;
  final String? errorMessage;

  SubscriptionPurchaseOutcome({
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
