import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ashrae_playground/core/config/supabase_config.dart';

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
}
