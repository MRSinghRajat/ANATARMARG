import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/widgets/coin_display.dart';
import '../../../../shared/widgets/room_with_character.dart';
import '../../../../shared/widgets/draggable_verse_card.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../content/data/repositories/verse_of_day_repository.dart';
import '../../../content/data/models/verse_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  /// When true, shown as Yatra tab - character will walk
  final bool isYatraTab;

  const HomeScreen({super.key, this.isYatraTab = false});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final VerseOfDayRepository _verseRepository = VerseOfDayRepository();
  VerseContent? _verseOfDay;
  bool _isLoadingVerse = true;

  @override
  void initState() {
    super.initState();
    CoinService().initialize();
    _loadVerseOfDay();
  }

  Future<void> _loadVerseOfDay() async {
    try {
      final verse = await _verseRepository.getVerseOfTheDay();
      setState(() {
        _verseOfDay = verse;
        _isLoadingVerse = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVerse = false;
      });
    }
  }

  void _openVerseFullScreen() {
    if (_verseOfDay != null) {
      Navigator.pushNamed(
        context,
        AppRouter.verseFullScreen,
        arguments: {
          'verse': _verseOfDay!,
          'likeCount': 1058, // Mock data - replace with actual
          'shareCount': 526, // Mock data - replace with actual
        },
      );
    }
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
      child: _isLoadingVerse
          ? _buildScrollablePlaceholder(
              scrollController,
              const Center(child: CircularProgressIndicator()),
            )
          : _verseOfDay == null
              ? _buildScrollablePlaceholder(
                  scrollController,
                  Center(
                    child: Text(
                      'Unable to load verse',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : DraggableVerseCard(
                  verse: _verseOfDay!,
                  scrollController: scrollController,
                  onTapFullScreen: _openVerseFullScreen,
                  likeCount: 1058,
                  shareCount: 526,
                  onLike: () {},
                  onShare: () {},
                ),
    );
  }

  Widget _buildScrollablePlaceholder(
      ScrollController scrollController, Widget child) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 400,
        child: child,
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
                      AppRouter.animatedOnboarding,
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
