#!/usr/bin/env python3
"""
Upload all Bhagavad Gita verses and translations to Supabase.
Uses REST API - requires verses/verse_translations to allow anon insert
(or RLS disabled). Run SUPABASE_ALLOW_SEED_INSERT.sql first if RLS blocks.
"""
import json
import os
import sys

try:
    import requests
except ImportError:
    print("Installing requests...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "-q"])
    import requests

# Supabase config (from lib/core/config/supabase_config.dart)
SUPABASE_URL = "https://qyikatemonzykqamtvod.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"

HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json",
    "Prefer": "resolution=merge-duplicates",
}


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(script_dir, "gita_full_cleaned.json")

    if not os.path.exists(json_path):
        print(f"Error: {json_path} not found. Run fetch_complete_gita.py first.")
        return 1

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    print(f"Loaded {len(data)} verses from gita_full_cleaned.json")

    # 1. Insert verses (batch by chapter)
    verses_by_chapter = {}
    for item in data:
        ch, v = item["chapter"], item["verse"]
        if ch not in verses_by_chapter:
            verses_by_chapter[ch] = []
        verses_by_chapter[ch].append({
            "id": f"bg_{ch}_{v}",
            "book_id": "bhagavad_gita",
            "chapter_id": f"bg_chapter_{ch}",
            "verse_number": v,
            "verse_number_display": f"{ch}.{v}",
            "order_index": v,
        })

    total_verses = 0
    for ch in sorted(verses_by_chapter.keys()):
        rows = verses_by_chapter[ch]
        url = f"{SUPABASE_URL}/rest/v1/verses"
        r = requests.post(url, headers=HEADERS, json=rows)
        if r.status_code not in (200, 201):
            print(f"Verses chapter {ch} failed: {r.status_code} - {r.text[:200]}")
            return 1
        total_verses += len(rows)
        print(f"  Inserted {len(rows)} verses for chapter {ch}")

    print(f"Total verses inserted: {total_verses}")

    # 2. Insert verse_translations (batch of 100 to avoid payload limits)
    translations = []
    for item in data:
        ch, v = item["chapter"], item["verse"]
        vid = f"bg_{ch}_{v}"
        hindi = item.get("hindi", "")
        english = item.get("english", "")
        translations.append({
            "verse_id": vid,
            "language_code": "hi",
            "language_name": "Hindi",
            "text": hindi,
            "is_primary": False,
            "translation_source": "Swami Tejomayananda",
        })
        translations.append({
            "verse_id": vid,
            "language_code": "en",
            "language_name": "English",
            "text": english,
            "is_primary": True,
            "translation_source": "Swami Tejomayananda",
        })

    batch_size = 100
    total_trans = 0
    for i in range(0, len(translations), batch_size):
        batch = translations[i : i + batch_size]
        url = f"{SUPABASE_URL}/rest/v1/verse_translations"
        r = requests.post(url, headers=HEADERS, json=batch)
        if r.status_code not in (200, 201):
            print(f"Translations batch {i//batch_size + 1} failed: {r.status_code} - {r.text[:300]}")
            return 1
        total_trans += len(batch)
        print(f"  Inserted translations {i+1}-{min(i+batch_size, len(translations))} / {len(translations)}")

    print(f"Total translations inserted: {total_trans}")
    print("Done. All verses and translations uploaded to Supabase.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
