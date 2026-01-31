import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/guide_animation_service.dart';
import 'onboarding_welcome_screen.dart';
import 'onboarding_character_intro_screen.dart';
import 'onboarding_form_screen.dart';
import 'onboarding_first_task_screen.dart';
import 'onboarding_home_tour_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardingWelcomeScreen(),
    const OnboardingCharacterIntroScreen(),
    const OnboardingFormScreen(),
    const OnboardingFirstTaskScreen(),
    const OnboardingHomeTourScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete onboarding
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  // Update character animation based on page
                  _updateCharacterState(index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
            
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(
          _pages.length,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? AppColors.warmOrange
                    : AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Back'),
            )
          else
            const SizedBox(),
          
          ElevatedButton(
            onPressed: _nextPage,
            child: Text(
              _currentPage == _pages.length - 1 ? 'Enter Home' : 'Continue',
            ),
          ),
        ],
      ),
    );
  }

  void _updateCharacterState(int pageIndex) {
    final guideService = GuideAnimationService();
    switch (pageIndex) {
      case 0:
        guideService.setState(GuideState.welcoming);
        break;
      case 1:
        guideService.setState(GuideState.speaking);
        break;
      case 2:
        guideService.setState(GuideState.pointing);
        break;
      case 3:
        guideService.setState(GuideState.sitting);
        break;
      case 4:
        guideService.setState(GuideState.pointing);
        break;
    }
  }
}
