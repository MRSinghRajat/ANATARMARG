import os
import sys
import json
import base64
import time
import uuid
import urllib.request
import ssl
from urllib.error import HTTPError

# Use `.env` file directly if needed, or environment variables
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
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}
GET_HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}"
}

BUCKET_NAME = "sacred-stories"
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sacred_page_images")

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def generate_image(prompt: str, filename: str) -> str:
    """Generate image using OpenAI DALL-E REST API and save to disk."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    filepath = os.path.join(OUTPUT_DIR, filename)

    if os.path.exists(filepath):
        print(f"    [~] Image already exists locally: {filename}")
        return filepath

    print(f"    [*] Generating image with DALL-E 3...")
    url = "https://api.openai.com/v1/images/generations"
    payload = {
        "model": "dall-e-3",
        "prompt": prompt,
        "size": "1024x1024",
        "quality": "standard",
        "n": 1,
        "response_format": "url"
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {OPENAI_API_KEY}"
    }, method='POST')
    
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            data = json.loads(response.read().decode())
            image_url = data['data'][0]['url']
            print(f"    [+] Generated URL from OpenAI: {image_url[:40]}...")
            
            # Download image bytes
            img_req = urllib.request.Request(image_url)
            with urllib.request.urlopen(img_req, context=ctx) as img_resp:
                img_data = img_resp.read()
                
            with open(filepath, "wb") as f:
                f.write(img_data)
            print(f"    [+] Saved locally to {filepath}")
            return filepath
    except HTTPError as e:
        print(f"    [!] Error generating image: {e.code} - {e.read().decode()}")
        return None
    except Exception as e:
        print(f"    [!] Unknown error generating image: {e}")
        return None


def upload_to_storage(filepath: str, storage_path: str) -> str:
    """Upload file to Supabase Storage. Returns the public URL."""
    print(f"    [*] Uploading to storage: {storage_path}...")
    with open(filepath, "rb") as f:
        file_data = f.read()

    upload_headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "image/png",
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


def update_story_pages(story_id: str, pages_json):
    """Update the pages array for a sacred story."""
    req = urllib.request.Request(
        f"{SUPABASE_URL}/rest/v1/sacred_stories?id=eq.{story_id}",
        headers=HEADERS,
        data=json.dumps({"pages": pages_json}).encode('utf-8'),
        method="PATCH"
    )
    try:
        with urllib.request.urlopen(req, context=ctx) as r:
            print(f"  [+] Story DB nicely updated with new pages array!")
            return True
    except HTTPError as e:
        print(f"  [!] Update DB failed: {e.code} - {e.read().decode()}")
        return False


def run_process():
    print("Fetching sacred stories from Supabase...")
    req = urllib.request.Request(f"{SUPABASE_URL}/rest/v1/sacred_stories?select=id,title,slug,pages", headers=GET_HEADERS)
    with urllib.request.urlopen(req, context=ctx) as r:
        stories = json.loads(r.read().decode())
    
    print(f"Found {len(stories)} stories to process.\n")
    
    for story in stories:
        story_id = story['id']
        title = story['title']
        slug = story.get('slug', story_id)
        pages = story.get('pages', [])
        
        if not pages:
            continue
            
        print(f"\n==========================================")
        print(f"Analyzing Story: {title} ({len(pages)} pages)")
        print(f"==========================================")
        
        needs_db_update = False
        
        for idx, page in enumerate(pages):
            print(f"\n  Processing Page {idx+1}/{len(pages)}:")
            
            if not isinstance(page, dict):
                print("    [!] Page is not a dictionary. Skipping malformed data.")
                continue
                
            eng_text = page.get('text_english', '')
            if not eng_text:
                print("    [!] No english text to base the image prompt on. Skipping.")
                continue
                
            # Build the prompt (made more peaceful to prevent OpenAI safety violations)
            prompt = (
                f"A beautiful, peaceful, highly detailed digital painting illustrating the following scene from Indian Mythology: '{eng_text}'. "
                f"Atmosphere is peaceful, spiritual, and calm. Visuals are respectful. Traditional Indian miniature painting aesthetics. "
                f"DO NOT include any violence, weapons, gore, or scary elements. Make it serene and beautiful."
            )
            
            # Generate local image
            filename = f"{slug}_page_{idx}_{uuid.uuid4().hex[:8]}.png"
            local_path = generate_image(prompt, filename)
            
            if local_path:
                # Upload to Supabase
                storage_path = f"pages/{slug}_page_{idx}.png"
                public_url = upload_to_storage(local_path, storage_path)
                
                # Modify Array
                if public_url:
                    page['image_url'] = public_url
                    needs_db_update = True
                    
            # Avoid rate limit
            time.sleep(1)
                
        # Update database array for this story
        if needs_db_update:
            print(f"\n  Updating database for '{title}'...")
            update_story_pages(story_id, pages)


if __name__ == "__main__":
    run_process()
