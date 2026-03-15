import 'dart:math' as math;

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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  static const Color _gold = Color(0xFFF2C94C);
  static const Color _googleBlue = Color(0xFF2D3A4B);
  static const Color _onboardingBlue = Color(0xFF0B1623);

  late AnimationController _particleController;
  late AnimationController _logoGlowController;
  late AnimationController _waterFlowController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _logoGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _waterFlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoGlowController.dispose();
    _waterFlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
        backgroundColor: _onboardingBlue,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Onboarding-style blue background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F1C2E),
                    _onboardingBlue,
                    Color(0xFF0A1220),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Water flowing (waves) — RepaintBoundary keeps animation from repainting content below
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _waterFlowController,
                  builder: (_, __) => CustomPaint(
                    painter: _LoginWaterFlowPainter(
                      progress: _waterFlowController.value,
                      gold: _gold,
                      base: _onboardingBlue,
                    ),
                  ),
                ),
              ),
            ),
            // Rain / falling particles
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (_, __) => CustomPaint(
                    painter: _LoginParticlesPainter(
                      progress: _particleController.value,
                      particleColor: _gold,
                    ),
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Logo with animated glow background
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: AnimatedBuilder(
                      animation: _logoGlowController,
                      builder: (context, child) {
                        final t = _logoGlowController.value;
                        final glowAlpha = 0.15 + 0.12 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withValues(alpha: glowAlpha),
                                    blurRadius: 60 + 20 * t,
                                    spreadRadius: 8 + 4 * t,
                                  ),
                                ],
                              ),
                            ),
                            child!,
                          ],
                        );
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: Image.asset(
                          AppConfig.appLogoPath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            'ॐ',
                            style: TextStyle(
                              fontSize: 240,
                              fontWeight: FontWeight.w300,
                              color: _gold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The Divine Path',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _gold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Continue with Google — dark blue
                  _LoginButton(
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
                          Navigator.pushReplacementNamed(context, AppRouter.home);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          if (e.toString().contains('cancelled')) return;
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
                    backgroundColor: _googleBlue,
                    foregroundColor: Colors.white,
                    icon: Icons.g_mobiledata,
                    label: AppStrings.get('continue_with_google', lang),
                  ),
                  if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                    const SizedBox(height: 16),
                    _LoginButton(
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
                            Navigator.pushReplacementNamed(context, AppRouter.home);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            if (e.toString().contains('AuthorizationErrorCode.canceled')) return;
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      icon: Icons.apple,
                      label: AppStrings.get('continue_with_apple', lang),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

class _LoginParticlesPainter extends CustomPainter {
  final double progress;
  final Color particleColor;

  _LoginParticlesPainter({required this.progress, required this.particleColor});

  static final List<({double x, double y, double size, double speed})> _particles =
      List.generate(16, (i) {
    final rng = math.Random(i * 31);
    return (
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 1.2 + rng.nextDouble() * 2.2,
      speed: 0.25 + rng.nextDouble() * 0.6,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress * p.speed + p.y) % 1.0;
      final y = size.height * (1.0 - t);
      final x = size.width * p.x + math.sin(t * math.pi * 2) * 18;
      double a;
      if (t < 0.12) {
        a = t / 0.12;
      } else if (t > 0.88) {
        a = (1.0 - t) / 0.12;
      } else {
        a = 0.35;
      }
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = particleColor.withValues(alpha: a * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoginParticlesPainter o) =>
      o.progress != progress || o.particleColor != particleColor;
}

/// Water flowing / wave effect for login background.
class _LoginWaterFlowPainter extends CustomPainter {
  final double progress;
  final Color gold;
  final Color base;

  _LoginWaterFlowPainter({required this.progress, required this.gold, required this.base});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (int layer = 0; layer < 3; layer++) {
      final path = Path();
      final a = 0.03 + layer * 0.02;
      final yBase = h * (0.65 - layer * 0.1);
      final amp = 14.0 + layer * 6.0;
      final freq = 2.2 + layer * 0.5;
      final phase = progress * math.pi * 2 + layer * 1.2;
      path.moveTo(0, h + 20);
      path.lineTo(0, yBase);
      for (double x = 0; x <= w + 10; x += 6) {
        path.lineTo(
          x,
          yBase +
              amp * math.sin(freq * (x / w) * math.pi * 2 + phase) +
              amp * 0.5 * math.sin(freq * 1.5 * (x / w) * math.pi * 2 + phase * 0.7),
        );
      }
      path.lineTo(w + 10, h + 20);
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gold.withValues(alpha: a),
              base.withValues(alpha: a * 0.3),
            ],
          ).createShader(Rect.fromLTWH(0, yBase, w, h - yBase + 20)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoginWaterFlowPainter o) =>
      o.progress != progress || o.gold != gold || o.base != base;
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
