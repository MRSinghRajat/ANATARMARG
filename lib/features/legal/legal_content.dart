/// In-app legal copy. Keep in sync with `web/legal/terms.html` and
/// `web/legal/privacy.html` when you change wording.
class LegalContent {
  LegalContent._();

  static const String lastUpdated = 'March 24, 2026';

  static const List<LegalSection> termsSections = [
    LegalSection(
      '1. Agreement',
      'By downloading, accessing, or using Antar Marg (“the App”), you agree to these Terms of Service. If you do not agree, do not use the App. We may update these terms; continued use after changes means you accept the revised terms.',
    ),
    LegalSection(
      '2. The service',
      'Antar Marg provides spiritual and wellness-oriented content and features (including reading, audio, journeys, community-style experiences, and optional subscriptions). The App is for personal, non-commercial use unless we agree otherwise in writing.',
    ),
    LegalSection(
      '3. Not medical or professional advice',
      'Content in the App is for inspiration and self-reflection only. It is not medical, psychological, legal, or religious advice. If you have health concerns, consult a qualified professional. Use of the App is at your own risk.',
    ),
    LegalSection(
      '4. Accounts',
      'You may sign in with services such as Apple or Google. You are responsible for your account credentials and for activity under your account. Notify us if you suspect unauthorized access.',
    ),
    LegalSection(
      '5. Subscriptions and purchases',
      'Paid features may be offered via in-app purchases processed by Apple (or other platform providers). Billing, renewals, and refunds are governed by the platform’s terms. We use third-party services (such as RevenueCat) to manage entitlements; their processing is subject to their policies.',
    ),
    LegalSection(
      '6. Acceptable use',
      'You agree not to misuse the App: no unlawful activity, harassment, scraping or automated access without permission, attempts to break security, reverse engineering where prohibited, or interference with other users’ experience.',
    ),
    LegalSection(
      '7. Intellectual property',
      'The App, branding, text, graphics, audio, and software are owned by us or our licensors. You receive a limited, revocable license to use the App for personal purposes. You may not copy, modify, or distribute our materials except as allowed by law or with our consent.',
    ),
    LegalSection(
      '8. Third-party services',
      'The App may rely on third parties (e.g. cloud hosting, authentication, analytics, notifications, payments). Their use is subject to their terms and privacy practices.',
    ),
    LegalSection(
      '9. Disclaimers',
      'The App is provided “as is” and “as available.” To the fullest extent permitted by law, we disclaim warranties of merchantability, fitness for a particular purpose, and non-infringement. We do not guarantee uninterrupted or error-free operation.',
    ),
    LegalSection(
      '10. Limitation of liability',
      'To the maximum extent permitted by law, we are not liable for indirect, incidental, special, consequential, or punitive damages, or loss of profits or data, arising from your use of the App. Our total liability for claims relating to the App is limited to the greater of amounts you paid us in the twelve months before the claim or fifty dollars (USD), unless mandatory law requires otherwise.',
    ),
    LegalSection(
      '11. Termination',
      'We may suspend or terminate access to the App if you violate these terms or if we discontinue the service. You may stop using the App at any time. Provisions that by nature should survive will survive termination.',
    ),
    LegalSection(
      '12. Governing law',
      'These terms are governed by the laws applicable in your jurisdiction as required by mandatory consumer protection rules, unless a different governing law is required by the platform or your place of residence.',
    ),
    LegalSection(
      '13. Contact',
      'Questions about these Terms: contact us at the support email listed in the App Store listing or on our website.',
    ),
  ];

  static const List<LegalSection> privacySections = [
    LegalSection(
      '1. Introduction',
      'This Privacy Policy describes how Antar Marg (“we,” “us”) collects, uses, and shares information when you use our mobile application. By using the App, you agree to this policy.',
    ),
    LegalSection(
      '2. Information we collect',
      '• Account and profile: information you provide when you sign in (e.g. email, name, profile photo if you choose), and preferences such as language.\n'
      '• Usage: how you interact with the App (e.g. features used, progress, reading or listening activity) to operate and improve the service.\n'
      '• Device and diagnostics: device type, OS version, app version, and crash or performance data to maintain reliability.\n'
      '• Purchases: subscription status and transaction identifiers processed by Apple (and partners such as RevenueCat) — we do not receive your full payment card details.\n'
      '• Communications: messages you send to us for support.',
    ),
    LegalSection(
      '3. How we use information',
      'We use information to provide and personalize the App, authenticate users, process subscriptions, send notifications you opt into, analyze usage in aggregate, fix bugs, comply with law, and protect safety and security.',
    ),
    LegalSection(
      '4. How we share information',
      'We share data with service providers who help us run the App, such as:\n'
      '• Cloud/database and authentication (e.g. Supabase or similar backend)\n'
      '• Subscription and entitlement management (e.g. RevenueCat)\n'
      '• Push notifications (e.g. Firebase Cloud Messaging / Apple Push Notification service)\n'
      '• Sign-in providers (Apple, Google) according to their policies\n'
      'We require processors to use data only as instructed. We may disclose information if required by law or to protect rights and safety.',
    ),
    LegalSection(
      '5. Storage and retention',
      'We retain information as long as needed to provide the App and for legitimate business purposes (e.g. legal, tax, fraud prevention). You may request deletion of your account where applicable; some data may be retained as required by law.',
    ),
    LegalSection(
      '6. Your choices and rights',
      'Depending on where you live, you may have rights to access, correct, delete, or export personal data, or to object to certain processing. Contact us to exercise these rights. You can disable push notifications in device or App settings.',
    ),
    LegalSection(
      '7. Children',
      'The App is not directed at children under 13 (or the minimum age required in your region). We do not knowingly collect personal information from children. If you believe we have, contact us and we will delete it.',
    ),
    LegalSection(
      '8. International users',
      'If you use the App from outside the country where we operate, your information may be processed in other countries where we or our providers operate, subject to applicable safeguards.',
    ),
    LegalSection(
      '9. Security',
      'We use reasonable technical and organizational measures to protect information. No method of transmission over the internet is 100% secure.',
    ),
    LegalSection(
      '10. Changes',
      'We may update this Privacy Policy. We will post the new version in the App and update the “Last updated” date. Material changes may be communicated as required by law.',
    ),
    LegalSection(
      '11. Contact',
      'Privacy questions: use the support contact shown on the App Store listing or our website.',
    ),
  ];
}

class LegalSection {
  final String title;
  final String body;

  const LegalSection(this.title, this.body);
}
