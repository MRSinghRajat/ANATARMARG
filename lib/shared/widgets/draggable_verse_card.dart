import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/content/data/models/verse_model.dart';

/// Draggable card widget for Verse of the Day
/// Can be dragged upward to expand, and tapped to open full screen
class DraggableVerseCard extends StatelessWidget {
  final VerseContent verse;
  final VoidCallback onTapFullScreen;
  final int? likeCount;
  final int? shareCount;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  /// Optional scroll controller for use inside DraggableScrollableSheet
  final ScrollController? scrollController;

  const DraggableVerseCard({
    super.key,
    required this.verse,
    required this.onTapFullScreen,
    this.likeCount,
    this.shareCount,
    this.onLike,
    this.onShare,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle - must be inside scrollable for sheet to respond to drag
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.borderColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Verse Reference
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              verse.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Verse of the day',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.tertiaryText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Full Screen Icon
                      IconButton(
                        onPressed: onTapFullScreen,
                        icon: const Icon(
                          Icons.fullscreen,
                          color: AppColors.warmOrange,
                        ),
                        tooltip: 'Open full screen',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Verse Text (truncated preview)
                  Text(
                    verse.content.length > 200
                        ? '${verse.content.substring(0, 200)}...'
                        : verse.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: AppColors.primaryText,
                        ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Engagement Metrics
                  if (likeCount != null || shareCount != null)
                    Row(
                      children: [
                        if (likeCount != null)
                          _buildMetricChip(
                            icon: Icons.favorite_border,
                            count: likeCount!,
                            onTap: onLike,
                          ),
                        if (shareCount != null) ...[
                          const SizedBox(width: 12),
                          _buildMetricChip(
                            icon: Icons.share,
                            count: shareCount!,
                            onTap: onShare,
                          ),
                        ],
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onShare ?? onTapFullScreen,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share Verse with a Friend'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warmOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required int count,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.borderColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.tertiaryText),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.tertiaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
