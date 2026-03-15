import urllib.request, json, ssl, os

SUPABASE_URL = "https://qyikatemonzykqamtvod.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"

H = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json"
}
GET_HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}"
}

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

target_slug = "krishna-sudama-friendship"

req = urllib.request.Request(f"{SUPABASE_URL}/rest/v1/sacred_stories?slug=eq.{target_slug}&select=id", headers=GET_HEADERS)
with urllib.request.urlopen(req, context=ctx) as r:
    stories = json.loads(r.read().decode())
    story_id = stories[0]['id']

req_pages = urllib.request.Request(f"{SUPABASE_URL}/rest/v1/story_pages?story_id=eq.{story_id}&order=page_number", headers=GET_HEADERS)
with urllib.request.urlopen(req_pages, context=ctx) as r:
    pages = json.loads(r.read().decode())

print(f"Updating audio URLs for {len(pages)} pages...")

for page in pages:
    page_num = page['page_number']
    
    url_en = f"{SUPABASE_URL}/storage/v1/object/public/sacred-stories/audio/{target_slug}_page_{page_num}.mp3"
    url_hi = f"{SUPABASE_URL}/storage/v1/object/public/sacred-stories/audio/{target_slug}_page_{page_num}_hi.mp3"
    
    payload = {
        # 'audio_url_en' will hold the English version
        "audio_url_en": url_en,
        # The existing 'audio_url' will hold the Hindi version
        "audio_url": url_hi
    }
    
    patch_req = urllib.request.Request(
        f"{SUPABASE_URL}/rest/v1/story_pages?id=eq.{page['id']}",
        data=json.dumps(payload).encode('utf-8'),
        headers=H,
        method='PATCH'
    )
    try:
        with urllib.request.urlopen(patch_req, context=ctx) as pr:
            print(f"  [+] Page {page_num}: DB Updated! En URL: {url_en} | Hi (Main) URL: {url_hi}")
    except Exception as e:
        print(f"  [!] Failed to update page {page_num}: {e}")

print("\nDone patching existing audio mappings!")
