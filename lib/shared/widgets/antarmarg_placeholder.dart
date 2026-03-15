import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';

/// Placeholder shown when a book, sacred text, story or any content
/// has no image. Uses app logo when no god name; otherwise shows deity name.
class AntarmargPlaceholder extends StatelessWidget {
  const AntarmargPlaceholder({
    super.key,
    this.compact = false,
    this.godName,
  });

  /// When true, uses smaller logo/text (e.g. for mini player or small cards).
  final bool compact;

  /// God/deity name. When set, shows deity name on gradient. When null/empty, shows app logo.
  final String? godName;

  @override
  Widget build(BuildContext context) {
    final bgColors = [
      AppColors.matteGold.withValues(alpha: 0.22),
      AppColors.matteGold.withValues(alpha: 0.08),
      AppColors.charcoalDark,
    ];
    final showLogo = godName == null || godName!.isEmpty;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.matteGold.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
          ),
          if (showLogo)
            Positioned.fill(
              child: Center(
                child: _LogoImage(compact: compact),
              ),
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: compact ? 24 : 40),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.matteGold,
                      AppColors.matteGold.withValues(alpha: 0.9),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    godName!,
                    style: GoogleFonts.crimsonPro(
                      fontSize: compact ? 16 : 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: compact ? 1 : 2,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists(AppConfig.appLogoPath),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.asset(
            AppConfig.appLogoPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackOm(context),
          );
        }
        return _fallbackOm(context);
      },
    );
  }

  Widget _fallbackOm(BuildContext context) {
    final size = compact ? 36.0 : 56.0;
    return Text(
      'ॐ',
      style: TextStyle(
        fontSize: size,
        color: AppColors.matteGold.withValues(alpha: 0.9),
        fontWeight: FontWeight.w300,
      ),
    );
  }

  static Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
