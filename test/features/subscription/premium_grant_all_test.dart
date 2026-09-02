import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:antarmarg/core/config/app_config.dart';

void main() {
  group('AppConfig.premiumGrantAll', () {
    test('defaults to false when PREMIUM_GRANT_ALL unset', () {
      dotenv.testLoad(fileInput: '');
      expect(AppConfig.premiumGrantAll, isFalse);
    });

    test('true in debug when PREMIUM_GRANT_ALL=true', () {
      dotenv.testLoad(fileInput: 'PREMIUM_GRANT_ALL=true');
      expect(AppConfig.premiumGrantAll, isTrue);
    });

    test('false when PREMIUM_GRANT_ALL=false', () {
      dotenv.testLoad(fileInput: 'PREMIUM_GRANT_ALL=false');
      expect(AppConfig.premiumGrantAll, isFalse);
    });

    // kReleaseMode is compile-time; release builds always get false regardless of .env.
    // Manual QA: flutter build ipa with PREMIUM_GRANT_ALL=true bundled → must still be non-Pro.
  });
}
