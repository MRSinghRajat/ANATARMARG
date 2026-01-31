// Run with: dart run scripts/generate_gita_sql.dart
// DEPRECATED: Use generate_gita_supabase.py instead for full Supabase SQL generation
// This script only generates verse_translations - the Python script generates both verses and translations
//
// For complete Gita data: python scripts/generate_gita_supabase.py
// Reads from: scripts/gita_full_cleaned.json or scripts/gita_data_full.json

import 'dart:convert';
import 'dart:io';

void main() {
  const jsonData = '''
[
  {"chapter": 1, "verse": 1, "hindi": "धृतराष्ट्र ने कहा -- हे संजय ! धर्मभूमि कुरुक्षेत्र में एकत्र हुए युद्ध के इच्छुक (युयुत्सव:) मेरे और पाण्डु के पुत्रों ने क्या किया?", "english": "The King Dhritarashtra asked: \\"O Sanjaya! What happened on the sacred battlefield of Kurukshetra, when my people gathered against the Pandavas?\\""},
  {"chapter": 1, "verse": 2, "hindi": "संजय ने कहा -- पाण्डव-सैन्य की व्यूह रचना देखकर राजा दुर्योधन ने आचार्य द्रोण के पास जाकर ये वचन कहे।", "english": "Sanjaya replied: \\"The Prince Duryodhana, when he saw the army of the Pandavas paraded, approached his preceptor Guru Drona and spoke as follows:"},
  {"chapter": 1, "verse": 3, "hindi": "हे आचार्य ! आपके बुद्धिमान शिष्य द्रुपदपुत्र (धृष्टद्द्युम्न) द्वारा व्यूहाकार खड़ी की गयी पाण्डु पुत्रों की इस महती सेना को देखिये।", "english": "Revered Father! Behold this mighty host of the Pandavas, paraded by the son of King Drupada, thy wise disciple."}
]
''';

  final data = jsonDecode(jsonData) as List;
  final buffer = StringBuffer();

  for (final item in data) {
    final ch = item['chapter'] as int;
    final v = item['verse'] as int;
    final hindi = (item['hindi'] as String).replaceAll("'", "''");
    final english = (item['english'] as String)
        .replaceAll("'", "''")
        .replaceAll('"', '\\"');
    final verseId = 'bg_${ch}_$v';
    buffer.writeln(
        "INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES");
    buffer.writeln(
        "('$verseId', 'hi', 'Hindi', '$hindi', FALSE, 'Swami Tejomayananda'),");
    buffer.writeln(
        "('$verseId', 'en', 'English', '$english', TRUE, 'Swami Sivananda')");
    buffer.writeln(
        "ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text;");
    buffer.writeln();
  }

  File('SUPABASE_GITA_TRANSLATIONS.sql').writeAsStringSync(buffer.toString());
  print('Generated SUPABASE_GITA_TRANSLATIONS.sql');
}
