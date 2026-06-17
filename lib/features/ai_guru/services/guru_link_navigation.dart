import 'package:flutter/material.dart';

import '../../../core/utils/app_router.dart';

/// Resolves tappable Guru tags to in-app navigation (best-effort).
void navigateFromGuruLink(BuildContext context, String type, String value) {
  final v = value.trim();
  if (v.isEmpty) return;

  switch (type) {
    case 'JOURNEY':
      final isUuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      ).hasMatch(v);
      if (isUuid) {
        Navigator.pushNamed(
          context,
          AppRouter.journeyHome,
          arguments: {'userJourneyId': v},
        );
      } else {
        Navigator.pushNamed(
          context,
          AppRouter.journeySetup,
          arguments: {'slug': v},
        );
      }
      return;
    case 'VERSE':
      Navigator.pushNamed(context, AppRouter.listenAllBooks);
      return;
    case 'STORY':
      Navigator.pushNamed(context, AppRouter.listenAllStories);
      return;
    case 'SACRED':
      Navigator.pushNamed(context, AppRouter.listenAllTexts);
      return;
    case 'MANTRA':
      Navigator.pushNamed(context, AppRouter.listenAllChants);
      return;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
  }
}
