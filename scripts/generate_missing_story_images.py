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

HEADERS = {"apikey": SUPABASE_ANON_KEY, "Authorization": f"Bearer {SUPABASE_ANON_KEY}", "Content-Type": "application/json", "Prefer": "return=minimal"}
GET_HEADERS = {"apikey": SUPABASE_ANON_KEY, "Authorization": f"Bearer {SUPABASE_ANON_KEY}"}

BUCKET_NAME = "sacred-stories"
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sacred_page_images")

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def generate_image(prompt: str, filename: str) -> str:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    filepath = os.path.join(OUTPUT_DIR, filename)

    if os.path.exists(filepath):
        print(f"    [~] Image already exists locally: {filename}")
        return filepath

    print(f"    [*] Generating image with DALL-E 3...")
    url = "https://api.openai.com/v1/images/generations"
    payload = {"model": "dall-e-3", "prompt": prompt, "size": "1024x1024", "quality": "standard", "n": 1, "response_format": "url"}
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={"Content-Type": "application/json", "Authorization": f"Bearer {OPENAI_API_KEY}"}, method='POST')
    
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            data = json.loads(response.read().decode())
            image_url = data['data'][0]['url']
            
            img_req = urllib.request.Request(image_url)
            with urllib.request.urlopen(img_req, context=ctx) as img_resp:
                img_data = img_resp.read()
                
            with open(filepath, "wb") as f:
                f.write(img_data)
            return filepath
    except HTTPError as e:
        status = e.code
        body = e.read().decode()
        print(f"    [!] Error generating image: {status} - {body}")
        if status == 429:
            print("    [!] Rate limited! Waiting 20 seconds...")
            time.sleep(20)
            return generate_image(prompt, filename) # retry
        return None
    except Exception as e:
        print(f"    [!] Unknown error generating image: {e}")
        return None

def upload_to_storage(filepath: str, storage_path: str) -> str:
    print(f"    [*] Uploading to storage: {storage_path}...")
    with open(filepath, "rb") as f:
        file_data = f.read()

    upload_headers = {"apikey": SUPABASE_ANON_KEY, "Authorization": f"Bearer {SUPABASE_ANON_KEY}", "Content-Type": "image/png", "x-upsert": "true"}
    req = urllib.request.Request(f"{SUPABASE_URL}/storage/v1/object/{BUCKET_NAME}/{storage_path}", headers=upload_headers, data=file_data, method="POST")
    try:
        with urllib.request.urlopen(req, context=ctx) as r:
            return f"{SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/{storage_path}"
    except HTTPError as e:
        print(f"    [!] Upload failed: {e.code} - {e.read().decode()}")
        return ""

def main():
    print("Fetching story pages from Supabase...")
    req = urllib.request.Request(f"{SUPABASE_URL}/rest/v1/story_pages?select=*", headers=GET_HEADERS)
    with urllib.request.urlopen(req, context=ctx) as r:
        pages = json.loads(r.read().decode())
        
    req_stories = urllib.request.Request(f"{SUPABASE_URL}/rest/v1/sacred_stories?select=id,slug,title,pages", headers=GET_HEADERS)
    with urllib.request.urlopen(req_stories, context=ctx) as r:
        stories = json.loads(r.read().decode())
        
    story_map = {s['id']: s for s in stories}
    pages_to_process = [p for p in pages if not p.get('image_url') and p.get('text_english')]
    
    if not pages_to_process:
        print("No missing images found (or pages lacked descriptions).")
        return
        
    print(f"Found {len(pages_to_process)} pages missing images.")
    
    # Check what's already in our SQL file if it exists, so we don't start from 0 if interrupted
    sql_file_path = 'scripts/fix_missing_images.sql'
    existing_sql = ""
    if os.path.exists(sql_file_path):
        with open(sql_file_path, 'r') as f:
            existing_sql = f.read()
            
    with open(sql_file_path, 'a') as f:
        count = 0
        for page in pages_to_process:
            page_id_str = f"id = '{page['id']}'"
            if page_id_str in existing_sql:
                print(f"Skipping page {page['story_id']} : {page['page_number']} (already in SQL file)")
                continue
                
            story_id = page['story_id']
            story = story_map.get(story_id)
            if not story: continue
                
            slug = story.get('slug', story_id)
            page_num = page['page_number']
            eng_text = page['text_english']
            
            print(f"\n==========================================")
            print(f"[{count+1}/{len(pages_to_process)}] Generating for: {slug} | Page {page_num}")
                
            prompt = (
                f"A beautiful, peaceful, highly detailed digital painting illustrating the following scene from Indian Mythology: '{eng_text}'. "
                f"Atmosphere is peaceful, spiritual, and calm. Visuals are respectful. Traditional Indian miniature painting aesthetics. "
                f"DO NOT include any violence, weapons, gore, or scary elements. Make it serene and beautiful."
            )
            
            # Using clean filename without random hex, as requested
            filename = f"{slug}_page_{page_num}.png"
            local_path = generate_image(prompt, filename)
            
            if local_path:
                storage_path = f"pages/{filename}"
                public_url = upload_to_storage(local_path, storage_path)
                
                if public_url:
                    stmt1 = f"UPDATE story_pages SET image_url = '{public_url}' WHERE id = '{page['id']}';\n"
                    # We will only append the story_pages updates for simplicity, 
                    # as the app prioritizes story_pages over sacred_stories anyway.
                    f.write(stmt1)
                    f.flush()
                    print(f"    [+] Successfully added to SQL: {filename}")
                    count += 1
                    
            time.sleep(2)
        
    print(f"\nDone! Please run the statements inside {sql_file_path} in your Supabase SQL Editor.")
        
if __name__ == "__main__":
    main()
