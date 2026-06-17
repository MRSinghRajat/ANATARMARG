import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antarmarg/core/services/notification_preferences.dart';
import 'package:antarmarg/features/profile/presentation/screens/notifications_settings_screen.dart';

void main() {
  testWidgets('NotificationsSettingsScreen loads and toggles daily switch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      NotificationPreferences.keyMaster: true,
      NotificationPreferences.keyDaily: true,
      NotificationPreferences.keyPrayer: false,
      NotificationPreferences.keyUpdates: true,
      NotificationPreferences.keyReading: true,
    });

    await tester.pumpWidget(const MaterialApp(
      home: NotificationsSettingsScreen(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Notification center'), findsOneWidget);
    expect(find.text('Daily reminders'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Continue reading'),
      500,
    );
    await tester.pumpAndSettle();
    expect(find.text('Prayer alerts'), findsOneWidget);
    expect(find.text('Messages & updates'), findsOneWidget);
    expect(find.text('Continue reading'), findsOneWidget);

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(5));

    final masterSwitch = tester.widget<Switch>(switches.at(0));
    expect(masterSwitch.value, true);

    final dailySwitch = tester.widget<Switch>(switches.at(1));
    expect(dailySwitch.value, true);

    final prayerSwitch = tester.widget<Switch>(switches.at(2));
    expect(prayerSwitch.value, false);

    await tester.tap(switches.at(1));
    await tester.pump();

    final dailyToggled = tester.widget<Switch>(switches.at(1));
    expect(dailyToggled.value, false);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(NotificationPreferences.keyDaily), false);
  });
}
