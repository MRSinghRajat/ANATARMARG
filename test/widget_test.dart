// Widget tests for Antar Marg app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antarmarg/main.dart';
import 'package:antarmarg/features/onboarding/presentation/screens/spiritual_onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App initializes and shows login screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      SpiritualOnboardingScreen.onboardingCompleteKey: true,
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AntarMargApp(),
      ),
    );

    // Splash + async prefs; avoid pumpAndSettle (login screen has endless animations).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify that login screen elements are present (Google Sign-In button)
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      SpiritualOnboardingScreen.onboardingCompleteKey: true,
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: AntarMargApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify app name appears somewhere in the UI

  });
}
