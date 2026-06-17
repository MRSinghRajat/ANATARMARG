import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Public **https://** URLs for legal pages.
///
/// **RevenueCat Paywall** (and similar) ask for Terms / Privacy links that open in the
/// system in-app browser (SFSafariViewController / Chrome Custom Tabs). Those fields need
/// **full HTTPS URLs**, not Flutter routes like `/legal/terms`.
///
/// **Paste into the RevenueCat dashboard** (Paywall → footer / legal URL fields), or App Store
/// Connect metadata, using the same strings as [defaultTermsOfServiceHttps] and
/// [defaultPrivacyPolicyHttps], unless you override via `.env`.
///
/// Host the HTML from `web/legal/terms.html` and `web/legal/privacy.html` at these paths on your domain.
class LegalUrls {
  LegalUrls._();

  /// Default Terms URL (copy-paste for RC paywall / App Store if you use antarmarg.app hosting).
  static const String defaultTermsOfServiceHttps =
      'https://antarmarg.app/legal/terms.html';

  /// Default Privacy URL (copy-paste for RC paywall / App Store).
  static const String defaultPrivacyPolicyHttps =
      'https://antarmarg.app/legal/privacy.html';

  /// Resolved URL: `.env` `LEGAL_TERMS_URL` if set, else [defaultTermsOfServiceHttps].
  static String get termsOfServiceUrl {
    if (!dotenv.isInitialized) return defaultTermsOfServiceHttps;
    final u = dotenv.env['LEGAL_TERMS_URL']?.trim();
    return (u != null && u.isNotEmpty) ? u : defaultTermsOfServiceHttps;
  }

  /// Resolved URL: `.env` `LEGAL_PRIVACY_URL` if set, else [defaultPrivacyPolicyHttps].
  static String get privacyPolicyUrl {
    if (!dotenv.isInitialized) return defaultPrivacyPolicyHttps;
    final u = dotenv.env['LEGAL_PRIVACY_URL']?.trim();
    return (u != null && u.isNotEmpty) ? u : defaultPrivacyPolicyHttps;
  }
}
