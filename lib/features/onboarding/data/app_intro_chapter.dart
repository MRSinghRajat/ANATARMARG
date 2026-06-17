import 'package:flutter/material.dart';

/// One screen in the pre-login “how the app works” tour.
/// Optional [lottieAsset] for future motion; when null, [icon] is used with a gentle pulse.
class AppIntroChapter {
  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;
  final IconData icon;
  final String? lottieAsset;

  const AppIntroChapter({
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
    required this.icon,
    this.lottieAsset,
  });
}
