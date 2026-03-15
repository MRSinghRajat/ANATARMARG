import urllib.request
import urllib.parse
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
GET_HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}"
}

def translate_en_to_hi(text):
    if not text or len(text.strip()) == 0:
        return ""
    url = f"https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=hi&dt=t&q={urllib.parse.quote(text)}"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, context=ctx) as response:
            res = json.loads(response.read().decode('utf-8'))
            return "".join([x[0] for x in res[0] if x[0]])
    except Exception as e:
        print(f"    [!] Translation error: {e}")
        return text

def supabase_get(endpoint):
    url = f"{SUPABASE_URL}/rest/v1/{endpoint}"
    req = urllib.request.Request(url, headers=GET_HEADERS)
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        print(f"    [!] GET Error {endpoint}: {e}")
        return []

def supabase_post(table, data):
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=HEADERS, method='POST')
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            return response.status
    except urllib.error.HTTPError as e:
        if e.code == 409:
            return 409 # Conflict, already exists
        print(f"    [!] Error inserting into {table}: {e.code} - {e.read().decode()}")
        return e.code
    except Exception as e:
        print(f"    [!] Unknown error: {e}")
        return 500

def run_import():
    book_id = "ramayana"
    chapter_id = "ram_kanda_1" # Bala Kanda
    print(f"Starting to generate Commentary for {book_id} - {chapter_id} based on existing English translations...")
    
    # Fetch all verses for Ramayana Kanda 1
    verses = supabase_get(f"verses?select=id,verse_number_display&chapter_id=eq.{chapter_id}&order=verse_number.asc")
    if not verses:
        print("No verses found for Ramayana Bala Kanda! Check your chapter_id.")
        return
        
    print(f"Found {len(verses)} verses. Processing...")
    
    for v in verses:
        v_id = v['id']
        display_num = v.get('verse_number_display', '')
        
        # Check existing translations for this verse
        trans = supabase_get(f"verse_translations?select=language_code,text&verse_id=eq.{v_id}")
        lang_map = {t['language_code']: t['text'] for t in trans if 'language_code' in t}
        
        # Check if commentary already exists
        if "en-commentary" in lang_map and "hi-commentary" in lang_map:
            continue
            
        print(f"Processing Bala Kanda Verse {display_num}...")
        
        en_text = lang_map.get("en", "")
        if not en_text:
            print(f"  [!] No English base translation found. Skipping commentary generation.")
            continue
            
        # Build an explanatory commentary string for Ramayana
        commentary_en = (
            f"Commentary on Verse {display_num}: "
            f"This profound verse from the Bala Kanda conveys: '{en_text}'. "
            f"It establishes the glory and foundational events of Lord Rama's divine advent and teachings."
        )
        
        # Add English Commentary if missing
        if "en-commentary" not in lang_map:
            print(f"      + English Commentary")
            supabase_post("verse_translations", {
                "id": str(uuid.uuid4()),
                "verse_id": v_id,
                "language_code": "en-commentary",
                "language_name": "English Commentary",
                "text": commentary_en,
                "is_primary": False
            })
            
        # Add Hindi Commentary if missing
        if "hi-commentary" not in lang_map:
            print(f"      + Hindi Commentary")
            commentary_hi = translate_en_to_hi(commentary_en)
            supabase_post("verse_translations", {
                "id": str(uuid.uuid4()),
                "verse_id": v_id,
                "language_code": "hi-commentary",
                "language_name": "Hindi Commentary",
                "text": commentary_hi,
                "is_primary": False
            })
            time.sleep(0.5) # throttle 

print("Done")
if __name__ == "__main__":
    run_import()
