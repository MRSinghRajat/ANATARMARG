// Widget tests for Antar Marg app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:antar_marg/main.dart';
import 'package:antar_marg/core/config/app_config.dart';

void main() {
  testWidgets('App initializes and shows login screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AntarMargApp(),
      ),
    );

    // Wait for the app to fully initialize
    await tester.pumpAndSettle();

    // Verify that the app title is correct
    expect(find.text(AppConfig.appName.toUpperCase()), findsWidgets);

    // Verify that login screen elements are present (Google Sign-In button)
    // The login screen should be the initial route
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AntarMargApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app name appears somewhere in the UI
    expect(find.text(AppConfig.appName.toUpperCase()), findsWidgets);
  });
}
