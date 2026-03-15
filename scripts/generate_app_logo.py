import os
import sys
import json
import urllib.request
import ssl
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

OPENAI_API_KEY = get_env_var("GPT_API_KEY") or get_env_var("OPENAI_API_KEY")

if not OPENAI_API_KEY:
    print("Error: Could not find GPT_API_KEY or OPENAI_API_KEY in environment or .env file.")
    sys.exit(1)

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "app_logo_concepts")

def generate_logo(prompt: str, filename: str):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    filepath = os.path.join(OUTPUT_DIR, filename)

    print(f"[*] Generating App Logo with DALL-E 3...")
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
            print(f"[+] Download URL obtained from OpenAI.")
            
            img_req = urllib.request.Request(image_url)
            with urllib.request.urlopen(img_req, context=ctx) as img_resp:
                img_data = img_resp.read()
                
            with open(filepath, "wb") as f:
                f.write(img_data)
            print(f"[+] Great Success! Logo saved locally to {filepath}")
            return filepath
    except HTTPError as e:
        print(f"[!] Error generating image: {e.code} - {e.read().decode()}")
        return None
    except Exception as e:
        print(f"[!] Unknown error generating image: {e}")
        return None

if __name__ == "__main__":
    prompt = (
        "A highly polished, premium mobile app icon design for an iOS app name 'Antar Marg' (The Inner Path), a spiritual journey and sacred stories app. "
        "The logo features a glowing, mystical golden lotus flower or an intricate, sacred Om symbol in the center. "
        "The background is a smooth, vibrant deep royal purple and sunset orange elegant gradient. "
        "The style is clean vector art, flat design with rich gradients, highly professional, no text, no words. "
        "It must look exactly like a high-end App Store Icon UI design, perfectly square canvas but designed with a subtle rounded center aesthetic."
    )
    
    filename = "antarmarg_logo_concept_1.png"
    generate_logo(prompt, filename)
