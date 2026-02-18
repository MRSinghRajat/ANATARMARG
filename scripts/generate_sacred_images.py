#!/usr/bin/env python3
"""
Generate cover images for sacred stories using OpenAI DALL-E API,
then upload to Supabase Storage and update the sacred_stories table.
"""
import os
import sys
import json
import base64

try:
    import requests
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "-q"])
    import requests

try:
    from openai import OpenAI
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "openai", "-q"])
    from openai import OpenAI

# ── Config ──────────────────────────────────────────────────────────────────
SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://qyikatemonzykqamtvod.supabase.co")
SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY", "")
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")

HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json",
}

BUCKET_NAME = "sacred-stories"
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sacred_images")

# Image prompts for each story slug
STORY_PROMPTS = {
    "ganesha-elephant-head": (
        "A divine sacred scene depicting the story of how Lord Ganesha received his elephant head. "
        "Lord Shiva placing the elephant head on young Ganesha's body, surrounded by celestial light "
        "and divine beings. Traditional Indian miniature painting art style with rich gold, saffron, "
        "and warm tones. Ornate decorative border. Lotus petals floating. Spiritual devotional atmosphere. "
        "Premium quality mythological illustration."
    ),
    "krishna-lifts-govardhan": (
        "Lord Krishna lifting the massive Govardhan mountain effortlessly with one finger, "
        "villagers and cows taking shelter beneath the mountain from torrential rain. "
        "Krishna is depicted as a young blue-skinned deity with a peacock feather in his crown. "
        "Traditional Indian miniature painting style with vibrant blues, greens, and golden accents. "
        "Lush landscape, dramatic sky. Sacred Hindu mythology illustration with devotional mood."
    ),
}


def generate_image(prompt: str, filename: str) -> str:
    """Generate image using OpenAI DALL-E and save to disk. Returns local path."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    filepath = os.path.join(OUTPUT_DIR, filename)

    if os.path.exists(filepath):
        print(f"  Image already exists: {filepath}")
        return filepath

    print(f"  Generating image with DALL-E...")
    client = OpenAI(api_key=OPENAI_API_KEY)
    response = client.images.generate(
        model="dall-e-3",
        prompt=prompt,
        size="1024x1024",
        quality="standard",
        n=1,
        response_format="b64_json",
    )

    img_data = base64.b64decode(response.data[0].b64_json)
    with open(filepath, "wb") as f:
        f.write(img_data)
    print(f"  Saved: {filepath} ({len(img_data)} bytes)")
    return filepath


def create_bucket():
    """Create the storage bucket if it doesn't exist."""
    print(f"\nCreating storage bucket '{BUCKET_NAME}'...")
    r = requests.post(
        f"{SUPABASE_URL}/storage/v1/bucket",
        headers=HEADERS,
        json={"id": BUCKET_NAME, "name": BUCKET_NAME, "public": True},
    )
    if r.status_code in (200, 201):
        print(f"  Bucket created successfully!")
    elif "already exists" in r.text.lower() or r.status_code == 409:
        print(f"  Bucket already exists, continuing...")
    else:
        print(f"  Bucket creation response: {r.status_code} - {r.text[:300]}")
        print("  You may need to create the bucket manually in Supabase dashboard.")
        print(f"  Bucket name: {BUCKET_NAME}, set to Public.")
        return False
    return True


def upload_to_storage(filepath: str, storage_path: str) -> str:
    """Upload file to Supabase Storage. Returns the public URL."""
    print(f"  Uploading to storage: {storage_path}...")
    with open(filepath, "rb") as f:
        file_data = f.read()

    upload_headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "image/png",
        "x-upsert": "true",
    }

    r = requests.post(
        f"{SUPABASE_URL}/storage/v1/object/{BUCKET_NAME}/{storage_path}",
        headers=upload_headers,
        data=file_data,
    )

    if r.status_code in (200, 201):
        public_url = f"{SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/{storage_path}"
        print(f"  Upload successful! Public URL: {public_url}")
        return public_url
    else:
        print(f"  Upload failed: {r.status_code} - {r.text[:300]}")
        return ""


def update_story_cover(story_id: str, cover_url: str):
    """Update the cover_image_url for a sacred story."""
    print(f"  Updating story {story_id} with cover URL...")
    patch_headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    r = requests.patch(
        f"{SUPABASE_URL}/rest/v1/sacred_stories?id=eq.{story_id}",
        headers=patch_headers,
        json={"cover_image_url": cover_url},
    )
    if r.status_code in (200, 204):
        print(f"  Story updated successfully!")
    else:
        print(f"  Update failed: {r.status_code} - {r.text[:300]}")


def main():
    # 1. Fetch sacred stories
    print("Fetching sacred stories from Supabase...")
    r = requests.get(
        f"{SUPABASE_URL}/rest/v1/sacred_stories?select=id,title,slug,cover_image_url&order=order_index.asc",
        headers={"apikey": SUPABASE_ANON_KEY, "Authorization": f"Bearer {SUPABASE_ANON_KEY}"},
    )
    stories = r.json()
    print(f"Found {len(stories)} stories.\n")

    # 2. Create bucket
    bucket_ok = create_bucket()

    # 3. Generate, upload, and update each story
    for story in stories:
        slug = story["slug"]
        title = story["title"]
        story_id = story["id"]
        existing_cover = story.get("cover_image_url")

        print(f"\n{'='*60}")
        print(f"Story: {title} (slug: {slug})")
        print(f"{'='*60}")

        if existing_cover:
            print(f"  Already has cover image: {existing_cover[:60]}...")
            continue

        prompt = STORY_PROMPTS.get(slug)
        if not prompt:
            print(f"  No prompt defined for slug '{slug}', skipping.")
            continue

        # Generate image
        filename = f"{slug}.png"
        filepath = generate_image(prompt, filename)

        if not bucket_ok:
            print(f"  Skipping upload (bucket not ready). Image saved at: {filepath}")
            continue

        # Upload to storage
        storage_path = f"covers/{slug}.png"
        public_url = upload_to_storage(filepath, storage_path)

        if public_url:
            # Update story record
            update_story_cover(story_id, public_url)
        else:
            print(f"  Upload failed. Image saved locally at: {filepath}")

    print("\n\nDone! All sacred stories processed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
