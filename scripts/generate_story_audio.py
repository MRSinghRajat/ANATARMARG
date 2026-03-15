import os, sys, json, time, urllib.request, ssl
from urllib.error import HTTPError

def get_env_var(key):
    val = os.environ.get(key)
    if val: return val
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '.env')
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                if line.startswith(f"{key}="):
                    return line.strip().split('=', 1)[1].strip()
    return ""

SUPABASE_URL = get_env_var("SUPABASE_URL") or "https://qyikatemonzykqamtvod.supabase.co"
SUPABASE_ANON_KEY = get_env_var("SUPABASE_ANON_KEY")
OPENAI_API_KEY = get_env_var("GPT_API_KEY") or get_env_var("OPENAI_API_KEY")

if not OPENAI_API_KEY:
    print("Error: Could not find GPT_API_KEY or OPENAI_API_KEY in environment or .env file.")
    sys.exit(1)

HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json"
}
GET_HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}"
}

BUCKET_NAME = "sacred-stories"
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sacred_page_audio")

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def generate_audio(text: str, filename: str) -> str:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    filepath = os.path.join(OUTPUT_DIR, filename)

    if os.path.exists(filepath):
        print(f"    [~] Audio already exists locally: {filename}")
        return filepath

    print(f"    [*] Generating audio with OpenAI TTS...")
    url = "https://api.openai.com/v1/audio/speech"
    # 'onyx' is a deep, resonant voice, good for narration.
    payload = {
        "model": "tts-1",
        "input": text,
        "voice": "onyx" 
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {OPENAI_API_KEY}"
    }, method='POST')
    
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            audio_data = response.read()
            with open(filepath, "wb") as f:
                f.write(audio_data)
            print(f"    [+] Saved locally to {filepath}")
            return filepath
    except HTTPError as e:
        print(f"    [!] Error generating audio: {e.code} - {e.read().decode()}")
        return None
    except Exception as e:
        print(f"    [!] Unknown error generating audio: {e}")
        return None

def upload_to_storage(filepath: str, storage_path: str) -> str:
    print(f"    [*] Uploading to storage: {storage_path}...")
    with open(filepath, "rb") as f:
        file_data = f.read()

    upload_headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "audio/mpeg",
        "x-upsert": "true",
    }

    req = urllib.request.Request(
        f"{SUPABASE_URL}/storage/v1/object/{BUCKET_NAME}/{storage_path}",
        headers=upload_headers,
        data=file_data,
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(req, context=ctx) as r:
            public_url = f"{SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/{storage_path}"
            print(f"    [+] Upload successful! URL: {public_url}")
            return public_url
    except HTTPError as e:
        print(f"    [!] Upload failed: {e.code} - {e.read().decode()}")
        return ""

def main():
    # We will pick the short 4-page story we know
    target_slug = "krishna-sudama-friendship"
    
    print(f"Fetching story '{target_slug}' from Supabase...")
    req = urllib.request.Request(f"{SUPABASE_URL}/rest/v1/sacred_stories?slug=eq.{target_slug}&select=id,title,pages", headers=GET_HEADERS)
    with urllib.request.urlopen(req, context=ctx) as r:
        stories = json.loads(r.read().decode())
        
    if not stories:
        print("Story not found!")
        return
        
    story = stories[0]
    story_id = story['id']
    title = story['title']
    
    print(f"Fetching pages for '{title}'...")
    req_pages = urllib.request.Request(f"{SUPABASE_URL}/rest/v1/story_pages?story_id=eq.{story_id}&order=page_number", headers=GET_HEADERS)
    with urllib.request.urlopen(req_pages, context=ctx) as r:
        pages = json.loads(r.read().decode())
        
    print(f"Found {len(pages)} pages.")
    
    for page in pages:
        page_num = page['page_number']
        hindi_text = page.get('text_hindi', '')
        
        if not hindi_text:
            print(f"  [!] No hindi text for page {page_num}. Skipping.")
            continue
            
        print(f"\n==========================================")
        print(f"Generating Audio for Page {page_num}")
        print(f"Text: {hindi_text[:50]}...")
        
        filename = f"{target_slug}_page_{page_num}_hi.mp3"
        local_path = generate_audio(hindi_text, filename)
        
        if local_path:
            storage_path = f"audio/{filename}"
            public_url = upload_to_storage(local_path, storage_path)
            
            if public_url:
                print(f"    [*] Updating database for page {page_num}...")
                
                patch_req = urllib.request.Request(
                    f"{SUPABASE_URL}/rest/v1/story_pages?id=eq.{page['id']}",
                    data=json.dumps({"audio_url": public_url}).encode('utf-8'),
                    headers=HEADERS,
                    method='PATCH'
                )
                try:
                    with urllib.request.urlopen(patch_req, context=ctx) as pr:
                        print("    [+] DB Updated!")
                except HTTPError as e:
                    print(f"    [!] DB Update failed: {e.read().decode()}")
                    
        time.sleep(1)

if __name__ == "__main__":
    main()
