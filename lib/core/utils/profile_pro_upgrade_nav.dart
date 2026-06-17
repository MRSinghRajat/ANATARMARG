import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/navigation/presentation/providers/main_navigation_intent_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/pro_upgrade_mini_banner.dart';

/// Brief bottom gradient banner only (no modal / no buttons).
void navigateToProfileForProUpgrade(BuildContext context, {String? message}) {
  showProUpgradeMiniBanner(context, message: message ?? 'Upgrade to Pro to unlock this');
}

/// Switches to Profile tab — e.g. explicit “Profile” CTAs that should not show the banner.
void openProfileTabForProUpgrade(BuildContext context) {
  try {
    ProviderScope.containerOf(context, listen: false)
        .read(mainNavIntentProvider.notifier)
        .state = const MainNavIntent(NavItem.profile);
  } catch (_) {}
}
