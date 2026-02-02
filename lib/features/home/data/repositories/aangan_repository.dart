import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_intention_model.dart';
import '../services/user_presence_service.dart';

enum AanganTimeContext {
  morning,
  day,
  evening,
  night,
}

class AanganContent {
  final String greeting;
  final String intention;
  final String buttonText;
  final String quietText;
  final AanganTimeContext timeContext;

  AanganContent({
    required this.greeting,
    required this.intention,
    required this.buttonText,
    required this.quietText,
    required this.timeContext,
  });
}

class AanganRepository {
  final UserPresenceService _presenceService = UserPresenceService();
  static const String _todayIntentionKey = 'aangan_today_intention_json';
  static const String _todayDateKey = 'aangan_today_date_key';

  // Seed Data (Kids/Safe)
  final List<DailyIntentionModel> _seedIntentions = [
    DailyIntentionModel(id: '1', text: 'Today we practice kindness.', tone: IntentionTone.gentle),
    DailyIntentionModel(id: '2', text: 'Small actions matter.', tone: IntentionTone.encouraging),
    DailyIntentionModel(id: '3', text: 'Let’s stay calm today.', tone: IntentionTone.gentle),
    DailyIntentionModel(id: '4', text: 'We listen with our hearts.', tone: IntentionTone.gentle),
    DailyIntentionModel(id: '5', text: 'Patience is a superpower.', tone: IntentionTone.encouraging),
    DailyIntentionModel(id: '6', text: 'Breathe in, breathe out.', tone: IntentionTone.neutral),
    DailyIntentionModel(id: '7', text: 'Kind words create smiles.', tone: IntentionTone.encouraging),
  ];

  Future<AanganContent> getDailyContent() async {
    // 1. Determine Time Context
    final timeContext = _getTimeContext();

    // 2. Determine Greeting based on Presence
    final greeting = await _getGreeting(timeContext);

    // 3. Get or Generate Intention (Locked for the Day)
    final intention = await _getOrGenerateIntention();

    // 4. Update Last Seen (Side effect, but ensures tracking)
    await _presenceService.updateLastSeen();

    return AanganContent(
      greeting: greeting,
      intention: intention.text,
      buttonText: "Let's begin 🌿",
      quietText: "Take one slow breath",
      timeContext: timeContext,
    );
  }

  AanganTimeContext _getTimeContext() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return AanganTimeContext.morning;
    } else if (hour >= 12 && hour < 17) {
      return AanganTimeContext.day;
    } else if (hour >= 17 && hour < 20) {
      return AanganTimeContext.evening;
    } else {
      return AanganTimeContext.night;
    }
  }

  Future<String> _getGreeting(AanganTimeContext timeContext) async {
    final lastSeen = await _presenceService.getLastSeen();
    final now = DateTime.now();

    // First time ever
    if (lastSeen == null) {
      return _getTimeBasedGreeting(timeContext);
    }

    // Check gap
    final isSameDay = lastSeen.year == now.year && 
                      lastSeen.month == now.month && 
                      lastSeen.day == now.day;
                      
    if (isSameDay) {
      return 'Good to see you again';
    }

    final daysGap = now.difference(lastSeen).inDays;
    
    if (daysGap > 7) {
      return 'It’s okay to begin again.';
    } else if (daysGap > 3) {
      return 'Welcome back. Take your time.';
    } else {
      // Regular return
      return _getTimeBasedGreeting(timeContext);
    }
  }

  String _getTimeBasedGreeting(AanganTimeContext context) {
    switch (context) {
      case AanganTimeContext.morning:
        return 'Good morning';
      case AanganTimeContext.day:
        return 'Good afternoon';
      case AanganTimeContext.evening:
        return 'Good evening';
      case AanganTimeContext.night:
        return 'Welcome back';
    }
  }

  Future<DailyIntentionModel> _getOrGenerateIntention() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}_${now.month}_${now.day}';
    
    final storedDateKey = prefs.getString(_todayDateKey);
    final storedIntentionJson = prefs.getString(_todayIntentionKey);

    // If we have an intention stored for TODAY, return it (LOCK)
    if (storedDateKey == todayKey && storedIntentionJson != null) {
      return DailyIntentionModel.fromJson(jsonDecode(storedIntentionJson));
    }

    // Otherwise, generate new one
    final newIntention = _seedIntentions[Random().nextInt(_seedIntentions.length)];
    
    // Save it
    await prefs.setString(_todayDateKey, todayKey);
    await prefs.setString(_todayIntentionKey, jsonEncode(newIntention.toJson()));

    return newIntention;
  }
}
