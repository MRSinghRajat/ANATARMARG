import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/supabase_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Title
              Text(
                AppConfig.appName.toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'The Inner Path',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 48),

              // Social Login Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Google Sign In
                    ElevatedButton.icon(
                      onPressed: () async {
                        final configError = SupabaseService().validateGoogleConfig();
                        if (configError != null) {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Configuration Missing'),
                                content: Text(
                                    '$configError\n\nPlease add GOOGLE_WEB_CLIENT_ID to your .env file.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                          return;
                        }

                        try {
                          await SupabaseService().signInWithGoogle();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                                context, '/animated-onboarding');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            // If cancelled, just return
                            if (e.toString().contains('cancelled')) {
                              return;
                            }
                            // ApiException 10 = DEVELOPER_ERROR (SHA-1/OAuth misconfiguration)
                            final msg = e.toString().contains('ApiException: 10')
                                ? 'Google Sign-In needs setup. Add SHA-1 to Google Cloud Console.'
                                : 'Sign in failed: $e';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Continue with Google'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Continue without signing in (use app with local data)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/animated-onboarding');
                      },
                      child: const Text('Continue without signing in'),
                    ),
                    const SizedBox(height: 16),

                    // Apple Sign In (iOS only - will be implemented later)
                    // For now, skip Apple sign-in on Android
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement Apple Sign In
                          Navigator.pushReplacementNamed(
                              context, '/animated-onboarding');
                        },
                        icon: const Icon(Icons.apple, size: 24),
                        label: const Text('Continue with Apple'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
