import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antarmarg/features/onboarding/presentation/screens/spiritual_onboarding_screen.dart';
import 'package:antarmarg/features/profile/presentation/providers/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding language toggle writes languageProvider and prefs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SpiritualOnboardingScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(container.read(languageProvider), 'en');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language_code'), 'en');
  });
}
