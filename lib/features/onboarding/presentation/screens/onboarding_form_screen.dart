import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../../shared/services/guide_animation_service.dart';

final onboardingFormProvider = StateNotifierProvider<OnboardingFormNotifier, OnboardingFormState>((ref) {
  return OnboardingFormNotifier();
});

class OnboardingFormState {
  final String? name;
  final int? age;
  final String? location;
  final String? spiritualBackground;
  final List<String> goals;

  OnboardingFormState({
    this.name,
    this.age,
    this.location,
    this.spiritualBackground,
    this.goals = const [],
  });

  bool get isValid => name != null && name!.isNotEmpty;
}

class OnboardingFormNotifier extends StateNotifier<OnboardingFormState> {
  OnboardingFormNotifier() : super(OnboardingFormState());

  void setName(String name) {
    state = OnboardingFormState(
      name: name,
      age: state.age,
      location: state.location,
      spiritualBackground: state.spiritualBackground,
      goals: state.goals,
    );
  }

  void setAge(int age) {
    state = OnboardingFormState(
      name: state.name,
      age: age,
      location: state.location,
      spiritualBackground: state.spiritualBackground,
      goals: state.goals,
    );
  }

  void setLocation(String location) {
    state = OnboardingFormState(
      name: state.name,
      age: state.age,
      location: location,
      spiritualBackground: state.spiritualBackground,
      goals: state.goals,
    );
  }

  void setSpiritualBackground(String background) {
    state = OnboardingFormState(
      name: state.name,
      age: state.age,
      location: state.location,
      spiritualBackground: background,
      goals: state.goals,
    );
  }

  void toggleGoal(String goal) {
    final goals = List<String>.from(state.goals);
    if (goals.contains(goal)) {
      goals.remove(goal);
    } else {
      goals.add(goal);
    }
    state = OnboardingFormState(
      name: state.name,
      age: state.age,
      location: state.location,
      spiritualBackground: state.spiritualBackground,
      goals: goals,
    );
  }
}

class OnboardingFormScreen extends ConsumerStatefulWidget {
  const OnboardingFormScreen({super.key});

  @override
  ConsumerState<OnboardingFormScreen> createState() => _OnboardingFormScreenState();
}

class _OnboardingFormScreenState extends ConsumerState<OnboardingFormScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();

  final List<String> _spiritualBackgrounds = [
    'New to spirituality',
    'Some experience',
    'Experienced practitioner',
    'Just exploring',
  ];

  static const _spiritualBackgroundHindi = {
    'New to spirituality': 'आध्यात्म में नए',
    'Some experience': 'कुछ अनुभव',
    'Experienced practitioner': 'अनुभवी साधक',
    'Just exploring': 'अभी जान रहे हैं',
  };

  final List<String> _goals = [
    'Learn ancient wisdom',
    'Daily reflection',
    'Personal growth',
    'Understanding dharma',
    'Peace and clarity',
  ];

  static const _goalHindi = {
    'Learn ancient wisdom': 'प्राचीन ज्ञान सीखें',
    'Daily reflection': 'दैनिक चिंतन',
    'Personal growth': 'व्यक्तिगत विकास',
    'Understanding dharma': 'धर्म को समझें',
    'Peace and clarity': 'शांति और स्पष्टता',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(onboardingFormProvider);
    final formNotifier = ref.read(onboardingFormProvider.notifier);

    // Update character animation based on focus
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Character
            const AnimatedGuide(
              width: 510,
              height: 510,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              localized(ref, en: 'Tell Us About Yourself', hi: 'अपने बारे में बताएँ'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 32),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localized(ref, en: 'Your Name *', hi: 'आपका नाम *'),
                        hintText: localized(ref, en: 'Enter your name', hi: 'अपना नाम लिखें'),
                      ),
                      onChanged: (value) {
                        formNotifier.setName(value);
                        GuideAnimationService().setState(GuideState.pointing);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Age
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: localized(ref, en: 'Age (Optional)', hi: 'उम्र (वैकल्पिक)'),
                        hintText: localized(ref, en: 'Enter your age', hi: 'अपनी उम्र लिखें'),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final age = int.tryParse(value);
                        if (age != null) {
                          formNotifier.setAge(age);
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: localized(ref, en: 'Location (Optional)', hi: 'स्थान (वैकल्पिक)'),
                        hintText: localized(ref, en: 'City, Country', hi: 'शहर, देश'),
                      ),
                      onChanged: (value) {
                        formNotifier.setLocation(value);
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Spiritual Background
                    Text(
                      localized(ref, en: 'Spiritual Background', hi: 'आध्यात्मिक पृष्ठभूमि'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _spiritualBackgrounds.map((bg) {
                        final isSelected = formState.spiritualBackground == bg;
                        return FilterChip(
                          label: Text(localized(ref, en: bg, hi: _spiritualBackgroundHindi[bg])),
                          selected: isSelected,
                          onSelected: (selected) {
                            formNotifier.setSpiritualBackground(bg);
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Goals
                    Text(
                      localized(
                        ref,
                        en: 'Your Goals (Select all that apply)',
                        hi: 'आपके लक्ष्य (सभी लागू विकल्प चुनें)',
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _goals.map((goal) {
                        final isSelected = formState.goals.contains(goal);
                        return FilterChip(
                          label: Text(localized(ref, en: goal, hi: _goalHindi[goal])),
                          selected: isSelected,
                          onSelected: (selected) {
                            formNotifier.toggleGoal(goal);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
