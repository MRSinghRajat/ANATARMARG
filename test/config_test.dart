import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:antarmarg/core/config/supabase_config.dart';

void main() {
  test('SupabaseConfig loads values from dotenv', () async {
    // Load mock values directly into dotenv
    dotenv.testLoad(fileInput: '''
SUPABASE_URL=http://mock.url
SUPABASE_ANON_KEY=mock_key
''');

    expect(SupabaseConfig.supabaseUrl, 'http://mock.url');
    expect(SupabaseConfig.supabaseAnonKey, 'mock_key');
  });

  test('SupabaseConfig handles missing values', () {
    // Clear dotenv
    dotenv.testLoad(fileInput: '');

    expect(SupabaseConfig.supabaseUrl, '');
    expect(SupabaseConfig.supabaseAnonKey, '');
  });

  test('release Flutter asset is .env.app (not full .env)', () {
    // Contract for TestFlight: pubspec ships allowlisted `.env.app` only.
    // lib/main.dart must load `.env.app` first so Supabase initializes in release.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('- .env.app'), isTrue);
    // Avoid regressing to bundling the full local `.env` secret-bearing file.
    final assetsMatch = RegExp(r'assets:\s*\n((?:[ \t]+- .*\n)+)', multiLine: true)
        .firstMatch(pubspec);
    expect(assetsMatch, isNotNull);
    final assetsBlock = assetsMatch!.group(1)!;
    expect(assetsBlock.contains('.env.app'), isTrue);
    expect(
      RegExp(r'(?m)^[ \t]+- \.env\s*$').hasMatch(assetsBlock),
      isFalse,
      reason: 'Do not ship root .env as a Flutter asset',
    );
  });
}
