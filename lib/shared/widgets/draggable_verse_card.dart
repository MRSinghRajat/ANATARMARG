import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/content/data/models/verse_model.dart';

/// Draggable card widget for Verse of the Day
/// Content scrolls independently; sheet moves only when dragging the handle.
class DraggableVerseCard extends StatefulWidget {
  final VerseContent verse;
  final VoidCallback onTapFullScreen;
  final int? likeCount;
  final int? shareCount;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  /// Sheet's scroll controller – only the drag handle updates this; content uses its own.
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
  State<DraggableVerseCard> createState() => _DraggableVerseCardState();
}

class _DraggableVerseCardState extends State<DraggableVerseCard> {
  late final ScrollController _contentScrollController;

  @override
  void initState() {
    super.initState();
    _contentScrollController = ScrollController();
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = widget.scrollController;
    final verse = widget.verse;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(context, scrollController),
          Expanded(
            child: scrollController != null
                ? _buildStackedScrollViews(context, verse, scrollController)
                : _buildContentScroll(context, verse),
          ),
        ],
      ),
    );
  }

  /// Sheet controller is attached to the back scroll view (handle-only); content scrolls in front.
  Widget _buildStackedScrollViews(
      BuildContext context, VerseContent verse, ScrollController sheetController) {
    return Stack(
      children: [
        ListView(
          controller: sheetController,
          physics: const NeverScrollableScrollPhysics(),
          children: [SizedBox(height: 10000)],
        ),
        _buildContentScroll(context, verse),
      ],
    );
  }

  Widget _buildDragHandle(BuildContext context, ScrollController? sheetController) {
    const handle = Padding(
      padding: EdgeInsets.only(top: 12, bottom: 12),
      child: Center(
        child: _DragHandleBar(),
      ),
    );

    if (sheetController == null || !sheetController.hasClients) {
      return handle;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (DragUpdateDetails d) {
        if (!sheetController.hasClients) return;
        final pos = sheetController.position;
        final newOffset = (sheetController.offset + d.delta.dy)
            .clamp(pos.minScrollExtent, pos.maxScrollExtent);
        sheetController.jumpTo(newOffset);
      },
      child: handle,
    );
  }

  Widget _buildContentScroll(BuildContext context, VerseContent verse) {
    return SingleChildScrollView(
      controller: _contentScrollController,
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
              IconButton(
                onPressed: widget.onTapFullScreen,
                icon: const Icon(
                  Icons.fullscreen,
                  color: AppColors.warmOrange,
                ),
                tooltip: 'Open full screen',
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          if (widget.likeCount != null || widget.shareCount != null)
            Row(
              children: [
                if (widget.likeCount != null)
                  _buildMetricChip(
                    icon: Icons.favorite_border,
                    count: widget.likeCount!,
                    onTap: widget.onLike,
                  ),
                if (widget.shareCount != null) ...[
                  const SizedBox(width: 12),
                  _buildMetricChip(
                    icon: Icons.share,
                    count: widget.shareCount!,
                    onTap: widget.onShare,
                  ),
                ],
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onShare ?? widget.onTapFullScreen,
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

class _DragHandleBar extends StatelessWidget {
  const _DragHandleBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.borderColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
