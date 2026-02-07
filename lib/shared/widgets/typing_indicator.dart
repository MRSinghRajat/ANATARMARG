import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Animated typing/thinking indicator for chat - smooth, fluent animation.
class TypingIndicator extends StatefulWidget {
  final String label;
  final bool compact;

  const TypingIndicator({
    super.key,
    this.label = 'Thinking...',
    this.compact = false,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _dotController;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _dot1 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.0, 0.33, curve: Curves.easeInOut),
      ),
    );
    _dot2 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.15, 0.48, curve: Curves.easeInOut),
      ),
    );
    _dot3 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.3, 0.63, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 6.0 : 8.0;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.compact) ...[
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.tertiaryText.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 8),
          ],
          AnimatedBuilder(
            animation: _dotController,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(_dot1.value, size),
                  const SizedBox(width: 4),
                  _buildDot(_dot2.value, size),
                  const SizedBox(width: 4),
                  _buildDot(_dot3.value, size),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double scale, double baseSize) {
    return Transform.scale(
      scale: 0.3 + (0.7 * scale),
      child: Container(
        width: baseSize,
        height: baseSize,
        decoration: BoxDecoration(
          color: AppColors.warmOrange.withOpacity(0.6 + (0.4 * scale)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
