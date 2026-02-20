import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/app_router.dart';
import '../../../profile/presentation/providers/language_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
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
                                context, AppRouter.home);
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
                      label: Text(AppStrings.get('continue_with_google', lang)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign up with Email (OOB magic link)
                    OutlinedButton.icon(
                      onPressed: () async {
                        if (!SupabaseService().isInitialized) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to .env',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                          return;
                        }
                        if (context.mounted) {
                          Navigator.pushNamed(context, AppRouter.signUp);
                        }
                      },
                      icon: const Icon(Icons.email_outlined, size: 22),
                      label: Text(AppStrings.get('continue_with_email', lang)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Continue without signing in (use app with local data)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, AppRouter.home);
                      },
                      child: Text(AppStrings.get('skip_for_now', lang)),
                    ),
                    const SizedBox(height: 16),

                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!SupabaseService().isInitialized) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Supabase is not configured.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                            return;
                          }
                          try {
                            await SupabaseService().signInWithApple();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRouter.home);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              if (e.toString().contains('AuthorizationErrorCode.canceled')) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Apple Sign In failed: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.apple, size: 24),
                        label: Text(AppStrings.get('continue_with_apple', lang)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),

                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),

                    // ─── Preview Onboarding (test shortcut) ───
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, AppRouter.spiritualOnboarding);
                      },
                      icon: const Icon(Icons.auto_awesome, size: 20),
                      label: const Text('Preview Onboarding'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: const Color(0xFFD4AF37),
                        side: const BorderSide(
                          color: Color(0x55D4AF37),
                        ),
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
