import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CoinDisplay extends StatelessWidget {
  final int coinCount;
  final double? size;

  const CoinDisplay({
    super.key,
    required this.coinCount,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.coinGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.coinGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond,
            color: AppColors.coinGreen,
            size: size ?? 20,
          ),
          const SizedBox(width: 6),
          Text(
            coinCount.toString(),
            style: TextStyle(
              fontSize: size ?? 16,
              fontWeight: FontWeight.bold,
              color: AppColors.coinGreen,
            ),
          ),
        ],
      ),
    );
  }
}
