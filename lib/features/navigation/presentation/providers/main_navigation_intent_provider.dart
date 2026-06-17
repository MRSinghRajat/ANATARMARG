import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/bottom_nav_bar.dart';

/// Bottom bar host key for measuring layout (post-login tab tour highlight).
final GlobalKey mainNavBottomBarLayerKey =
    GlobalKey(debugLabel: 'main_nav_bottom_bar');

/// One-shot intent from nested flows (e.g. Ashram task → Aangan → Mandir).
class MainNavIntent {
  final NavItem nav;
  /// When [nav] is [NavItem.home]: `0` = Aatma, `1` = Mandir.
  final int? aanganTabIndex;

  const MainNavIntent(this.nav, {this.aanganTabIndex});
}

final mainNavIntentProvider = StateProvider<MainNavIntent?>((ref) => null);

/// Consumed by [AanganScreen] after [MainNavigationScreen] switches tab.
final aanganPendingTabProvider = StateProvider<int?>((ref) => null);

/// While non-null, [BottomNavBar] pulses this tab (first-run / replay tab tour).
final tabTourHighlightProvider = StateProvider<NavItem?>((ref) => null);
