import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Short floating banner at the bottom (auto-dismiss ~2s), Pro gradient styling.
void showProUpgradeMiniBanner(
  BuildContext context, {
  String message = 'Upgrade to Pro to unlock this',
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryOrange.withValues(alpha: 0.92),
                AppColors.deepPurple.withValues(alpha: 0.88),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white.withValues(alpha: 0.95),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}
