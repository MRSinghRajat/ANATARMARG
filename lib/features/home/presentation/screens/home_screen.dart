import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/widgets/coin_display.dart';
import '../../../../shared/widgets/room_with_character.dart';
import '../../../../shared/services/coin_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  /// When true, shown as Yatra tab - character will walk
  final bool isYatraTab;

  const HomeScreen({super.key, this.isYatraTab = false});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    CoinService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final coinService = CoinService();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Room + Character (top half - fixed)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: RoomWithCharacter.roomHeight(context),
              child: RoomWithCharacter(
                characterSize: 600,
                isOnYatraPage: widget.isYatraTab,
                characterPadding: const EdgeInsets.only(top: 50),
              ),
            ),
            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context, coinService),
            ),
            // Draggable bottom half - Verse pane (pull up for full screen, pull down to half)
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,
              maxChildSize: 0.98,
              snap: true,
              snapSizes: const [0.25, 0.5, 0.98],
              builder: (context, scrollController) =>
                  _buildVerseSheet(context, scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseSheet(
      BuildContext context, ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Icon(Icons.menu_book, size: 48, color: AppColors.warmOrange.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              'Verse of the Day',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your daily verse awaits in Ashram. Swipe to the Ashram tab to read today\'s sacred verse.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.tertiaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CoinService coinService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Avatar with Test Button
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.warmOrange.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppColors.warmOrange),
              ),
              const SizedBox(width: 8),
              // Test Button for Onboarding
              Tooltip(
                message: 'Test Onboarding',
                child: IconButton(
                  icon: const Icon(Icons.school, size: 20),
                  color: AppColors.warmOrange,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.home,
                    );
                  },
                ),
              ),
            ],
          ),

          // Gamification Metrics
          StreamBuilder<int>(
            stream: coinService.coinStream,
            initialData: coinService.currentBalance,
            builder: (context, snapshot) {
              return CoinDisplay(coinCount: snapshot.data ?? 0);
            },
          ),
        ],
      ),
    );
  }

}
