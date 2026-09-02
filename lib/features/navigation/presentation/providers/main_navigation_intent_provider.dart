import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/bottom_nav_bar.dart';

/// One-shot intent from nested flows (e.g. Ashram task → Aangan → Mandir).
class MainNavIntent {
  final NavItem nav;
  /// When [nav] is [NavItem.home]: `0` = Aatma, `1` = Mandir.
  final int? aanganTabIndex;
  /// When [nav] is [NavItem.books]: `0` = Read, `1` = Listen, `2` = Journey.
  final int? granthalayaTabIndex;

  const MainNavIntent(this.nav, {this.aanganTabIndex, this.granthalayaTabIndex});
}

final mainNavIntentProvider = StateProvider<MainNavIntent?>((ref) => null);

/// Consumed by [AanganScreen] after [MainNavigationScreen] switches tab.
final aanganPendingTabProvider = StateProvider<int?>((ref) => null);

/// Consumed by [BooksLibraryScreen] after [MainNavigationScreen] switches tab.
final granthalayaPendingTabProvider = StateProvider<int?>((ref) => null);

/// While non-null, [BottomNavBar] pulses this tab (first-run / replay tab tour).
final tabTourHighlightProvider = StateProvider<NavItem?>((ref) => null);
