import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../../shared/widgets/coin_earned_overlay.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../../../shared/services/avatar_growth_service.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../core/utils/sound_manager.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  final int? bonusCoins;

  const PrayerScreen({
    super.key,
    this.bonusCoins,
  });

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  int _selectedDuration = 1; // minutes
  int _remainingSeconds = 60;
  bool _isPraying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    GuideAnimationService().setState(GuideState.praying);
    SoundManager().playBackgroundSound(SoundType.prayer);
    _remainingSeconds = _selectedDuration * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    SoundManager().stopBackgroundSound();
    super.dispose();
  }

  void _startPrayer() {
    if (_isPraying) return;

    setState(() {
      _isPraying = true;
      _remainingSeconds = _selectedDuration * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completePrayer();
        timer.cancel();
      }
    });
  }

  void _stopPrayer() {
    _timer?.cancel();
    setState(() {
      _isPraying = false;
    });
  }

  Future<void> _completePrayer() async {
    _timer?.cancel();

    // Award bonus coins if provided
    if (widget.bonusCoins != null) {
      await CoinService().addCoins(widget.bonusCoins!);
    }

    // Avatar grows through daily actions (vision-aligned)
    await AvatarGrowthService().completeAction(
      wisdomGain: 1,
      karmaGain: 5,
      extendsStreak: true,
    );

    AvatarGrowthService().setAnimationState(GuideState.welcoming);

    if (mounted && widget.bonusCoins != null && widget.bonusCoins! > 0) {
      CoinEarnedOverlay.show(
        context,
        amount: widget.bonusCoins!,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Prayer complete!'),
            ],
          ),
          backgroundColor: AppColors.successColor,
        ),
      );
    }

    if (mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightGreen.withOpacity(0.2),
              AppColors.primaryBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Character
              const AnimatedGuide(
                width: 720,
                height: 720,
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Prayer Time',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              // Duration Selector (if not praying)
              if (!_isPraying) ...[
                Text(
                  'Select duration',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [1, 2, 3, 5].map((minutes) {
                    final isSelected = _selectedDuration == minutes;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDuration = minutes;
                            _remainingSeconds = minutes * 60;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.warmOrange
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.warmOrange
                                  : AppColors.borderColor,
                            ),
                          ),
                          child: Text(
                            '$minutes min',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryText,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 32),

              // Timer Display
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.warmOrange,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warmOrange,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              if (!_isPraying)
                ElevatedButton.icon(
                  onPressed: _startPrayer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Prayer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _stopPrayer,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _completePrayer,
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Optional: Guided Prayer Text
              if (_isPraying)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'May peace and wisdom guide your path...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.secondaryText,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
