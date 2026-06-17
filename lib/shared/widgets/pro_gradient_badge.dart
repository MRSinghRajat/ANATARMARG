import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Orange–purple gradient "Pro" text (matches Ashram Active Journey / My habits).
class ProGradientLabel extends StatelessWidget {
  const ProGradientLabel({super.key, this.fontSize = 12});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppColors.primaryOrange,
          AppColors.deepPurple,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        'Pro',
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Same gradient on the premium workspace icon (compact badge).
class ProGradientPremiumIcon extends StatelessWidget {
  const ProGradientPremiumIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppColors.primaryOrange,
          AppColors.deepPurple,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(
        Icons.workspace_premium_rounded,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
