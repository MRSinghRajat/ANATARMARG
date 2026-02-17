import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// Centralized clock for the app.
///
/// In production: returns real system time via `clock.now()`.
/// In debug mode: can be overridden to any date for testing daily tasks,
/// verses, stories, etc.
///
/// Usage: Replace `DateTime.now()` with `AppClock.now()` everywhere.
class AppClock {
  static DateTime? _debugOverride;

  /// Current date-time. Uses debug override if set, otherwise real clock.
  static DateTime now() {
    if (kDebugMode && _debugOverride != null) {
      // Keep the overridden date but use current wall-clock time
      final real = clock.now();
      return DateTime(
        _debugOverride!.year,
        _debugOverride!.month,
        _debugOverride!.day,
        real.hour,
        real.minute,
        real.second,
      );
    }
    return clock.now();
  }

  /// Today's date string (YYYY-MM-DD)
  static String todayString() {
    return now().toIso8601String().split('T')[0];
  }

  /// Set a debug date override (debug builds only).
  /// Pass null to clear and return to real time.
  static void setDebugDate(DateTime? date) {
    if (kDebugMode) {
      _debugOverride = date;
    }
  }

  /// Current debug date override, if any.
  static DateTime? get debugDate => kDebugMode ? _debugOverride : null;

  /// Whether a debug override is currently active.
  static bool get isOverridden => kDebugMode && _debugOverride != null;
}
