import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antarmarg/core/services/daily_streak_service.dart';
import 'package:antarmarg/core/utils/app_clock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DailyStreakService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppClock.setDebugDate(null);
    service = DailyStreakService.instance;
    await service.debugResetForTests();
  });

  tearDown(() {
    AppClock.setDebugDate(null);
  });

  test('same-day re-open leaves streak unchanged', () async {
    AppClock.setDebugDate(DateTime(2026, 8, 30));
    final first = await service.recordVisitAndGetPrompt();
    expect(first.prompt, DailyStreakPrompt.day1);
    expect(first.currentStreak, 1);

    final second = await service.recordVisitAndGetPrompt();
    expect(second.prompt, DailyStreakPrompt.none);
    expect(second.currentStreak, 1);
  });

  test('next-day open increments streak', () async {
    AppClock.setDebugDate(DateTime(2026, 8, 30));
    await service.recordVisitAndGetPrompt();

    AppClock.setDebugDate(DateTime(2026, 8, 31));
    final next = await service.recordVisitAndGetPrompt();
    expect(next.prompt, DailyStreakPrompt.streakCount);
    expect(next.currentStreak, 2);
    expect(next.showStreakCelebration, isTrue);
  });

  test('gap of missedYouThresholdDays triggers missed-you and does not auto-reset',
      () async {
    AppClock.setDebugDate(DateTime(2026, 8, 28));
    await service.recordVisitAndGetPrompt();

    AppClock.setDebugDate(DateTime(2026, 8, 30));
    final missed = await service.recordVisitAndGetPrompt();
    expect(missed.prompt, DailyStreakPrompt.missedYou);
    expect(missed.previousStreak, 1);
    expect(missed.currentStreak, 0);

    await service.restartStreakToday();
    expect(service.currentStreak, 1);
  });

  test('timezone travel west (calendar day goes backward) does not increment or reset',
      () async {
    AppClock.setDebugDate(DateTime(2026, 8, 31));
    await service.recordVisitAndGetPrompt();
    expect(service.currentStreak, 1);

    AppClock.setDebugDate(DateTime(2026, 8, 30));
    final result = await service.recordVisitAndGetPrompt();
    expect(result.prompt, DailyStreakPrompt.none);
    expect(result.currentStreak, 1);
  });
}
