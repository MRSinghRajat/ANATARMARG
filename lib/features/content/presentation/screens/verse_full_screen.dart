import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/coin_calculator.dart';
import '../../../../shared/widgets/coin_earned_overlay.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/avatar_growth_service.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../data/models/verse_model.dart';

/// Full-screen verse reading screen with scrollable text and images
class VerseFullScreen extends StatefulWidget {
  final VerseContent verse;
  final int? likeCount;
  final int? shareCount;
  final VoidCallback? onLike;
  final VoidCallback? onShare;

  const VerseFullScreen({
    super.key,
    required this.verse,
    this.likeCount,
    this.shareCount,
    this.onLike,
    this.onShare,
  });

  @override
  State<VerseFullScreen> createState() => _VerseFullScreenState();
}

class _VerseFullScreenState extends State<VerseFullScreen> {
  bool _isCompleted = false;
  final GlobalKey _completeButtonKey = GlobalKey();

  Future<void> _completeVerse() async {
    if (_isCompleted) return;

    setState(() => _isCompleted = true);

    final coins = CoinCalculator.calculateReadingReward(false);
    await CoinService().addCoins(coins);
    await AvatarGrowthService().completeAction(
      wisdomGain: 1,
      karmaGain: 5,
      extendsStreak: true,
    );
    GuideAnimationService().setState(GuideState.welcoming);

    if (mounted) {
      CoinEarnedOverlay.show(
        context,
        amount: coins,
        fromKey: _completeButtonKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse Reference
                    Text(
                      widget.verse.title,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verse of the day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.tertiaryText,
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Placeholder for verse image
                    // TODO: Replace with actual image from GPT/DALL-E or assets
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.lightGreen.withOpacity(0.3),
                            AppColors.warmOrange.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: AppColors.tertiaryText.withOpacity(0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Verse Text (full content)
                    Text(
                      widget.verse.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.8,
                            fontSize: 18,
                            color: AppColors.primaryText,
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Book Reference
                    if (widget.verse.book.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: AppColors.warmOrange,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Source',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.tertiaryText,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.verse.book,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onLike,
                            icon: const Icon(
                              Icons.favorite_border,
                              color: AppColors.tertiaryText,
                            ),
                            label: Text(
                              widget.likeCount != null
                                  ? 'Like (${widget.likeCount})'
                                  : 'Like',
                              style: const TextStyle(
                                  color: AppColors.tertiaryText),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                  color: AppColors.borderColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onShare,
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warmOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Mark as Read / Complete
                    if (!_isCompleted)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          key: _completeButtonKey,
                          onPressed: _completeVerse,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark as Read'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coinGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.successColor.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.successColor),
                            SizedBox(width: 8),
                            Text(
                              'Verse read!',
                              style: TextStyle(
                                color: AppColors.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          ),
          const Spacer(),
          Text(
            'Verse of the Day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          // Placeholder for symmetry
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
