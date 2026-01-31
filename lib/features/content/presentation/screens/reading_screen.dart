import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../../shared/widgets/coin_earned_overlay.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../../../shared/services/avatar_growth_service.dart';
import '../../../../shared/services/coin_service.dart';
import '../../data/models/verse_model.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import '../../../quests/data/repositories/quest_stage_repository.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final VerseContent verse;
  final String? taskId;
  final int coinReward;
  final String? taskType;
  final String? questStageKey;

  const ReadingScreen({
    super.key,
    required this.verse,
    this.taskId,
    this.coinReward = 35,
    this.taskType,
    this.questStageKey,
  });

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  bool _isCompleted = false;
  final TaskRepository _taskRepository = TaskRepository();
  final GlobalKey _completeButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    GuideAnimationService().setState(GuideState.speaking);
  }

  Future<void> _completeReading() async {
    if (_isCompleted) return;

    setState(() {
      _isCompleted = true;
    });

    // Complete daily task (not for quests - quests use questStageKey)
    if (widget.taskId != null && !widget.taskId!.startsWith('quest_')) {
      await _taskRepository.completeTask(widget.taskId!);
    }

    // Mark quest stage complete if from quest flow
    if (widget.questStageKey != null) {
      await QuestStageRepository().markStageComplete(widget.questStageKey!);
    }

    // Award coins
    await CoinService().addCoins(widget.coinReward);

    // Avatar grows through daily actions (vision-aligned)
    await AvatarGrowthService().completeAction(
      wisdomGain: 1,
      karmaGain: 5,
      extendsStreak: true,
    );

    // Character receives item/reward
    if (widget.taskType != null) {
      AvatarGrowthService().receiveItem(widget.taskType!);
    } else {
      GuideAnimationService().setState(GuideState.welcoming);
    }

    if (mounted) {
      CoinEarnedOverlay.show(
        context,
        amount: widget.coinReward,
        fromKey: _completeButtonKey,
      );
    }

    // Show prayer option (skip for quest flow - go back to quest path)
    if (widget.questStageKey != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    // Show prayer option for daily tasks
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _showPrayerOption();
      }
    });
  }

  void _showPrayerOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              size: 48,
              color: AppColors.warmOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to pray?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a moment for reflection and prayer',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/prayer',
                        arguments: {'bonusCoins': 10},
                      ).then((_) {
                        Navigator.pop(context); // Return to home after prayer
                      });
                    },
                    child: const Text('Pray'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.verse.title),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse Reference
                if (widget.verse.chapter != null ||
                    widget.verse.verseNumber != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warmOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: AppColors.warmOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.verse.book}${widget.verse.chapter != null ? " • Chapter ${widget.verse.chapter}" : ""}${widget.verse.verseNumber != null ? " • Verse ${widget.verse.verseNumber}" : ""}',
                          style: const TextStyle(
                            color: AppColors.warmOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Verse Content
                Text(
                  widget.verse.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                if (widget.verse.context != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Context',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.verse.context!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Complete Button
                if (!_isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: _completeButtonKey,
                      onPressed: _completeReading,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Complete Reading'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                        Icon(
                          Icons.check_circle,
                          color: AppColors.successColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Reading Completed!',
                          style: TextStyle(
                            color: AppColors.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 100), // Space for character
              ],
            ),
          ),

          // Character (bottom right)
          const Positioned(
            bottom: 20,
            right: 20,
            child: AnimatedGuide(
              width: 420,
              height: 420,
              alignment: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }
}
