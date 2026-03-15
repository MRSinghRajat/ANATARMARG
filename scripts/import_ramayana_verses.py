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

DATA_URL = "https://raw.githubusercontent.com/Ashutosh-Vijay/Valmiki_Ramayan_Dataset/main/data/Valmiki_Ramayan_Shlokas.json"

kanda_map = {
    "Bala Kanda": "ram_kanda_1",
    "Ayodhya Kanda": "ram_kanda_2",
    "Aranya Kanda": "ram_kanda_3",
    "Kishkindha Kanda": "ram_kanda_4",
    "Sundara Kanda": "ram_kanda_5",
    "Yuddha Kanda": "ram_kanda_6",
    "Uttara Kanda": "ram_kanda_7"
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
    print("Downloading Ramayana JSON Dataset...")
    req = urllib.request.Request(DATA_URL)
    with urllib.request.urlopen(req, context=ctx) as response:
        data = json.loads(response.read().decode())
    print(f"Loaded {len(data)} shlokas from dataset.")
    
    # Pre-fetch existing verses and translations to minimize API calls
    existing_verses = set()
    print("Fetching existing verses...")
    verses_data = supabase_get("verses?select=id&book_id=eq.ramayana")
    for v in verses_data:
        existing_verses.add(v['id'])
        
    print("Fetching existing verse translations...")
    # Fetch translations in batches if there are many, or just fetch all
    existing_translations = {} # format: { verse_id: set([language_code]) }
    try:
        # Since verse_translations has no book_id directly we fetch by joined query, or fetch all.
        # Alternatively, for safely doing this across up to thousands of verses, we can fetch
        # translations chapter by chapter later, but checking verse by verse is also okay if we cache.
        pass
    except Exception as e:
        print(str(e))
    
    # We will fetch translations per chapter to avoid hitting limits
    chapter_translation_cache = {}

    order_idx = 2000
    
    for shloka in data:
        kname = shloka.get("kanda")
        if kname not in kanda_map:
            continue
            
        sarga = shloka.get("sarga")
        s_num = shloka.get("shloka")
        
        chap_id = kanda_map[kname]
        v_id = f"{chap_id}_{sarga}_{s_num}"
        display_num = f"{sarga}.{s_num}"
        
        translation_eng = shloka.get("translation") or ""
        explanation_eng = shloka.get("explanation") or ""
        comments_eng = shloka.get("comments") or ""
        commentary_eng = (explanation_eng + "\n" + comments_eng).strip()
        
        if not translation_eng and not commentary_eng:
            continue
            
        print(f"Processing {kname} {display_num}...")
        
        # 1. Insert Verse Record itself if not exists
        if v_id not in existing_verses:
            verse_payload = {
                "id": v_id,
                "book_id": "ramayana",
                "chapter_id": chap_id,
                "verse_number": s_num,
                "verse_number_display": display_num,
                "order_index": order_idx
            }
            supabase_post("verses", verse_payload)
            existing_verses.add(v_id)
            
        # 2. Check existing translations for this chapter if not cached
        if chap_id not in chapter_translation_cache:
            # Fetch all verses for this chapter
            chap_verses = supabase_get(f"verses?select=id&chapter_id=eq.{chap_id}")
            chap_verse_ids = [v['id'] for v in chap_verses]
            chapter_translation_cache[chap_id] = {}
            if chap_verse_ids:
                # Fetch translations by chunks of 50 to avoid too long URI
                for i in range(0, len(chap_verse_ids), 50):
                    chunk = chap_verse_ids[i:i+50]
                    chunk_str = ",".join(chunk)
                    trans_data = supabase_get(f"verse_translations?select=verse_id,language_code&verse_id=in.({chunk_str})")
                    for t in trans_data:
                        vid = t['verse_id']
                        if vid not in chapter_translation_cache[chap_id]:
                            chapter_translation_cache[chap_id][vid] = set()
                        chapter_translation_cache[chap_id][vid].add(t['language_code'])
        
        existing_langs = chapter_translation_cache[chap_id].get(v_id, set())

        # 3. Insert Missing Languages Only
        
        # English translation
        if "en" not in existing_langs and translation_eng:
            print(f"      + English Translation")
            supabase_post("verse_translations", {
                "id": str(uuid.uuid4()),
                "verse_id": v_id,
                "language_code": "en",
                "language_name": "English",
                "text": translation_eng,
                "is_primary": False
            })
            existing_langs.add("en")
            
        # Hindi translation
        if "hi" not in existing_langs and translation_eng:
            print(f"      + Hindi Translation")
            translation_hi = translate_en_to_hi(translation_eng)
            supabase_post("verse_translations", {
                "id": str(uuid.uuid4()),
                "verse_id": v_id,
                "language_code": "hi",
                "language_name": "Hindi",
                "text": translation_hi,
                "is_primary": True
            })
            time.sleep(0.5) # Google Translate throttling
            existing_langs.add("hi")
            
        # English Commentary
        if "en-commentary" not in existing_langs and commentary_eng:
            print(f"      + English Commentary")
            supabase_post("verse_translations", {
                "id": str(uuid.uuid4()),
                "verse_id": v_id,
                "language_code": "en-commentary",
                "language_name": "English Commentary",
                "text": commentary_eng,
                "is_primary": False
            })
            existing_langs.add("en-commentary")
            
        # Hindi Commentary
        if "hi-commentary" not in existing_langs and commentary_eng:
            print(f"      + Hindi Commentary")
            commentary_hi = translate_en_to_hi(commentary_eng)
            supabase_post("verse_translations", {
                "id": str(uuid.uuid4()),
                "verse_id": v_id,
                "language_code": "hi-commentary",
                "language_name": "Hindi Commentary",
                "text": commentary_hi,
                "is_primary": False
            })
            time.sleep(0.5) # Google Translate throttling
            existing_langs.add("hi-commentary")
            
        chapter_translation_cache[chap_id][v_id] = existing_langs
        order_idx += 1

if __name__ == "__main__":
    run_import()
