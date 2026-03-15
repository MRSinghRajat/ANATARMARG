import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/aangan_notification_service.dart';

/// In-app notification that slides in from the right on Aangan screen.
/// Stays until the user dismisses it. Cross button = "do not show this notification again".
class AanganSlideNotification extends StatefulWidget {
  final AanganNotificationItem item;
  /// Called when user taps the notification (dismiss for today).
  final VoidCallback? onDismiss;
  /// Called when user taps the cross (dismiss and do not show this notification again).
  final VoidCallback? onDismissDoNotShowAgain;
  final Duration? autoDismissAfter;

  const AanganSlideNotification({
    super.key,
    required this.item,
    this.onDismiss,
    this.onDismissDoNotShowAgain,
    this.autoDismissAfter,
  });

  @override
  State<AanganSlideNotification> createState() => _AanganSlideNotificationState();
}

class _AanganSlideNotificationState extends State<AanganSlideNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  void _dismiss({bool doNotShowAgain = false}) {
    _controller.reverse().then((_) {
      if (!mounted) return;
      if (doNotShowAgain) {
        widget.onDismissDoNotShowAgain?.call();
      } else {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Below Aatma/Mandir tab: ~12 + tabBar(~36) + 8 gap
    const double topBelowTab = 56;
    const double rightInset = 12;
    const double maxWidth = 200;

    return Positioned(
      top: MediaQuery.of(context).padding.top + topBelowTab,
      right: rightInset,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.only(left: 12, right: 4, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.ashramCardDark.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.ashramAccentGold.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _dismiss(doNotShowAgain: false);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.item.emojiOrIcon != null) ...[
                          Text(
                            widget.item.emojiOrIcon!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            widget.item.title,
                            style: GoogleFonts.tenorSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ashramAccentGold.withValues(alpha: 0.95),
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _dismiss(doNotShowAgain: true);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.ashramAccentGold.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
