// Garbh Sanskar route constants
// Import and add these to AppRouter.generateRoute() in app_router.dart

// Routes:
// '/garbh-sanskar-setup'  → GarbhSanskarSetupScreen
// '/garbh-sanskar-home'   → GarbhSanskarHomeScreen

// To add to AppRouter.generateRoute():
//
// import '../../features/garbh_sanskar/presentation/screens/garbh_sanskar_setup_screen.dart';
// import '../../features/garbh_sanskar/presentation/screens/garbh_sanskar_home_screen.dart';
//
// case '/garbh-sanskar-setup':
//   return MaterialPageRoute(builder: (_) => const GarbhSanskarSetupScreen());
// case '/garbh-sanskar-home':
//   return MaterialPageRoute(builder: (_) => const GarbhSanskarHomeScreen());
//
// To add the entry card to any screen, import and use:
// import '../../features/garbh_sanskar/presentation/widgets/garbh_sanskar_entry_card.dart';
// GarbhSanskarEntryCard()

class GarbhSanskarRoutes {
  static const String setup = '/garbh-sanskar-setup';
  static const String home = '/garbh-sanskar-home';
}
