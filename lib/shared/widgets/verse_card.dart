import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VerseCard extends StatelessWidget {
  final String verseReference;
  final String verseText;
  final int? likeCount;
  final int? shareCount;
  final VoidCallback? onShare;
  final VoidCallback? onLike;

  const VerseCard({
    super.key,
    required this.verseReference,
    required this.verseText,
    this.likeCount,
    this.shareCount,
    this.onShare,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Background image would go here
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse Reference
              Text(
                verseReference,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verse of the day',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              
              // Verse Text
              Text(
                verseText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like and Share
                  Row(
                    children: [
                      if (likeCount != null)
                        _buildActionButton(
                          icon: Icons.favorite_border,
                          count: likeCount!,
                          onTap: onLike,
                        ),
                      const SizedBox(width: 16),
                      if (shareCount != null)
                        _buildActionButton(
                          icon: Icons.share,
                          count: shareCount!,
                          onTap: onShare,
                        ),
                    ],
                  ),
                  
                  // Share Verse Button
                  ElevatedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share Verse'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warmOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.tertiaryText),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}
