import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

/// Funnel analytics. No PII — only event names, tab labels, and Supabase uid.
class AppAnalytics {
  AppAnalytics._();

  static const String onboardingComplete = 'onboarding_complete';
  static const String paywallViewed = 'paywall_viewed';
  static const String purchaseCompleted = 'purchase_completed';
  static const String tabViewed = 'tab_viewed';

  static Future<void> log(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final analytics = FirebaseAnalytics.instance;
      final uid = SupabaseService().currentUserId;
      if (uid != null && uid.isNotEmpty) {
        await analytics.setUserId(id: uid);
      }
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      if (kDebugMode) debugPrint('AppAnalytics.log($name) failed: $e');
    }
  }

  static Future<void> logOnboardingComplete() => log(onboardingComplete);

  static Future<void> logPaywallViewed({String source = 'unknown'}) =>
      log(paywallViewed, parameters: {'source': source});

  static Future<void> logPurchaseCompleted({String? productId}) => log(
        purchaseCompleted,
        parameters: {
          if (productId != null && productId.isNotEmpty) 'product_id': productId,
        },
      );

  static Future<void> logTabViewed(String tabName) =>
      log(tabViewed, parameters: {'tab': tabName});
}
