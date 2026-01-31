#!/usr/bin/env python3
"""
Generate Supabase SQL files from Gita JSON data.
Reads from gita_full_cleaned.json or gita_data_full.json
Outputs: SUPABASE_GITA_DATA.sql, SUPABASE_GITA_TRANSLATIONS.sql
"""
import json
import os

def escape_sql(s):
    """Escape single quotes for SQL."""
    if s is None:
        return ""
    return str(s).replace("'", "''")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # Try gita_full_cleaned.json first, then gita_data_full.json
    json_paths = [
        os.path.join(script_dir, "gita_full_cleaned.json"),
        os.path.join(script_dir, "gita_data_full.json"),
    ]
    
    data = None
    for path in json_paths:
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            print(f"Loaded {len(data)} verses from {os.path.basename(path)}")
            break
    
    if not data:
        print("Error: No JSON file found. Create gita_full_cleaned.json or gita_data_full.json")
        return 1
    
    # Generate verses SQL - group by chapter for cleaner output
    verses_by_chapter = {}
    for item in data:
        ch = item["chapter"]
        v = item["verse"]
        if ch not in verses_by_chapter:
            verses_by_chapter[ch] = []
        verses_by_chapter[ch].append((ch, v))
    
    verses_sql = []
    verses_sql.append("-- Bhagavad Gita Verse Data - All 18 Chapters")
    verses_sql.append("-- Run after SUPABASE_BOOKS_SCHEMA.sql")
    verses_sql.append("-- Generated from gita_full_cleaned.json")
    verses_sql.append("")
    
    for ch in sorted(verses_by_chapter.keys()):
        verses = verses_by_chapter[ch]
        verses_sql.append(f"-- ============================================")
        verses_sql.append(f"-- VERSES: Chapter {ch} (verses 1-{len(verses)})")
        verses_sql.append(f"-- ============================================")
        verses_sql.append("INSERT INTO verses (id, book_id, chapter_id, verse_number, verse_number_display, order_index) VALUES")
        rows = []
        for ch_num, v_num in verses:
            vid = f"bg_{ch_num}_{v_num}"
            vdisp = f"{ch_num}.{v_num}"
            rows.append(f"('{vid}', 'bhagavad_gita', 'bg_chapter_{ch_num}', {v_num}, '{vdisp}', {v_num})")
        verses_sql.append(",\n".join(rows))
        verses_sql.append("ON CONFLICT (id) DO NOTHING;")
        verses_sql.append("")
    
    verses_file = os.path.join(project_root, "SUPABASE_GITA_DATA.sql")
    with open(verses_file, "w", encoding="utf-8") as f:
        f.write("\n".join(verses_sql))
    print(f"Generated {verses_file}")
    
    # Generate translations SQL
    trans_sql = []
    trans_sql.append("-- Bhagavad Gita Verse Translations - All 18 Chapters")
    trans_sql.append("-- Run after SUPABASE_GITA_DATA.sql")
    trans_sql.append("-- Generated from gita_full_cleaned.json")
    trans_sql.append("")
    
    # Batch translations by verse for cleaner SQL (2 rows per verse: Hindi + English)
    for item in data:
        ch = item["chapter"]
        v = item["verse"]
        hindi = escape_sql(item.get("hindi", ""))
        english = escape_sql(item.get("english", ""))
        vid = f"bg_{ch}_{v}"
        
        trans_sql.append("INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES")
        trans_sql.append(f"  ('{vid}', 'hi', 'Hindi', '{hindi}', FALSE, 'Swami Tejomayananda'),")
        trans_sql.append(f"  ('{vid}', 'en', 'English', '{english}', TRUE, 'Swami Tejomayananda')")
        trans_sql.append("ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;")
        trans_sql.append("")
    
    trans_file = os.path.join(project_root, "SUPABASE_GITA_TRANSLATIONS.sql")
    with open(trans_file, "w", encoding="utf-8") as f:
        f.write("\n".join(trans_sql))
    print(f"Generated {trans_file}")
    
    return 0

if __name__ == "__main__":
    exit(main())
