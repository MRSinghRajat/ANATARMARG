import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../gamification/data/repositories/avatar_repository.dart';
import '../../data/models/affirmation_model.dart';
import '../../data/models/ashram_daily_verse_model.dart';
import '../../data/repositories/affirmation_repository.dart';
import '../../data/repositories/ashram_daily_verse_repository.dart';
import 'ashram_verse_detail_screen.dart';

class AshramScreen extends ConsumerStatefulWidget {
  const AshramScreen({super.key});

  @override
  ConsumerState<AshramScreen> createState() => _AshramScreenState();
}

class _AshramScreenState extends ConsumerState<AshramScreen> {
  final CoinService _coinService = CoinService();
  final AvatarRepository _avatarRepository = AvatarRepository();
  final AffirmationRepository _affirmationRepository = AffirmationRepository();
  final AshramDailyVerseRepository _verseRepository = AshramDailyVerseRepository();

  List<AffirmationModel> _affirmations = [];
  Set<String> _completedIds = {};
  bool _isLoading = true;
  AshramDailyVerseModel? _dailyVerse;
  bool _verseLoading = true;

  @override
  void initState() {
    super.initState();
    _coinService.initialize();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadAffirmations();
    _loadDailyVerse();
  }

  Future<void> _loadAffirmations() async {
    try {
      final list = await _affirmationRepository.getDailyAffirmations();
      final completed = await _affirmationRepository.getCompletedIds();
      if (mounted) {
        setState(() {
          _affirmations = list;
          _completedIds = completed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _affirmations = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDailyVerse() async {
    try {
      final verse = await _verseRepository.getTodaysVerse();
      if (mounted) {
        setState(() {
          _dailyVerse = verse;
          _verseLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dailyVerse = null;
          _verseLoading = false;
        });
      }
    }
  }

  Future<void> _onVerseTap() async {
    if (_dailyVerse == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AshramVerseDetailScreen(verse: _dailyVerse!),
      ),
    );
    await _loadDailyVerse(); // Refresh - verse card should hide
  }

  Future<void> _toggleAffirmationCompleted(String id) async {
    await _affirmationRepository.toggleCompleted(id);
    final completed = await _affirmationRepository.getCompletedIds();
    if (mounted) setState(() => _completedIds = completed);
  }

  List<AffirmationModel> get _sortedAffirmations {
    final pending = _affirmations.where((a) => !_completedIds.contains(a.id)).toList();
    final done = _affirmations.where((a) => _completedIds.contains(a.id)).toList();
    return [...pending, ...done];
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'air':
        return Icons.air;
      case 'psychology':
        return Icons.psychology;
      case 'spa':
        return Icons.spa;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Top 60%: background + character (always visible when sheet is at min 40%)
    final topHeight = screenHeight * 0.60;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623), // navy-deep
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
            // Cosmic background
            _CosmicBackground(),
            // Geometry overlay
            _GeometryOverlay(),
            // Layer 1: Background + OM section (top 60% of screen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.2, 0.3),
                        radius: 0.8,
                        colors: [
                          Color(0x14D4AF37), // gold at 8% opacity
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.4],
                      ),
                    ),
                  ),
                  // OM Sanctuary Section
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _buildPremiumHeader(context),
                        ),
                        const SizedBox(height: 40),
                        // OM Stage
                        Expanded(
                          child: const Center(
                            child: _OmSanctuary(),
                          ),
                        ),
                        // User Identity
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: _buildUserIdentity(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Layer 2: Draggable sheet (full screen parent so it can expand to top)
            // Min 40% of screen, can expand to 95%
            Positioned.fill(
              child: DraggableScrollableSheet(
                initialChildSize: 0.40,
                minChildSize: 0.40,
                maxChildSize: 0.95,
                snap: true,
                snapSizes: const [0.40, 0.60, 0.95],
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.ashramBackgroundDark,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, -20),
                        ),
                      ],
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: 48,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Daily verse card
                              if (!_verseLoading && _dailyVerse != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: _buildDailyVerseCard(),
                                ),
                              if (!_verseLoading && _dailyVerse != null)
                                const SizedBox(height: 20),
                              // Section Header
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Color(0xFFF4E4B6), Color(0xFFD4AF37)],
                                      ).createShader(bounds),
                                      child: Text(
                                        "Today's Practice",
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${_completedIds.length}/3',
                                          style: GoogleFonts.tenorSans(
                                            fontSize: 13,
                                            color: const Color(0xFFF4E4B6).withValues(alpha: 0.6),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 60,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: _completedIds.length / 3,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFD4AF37), Color(0xFFF4E4B6)],
                                                ),
                                                borderRadius: BorderRadius.circular(2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                                                    blurRadius: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        if (_isLoading)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.ashramSaffron,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _buildAffirmationCard(
                                    _sortedAffirmations[index],
                                  );
                                },
                                childCount: _sortedAffirmations.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVerseCard() {
    final v = _dailyVerse!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onVerseTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.ashramSaffron.withOpacity(0.2),
                AppColors.ashramSaffron.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.ashramSaffron.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.ashramSaffron.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.ashramSaffron.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: AppColors.ashramSaffron,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verse of the Day',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ashramAccentGold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      v.bookName,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      v.hindiOrEnglishText.length > 80
                          ? '${v.hindiOrEnglishText.substring(0, 80)}...'
                          : v.hindiOrEnglishText,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return FutureBuilder(
      future: _avatarRepository.getAvatar(),
      builder: (context, avatarSnapshot) {
        return StreamBuilder<int>(
          stream: _coinService.coinStream,
          initialData: _coinService.currentBalance,
          builder: (context, coinSnapshot) {
            final coins = coinSnapshot.data ?? 0;
            final avatar = avatarSnapshot.data;
            final hearts = avatar?.karmaBalance ?? 70;
            final streak = avatar?.streakDays ?? 0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Avatar with shimmer
                _PremiumProfileAvatar(),
                // Stats Row
                Row(
                  children: [
                    _buildPremiumStatBubble('$hearts', '❤️'),
                    const SizedBox(width: 10),
                    _buildPremiumStatBubble('$coins', '💎'),
                    const SizedBox(width: 10),
                    _buildPremiumStatBubble('$streak', '🔥'),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumStatBubble(String value, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2837).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.tenorSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: const Color(0xFFF4E4B6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserIdentity() {
    return Column(
      children: [
        Text(
          'NAMASTE',
          style: GoogleFonts.tenorSans(
            fontSize: 13,
            letterSpacing: 3,
            color: const Color(0xFFF4E4B6).withValues(alpha: 0.6),
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF4E4B6), Color(0xFFFFF8E7)],
          ).createShader(bounds),
          child: Text(
            'Mr. Singh',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Day 1 of your spiritual journey',
          style: GoogleFonts.tenorSans(
            fontSize: 12,
            color: const Color(0xFFF4E4B6).withValues(alpha: 0.5),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAffirmationCard(AffirmationModel item) {
    final isCompleted = _completedIds.contains(item.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleAffirmationCompleted(item.id),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCompleted
                    ? [
                        const Color(0xFF1A2837).withValues(alpha: 0.2),
                        const Color(0xFF2A3847).withValues(alpha: 0.1),
                      ]
                    : [
                        const Color(0xFF1A2837).withValues(alpha: 0.4),
                        const Color(0xFF2A3847).withValues(alpha: 0.2),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: isCompleted ? 0.1 : 0.1),
              ),
            ),
            child: Row(
              children: [
                // Quest Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        const Color(0xFFD4AF37).withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    _iconFromName(item.iconName),
                    color: const Color(0xFFD4AF37),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                // Quest Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        style: GoogleFonts.tenorSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFF8E7),
                          letterSpacing: 0.3,
                          height: 1.4,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFFFFF8E7).withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Daily practice • 5 minutes',
                        style: GoogleFonts.tenorSans(
                          fontSize: 11,
                          color: const Color(0xFFF4E4B6).withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkbox
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      width: 2,
                    ),
                    gradient: isCompleted
                        ? const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFF4E4B6)],
                          )
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xFF0B1623),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cosmic background with animated gradients
class _CosmicBackground extends StatefulWidget {
  const _CosmicBackground();

  @override
  State<_CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<_CosmicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final scale = 1.0 + 0.1 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
          final opacity = 0.8 + 0.2 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
          return Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.2, 0.3),
                  radius: 0.8 * scale,
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: 0.08 * opacity),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Geometry overlay with diagonal lines
class _GeometryOverlay extends StatefulWidget {
  const _GeometryOverlay();

  @override
  State<_GeometryOverlay> createState() => _GeometryOverlayState();
}

class _GeometryOverlayState extends State<_GeometryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final opacity = 0.02 + 0.02 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
          final scale = 1.0 + 0.05 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
          return Positioned.fill(
            child: Transform.scale(
              scale: scale,
              child: CustomPaint(
                painter: _GeometryPainter(opacity: opacity),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GeometryPainter extends CustomPainter {
  final double opacity;

  _GeometryPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: opacity)
      ..strokeWidth = 1;

    const spacing = 80.0;
    // Diagonal lines at 45 degrees
    for (var i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    // Diagonal lines at -45 degrees
    for (var i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i.toDouble(), size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GeometryPainter oldDelegate) {
    // Only repaint if opacity changed significantly
    return (oldDelegate.opacity - opacity).abs() > 0.005;
  }
}

/// Premium profile avatar with shimmer effect
class _PremiumProfileAvatar extends StatefulWidget {
  const _PremiumProfileAvatar();

  @override
  State<_PremiumProfileAvatar> createState() => _PremiumProfileAvatarState();
}

class _PremiumProfileAvatarState extends State<_PremiumProfileAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Profile tap interaction
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, _) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD4AF37), Color(0xFFF4E4B6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect
                  Positioned.fill(
                    child: Transform.rotate(
                      angle: _shimmerController.value * 2 * math.pi,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                            stops: [
                              0.0,
                              _shimmerController.value % 1.0,
                              (_shimmerController.value % 1.0) + 0.2,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Inner circle
                  Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0B1623),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// OM Sanctuary with rotating mandala rings and energy pulses
class _OmSanctuary extends StatefulWidget {
  const _OmSanctuary();

  @override
  State<_OmSanctuary> createState() => _OmSanctuaryState();
}

class _OmSanctuaryState extends State<_OmSanctuary>
    with TickerProviderStateMixin {
  static const String _om = 'ॐ';
  static const double _size = 340;

  late AnimationController _mandalaController1;
  late AnimationController _mandalaController2;
  late AnimationController _mandalaController3;
  late AnimationController _energyController;
  late AnimationController _omBreathingController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _mandalaController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _mandalaController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();
    _mandalaController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _energyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _omBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _mandalaController1.dispose();
    _mandalaController2.dispose();
    _mandalaController3.dispose();
    _energyController.dispose();
    _omBreathingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Rotating Mandala Rings
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _mandalaController1,
                _mandalaController2,
                _mandalaController3,
              ]),
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: _mandalaController1.value * 2 * math.pi,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -_mandalaController2.value * 2 * math.pi,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: _mandalaController3.value * 2 * math.pi,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Energy Pulses
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _energyController,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildEnergyRing(_energyController.value, 0),
                    _buildEnergyRing((_energyController.value + 0.325) % 1.0, 1.3),
                    _buildEnergyRing((_energyController.value + 0.65) % 1.0, 2.6),
                  ],
                );
              },
            ),
          ),
          // Floating Particles
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(_size, _size),
                  painter: _FloatingParticlesPainter(
                    progress: _particleController.value,
                    color: gold,
                  ),
                );
              },
            ),
          ),
          // OM Symbol with breathing animation
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _omBreathingController,
              builder: (context, _) {
                final t = _omBreathingController.value;
                final scale = 1.0 + 0.05 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
                final blur1 = 40.0 + 20.0 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
                final blur2 = 80.0 + 20.0 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
                final opacity1 = 0.6 + 0.2 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
                final opacity2 = 0.3 + 0.2 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));

                return Transform.scale(
                  scale: scale,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFF4E4B6), Color(0xFFD4AF37), Color(0xFF9B7E2A)],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      _om,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 140,
                        height: 1,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: gold.withValues(alpha: opacity1),
                            blurRadius: blur1,
                            offset: Offset.zero,
                          ),
                          Shadow(
                            color: gold.withValues(alpha: opacity2),
                            blurRadius: blur2,
                            offset: Offset.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyRing(double progress, double delay) {
    if (progress < delay / 4) return const SizedBox.shrink();
    final t = (progress - delay / 4) / (1 - delay / 4);
    final size = 100.0 + t * 240.0;
    final opacity = t < 0.5 ? (t * 2) * 0.6 : (1 - t) * 2 * 0.6;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: opacity),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: opacity * 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

/// OM symbol with pulsing rings and floating golden particles (matching HTML design).
class _OmWithGlowAndParticles extends StatefulWidget {
  const _OmWithGlowAndParticles();

  @override
  State<_OmWithGlowAndParticles> createState() => _OmWithGlowAndParticlesState();
}

class _OmWithGlowAndParticlesState extends State<_OmWithGlowAndParticles>
    with TickerProviderStateMixin {
  static const String _om = 'ॐ';
  static const double _size = 280;

  late AnimationController _ringController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    // Ring pulse animation: 3s duration, matches HTML
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    // OM glow animation: 2s duration, matches HTML
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    // Particle animation: 4-6s duration, matches HTML
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC8C857); // #ffc857 from HTML

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Pulsing rings (3 concentric circles)
          AnimatedBuilder(
            animation: _ringController,
            builder: (context, _) {
              final t = _ringController.value;
              // Pulse: scale from 1.0 to 1.1, opacity from 0.3 to 0.6
              final scale1 = 1.0 + 0.1 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
              final opacity1 = 0.3 + 0.3 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
              final scale2 = 1.0 + 0.1 * (0.5 + 0.5 * math.sin((t + 0.167) * 2 * math.pi));
              final opacity2 = 0.3 + 0.3 * (0.5 + 0.5 * math.sin((t + 0.167) * 2 * math.pi));
              final scale3 = 1.0 + 0.1 * (0.5 + 0.5 * math.sin((t + 0.333) * 2 * math.pi));
              final opacity3 = 0.3 + 0.3 * (0.5 + 0.5 * math.sin((t + 0.333) * 2 * math.pi));
              
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Ring 1: 280px
                  Transform.scale(
                    scale: scale1,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: gold.withValues(alpha: opacity1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Ring 2: 230px
                  Transform.scale(
                    scale: scale2,
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: gold.withValues(alpha: opacity2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Ring 3: 180px
                  Transform.scale(
                    scale: scale3,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: gold.withValues(alpha: opacity3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Floating particles (moving upward)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                size: Size(_size, _size),
                painter: _FloatingParticlesPainter(
                  progress: _particleController.value,
                  color: gold,
                ),
              );
            },
          ),
          // OM symbol with pulsing glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              final t = _glowController.value;
              // Glow pulse: blur radius from 40 to 60, opacity from 0.6 to 0.9
              final blurRadius = 40.0 + 20.0 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
              final glowOpacity = 0.6 + 0.3 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
              
              return Center(
                child: Text(
                  _om,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifDevanagari(
                    fontSize: 120,
                    height: 1,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: gold.withValues(alpha: glowOpacity),
                        blurRadius: blurRadius,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Paints floating golden particles that move upward around the OM (matching HTML).
class _FloatingParticlesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _FloatingParticlesPainter({required this.progress, required this.color});

  static final List<({double angle, double radius, double width, double height, double speed, double delay})> _particles = () {
    const count = 25; // Reduced from 40 for better performance
    final list = <({double angle, double radius, double width, double height, double speed, double delay})>[];
    final random = math.Random(42); // Fixed seed for consistency, but appears random
    for (var i = 0; i < count; i++) {
      list.add((
        angle: random.nextDouble() * 2 * math.pi, // Random angle
        radius: 50 + random.nextDouble() * 80, // Random radius 50-130
        width: 1.2 + random.nextDouble() * 1.2, // Thin width 1.2-2.4
        height: 3 + random.nextDouble() * 3, // Droplet height 3-6
        speed: 0.15 + random.nextDouble() * 0.2, // Random speed
        delay: random.nextDouble(), // Random delay
      ));
    }
    return list;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (var i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final t = (progress + p.delay) % 1.0;
      
      // Particle moves upward (negative Y) with random horizontal drift
      final startY = centerY + p.radius * math.sin(p.angle);
      final startX = centerX + p.radius * math.cos(p.angle);
      final driftX = (p.angle * 10) % 30 - 15; // Random drift based on angle
      final endY = startY - 250 * t * p.speed; // Move upward
      final endX = startX + driftX * t; // Horizontal drift
      
      // Opacity: fade in at start, fade out at end
      double alpha;
      if (t < 0.1) {
        alpha = t / 0.1; // Fade in
      } else if (t > 0.85) {
        alpha = (1.0 - t) / 0.15; // Fade out
      } else {
        alpha = 0.4 + 0.2 * (0.5 + 0.5 * math.sin((t - 0.1) * math.pi / 0.75));
      }
      
      if (endY < -20 || endY > size.height + 20) continue;
      
      // Draw droplet shape (teardrop/ellipse)
      canvas.save();
      canvas.translate(endX, endY);
      // Rotate slightly based on movement direction
      final rotation = math.atan2(driftX, -250 * p.speed);
      canvas.rotate(rotation);
      
      final paint = Paint()
        ..color = color.withValues(alpha: alpha.clamp(0.0, 0.6))
        ..style = PaintingStyle.fill;
      
      // Draw droplet as thin ellipse (vertical)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.width,
        height: p.height,
      );
      canvas.drawOval(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    // Only repaint if progress changed significantly (every 0.01)
    return (oldDelegate.progress - progress).abs() > 0.01;
  }
}

