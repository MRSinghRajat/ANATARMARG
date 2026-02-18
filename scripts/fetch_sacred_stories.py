#!/usr/bin/env python3
"""Fetch sacred stories from Supabase and show details."""
import requests
import json

SUPABASE_URL = "https://qyikatemonzykqamtvod.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"

HEADERS = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
}

r = requests.get(
    f"{SUPABASE_URL}/rest/v1/sacred_stories?select=*&order=order_index.asc",
    headers=HEADERS,
)
data = r.json()
print(f"Total sacred stories: {len(data)}\n")

for i, s in enumerate(data):
    print(f"--- Story {i+1} ---")
    print(f"  ID:    {s['id']}")
    print(f"  Title: {s['title']}")
    print(f"  Slug:  {s['slug']}")
    print(f"  Category: {s['category']}")
    print(f"  Deity: {s.get('deity_slug', 'none')}")
    print(f"  Cover Image: {s.get('cover_image_url') or 'NONE'}")
    pages = s.get("pages", [])
    print(f"  Pages: {len(pages)}")
    for j, p in enumerate(pages):
        eng = p.get("text_english", "")[:80]
        ill = p.get("illustration_url", "NONE") or "NONE"
        print(f"    Page {j+1}: illustration={ill} | text={eng}...")
    print()
