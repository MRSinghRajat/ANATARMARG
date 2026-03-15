import urllib.request
import urllib.parse
import json
import ssl
import uuid
import time
import os

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


# Names data array containing the 1000 names (we'll start with a representative subset to build the SQL)
NAMES_DATA = [
    {"shloka_num": 1, "names": [
        {"name": "Vishwam", "transliteration": "Viśhvam", "meaning": "The Universe itself; He who is the entire cosmos"},
        {"name": "Vishnuh", "transliteration": "Viṣṇuḥ", "meaning": "The all-pervading one; from the root 'vish' (to pervade)"},
        {"name": "Vashatkaarah", "transliteration": "Vaṣhaṭkāraḥ", "meaning": "He who controls and directs all sacrificial offerings"},
        {"name": "Bhoota-bhavya-bhavat-prabhuh", "transliteration": "Bhūta-bhavya-bhavat-prabhuḥ", "meaning": "Lord of past, present, and future"},
        {"name": "Bhootakrit", "transliteration": "Bhūtakṛt", "meaning": "The creator of all beings"},
        {"name": "Bhoota-bhrit", "transliteration": "Bhūtabhṛit", "meaning": "The sustainer and nourisher of all beings"},
        {"name": "Bhaavah", "transliteration": "Bhāvaḥ", "meaning": "Pure existence; He who exists by His own nature"},
        {"name": "Bhootatma", "transliteration": "Bhūtātmā", "meaning": "The inner soul/spirit of all beings"}
    ]},
    {"shloka_num": 2, "names": [
        {"name": "Bhootabhavanah", "transliteration": "Bhūtabhāvanaḥ", "meaning": "He who causes the growth and welfare of all beings"},
        {"name": "Pootatma", "transliteration": "Pūtātmā", "meaning": "The pure-souled one; of immaculate nature"},
        {"name": "Paramatma", "transliteration": "Paramātmā", "meaning": "The Supreme Soul; the highest self"},
        {"name": "Muktanam Parama Gatih", "transliteration": "Muktānāṁ paramā gatiḥ", "meaning": "The ultimate refuge and goal of all liberated souls"},
        {"name": "Avyayah", "transliteration": "Avyayaḥ", "meaning": "The inexhaustible, immutable one"},
        {"name": "Purushah", "transliteration": "Puruṣhaḥ", "meaning": "He who dwells in the city of the body"},
        {"name": "Sakshi", "transliteration": "Sākṣhī", "meaning": "The eternal witness of all actions"},
        {"name": "Kshetrajnah", "transliteration": "Kṣhetrajñaḥ", "meaning": "The knower of the field (the body and the cosmos)"},
        {"name": "Akshara", "transliteration": "Akṣharaḥ", "meaning": "The imperishable, indestructible one"}
    ]}
    # ... In a full run, we would append all 1000 items ...
]

def insert_verse(book_id, chapter_id, verse_num, display_num, order_index):
    v_id = f"{book_id}_{chapter_id}_v{verse_num}"
    
    verse_payload = {
        "id": v_id,
        "book_id": book_id,
        "chapter_id": chapter_id,
        "verse_number": verse_num,
        "verse_number_display": display_num,
        "order_index": order_index
    }
    supabase_post("verses", verse_payload)
    return v_id

def insert_translation(verse_id, lang_code, lang_name, text, is_primary):
    supabase_post("verse_translations", {
        "id": str(uuid.uuid4()),
        "verse_id": verse_id,
        "language_code": lang_code,
        "language_name": lang_name,
        "text": text,
        "is_primary": is_primary
    })

def run_import():
    book_id = "vishnu_sahasranama"
    chapter_id = "vs_ch3"  # Chapter 3: The 1000 Names
    
    overall_name_counter = 1
    
    print("Beginning import of 1000 Names into the Database...")
    
    for shloka_group in NAMES_DATA:
        s_num = shloka_group["shloka_num"]
        
        # We will insert the overarching Shloka as a Verse
        v_id_shloka = insert_verse(book_id, chapter_id, overall_name_counter*1000 + s_num, f"{s_num}", s_num * 100)
        print(f"-> Inserted Shloka {s_num}")
        
        shloka_names = shloka_group["names"]
        name_sub_idx = 1
        
        for n in shloka_names:
            print(f"  -> Processing Name #{overall_name_counter}: {n['name']}")
            
            # Since user wants each Name to be individually tappable and searchable, we insert each Name 
            # as a sub-verse (or distinct verse) mapped sequentially right after the Shloka.
            v_id_name = insert_verse(
                book_id=book_id, 
                chapter_id=chapter_id, 
                verse_num=overall_name_counter, 
                display_num=f"{s_num}.{name_sub_idx}", # Display like 1.1, 1.2 meaning Shloka 1, Name 1
                order_index=(s_num * 100) + name_sub_idx
            )
            
            # 1. English Translation / Meaning
            en_meaning = n['meaning']
            insert_translation(v_id_name, "en", "English", en_meaning, False)
            
            # 2. Hindi Translation / Meaning
            hi_meaning = translate_en_to_hi(en_meaning)
            insert_translation(v_id_name, "hi", "Hindi", hi_meaning, True)
            
            # 3. Commentary (just adding a placeholder for names to follow structure)
            commentary_en = f"This is the {overall_name_counter} name of Lord Vishnu out of the Sahasranama, symbolizing {n['name']}."
            insert_translation(v_id_name, "en-commentary", "English Commentary", commentary_en, False)
            
            commentary_hi = translate_en_to_hi(commentary_en)
            insert_translation(v_id_name, "hi-commentary", "Hindi Commentary", commentary_hi, False)
            
            # Add transliteration separately so UI can display the Roman name easily
            insert_translation(v_id_name, "en-translit", "Transliteration", n['transliteration'], False)
            
            name_sub_idx += 1
            overall_name_counter += 1
            
            # gentle throttle 
            time.sleep(0.5)

if __name__ == "__main__":
    run_import()
