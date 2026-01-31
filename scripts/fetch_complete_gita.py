#!/usr/bin/env python3
"""
Fetch complete Bhagavad Gita (700 verses) from Vedic Scriptures API.
Saves to gita_full_cleaned.json in format: [{"chapter":1,"verse":1,"hindi":"...","english":"..."}, ...]
"""
import json
import os
import re
import time
import urllib.request

# Verse counts per chapter (Bhagavad Gita standard)
VERSE_COUNTS = {
    1: 47, 2: 72, 3: 43, 4: 42, 5: 29, 6: 47, 7: 30, 8: 28,
    9: 34, 10: 42, 11: 55, 12: 20, 13: 35, 14: 27, 15: 20,
    16: 24, 17: 28, 18: 78
}

API_BASE = "https://vedicscriptures.github.io/slok"

def strip_verse_prefix(text):
    """Remove verse number prefix like ।।1.1।। or 1.1 from text."""
    if not text:
        return ""
    # Remove ।।X.Y।। pattern (Devanagari)
    text = re.sub(r'^।।\d+\.\d+।।\s*', '', text)
    # Remove 1.1 or 1.1. style prefix
    text = re.sub(r'^\d+\.\d+\.?\s*', '', text)
    return text.strip()

def fetch_verse(chapter, verse):
    """Fetch a single verse from the API."""
    url = f"{API_BASE}/{chapter}/{verse}"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=15) as response:
            data = json.loads(response.read().decode())
            return data
    except Exception as e:
        print(f"Error fetching {chapter}.{verse}: {e}")
        return None

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "gita_full_cleaned.json")
    
    result = []
    total = sum(VERSE_COUNTS.values())
    count = 0
    
    print(f"Fetching {total} verses from Vedic Scriptures API...")
    
    for chapter in range(1, 19):
        verses_in_ch = VERSE_COUNTS[chapter]
        for verse in range(1, verses_in_ch + 1):
            count += 1
            data = fetch_verse(chapter, verse)
            if data:
                # Use Swami Tejomayananda for Hindi (tej.ht)
                hindi = ""
                if "tej" in data and "ht" in data["tej"]:
                    hindi = strip_verse_prefix(data["tej"]["ht"])
                
                # Use Purohit Swami for English (purohit.et) - matches user's format
                english = ""
                if "purohit" in data and "et" in data["purohit"]:
                    english = strip_verse_prefix(data["purohit"]["et"])
                elif "siva" in data and "et" in data["siva"]:
                    english = strip_verse_prefix(data["siva"]["et"])
                
                result.append({
                    "chapter": chapter,
                    "verse": verse,
                    "hindi": hindi,
                    "english": english
                })
                if count % 50 == 0:
                    print(f"  Fetched {count}/{total} verses...")
            else:
                print(f"  Skipped {chapter}.{verse}")
            
            # Be nice to the API - small delay
            time.sleep(0.1)
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    print(f"Saved {len(result)} verses to {output_path}")
    return 0 if len(result) == total else 1

if __name__ == "__main__":
    exit(main())
