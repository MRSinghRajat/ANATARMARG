import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  final List<String> _goals = [
    'Learn ancient wisdom',
    'Daily reflection',
    'Personal growth',
    'Understanding dharma',
    'Peace and clarity',
  ];

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
              'Tell Us About Yourself',
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
                      decoration: const InputDecoration(
                        labelText: 'Your Name *',
                        hintText: 'Enter your name',
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
                      decoration: const InputDecoration(
                        labelText: 'Age (Optional)',
                        hintText: 'Enter your age',
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
                      decoration: const InputDecoration(
                        labelText: 'Location (Optional)',
                        hintText: 'City, Country',
                      ),
                      onChanged: (value) {
                        formNotifier.setLocation(value);
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Spiritual Background
                    Text(
                      'Spiritual Background',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _spiritualBackgrounds.map((bg) {
                        final isSelected = formState.spiritualBackground == bg;
                        return FilterChip(
                          label: Text(bg),
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
                      'Your Goals (Select all that apply)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _goals.map((goal) {
                        final isSelected = formState.goals.contains(goal);
                        return FilterChip(
                          label: Text(goal),
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
