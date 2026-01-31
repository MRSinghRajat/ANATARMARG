import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Shows a flying coin animation from [fromKey] (or screen center) to top-right,
/// then displays a top-positioned snackbar with "+X coins".
class CoinEarnedOverlay {
  static const Duration _flightDuration = Duration(milliseconds: 600);
  static const Duration _snackbarDuration = Duration(seconds: 2);

  static Future<void> show(
    BuildContext context, {
    required int amount,
    GlobalKey? fromKey,
  }) async {
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    // Start position: from widget or center of screen
    Offset startOffset;
    if (fromKey?.currentContext != null) {
      final box = fromKey!.currentContext!.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final pos = box.localToGlobal(Offset.zero);
        startOffset =
            Offset(pos.dx + box.size.width / 2, pos.dy + box.size.height / 2);
      } else {
        startOffset =
            Offset(mediaQuery.size.width / 2, mediaQuery.size.height / 2);
      }
    } else {
      startOffset =
          Offset(mediaQuery.size.width / 2, mediaQuery.size.height / 2);
    }

    // End position: top-right (where coin display typically is)
    final endOffset = Offset(mediaQuery.size.width - 50, topPadding + 30);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _FlyingCoinOverlay(
        startOffset: startOffset,
        endOffset: endOffset,
        amount: amount,
        onComplete: () {
          entry.remove();
          _showTopSnackBar(context, amount);
        },
      ),
    );

    overlay.insert(entry);
  }

  static void _showTopSnackBar(BuildContext context, int amount) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond, color: Colors.white),
            const SizedBox(width: 8),
            Text('+$amount coins!',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppColors.coinGreen,
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    Future.delayed(_snackbarDuration, () {
      messenger.hideCurrentMaterialBanner();
    });
  }
}

class _FlyingCoinOverlay extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final int amount;
  final VoidCallback onComplete;

  const _FlyingCoinOverlay({
    required this.startOffset,
    required this.endOffset,
    required this.amount,
    required this.onComplete,
  });

  @override
  State<_FlyingCoinOverlay> createState() => _FlyingCoinOverlayState();
}

class _FlyingCoinOverlayState extends State<_FlyingCoinOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CoinEarnedOverlay._flightDuration,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(begin: 1.2, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Positioned(
            left: _positionAnimation.value.dx - 16,
            top: _positionAnimation.value.dy - 16,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coinGreen.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coinGreen.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.diamond,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
