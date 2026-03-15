import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../shared/services/feature_gate_config.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../../data/models/parva_model.dart';
import '../../data/repositories/parva_repository.dart';
import '../widgets/parva_card.dart';
import 'parva_quest_path_screen.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  final ParvaRepository _parvaRepository = ParvaRepository();
  final CoinService _coinService = CoinService();
  List<ParvaModel> _parvas = [];
  bool _isLoading = true;
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;

  // Mock user data - replace with actual user service
  final String _userName = 'Bala Sadhu';
  final String _userLevel = 'LEVEL 4: RISING SEEKER';
  final int _userLevelNumber = 4;
  final double _progressPercentage = 0.65; // 65%

  @override
  void initState() {
    super.initState();
    _loadParvas();
    _coinService.initialize();
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadParvas() async {
    setState(() => _isLoading = true);
    try {
      final parvas = await _parvaRepository.getAllParvas();
      setState(() {
        _parvas = parvas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _parvas = _parvaRepository.allParvas;
        _isLoading = false;
      });
    }
  }

  void _onParvaTap(int parvaId) {
    final parva = _parvaRepository.allParvas.firstWhere((p) => p.id == parvaId);

    // Navigate to path-style quest screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParvaQuestPathScreen(parva: parva),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Section
            _buildTopHeader(context),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    _buildTitleSection(),
                    const SizedBox(height: 20),

                    // Parvas Grid
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildParvasGrid(_parvas),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Profile and Rewards Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Profile Card
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.saffron,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.warmOrange,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade900,
                                ),
                      ),
                      Text(
                        _userLevel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),

              // Rewards
              Row(
                children: [
                  // Star/Coins
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        StreamBuilder<int>(
                          stream: _coinService.coinStream,
                          initialData: _coinService.currentBalance,
                          builder: (context, snapshot) {
                            return Text(
                              '${snapshot.data ?? 0}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Trophy
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GYAN PROGRESS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
              ),
              Text(
                '${(_progressPercentage * 100).toInt()}% TO LEVEL ${_userLevelNumber + 1}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progressPercentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warmOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Path of the Pandavas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A8A), // Dark blue
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '18 Parvas of Wisdom',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildParvasGrid(List<ParvaModel> parvas) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: parvas.length,
      itemBuilder: (context, index) {
        final parva = parvas[index];
        final isLocked =
            !_isPremium && index >= FeatureGateConfig.freeParvasCount;
        return Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: Stack(
            children: [
              ParvaCard(
                parva: parva,
                onTap: isLocked
                    ? () => PaywallScreen.showAsBottomSheet(context)
                    : () => _onParvaTap(parva.id),
              ),
              if (isLocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
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
        );
      },
    );
  }
}
