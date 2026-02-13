import 'package:purchases_flutter/purchases_flutter.dart';

/// Subscription plan types
enum SubscriptionPlanType {
  monthly,
  yearly,
  lifetime,
}

/// Subscription plan details for UI display
class SubscriptionPlan {
  final SubscriptionPlanType type;
  final String id;
  final String title;
  final String description;
  final String? priceString;
  final double? priceAmount;
  final String? currencyCode;
  final String? period;
  final String? savings;
  final bool isBestValue;
  final bool isMostPopular;
  final Package? package;

  const SubscriptionPlan({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    this.priceString,
    this.priceAmount,
    this.currencyCode,
    this.period,
    this.savings,
    this.isBestValue = false,
    this.isMostPopular = false,
    this.package,
  });

  /// Create from RevenueCat package
  factory SubscriptionPlan.fromPackage(Package package) {
    final storeProduct = package.storeProduct;
    final type = _getTypeFromPackage(package);
    
    return SubscriptionPlan(
      type: type,
      id: package.identifier,
      title: _getTitleForType(type),
      description: _getDescriptionForType(type),
      priceString: storeProduct.priceString,
      priceAmount: storeProduct.price,
      currencyCode: storeProduct.currencyCode,
      period: _getPeriodString(package),
      savings: _getSavings(type),
      isBestValue: type == SubscriptionPlanType.yearly,
      isMostPopular: type == SubscriptionPlanType.monthly,
      package: package,
    );
  }

  static SubscriptionPlanType _getTypeFromPackage(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return SubscriptionPlanType.monthly;
      case PackageType.annual:
        return SubscriptionPlanType.yearly;
      case PackageType.lifetime:
        return SubscriptionPlanType.lifetime;
      default:
        // Check identifier for custom packages
        final id = package.identifier.toLowerCase();
        if (id.contains('lifetime')) return SubscriptionPlanType.lifetime;
        if (id.contains('year') || id.contains('annual')) return SubscriptionPlanType.yearly;
        return SubscriptionPlanType.monthly;
    }
  }

  static String _getTitleForType(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.monthly:
        return 'Monthly';
      case SubscriptionPlanType.yearly:
        return 'Yearly';
      case SubscriptionPlanType.lifetime:
        return 'Lifetime';
    }
  }

  static String _getDescriptionForType(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.monthly:
        return 'Billed monthly, cancel anytime';
      case SubscriptionPlanType.yearly:
        return 'Save 50% compared to monthly';
      case SubscriptionPlanType.lifetime:
        return 'One-time purchase, forever access';
    }
  }

  static String _getPeriodString(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return '/month';
      case PackageType.annual:
        return '/year';
      case PackageType.lifetime:
        return 'one-time';
      default:
        return '';
    }
  }

  static String? _getSavings(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.yearly:
        return 'Save 50%';
      case SubscriptionPlanType.lifetime:
        return 'Best Value';
      default:
        return null;
    }
  }
}

/// User subscription status
class SubscriptionStatus {
  final bool isActive;
  final bool isLifetime;
  final bool isInTrial;
  final bool willRenew;
  final String? productId;
  final DateTime? expirationDate;
  final DateTime? purchaseDate;
  final String? managementUrl;

  const SubscriptionStatus({
    this.isActive = false,
    this.isLifetime = false,
    this.isInTrial = false,
    this.willRenew = false,
    this.productId,
    this.expirationDate,
    this.purchaseDate,
    this.managementUrl,
  });

  factory SubscriptionStatus.fromCustomerInfo(
    CustomerInfo info,
    String entitlementId,
  ) {
    final entitlement = info.entitlements.all[entitlementId];
    
    if (entitlement == null || !entitlement.isActive) {
      return const SubscriptionStatus(isActive: false);
    }

    DateTime? expDate;
    DateTime? purchDate;
    
    if (entitlement.expirationDate != null) {
      expDate = DateTime.tryParse(entitlement.expirationDate!);
    }
    if (entitlement.latestPurchaseDate != null) {
      purchDate = DateTime.tryParse(entitlement.latestPurchaseDate!);
    }

    return SubscriptionStatus(
      isActive: entitlement.isActive,
      isLifetime: expDate == null, // No expiration = lifetime
      isInTrial: entitlement.periodType == PeriodType.trial,
      willRenew: entitlement.willRenew,
      productId: entitlement.productIdentifier,
      expirationDate: expDate,
      purchaseDate: purchDate,
      managementUrl: info.managementURL,
    );
  }

  /// Get a readable status string
  String get statusText {
    if (!isActive) return 'Not subscribed';
    if (isLifetime) return 'Lifetime access';
    if (isInTrial) return 'Free trial';
    return willRenew ? 'Active' : 'Expires soon';
  }

  /// Get remaining days until expiration
  int? get daysRemaining {
    if (expirationDate == null || isLifetime) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }
}

/// Premium features available to subscribers
class PremiumFeatures {
  static const List<PremiumFeature> features = [
    PremiumFeature(
      icon: '📚',
      title: 'Unlimited Access',
      description: 'Access all books, chapters, and verses',
    ),
    PremiumFeature(
      icon: '🧘',
      title: 'Ad-Free Experience',
      description: 'Enjoy uninterrupted spiritual practice',
    ),
    PremiumFeature(
      icon: '💬',
      title: 'Unlimited AI Chat',
      description: 'Ask unlimited questions to spiritual AI',
    ),
    PremiumFeature(
      icon: '🎨',
      title: 'Exclusive Customizations',
      description: 'Unlock all sanctuary themes and items',
    ),
    PremiumFeature(
      icon: '📖',
      title: 'Offline Reading',
      description: 'Download content for offline access',
    ),
    PremiumFeature(
      icon: '🔔',
      title: 'Priority Support',
      description: 'Get faster responses from our team',
    ),
  ];
}

/// Individual premium feature
class PremiumFeature {
  final String icon;
  final String title;
  final String description;

  const PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
