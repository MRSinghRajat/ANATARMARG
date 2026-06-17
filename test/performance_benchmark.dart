import 'dart:convert';
import 'package:antarmarg/features/books/data/models/verse_translation_model.dart';

void main() {
  const int totalItems = 10000;
  const String targetLanguage = 'en';
  const double targetPercentage = 0.05; // 5% of items are 'en'

  // Generate simulated response data (List of Maps)
  final List<Map<String, dynamic>> largeDataset = [];
  final List<Map<String, dynamic>> smallDataset = [];

  for (int i = 0; i < totalItems; i++) {
    final bool isTarget = i < (totalItems * targetPercentage);
    final String lang = isTarget ? targetLanguage : 'other';

    final item = {
      'id': 'id_$i',
      'verse_id': 'verse_$i',
      'language_code': lang,
      'language_name': lang == 'en' ? 'English' : 'Other',
      'text': 'Some translation text here...',
      'is_primary': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    largeDataset.add(item);
    if (isTarget) {
      smallDataset.add(item);
    }
  }

  print('Benchmark started...');
  print('Total items: $totalItems');
  print('Target items: ${smallDataset.length}');

  // Measure Baseline (Client-side filtering)
  final stopwatch = Stopwatch()..start();

  final List<VerseTranslationModel> baselineResult = [];
  for (final row in largeDataset) {
    final tMap = row;
    if ((tMap['language_code'] as String?) != targetLanguage) {
      continue;
    }
    baselineResult.add(VerseTranslationModel.fromJson(tMap));
  }

  stopwatch.stop();
  final int baselineTime = stopwatch.elapsedMicroseconds;
  print('Baseline (Client-side filtering): $baselineTimeµs');

  // Measure Optimized (Server-side filtering simulation)
  stopwatch.reset();
  stopwatch.start();

  final List<VerseTranslationModel> optimizedResult = [];
  for (final row in smallDataset) {
    // No filtering needed here as server sent only matching rows
    // But we still convert to model
    optimizedResult.add(VerseTranslationModel.fromJson(row));
  }

  stopwatch.stop();
  final int optimizedTime = stopwatch.elapsedMicroseconds;
  print('Optimized (Server-side filtering): $optimizedTimeµs');

  // Calculate Improvement
  final double improvement = (baselineTime - optimizedTime) / baselineTime * 100;
  print('CPU Improvement: ${improvement.toStringAsFixed(2)}%');

  // Estimate Data Transfer Savings
  // Crude estimation using JSON string length
  final int largeSize = jsonEncode(largeDataset).length;
  final int smallSize = jsonEncode(smallDataset).length;

  print('Estimated Data Transfer Size (Baseline): ${(largeSize / 1024).toStringAsFixed(2)} KB');
  print('Estimated Data Transfer Size (Optimized): ${(smallSize / 1024).toStringAsFixed(2)} KB');
  final double sizeImprovement = (largeSize - smallSize) / largeSize * 100;
  print('Data Transfer Improvement: ${sizeImprovement.toStringAsFixed(2)}%');
}
