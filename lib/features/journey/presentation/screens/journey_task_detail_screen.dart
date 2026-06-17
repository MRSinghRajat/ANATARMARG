import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/widgets/flying_coins_animation.dart';
import '../../../profile/presentation/providers/language_provider.dart';
import '../../data/journey_logic.dart';
import '../../data/models/journey_models.dart';
import '../../data/repositories/journey_repository.dart';
import '../providers/journey_providers.dart';

class JourneyTaskDetailScreen extends ConsumerStatefulWidget {
  final String userJourneyId;
  final String taskId;

  const JourneyTaskDetailScreen({
    super.key,
    required this.userJourneyId,
    required this.taskId,
  });

  @override
  ConsumerState<JourneyTaskDetailScreen> createState() => _JourneyTaskDetailScreenState();
}

/// Fallback coin reward when task.coinReward is 0 (DB not yet updated).
const int _kJourneyTaskCoinReward = 5;

class _JourneyTaskDetailScreenState extends ConsumerState<JourneyTaskDetailScreen> {
  int _mantraCount = 0;
  bool _isCompleting = false;
  final GlobalKey _completeButtonKey = GlobalKey();
  bool _showHindiContent = false;

  Widget _appBarTitleWidget() {
    // Unconditional watches — never put ref.watch inside AsyncValue.when branches (Riverpod rule).
    final uj = ref.watch(userJourneyProvider(widget.userJourneyId)).valueOrNull;
    final typeId = uj?.journeyTypeId ?? '';
    final tasksAsync = ref.watch(journeyTasksProvider(typeId));
    if (uj == null) {
      return _appBarTitleText('Task');
    }
    return tasksAsync.when(
      data: (tasks) {
        final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;
        return _appBarTitleText(task?.title ?? 'Task');
      },
      loading: () => _appBarTitleText('Task'),
      error: (_, __) => _appBarTitleText('Task'),
    );
  }

  Widget _appBarTitleText(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: AppColors.zinc100,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final journeyAsync = ref.watch(userJourneyProvider(widget.userJourneyId));

    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      appBar: AppBar(
        title: _appBarTitleWidget(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.zinc100,
        surfaceTintColor: Colors.transparent,
      ),
      body: journeyAsync.when(
        data: (userJourney) {
          if (userJourney == null) {
            return const Center(child: Text('Journey not found'));
          }
          return _buildTaskContent(userJourney);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTaskContent(UserJourney userJourney) {
    final tasksAsync = ref.watch(journeyTasksProvider(userJourney.journeyTypeId));
    final completedTodayAsync =
        ref.watch(journeyCompletedTaskIdsTodayProvider(widget.userJourneyId));
    final completedToday = completedTodayAsync.valueOrNull ?? {};
    return tasksAsync.when(
      data: (tasks) {
        final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;
        if (task == null) return const Center(child: Text('Task not found'));

        final poolAsync = ref.watch(contentPoolByTaskSlugProvider(ContentPoolParams(
          taskSlug: task.slug,
          journeyTypeId: userJourney.journeyTypeId,
        )));

        return poolAsync.when(
          data: (poolList) {
            if (poolList.isEmpty) {
              return _buildNoContent(task, userJourney, tasks, completedToday);
            }
            final rotationType = poolList.first['rotation_type'] as String? ?? 'sequential';
            final picked = JourneyRepository.pickFromPool(
              poolList,
              userJourney.startDate,
              rotationType,
            );
            if (picked != null) {
              return _buildUnifiedContentTask(task, picked, userJourney, tasks, completedToday);
            }
            return _buildNoContent(task, userJourney, tasks, completedToday);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          ),
          error: (e, _) => _buildNoContent(task, userJourney, tasks, completedToday),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  /// Renders content from one row: content, content_hindi, instruction (or transliteration+translation+benefits), audio_url, ref_type+ref_id.
  /// UI matches reference: icon + title + Hindi + duration, subtitle + language toggle, mantra box, INSTRUCTION with subsections, Mark Complete.
  Widget _buildUnifiedContentTask(
    JourneyTask task,
    Map<String, dynamic> row,
    UserJourney userJourney,
    List<JourneyTask> allTasks,
    Set<String> completedTaskIdsToday,
  ) {
    final content = _str(row['content']);
    final contentHindi = _str(row['content_hindi']);
    final instruction = _str(row['instruction']);
    final instructionHindi = _str(row['instruction_hindi']);
    final transliteration = _str(row['transliteration']);
    final translation = _str(row['translation']);
    final benefits = row['benefits'];
    final refType = _str(row['ref_type']);
    final refId = _str(row['ref_id']);
    final refSlug = _str(row['ref_slug']);
    final refForLink = (refId != null && refId.isNotEmpty) ? refId : refSlug;
    final title = _str(row['title']) ?? task.title;
    final titleHindi = _str(row['title_hindi']) ?? task.titleHindi;
    final rawSecs = row['duration_seconds'];
    final durationMinutes = rawSecs is int
        ? rawSecs ~/ 60
        : rawSecs is num
            ? rawSecs.toInt().clamp(0, 999) ~/ 60
            : task.durationMinutes ?? 0;

    final useHindi = _showHindiContent && (contentHindi != null || instructionHindi != null);
    final mainText = _cleanContentText(useHindi ? (contentHindi ?? content ?? '') : (content ?? contentHindi ?? ''));
    final instructionText = _cleanContentText(useHindi ? (instructionHindi ?? instruction ?? '') : (instruction ?? instructionHindi ?? ''));

    final hasRef =
        refType != null && refType.isNotEmpty && refForLink != null && refForLink.isNotEmpty;
    final hasStructuredInstruction = (transliteration != null && transliteration.isNotEmpty) ||
        (translation != null && translation.isNotEmpty) ||
        (benefits is List && benefits.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUnifiedTaskTitleBlock(task: task, title: title, titleHindi: titleHindi, durationMinutes: durationMinutes),
          if ((content != null || contentHindi != null) && mainText.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title.isNotEmpty ? '${title.toUpperCase()} MANTRA' : 'MANTRA',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
                if ((contentHindi != null && content != null) || (instructionHindi != null && instruction != null))
                  _buildSegmentedLangToggle(),
              ],
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.25), width: 1),
                ),
                child: _JourneyLongMantraText(
                  text: mainText,
                  style: GoogleFonts.crimsonPro(fontSize: 18, color: Colors.white.withValues(alpha: 0.9), height: 1.9),
                ),
              ),
            ),
          ],
          if (hasStructuredInstruction || instructionText.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'INSTRUCTION',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            if (hasStructuredInstruction) ...[
              if (transliteration != null && transliteration.isNotEmpty) ...[
                Text(
                  'Transliteration',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _cleanContentText(transliteration),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.5),
                ),
                const SizedBox(height: 14),
              ],
              if (translation != null && translation.isNotEmpty) ...[
                Text(
                  'Meaning',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _cleanContentText(translation),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.5),
                ),
                const SizedBox(height: 14),
              ],
              if (benefits is List && benefits.isNotEmpty) ...[
                Text(
                  'Benefits',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                ...(benefits as List).map((e) {
                  final s = _str(e);
                  if (s == null || s.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryOrange)),
                        Expanded(
                          child: Text(
                            _cleanContentText(s),
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ] else if (instructionText.isNotEmpty)
              Text(
                instructionText,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.5),
              ),
          ],
          // Meditation timer — shown when task type is meditation + duration > 0
          if ((task.taskType == 'meditation' || task.taskType == 'yoga') &&
              durationMinutes > 0) ...[
            const SizedBox(height: 24),
            _MeditationTimerButton(durationMinutes: durationMinutes),
          ],
          // Mantra counter — shown for mantra tasks with a target count
          if (task.taskType == 'mantra' && (task.mantraCount ?? 0) > 0) ...[
            const SizedBox(height: 24),
            _buildMantraCounter(task.mantraCount!),
          ],
          // Open in Granthalaya link
          if (hasRef) ...[
            const SizedBox(height: 16),
            _buildRefLink(refType, refForLink),
          ],
          const SizedBox(height: 32),
          _buildCompleteButton(task, userJourney, allTasks, completedTaskIdsToday),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildUnifiedTaskTitleBlock({
    required JourneyTask task,
    required String title,
    String? titleHindi,
    int durationMinutes = 0,
  }) {
    final icon = task.icon ?? 'ॐ';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.journeyDeepPurple.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(icon, style: GoogleFonts.crimsonPro(fontSize: 24, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                  ),
                  if (titleHindi != null && titleHindi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      titleHindi,
                      style: GoogleFonts.crimsonPro(fontSize: 15, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                  if (durationMinutes > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 16, color: AppColors.primaryOrange.withValues(alpha: 0.9)),
                        const SizedBox(width: 4),
                        Text(
                          '$durationMinutes min',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryOrange.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Segmented control: English (gold when selected) | Hindi, matching reference image.
  Widget _buildSegmentedLangToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentChip(label: 'English', selected: !_showHindiContent, onTap: () => setState(() => _showHindiContent = false)),
          _segmentChip(label: 'Hindi', selected: _showHindiContent, onTap: () => setState(() => _showHindiContent = true)),
        ],
      ),
    );
  }

  Widget _segmentChip({required String label, required bool selected, required VoidCallback onTap}) {
    return Material(
      color: selected ? AppColors.primaryOrange : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black87 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefLink(String refType, String refIdOrSlug) {
    if (refType == 'lullaby') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.nightlight_round, color: AppColors.primaryOrange, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pick any calm song or lullaby you love and sing it yourself — in your own voice. '
                'No playback in the app; your live singing is what nurtures your baby.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final label = switch (refType) {
      'sacred_text' => 'Open in Granthalaya',
      _ => 'Read in Granthalaya',
    };
    return Material(
      color: AppColors.primaryOrange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _navigateToRef(refType, refIdOrSlug),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.primaryOrange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryOrange),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.primaryOrange.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRef(String refType, String refId) {
    if (refType == 'lullaby') return;
    Navigator.of(context).pushNamed(
      AppRouter.journeyOpenContent,
      arguments: {
        'refType': refType,
        'refIdOrSlug': refId,
      },
    );
  }

  Widget _buildNoContent(
    JourneyTask task,
    UserJourney userJourney,
    List<JourneyTask> allTasks,
    Set<String> completedTaskIdsToday,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTaskHeader(task),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'No content for this task yet.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.zinc500),
            ),
          ),
          const SizedBox(height: 32),
          _buildCompleteButton(task, userJourney, allTasks, completedTaskIdsToday),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  /// Universal rendering: show content from resolved map using standard keys.
  /// Handles body_text, lyrics, description, name, ritual_steps, transliteration, translation, audio, duration.
  Widget _buildResolvedContentTask(
    JourneyTask task,
    Map<String, dynamic> resolved,
    UserJourney userJourney,
    List<JourneyTask> allTasks,
    Set<String> completedTaskIdsToday,
  ) {
    final title = _str(resolved['title']) ?? _str(resolved['name']) ?? _str(resolved['name_sanskrit']) ?? task.title;
    final body = _str(resolved['body_text']) ?? _str(resolved['content']) ?? _str(resolved['lyrics']) ?? _str(resolved['description']) ?? _str(resolved['subtitle']);
    final transliteration = _str(resolved['transliteration']);
    final translation = _str(resolved['translation']);
    final significance = _str(resolved['significance']);
    final audioUrl = _str(resolved['audio_url']) ?? _str(resolved['audio_storage_path']);
    final ritualSteps = resolved['ritual_steps'];
    final durationSeconds = resolved['duration_seconds'] is int
        ? resolved['duration_seconds'] as int?
        : (resolved['duration_seconds'] as num?)?.toInt();

    final hasMainText = body != null && body.isNotEmpty;
    final hasSteps = ritualSteps is List && ritualSteps.isNotEmpty;
    final hasTransliterationOrTranslation = (transliteration != null && transliteration.isNotEmpty) || (translation != null && translation.isNotEmpty);
    final hasNothing = !hasMainText && !hasSteps && !hasTransliterationOrTranslation;

    // When resolved has no displayable content, try inline_content (JSON) as fallback so Garbh Gayatri etc. still show
    final inlineMap = _parseInlineContentJson(task.inlineContent) ?? _parseInlineContentJson(task.inlineContentHindi);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTaskHeader(task),
          const SizedBox(height: 20),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _cleanContentText(title),
                style: GoogleFonts.crimsonPro(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          if (significance != null && significance.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _cleanContentText(significance),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryOrange.withValues(alpha: 0.85), height: 1.5),
              ),
            ),
          if (hasMainText)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.1)),
              ),
              child: Text(
                _cleanContentText(body!),
                style: GoogleFonts.crimsonPro(fontSize: 17, color: Colors.white.withValues(alpha: 0.85), height: 1.8),
              ),
            ),
          if (transliteration != null && transliteration.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _cleanContentText(transliteration),
              style: GoogleFonts.crimsonPro(fontSize: 15, fontStyle: FontStyle.italic, color: AppColors.primaryOrange.withValues(alpha: 0.9)),
            ),
          ],
          if (translation != null && translation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _cleanContentText(translation),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
          if (hasSteps) ...[
            const SizedBox(height: 20),
            ...(ritualSteps as List).map((step) {
              final map = step is Map<String, dynamic> ? step : <String, dynamic>{};
              final stepNum = map['step'];
              final stepTitle = _str(map['title']) ?? 'Step ${stepNum ?? ''}';
              final desc = _str(map['description']) ?? '';
              final mantra = _str(map['mantra']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_cleanContentText(stepTitle), style: GoogleFonts.crimsonPro(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryOrange)),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(_cleanContentText(desc), style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), height: 1.5)),
                      ],
                      if (mantra != null && mantra.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(_cleanContentText(mantra), style: GoogleFonts.crimsonPro(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.primaryOrange.withValues(alpha: 0.9))),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
          if (durationSeconds != null && durationSeconds > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 18, color: AppColors.primaryOrange.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Text('${durationSeconds ~/ 60} min', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryOrange.withValues(alpha: 0.8))),
              ],
            ),
          ],
          if (audioUrl != null && audioUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Audio available',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryOrange.withValues(alpha: 0.7)),
            ),
          ],
          if (hasNothing && inlineMap != null) ...[
            const SizedBox(height: 16),
            ..._buildInlineContentFromMap(inlineMap),
          ],
          if (hasNothing && inlineMap == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No content loaded for this task.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.zinc500),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 32),
          _buildCompleteButton(task, userJourney, allTasks, completedTaskIdsToday),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }

  /// Makes stored content human-readable: literal \n and \\n become real newlines.
  static String _cleanContentText(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .split('\n')
        .map((e) => e.trim())
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  Widget _buildInlineTask(
    JourneyTask task,
    UserJourney userJourney,
    List<JourneyTask> allTasks,
    Set<String> completedTaskIdsToday,
  ) {
    final contentMapEn = _parseInlineContentJson(task.inlineContent);
    final contentMapHi = _parseInlineContentJson(task.inlineContentHindi);
    final hasBoth = contentMapEn != null && contentMapHi != null;
    final contentMap = hasBoth
        ? (_showHindiContent ? contentMapHi : contentMapEn)
        : (contentMapEn ?? contentMapHi ?? _parseInlineContentJson(task.inlineContent));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTaskHeader(task),
          if (hasBoth) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Language:', style: GoogleFonts.inter(fontSize: 14, color: AppColors.zinc500)),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('English'),
                  selected: !_showHindiContent,
                  onSelected: (v) => setState(() => _showHindiContent = false),
                  selectedColor: AppColors.primaryOrange.withValues(alpha: 0.3),
                  labelStyle: GoogleFonts.inter(fontSize: 13, color: _showHindiContent ? AppColors.zinc500 : AppColors.primaryOrange),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('हिंदी'),
                  selected: _showHindiContent,
                  onSelected: (v) => setState(() => _showHindiContent = true),
                  selectedColor: AppColors.primaryOrange.withValues(alpha: 0.3),
                  labelStyle: GoogleFonts.inter(fontSize: 13, color: _showHindiContent ? AppColors.primaryOrange : AppColors.zinc500),
                ),
              ],
            ),
          ],
          if (contentMap != null) ...[
            const SizedBox(height: 20),
            ..._buildInlineContentFromMap(contentMap),
          ] else if (task.inlineContent != null && task.inlineContent!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.1)),
              ),
              child: Text(
                task.inlineContent!,
                style: GoogleFonts.crimsonPro(fontSize: 17, color: Colors.white.withValues(alpha: 0.85), height: 1.8),
              ),
            ),
          ],
          if (task.mantraCount != null && task.mantraCount! > 0) ...[
            const SizedBox(height: 24),
            _buildMantraCounter(task.mantraCount!),
          ],
          const SizedBox(height: 32),
          _buildCompleteButton(task, userJourney, allTasks, completedTaskIdsToday),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  /// inline_content / inline_content_hindi are stored as JSON-encoded strings; double-decode to get the map.
  static Map<String, dynamic>? _parseInlineContentJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Widget> _buildInlineContentFromMap(Map<String, dynamic> content) {
    final title = _str(content['title']) ?? _str(content['title_hindi']) ?? _str(content['title_sanskrit']);
    final subtitle = _str(content['subtitle']);
    final bodyText = _str(content['body_text']) ?? _str(content['body']) ?? _str(content['text']);
    final description = _str(content['description']);
    final transliteration = _str(content['transliteration']);
    final translation = _str(content['translation']);
    final benefits = content['benefits'];
    final durationSeconds = content['duration_seconds'] is int
        ? content['duration_seconds'] as int?
        : (content['duration_seconds'] as num?)?.toInt();

    final children = <Widget>[];

    if (title != null && title.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _cleanContentText(title),
            style: GoogleFonts.crimsonPro(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
    if (subtitle != null && subtitle.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            _cleanContentText(subtitle),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryOrange.withValues(alpha: 0.9)),
          ),
        ),
      );
    }
    if (bodyText != null && bodyText.isNotEmpty) {
      children.add(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.1)),
          ),
          child: Text(
            _cleanContentText(bodyText),
            style: GoogleFonts.crimsonPro(fontSize: 17, color: Colors.white.withValues(alpha: 0.85), height: 1.8),
          ),
        ),
      );
    }
    if (transliteration != null && transliteration.isNotEmpty) {
      children.addAll([
        const SizedBox(height: 12),
        Text(
          _cleanContentText(transliteration),
          style: GoogleFonts.crimsonPro(fontSize: 15, fontStyle: FontStyle.italic, color: AppColors.primaryOrange.withValues(alpha: 0.9)),
        ),
      ]);
    }
    if (translation != null && translation.isNotEmpty) {
      children.addAll([
        const SizedBox(height: 8),
        Text(
          _cleanContentText(translation),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
        ),
      ]);
    }
    if (description != null && description.isNotEmpty && description != bodyText) {
      children.addAll([
        const SizedBox(height: 16),
        Text(
          _cleanContentText(description),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.75), height: 1.5),
        ),
      ]);
    }
    if (benefits is List && benefits.isNotEmpty) {
      children.addAll([
        const SizedBox(height: 16),
        Text('Benefits', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryOrange)),
        const SizedBox(height: 6),
        ...(benefits as List).map((e) {
          final s = _str(e);
          if (s == null || s.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryOrange.withValues(alpha: 0.8))),
                Expanded(child: Text(_cleanContentText(s), style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)))),
              ],
            ),
          );
        }),
      ]);
    }
    if (durationSeconds != null && durationSeconds > 0) {
      children.addAll([
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.timer_outlined, size: 18, color: AppColors.primaryOrange.withValues(alpha: 0.8)),
            const SizedBox(width: 6),
            Text('${durationSeconds ~/ 60} min', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryOrange.withValues(alpha: 0.8))),
          ],
        ),
      ]);
    }
    return children;
  }

  Widget _buildPoolTask(
    JourneyTask task,
    JourneyContentItem? item,
    UserJourney userJourney,
    List<JourneyTask> allTasks,
    Set<String> completedTaskIdsToday,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTaskHeader(task),
          if (item != null) ...[
            const SizedBox(height: 20),
            _buildContentCard(item),
            if (item.instruction != null && item.instruction!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                item.instruction!,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6), height: 1.6),
              ),
            ],
            if (item.content != null && item.content!.isNotEmpty && item.isInline) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.1)),
                ),
                child: Text(
                  item.content!,
                  style: GoogleFonts.crimsonPro(fontSize: 17, color: Colors.white.withValues(alpha: 0.85), height: 1.8),
                ),
              ),
            ],
            if (item.mantraCount != null && item.mantraCount! > 0) ...[
              const SizedBox(height: 24),
              _buildMantraCounter(item.mantraCount!),
            ],
          ] else ...[
            const SizedBox(height: 20),
            Center(child: Text('No content available today', style: GoogleFonts.inter(color: Colors.white38))),
          ],
          const SizedBox(height: 32),
          _buildCompleteButton(task, userJourney, allTasks, completedTaskIdsToday),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTaskHeader(JourneyTask task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.icon != null && task.icon!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(task.icon!, style: const TextStyle(fontSize: 32)),
          ),
        Text(
          task.title,
          style: GoogleFonts.crimsonPro(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (task.titleHindi != null) ...[
          const SizedBox(height: 4),
          Text(task.titleHindi!, style: GoogleFonts.crimsonPro(fontSize: 16, color: Colors.white.withValues(alpha: 0.5))),
        ],
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(task.description!, style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.5)),
        ],
        if (task.durationMinutes != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: AppColors.primaryOrange.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text('${task.durationMinutes} min', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryOrange.withValues(alpha: 0.6))),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContentCard(JourneyContentItem item) {
    final hasNavigation = item.refType != null &&
        item.refType!.isNotEmpty &&
        item.refType != 'lullaby';
    final coverImage = item.resolvedCoverImage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasNavigation ? () => _navigateToContent(item) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              if (coverImage != null && coverImage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 56, height: 56, child: Image.network(coverImage, fit: BoxFit.cover)),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(item.icon.isNotEmpty ? item.icon : '📖', style: const TextStyle(fontSize: 24))),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.resolvedTitle,
                      style: GoogleFonts.crimsonPro(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    if (item.refType != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _refTypeLabel(item.refType!),
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.primaryOrange.withValues(alpha: 0.6)),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasNavigation)
                Icon(Icons.chevron_right, color: AppColors.primaryOrange.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }

  String _refTypeLabel(String refType) {
    switch (refType) {
      case 'story': return 'Sacred Story';
      case 'sacred_text': return 'Sacred Text';
      case 'lullaby': return 'Sing your favourite song';
      case 'chapter': return 'Chapter';
      case 'verse': return 'Verse';
      default: return refType;
    }
  }

  void _navigateToContent(JourneyContentItem item) {
    final slug = item.refSlug ?? item.refId ?? '';
    if (slug.isEmpty) return;
    if (item.refType == 'lullaby') return;
    switch (item.refType) {
      case 'story':
      case 'sacred_story':
        Navigator.of(context).pushNamed(
          AppRouter.journeyOpenContent,
          arguments: {'refType': 'sacred_story', 'refIdOrSlug': slug},
        );
        return;
      case 'sacred_text':
        Navigator.of(context).pushNamed(
          AppRouter.journeyOpenContent,
          arguments: {'refType': 'sacred_text', 'refIdOrSlug': slug},
        );
        return;
      default:
        Navigator.of(context).pushNamed(
          AppRouter.journeyOpenContent,
          arguments: {'refType': 'sacred_story', 'refIdOrSlug': slug},
        );
    }
  }

  Widget _buildMantraCounter(int target) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text('MANTRA COUNT', style: GoogleFonts.cinzel(fontSize: 10, color: AppColors.primaryOrange, letterSpacing: 2)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (_mantraCount < target) {
                setState(() => _mantraCount++);
                HapticFeedback.lightImpact();
              }
              if (_mantraCount >= target) {
                HapticFeedback.heavyImpact();
              }
            },
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryOrange.withValues(alpha: _mantraCount >= target ? 0.4 : 0.15),
                    AppColors.primaryOrange.withValues(alpha: _mantraCount >= target ? 0.2 : 0.05),
                  ],
                ),
                border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  '$_mantraCount',
                  style: GoogleFonts.crimsonPro(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_mantraCount / $target',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 4),
          Text(
            _mantraCount >= target ? 'Complete!' : 'Tap to count',
            style: GoogleFonts.inter(fontSize: 12, color: _mantraCount >= target ? AppColors.primaryOrange : Colors.white.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(
    JourneyTask task,
    UserJourney userJourney,
    List<JourneyTask> allTasks,
    Set<String> completedTaskIdsToday,
  ) {
    final calendarPhase = JourneyLogic.getCurrentPhaseFromTasks(userJourney, allTasks);
    final reason = JourneyLogic.taskCompletionBlockedReason(
      userJourney: userJourney,
      task: task,
      calendarPhase: calendarPhase,
      allTasks: allTasks,
      completedTaskIdsToday: completedTaskIdsToday,
    );
    final canComplete = reason == null;
    return KeyedSubtree(
      key: _completeButtonKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (reason != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.zinc500.withValues(alpha: 0.35)),
              ),
              child: Text(
                reason,
                style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: AppColors.zinc500),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: (_isCompleting || !canComplete) ? null : () => _completeTask(task, userJourney, allTasks, completedTaskIdsToday),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: AppColors.zinc500.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.black54,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isCompleting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : Text(
                    canComplete ? 'Mark Complete' : 'Complete unavailable',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeTask(
    JourneyTask task,
    UserJourney userJourney,
    List<JourneyTask> allTasks,
    Set<String> completedTaskIdsToday,
  ) async {
    final calendarPhase = JourneyLogic.getCurrentPhaseFromTasks(userJourney, allTasks);
    if (!JourneyLogic.canCompleteTaskToday(
      userJourney: userJourney,
      task: task,
      calendarPhase: calendarPhase,
      allTasks: allTasks,
      completedTaskIdsToday: completedTaskIdsToday,
    )) {
      return;
    }
    setState(() => _isCompleting = true);
    try {
      final repo = ref.read(journeyRepositoryProvider);
      // Use coin reward from DB; fall back to constant only if 0/null
      final coins = (task.coinReward > 0) ? task.coinReward : _kJourneyTaskCoinReward;
      await repo.completeTask(
        userId: userJourney.userId,
        userJourneyId: widget.userJourneyId,
        taskId: task.id,
        mantraCountDone: _mantraCount > 0 ? _mantraCount : null,
        coinReward: coins,
      );
      await CoinService().addCoins(coins);
      ref.invalidate(todaysJourneyTasksProvider(widget.userJourneyId));
      ref.invalidate(displayedJourneyTasksProvider(widget.userJourneyId));
      ref.invalidate(journeyCompletedTaskIdsTodayProvider(widget.userJourneyId));
      ref.invalidate(allJourneyTasksWithTodayCompletionProvider(widget.userJourneyId));
      if (mounted) {
        await FlyingCoinsAnimation.show(
          context,
          amount: coins,
          fromKey: _completeButtonKey,
          toKey: FlyingCoinsAnimation.coinCounterKey,
        );
        if (mounted) {
          final currencyName = AppStrings.get(
            'ashram_currency',
            ref.read(languageProvider),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${task.title} completed! +$coins $currencyName'),
              backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.9),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }
}

// ─── Meditation Timer ─────────────────────────────────────────────────────────

class _MeditationTimerButton extends StatefulWidget {
  final int durationMinutes;

  const _MeditationTimerButton({required this.durationMinutes});

  @override
  State<_MeditationTimerButton> createState() => _MeditationTimerButtonState();
}

class _MeditationTimerButtonState extends State<_MeditationTimerButton> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPause() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      if (_secondsRemaining <= 0) {
        _secondsRemaining = widget.durationMinutes * 60;
      }
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining <= 0) {
            _running = false;
            t.cancel();
            HapticFeedback.heavyImpact();
          }
        });
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _secondsRemaining = widget.durationMinutes * 60;
    });
  }

  String get _display {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final done = _secondsRemaining <= 0;
    final total = widget.durationMinutes * 60;
    final progress = done ? 1.0 : 1.0 - (_secondsRemaining / total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ashramCardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'MEDITATION TIMER',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryOrange,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.charcoalCard,
                  valueColor: AlwaysStoppedAnimation(
                    done ? Colors.greenAccent : AppColors.primaryOrange,
                  ),
                ),
              ),
              Text(
                done ? '✓' : _display,
                style: GoogleFonts.inter(
                  fontSize: done ? 28 : 22,
                  fontWeight: FontWeight.w700,
                  color: done ? Colors.greenAccent : AppColors.zinc100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: done ? _reset : _startPause,
                icon: Icon(
                  done
                      ? Icons.refresh_rounded
                      : (_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  size: 20,
                ),
                label: Text(done ? 'Restart' : (_running ? 'Pause' : 'Start')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_running || (!done && _secondsRemaining < widget.durationMinutes * 60)) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _reset,
                  child: Text('Reset', style: GoogleFonts.inter(color: AppColors.zinc500)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Avoids layout jank from multi‑KB Devanagari blocks: show a preview first, expand on demand.
class _JourneyLongMantraText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _JourneyLongMantraText({required this.text, required this.style});

  @override
  State<_JourneyLongMantraText> createState() => _JourneyLongMantraTextState();
}

class _JourneyLongMantraTextState extends State<_JourneyLongMantraText> {
  static const int _previewChars = 2200;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.text;
    if (t.length <= _previewChars) {
      return Text(t, style: widget.style);
    }
    final shown = _expanded ? t : '${t.substring(0, _previewChars).trim()}…';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(shown, style: widget.style),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Show full text (${t.length} characters)',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ],
    );
  }
}
