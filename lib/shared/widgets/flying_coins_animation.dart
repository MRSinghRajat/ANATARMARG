import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced flying coins animation that shows coins flying from source to target
/// with particle effects and a merge animation at the destination.
class FlyingCoinsAnimation {
  /// GlobalKey for the coin counter widget at the top of the screen
  static GlobalKey? coinCounterKey;

  /// Show flying coins animation from a source position to the coin counter
  static Future<void> show(
    BuildContext context, {
    required int amount,
    required GlobalKey fromKey,
    GlobalKey? toKey,
    VoidCallback? onComplete,
  }) async {
    HapticFeedback.mediumImpact();
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    // Get source position
    Offset startOffset;
    if (fromKey.currentContext != null) {
      final box = fromKey.currentContext!.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final pos = box.localToGlobal(Offset.zero);
        startOffset = Offset(pos.dx + box.size.width / 2, pos.dy + box.size.height / 2);
      } else {
        startOffset = Offset(mediaQuery.size.width / 2, mediaQuery.size.height / 2);
      }
    } else {
      startOffset = Offset(mediaQuery.size.width / 2, mediaQuery.size.height / 2);
    }

    // Get target position (coin counter or default top-right)
    Offset endOffset;
    final targetKey = toKey ?? coinCounterKey;
    if (targetKey?.currentContext != null) {
      final box = targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final pos = box.localToGlobal(Offset.zero);
        endOffset = Offset(pos.dx + box.size.width / 2, pos.dy + box.size.height / 2);
      } else {
        endOffset = Offset(mediaQuery.size.width - 60, topPadding + 50);
      }
    } else {
      endOffset = Offset(mediaQuery.size.width - 60, topPadding + 50);
    }

    // Create overlay entries for multiple coins
    final entries = <OverlayEntry>[];
    final numberOfCoins = min(amount, 8); // Max 8 coins for performance
    
    for (int i = 0; i < numberOfCoins; i++) {
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (ctx) => _FlyingCoin(
          startOffset: startOffset,
          endOffset: endOffset,
          delay: Duration(milliseconds: i * 50),
          coinIndex: i,
          totalCoins: numberOfCoins,
          onComplete: () {
            entry.remove();
            entries.remove(entry);
            
            // When last coin arrives, show merge effect and call completion
            if (entries.isEmpty) {
              _showMergeEffect(context, endOffset, amount);
              onComplete?.call();
            }
          },
        ),
      );
      entries.add(entry);
      overlay.insert(entry);
    }

    // Also show the amount text floating up
    late OverlayEntry amountEntry;
    amountEntry = OverlayEntry(
      builder: (ctx) => _FloatingAmountText(
        position: startOffset,
        amount: amount,
        onComplete: () => amountEntry.remove(),
      ),
    );
    overlay.insert(amountEntry);
  }

  /// Show merge/burst effect at the coin counter
  static void _showMergeEffect(BuildContext context, Offset position, int amount) {
    HapticFeedback.lightImpact();
    final overlay = Overlay.of(context);
    
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _MergeEffect(
        position: position,
        amount: amount,
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

/// Individual flying coin with curved path
class _FlyingCoin extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final Duration delay;
  final int coinIndex;
  final int totalCoins;
  final VoidCallback onComplete;

  const _FlyingCoin({
    required this.startOffset,
    required this.endOffset,
    required this.delay,
    required this.coinIndex,
    required this.totalCoins,
    required this.onComplete,
  });

  @override
  State<_FlyingCoin> createState() => _FlyingCoinState();
}

class _FlyingCoinState extends State<_FlyingCoin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  final _random = Random();
  late double _curveOffset;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    
    // Random curve offset for variety
    _curveOffset = (_random.nextDouble() - 0.5) * 100;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    // Start with delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _started = true);
        _controller.forward().then((_) => widget.onComplete());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _calculatePosition(double progress) {
    // Quadratic bezier curve for natural arc
    final start = widget.startOffset;
    final end = widget.endOffset;
    
    // Control point for the curve (creates an arc)
    final controlPoint = Offset(
      (start.dx + end.dx) / 2 + _curveOffset,
      min(start.dy, end.dy) - 80 - (widget.coinIndex * 10),
    );
    
    // Quadratic bezier formula
    final t = progress;
    return Offset(
      pow(1 - t, 2) * start.dx + 2 * (1 - t) * t * controlPoint.dx + pow(t, 2) * end.dx,
      pow(1 - t, 2) * start.dy + 2 * (1 - t) * t * controlPoint.dy + pow(t, 2) * end.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = _calculatePosition(_progressAnimation.value);
        
        return Positioned(
          left: position.dx - 16,
          top: position.dy - 16,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFA500),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating "+X" text that rises from the source
class _FloatingAmountText extends StatefulWidget {
  final Offset position;
  final int amount;
  final VoidCallback onComplete;

  const _FloatingAmountText({
    required this.position,
    required this.amount,
    required this.onComplete,
  });

  @override
  State<_FloatingAmountText> createState() => _FloatingAmountTextState();
}

class _FloatingAmountTextState extends State<_FloatingAmountText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _offsetAnimation = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 70),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 30,
          top: widget.position.dy + _offsetAnimation.value - 20,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 16),
                    Text(
                      '${widget.amount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Merge/burst effect when coins arrive at the counter
class _MergeEffect extends StatefulWidget {
  final Offset position;
  final int amount;
  final VoidCallback onComplete;

  const _MergeEffect({
    required this.position,
    required this.amount,
    required this.onComplete,
  });

  @override
  State<_MergeEffect> createState() => _MergeEffectState();
}

class _MergeEffectState extends State<_MergeEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 40,
          top: widget.position.dy - 40,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withOpacity(0.8),
                      Colors.orange.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget wrapper that provides the GlobalKey for the coin counter
class CoinCounterTarget extends StatelessWidget {
  final Widget child;
  
  CoinCounterTarget({super.key, required this.child}) {
    FlyingCoinsAnimation.coinCounterKey ??= GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: FlyingCoinsAnimation.coinCounterKey,
      child: child,
    );
  }
}
