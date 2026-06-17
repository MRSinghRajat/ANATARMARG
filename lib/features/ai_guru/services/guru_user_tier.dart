import '../../../core/config/app_config.dart';
import '../../../core/services/revenuecat_service.dart';
import '../../../shared/services/feature_gate_config.dart';
import '../../../shared/services/premium_service.dart';

/// Maps RevenueCat Plus / Pro entitlements to [UserTier] for AI Guru.
Future<UserTier> resolveGuruUserTier() async {
  if (AppConfig.premiumGrantAll) return UserTier.pro;
  if (!await PremiumService.instance.isPremium) return UserTier.free;
  final info = RevenueCatService.instance.customerInfo;
  if (RevenueCatService.instance.hasActiveProEntitlement(info)) {
    return UserTier.pro;
  }
  if (RevenueCatService.instance.hasActivePlusEntitlement(info)) {
    return UserTier.plus;
  }
  // Premium but no explicit Plus/Pro split (legacy main entitlement).
  return UserTier.pro;
}

UserTier tierForPremium(bool isPremium) {
  if (!isPremium) return UserTier.free;
  return UserTier.pro;
}
