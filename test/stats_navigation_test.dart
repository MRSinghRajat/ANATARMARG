import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antarmarg/features/stats/presentation/screens/stats_screen.dart';
import 'package:antarmarg/features/gamification/presentation/screens/leaderboard_screen.dart';

void main() {
  testWidgets('StatsScreen navigates to LeaderboardScreen on button press', (WidgetTester tester) async {
    // Build the StatsScreen wrapped in a MaterialApp and ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Verify StatsScreen is loaded
    expect(find.text('Stats'), findsOneWidget);
    expect(find.byIcon(Icons.leaderboard), findsOneWidget);

    // Tap the leaderboard button
    await tester.tap(find.byIcon(Icons.leaderboard));

    // Wait for the navigation animation to finish
    await tester.pumpAndSettle();

    // Verify LeaderboardScreen is loaded
    expect(find.byType(LeaderboardScreen), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget); // Verify current user tile is present
  });
}
