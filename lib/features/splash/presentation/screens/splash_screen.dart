import 'package:flutter/material.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../onboarding/presentation/screens/spiritual_onboarding_screen.dart';

/// No visible splash. Checks session and onboarding, then navigates to home, login, or onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _splashBlue = Color(0xFF0B1623);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    // No artificial delay so navigation feels instant after first frame
    if (!mounted) return;

    // Already logged in: use session and go to home
    if (SupabaseService().isInitialized && SupabaseService().currentUserId != null) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
      return;
    }

    final complete = await SpiritualOnboardingScreen.isOnboardingComplete();
    if (!mounted) return;

    if (complete) {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.spiritualOnboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBlue,
      body: const SizedBox.expand(),
    );
  }
}
