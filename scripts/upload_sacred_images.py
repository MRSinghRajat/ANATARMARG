#!/usr/bin/env python3
"""
Upload sacred story images to Supabase Storage and update the sacred_stories table.
Tries multiple approaches:
1. Create bucket + upload via Storage API
2. If bucket creation fails, provide SQL to run manually
"""
import os
import sys
import base64
import requests

SUPABASE_URL = "https://qyikatemonzykqamtvod.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"

HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
}

BUCKET_NAME = "sacred-stories"
IMAGES_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sacred_images")

STORY_IMAGES = {
    "ganesha-elephant-head": "ganesha-elephant-head.png",
    "krishna-lifts-govardhan": "krishna-lifts-govardhan.png",
}


def try_create_bucket():
    """Try to create the bucket."""
    print("Step 1: Creating storage bucket...")
    r = requests.post(
        f"{SUPABASE_URL}/storage/v1/bucket",
        headers={**HEADERS, "Content-Type": "application/json"},
        json={"id": BUCKET_NAME, "name": BUCKET_NAME, "public": True},
    )
    print(f"  Response: {r.status_code} - {r.text[:200]}")
    return r.status_code in (200, 201, 409)


def upload_image(filepath: str, storage_path: str) -> str:
    """Upload image to Supabase Storage. Returns public URL or empty string."""
    with open(filepath, "rb") as f:
        file_data = f.read()

    print(f"  Uploading {storage_path} ({len(file_data)} bytes)...")
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
    print(f"  Upload response: {r.status_code} - {r.text[:200]}")

    if r.status_code in (200, 201):
        public_url = f"{SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/{storage_path}"
        print(f"  Public URL: {public_url}")
        return public_url
    return ""


def update_cover_url(story_id: str, url: str):
    """Update cover_image_url in sacred_stories."""
    r = requests.patch(
        f"{SUPABASE_URL}/rest/v1/sacred_stories?id=eq.{story_id}",
        headers={**HEADERS, "Content-Type": "application/json", "Prefer": "return=minimal"},
        json={"cover_image_url": url},
    )
    print(f"  DB update: {r.status_code}")
    return r.status_code in (200, 204)


def generate_sql_fallback():
    """If upload failed, generate SQL with base64 data URLs."""
    print("\n\n===================================")
    print("ALTERNATIVE: Direct base64 data URLs")
    print("===================================\n")

    stories_headers = {**HEADERS}
    r = requests.get(
        f"{SUPABASE_URL}/rest/v1/sacred_stories?select=id,title,slug,cover_image_url&order=order_index.asc",
        headers=stories_headers,
    )
    stories = r.json()

    print("Run this SQL in Supabase SQL Editor to create the bucket:\n")
    print(f"""
-- Create the storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('{BUCKET_NAME}', '{BUCKET_NAME}', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Allow public read access
CREATE POLICY "Public read access for {BUCKET_NAME}" ON storage.objects
  FOR SELECT USING (bucket_id = '{BUCKET_NAME}');

-- Allow authenticated uploads
CREATE POLICY "Allow uploads to {BUCKET_NAME}" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = '{BUCKET_NAME}');
""")
    print("After running the SQL above, re-run this script to upload images.\n")


def main():
    # Check images exist
    for slug, filename in STORY_IMAGES.items():
        path = os.path.join(IMAGES_DIR, filename)
        if not os.path.exists(path):
            print(f"ERROR: {path} not found. Run generate_sacred_images.py first.")
            return 1

    # Try to create bucket
    bucket_ok = try_create_bucket()

    if not bucket_ok:
        generate_sql_fallback()
        return 1

    # Fetch stories
    r = requests.get(
        f"{SUPABASE_URL}/rest/v1/sacred_stories?select=id,title,slug,cover_image_url&order=order_index.asc",
        headers=HEADERS,
    )
    stories = r.json()
    print(f"\nFound {len(stories)} stories\n")

    success_count = 0
    for s in stories:
        slug = s["slug"]
        title = s["title"]
        sid = s["id"]
        existing = s.get("cover_image_url")

        print(f"\n--- {title} ---")
        if existing:
            print(f"  Already has cover image, skipping.")
            continue

        filename = STORY_IMAGES.get(slug)
        if not filename:
            print(f"  No image for slug '{slug}'")
            continue

        filepath = os.path.join(IMAGES_DIR, filename)
        storage_path = f"covers/{slug}.png"

        url = upload_image(filepath, storage_path)
        if url:
            if update_cover_url(sid, url):
                success_count += 1

    # Verify
    print(f"\n\n=== VERIFICATION (updated {success_count} stories) ===")
    r = requests.get(
        f"{SUPABASE_URL}/rest/v1/sacred_stories?select=title,cover_image_url&order=order_index.asc",
        headers=HEADERS,
    )
    for s in r.json():
        print(f"  {s['title']}: {s.get('cover_image_url') or 'NONE'}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
