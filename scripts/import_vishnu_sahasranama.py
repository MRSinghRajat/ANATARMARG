import urllib.request
import json
import ssl
import sys
import uuid
import time

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

SUPABASE_URL = "https://qyikatemonzykqamtvod.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"

HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

def supabase_post(table, data):
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=HEADERS, method='POST')
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            return response.status
    except urllib.error.HTTPError as e:
        if e.code == 409:
            return 409
        print(f"    [!] Error inserting into {table}: {e.code} - {e.read().decode()}")
        return e.code
    except Exception as e:
        print(f"    [!] Unknown error: {e}")
        return 500

book_id = "vishnu_sahasranama"

def run_import():
    print("Setting up Vishnu Sahasranama...")
    
    # 1. Insert Book
    book_payload = {
        "id": book_id,
        "name": "Vishnu Sahasranama",
        "name_sanskrit": "विष्णुसहस्रनाम",
        "description": "Standalone Book - Part of Mahabharata, Anushasana Parva",
        "total_chapters": 5,
        "category": "stotra"
    }
    supabase_post("books", book_payload)
    
    chapters = [
        {"id": "vs_ch1", "number": 1, "title": "Dhyana Shlokas", "subtitle": "Meditation opening"},
        {"id": "vs_ch2", "number": 2, "title": "Purva Pithika", "subtitle": "Context - Yudhishthira's questions"},
        {"id": "vs_ch3", "number": 3, "title": "The 1000 Names", "subtitle": "Names 1-1000"},
        {"id": "vs_ch4", "number": 4, "title": "Uttara Pithika", "subtitle": "Phala Shruti - closing hymn"},
        {"id": "vs_ch5", "number": 5, "title": "Meaning & Benefits", "subtitle": "Editorial explanation"}
    ]
    
    for ch in chapters:
        ch_payload = {
            "id": ch["id"],
            "book_id": book_id,
            "chapter_number": ch["number"],
            "title": ch["title"],
            "subtitle": ch["subtitle"],
            "order_index": ch["number"]
        }
        supabase_post("chapters", ch_payload)

    # We will build out the rest of the parsing based on data.
    # For now, let's insert a couple of verses to verify.
    
    # CH 1
    v_id = "vs_ch1_v1"
    supabase_post("verses", {
        "id": v_id,
        "book_id": book_id,
        "chapter_id": "vs_ch1",
        "verse_number": 1,
        "verse_number_display": "1.1",
        "order_index": 1
    })
    supabase_post("verse_translations", {
        "id": str(uuid.uuid4()),
        "verse_id": v_id,
        "language_code": "sa",
        "language_name": "Sanskrit",
        "text": "यस्य स्मरणमात्रेण जन्मसंसारबन्धनात् ।\nविमुच्यते नमस्तस्मै विष्णवे प्रभविष्णवे ॥",
        "is_primary": True
    })
    supabase_post("verse_translations", {
        "id": str(uuid.uuid4()),
        "verse_id": v_id,
        "language_code": "en",
        "language_name": "English",
        "text": "By the mere remembrance of whom one is freed from the bondage of birth and worldly existence — salutations to that all-pervading Vishnu.",
        "is_primary": False
    })
    print("Basic setup complete. The rest of the 1000 names will be imported next.")

if __name__ == "__main__":
    run_import()
