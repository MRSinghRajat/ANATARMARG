#!/usr/bin/env python3
"""
Fetch complete Bhagavad Gita (700 verses) from Vedic Scriptures API.
Saves to gita_full_cleaned.json in format: [{"chapter":1,"verse":1,"hindi":"...","english":"..."}, ...]
"""
import json
import os
import re
import asyncio
import aiohttp

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

async def fetch_verse(session, chapter, verse, semaphore):
    """Fetch a single verse from the API with concurrency limit."""
    url = f"{API_BASE}/{chapter}/{verse}"
    async with semaphore:
        try:
            async with session.get(url, headers={'User-Agent': 'Mozilla/5.0'}) as response:
                if response.status == 200:
                    data = await response.json()
                    return data, chapter, verse
                else:
                    print(f"Error fetching {chapter}.{verse}: Status {response.status}")
                    return None, chapter, verse
        except Exception as e:
            print(f"Error fetching {chapter}.{verse}: {e}")
            return None, chapter, verse

async def process_verse(data, chapter, verse):
    """Process the fetched verse data into the desired format."""
    if not data:
        return None

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

    return {
        "chapter": chapter,
        "verse": verse,
        "hindi": hindi,
        "english": english
    }

async def main_async():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "gita_full_cleaned.json")
    
    total = sum(VERSE_COUNTS.values())
    print(f"Fetching {total} verses from Vedic Scriptures API...")
    
    # Limit concurrent requests to avoid hitting rate limits or errors
    # 20 is a safe number, much faster than 1 but not aggressive
    semaphore = asyncio.Semaphore(20)

    tasks = []
    async with aiohttp.ClientSession() as session:
        for chapter in range(1, 19):
            verses_in_ch = VERSE_COUNTS[chapter]
            for verse in range(1, verses_in_ch + 1):
                tasks.append(fetch_verse(session, chapter, verse, semaphore))

        # Gather all responses
        responses = await asyncio.gather(*tasks)

    # Process results
    results = []
    count = 0

    for data, chapter, verse in responses:
        processed = await process_verse(data, chapter, verse)
        if processed:
            results.append(processed)
            count += 1
            if count % 50 == 0:
                print(f"  Processed {count}/{total} verses...")
        else:
            print(f"  Skipped {chapter}.{verse}")
            
    # Sort results by chapter and verse as they might be out of order
    results.sort(key=lambda x: (x["chapter"], x["verse"]))
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"Saved {len(results)} verses to {output_path}")
    return 0 if len(results) == total else 1

def main():
    return asyncio.run(main_async())

if __name__ == "__main__":
    exit(main())
