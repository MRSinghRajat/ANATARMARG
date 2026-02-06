import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashrae_playground/features/profile/presentation/screens/notifications_settings_screen.dart';

void main() {
  testWidgets('NotificationsSettingsScreen loads and toggles settings', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      'notifications_daily': true,
      'notifications_prayer': false,
    });

    await tester.pumpWidget(const MaterialApp(
      home: NotificationsSettingsScreen(),
    ));

    // Wait for the FutureBuilder/async init to complete
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Daily Reminders'), findsOneWidget);
    expect(find.text('Prayer Alerts'), findsOneWidget);
    expect(find.text('New Content Updates'), findsOneWidget);

    // Check switch values (Switch widgets)
    final dailySwitch = tester.widget<Switch>(find.byType(Switch).at(0));
    expect(dailySwitch.value, true);

    final prayerSwitch = tester.widget<Switch>(find.byType(Switch).at(1));
    expect(prayerSwitch.value, false);

    final contentSwitch = tester.widget<Switch>(find.byType(Switch).at(2));
    expect(contentSwitch.value, true); // Default was true in code if null

    // Toggle a switch
    await tester.tap(find.byType(Switch).at(0));
    await tester.pump(); // Rebuild

    // Verify change
    final dailySwitchToggled = tester.widget<Switch>(find.byType(Switch).at(0));
    expect(dailySwitchToggled.value, false);

    // Verify persistence
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notifications_daily'), false);
  });
}
