import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';

class AnimatedOnboardingScreen extends ConsumerStatefulWidget {
  const AnimatedOnboardingScreen({super.key});

  @override
  ConsumerState<AnimatedOnboardingScreen> createState() =>
      _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState
    extends ConsumerState<AnimatedOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondaryBackground, // Light yellow at top
              AppColors.primaryBackground, // Warm beige
              Color(0xFF90EE90), // Green landscape
            ],
            stops: [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable Cards Section (Upper 60%)
              Expanded(
                flex: 6,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return _buildFeatureCard(index);
                  },
                ),
              ),

              // Bottom Section with Actions (Lower 40%)
              Expanded(
                flex: 4,
                child: _buildBottomSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Transform.rotate(
        angle: (index - _currentPage) * 0.1, // Slight rotation for depth
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _getCardContent(index),
          ),
        ),
      ),
    );
  }

  Widget _getCardContent(int index) {
    switch (index) {
      case 0:
        return _buildRoomCard1();
      case 1:
        return _buildRoomCard2();
      case 2:
        return _buildStoreCard();
      default:
        return _buildRoomCard1();
    }
  }

  // Card 1: Cozy Room with Character
  Widget _buildRoomCard1() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE8D5B7), // Light brown walls
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8D5B7),
            Color(0xFFD4C4A8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Wooden floor (solid color; texture asset optional)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF8B6F47),
              ),
            ),
          ),

          // Bookshelf
          Positioned(
            right: 20,
            top: 40,
            child: Container(
              width: 60,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF8B6F47),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: List.generate(
                    4,
                    (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF654321),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )),
              ),
            ),
          ),

          // Character (Sadhu) sitting
          Positioned(
            bottom: 40,
            left: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.saffron,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),

          // Red rug
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 100,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Window
          Positioned(
            top: 30,
            left: 20,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                border: Border.all(color: Colors.brown, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '🌅',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 2: Study Room
  Widget _buildRoomCard2() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF9B7EDE), // Purple walls
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9B7EDE),
            Color(0xFF7A5FB8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Bookshelf
          Positioned(
            left: 20,
            top: 40,
            child: Container(
              width: 80,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF654321),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: List.generate(
                    5,
                    (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B6F47),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )),
              ),
            ),
          ),

          // Desk with laptop
          Positioned(
            bottom: 60,
            right: 30,
            child: Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF8B6F47),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Laptop
                  Positioned(
                    top: 5,
                    left: 20,
                    child: Container(
                      width: 60,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Character with headphones
          Positioned(
            bottom: 80,
            left: 50,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF8B6F47),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // String lights
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: List.generate(
                  5,
                  (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Store/Shop Room
  Widget _buildStoreCard() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE8D5B7), // Light brown
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8D5B7),
            Color(0xFFD4C4A8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Vending Machine / Store
          Positioned(
            right: 30,
            top: 50,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade900, width: 3),
              ),
              child: Column(
                children: [
                  // Top section
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.green.shade900,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🛒',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  // Items grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.brown),
                        ),
                        child: const Center(
                          child: Text(
                            '💰',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Character on star mat
          Positioned(
            bottom: 60,
            left: 40,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.saffron,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // Star mat
                Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade300,
                    shape: BoxShape.rectangle,
                  ),
                  child: const Center(
                    child: Text(
                      '⭐',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Window with art
          Positioned(
            top: 30,
            left: 20,
            child: Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                border: Border.all(color: Colors.brown, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '🌊',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF90EE90), // Green landscape
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF90EE90),
            Color(0xFF7CCD7C),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Logo in background — no fixed dimensions; scales to fit, content overlays it
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Image.asset(
                  AppConfig.appLogoPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          // Content overlays the logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title (only on last page)
            if (_currentPage == 2) ...[
              Text(
                'Unlock the Store',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
              ),
              const SizedBox(height: 20),

              // Customize button
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: Text(
                  'Customize your room!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                ),
              ),
              const SizedBox(height: 20),
            ],

                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Already have account link
                TextButton(
              onPressed: _navigateToLogin,
              child: Text(
                'Already have an account',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.grey.shade700,
                ),
                ),
              ),

                const SizedBox(height: 16),

                // Begin Your Journey button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                onPressed: _navigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Begin Your Journey',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
