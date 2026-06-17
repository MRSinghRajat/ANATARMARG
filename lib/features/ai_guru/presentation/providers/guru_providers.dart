import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../ashram/data/models/daily_task_model.dart';
import '../../../ashram/data/repositories/daily_task_repository.dart';
import '../../repositories/guru_repository.dart';
import '../../services/guru_ai_credits_service.dart';
import '../../services/guru_api_service.dart';
import '../../services/guru_context_builder.dart';
import '../../services/guru_user_tier.dart';
import '../../../../shared/services/feature_gate_config.dart';

final guruAiCreditsServiceProvider = Provider<GuruAiCreditsService>((ref) {
  return GuruAiCreditsService(Supabase.instance.client);
});

final guruRepositoryProvider = Provider<GuruRepository>((ref) {
  return GuruRepository(Supabase.instance.client);
});

final guruContextBuilderProvider = Provider<GuruContextBuilder>((ref) {
  return GuruContextBuilder(Supabase.instance.client);
});

final guruApiServiceProvider = Provider<GuruApiService>((ref) {
  return GuruApiService(
    contextBuilder: ref.watch(guruContextBuilderProvider),
    repository: ref.watch(guruRepositoryProvider),
    credits: ref.watch(guruAiCreditsServiceProvider),
  );
});

/// Latest peek from Supabase (weekly included + purchased). Invalidate after sends / purchases.
final guruCreditPeekProvider = FutureProvider<GuruCreditPeek?>((ref) async {
  return ref.watch(guruAiCreditsServiceProvider).peek();
});

final guruUserTierProvider =
    FutureProvider<UserTier>((ref) async {
  ref.keepAlive();
  return resolveGuruUserTier();
});

/// Today's ashram daily tasks (for optional UI context).
final guruTodayTasksProvider =
    FutureProvider<List<UserDailyTask>>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return [];
  return DailyTaskRepository().getTodaysTasks();
});

/// Most recently read verse id, if any.
final guruLastVerseIdProvider = FutureProvider<String?>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return null;
  final res = await Supabase.instance.client
      .from('user_verse_progress')
      .select('verse_id')
      .eq('user_id', uid)
      .eq('is_read', true)
      .order('read_at', ascending: false)
      .limit(1)
      .maybeSingle();
  return res?['verse_id'] as String?;
});
