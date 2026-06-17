import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/legal_urls.dart';
import '../../../../core/theme/app_colors.dart';
import '../../legal_content.dart';

/// Scrollable legal document with optional “open in browser” for the public URL.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.sections,
    required this.externalUrl,
  });

  final String title;
  final List<LegalSection> sections;
  final String externalUrl;

  Future<void> _openExternal(BuildContext context) async {
    final uri = Uri.tryParse(externalUrl);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepAsh,
      appBar: AppBar(
        backgroundColor: AppColors.deepAsh,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _openExternal(context),
            child: Text(
              'Open link',
              style: GoogleFonts.poppins(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Last updated: ${LegalContent.lastUpdated}',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            externalUrl,
            style: GoogleFonts.inter(
              color: AppColors.primaryOrange.withValues(alpha: 0.9),
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryOrange.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          for (final s in sections) ...[
            Text(
              s.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.body,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

/// Terms of Service screen (in-app + [LegalUrls.termsOfServiceUrl]).
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Terms of Service',
      sections: LegalContent.termsSections,
      externalUrl: LegalUrls.termsOfServiceUrl,
    );
  }
}

/// Privacy Policy screen (in-app + [LegalUrls.privacyPolicyUrl]).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Privacy Policy',
      sections: LegalContent.privacySections,
      externalUrl: LegalUrls.privacyPolicyUrl,
    );
  }
}
