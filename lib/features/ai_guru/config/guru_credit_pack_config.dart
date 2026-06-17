import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App Store / Play product IDs for consumable AI Guru credits (configure in RevenueCat + stores).
class GuruCreditPackConfig {
  GuruCreditPackConfig._();

  /// (credits, store product id) — only entries with non-empty ids are offered.
  static List<({int credits, String productId})> configuredPacks() {
    final pairs = <({int credits, String productId})>[];
    void add(int credits, String? envKey) {
      final id = envKey?.trim();
      if (id != null && id.isNotEmpty) {
        pairs.add((credits: credits, productId: id));
      }
    }

    add(10, dotenv.env['GURU_CREDITS_PRODUCT_ID_10']);
    add(30, dotenv.env['GURU_CREDITS_PRODUCT_ID_30']);
    add(100, dotenv.env['GURU_CREDITS_PRODUCT_ID_100']);
    return pairs;
  }
}
