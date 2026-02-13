import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../sanctuary/data/models/sanctuary_customization_model.dart';
import '../../../sanctuary/data/services/sanctuary_customization_service.dart';
import '../../../sanctuary/presentation/widgets/customizable_om_sanctuary.dart';
import '../../../sanctuary/presentation/widgets/sanctuary_shop_sheet.dart';
import '../../../gamification/data/repositories/avatar_repository.dart';

/// Redesigned Aangan Screen with Customizable Om Sanctuary
/// Features:
/// - Top 40%: Customizable Om Sanctuary with live preview
/// - Bottom 60%: Draggable shop UI for purchasing customizations
/// - One-way sync to Ashram screen
class AanganScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBeginTap;

  const AanganScreen({
    super.key,
    this.onBeginTap,
  });

  @override
  ConsumerState<AanganScreen> createState() => _AanganScreenState();
}

class _AanganScreenState extends ConsumerState<AanganScreen>
    with TickerProviderStateMixin {
  final CoinService _coinService = CoinService();
  final SanctuaryCustomizationService _customizationService = SanctuaryCustomizationService();
  final AvatarRepository _avatarRepository = AvatarRepository();

  // The actual applied customization (nullable until loaded)
  SanctuaryCustomization? _appliedCustomization;
  // The preview customization (shown while browsing items)
  SanctuaryCustomization? _previewCustomization;
  // Whether we're in preview mode
  bool _isPreviewMode = false;
  // Stream subscription
  StreamSubscription<SanctuaryCustomization>? _customizationSubscription;
  // Loading state
  bool _customizationLoaded = false;

  SanctuaryCustomization get _displayCustomization => 
      _previewCustomization ?? _appliedCustomization ?? SanctuaryCustomization.defaultConfig;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _customizationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _coinService.initialize();
    
    // Cancel any existing subscription
    await _customizationSubscription?.cancel();
    
    // Subscribe to customization changes BEFORE initializing
    _customizationSubscription = _customizationService.customizationStream.listen((customization) {
      if (mounted) {
        setState(() {
          _appliedCustomization = customization;
          _customizationLoaded = true;
          // Clear preview when a new customization is applied
          _previewCustomization = null;
          _isPreviewMode = false;
        });
      }
    });
    
    // Wait for service to fully initialize (loads from Supabase)
    await _customizationService.ensureInitialized();
    
    // Set initial customization immediately
    if (mounted) {
      setState(() {
        _appliedCustomization = _customizationService.currentCustomization;
        _customizationLoaded = true;
      });
    }
  }

  void _onPreviewChange(SanctuaryCustomization preview) {
    setState(() {
      _previewCustomization = preview;
      _isPreviewMode = true;
    });
  }

  void _onPreviewClear() {
    setState(() {
      _previewCustomization = null;
      _isPreviewMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight * 0.45; // 45% for sanctuary area

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623), // Dark navy - matches Ashram
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background geometry overlay
            const Positioned.fill(child: _GeometryOverlay()),
            
            // Top Section: Om Sanctuary + Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topHeight,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Header with stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHeader(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Om Sanctuary - Live Preview
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_customizationLoaded)
                          CustomizableOmSanctuary(
                            size: 280,
                            customization: _displayCustomization,
                          ),
                        // Preview indicator
                        if (_isPreviewMode)
                          Positioned(
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9933).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.visibility, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PREVIEW MODE',
                                    style: GoogleFonts.tenorSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tagline
                  _buildTagline(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Section: Customization Shop Sheet
            Positioned.fill(
              child: NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  // Don't let the draggable sheet interfere with item scrolling
                  return false;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.50, // Start at 50%
                  minChildSize: 0.20,     // Min 20% - can drag lower now
                  maxChildSize: 0.95,     // Max 95%
                  snap: true,
                  snapSizes: const [0.20, 0.50, 0.75, 0.95],
                  builder: (context, scrollController) {
                    return SanctuaryShopSheet(
                      scrollController: scrollController,
                      onPreviewChange: _onPreviewChange,
                      onPreviewClear: _onPreviewClear,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                // Profile Avatar
                const _PremiumProfileAvatar(),
                
                // Stats Row
                Row(
                  children: [
                    _buildStatBubble('$hearts', '❤️'),
                    const SizedBox(width: 8),
                    _buildStatBubble('$coins', '💎'),
                    const SizedBox(width: 8),
                    _buildStatBubble('$streak', '🔥'),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatBubble(String value, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2837).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
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

  Widget _buildTagline() {
    return Column(
      children: [
        Text(
          'YOUR SANCTUARY',
          style: GoogleFonts.tenorSans(
            fontSize: 11,
            letterSpacing: 3,
            color: const Color(0xFFF4E4B6).withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF4E4B6), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: Text(
            'Make it uniquely yours',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Geometry overlay with diagonal lines
class _GeometryOverlay extends StatelessWidget {
  const _GeometryOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GeometryPainter(opacity: 0.03),
    );
  }
}

class _GeometryPainter extends CustomPainter {
  final double opacity;

  _GeometryPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(opacity)
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
  bool shouldRepaint(covariant _GeometryPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD4AF37), Color(0xFFF4E4B6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0B1623),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
