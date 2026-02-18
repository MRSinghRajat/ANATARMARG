#!/usr/bin/env python3
"""Clean test records and show final list."""
import requests
import json

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}

# Delete test records
r = requests.delete(
    f"{URL}/rest/v1/sacred_stories?slug=like.test-story*",
    headers=H,
)
print(f"Deleted test records: {r.status_code}")

# Show all stories
r = requests.get(
    f"{URL}/rest/v1/sacred_stories?select=title,deity_slug,category,slug&order=order_index.asc",
    headers=H,
)
data = r.json()
print(f"\nTotal stories: {len(data)}")
for i, s in enumerate(data):
    print(f"  {i+1}. [{s['deity_slug']}] {s['title']} ({s['category']}) - {s['slug']}")

# Show which slugs are missing from our plan
expected = [
    "shiva-halahala-poison", "shiva-ganga-descent", "shiva-ardhanarishvara",
    "shiva-destroys-tripura", "shiva-nandi-devotion",
    "krishna-butter-thief", "krishna-kalia-naag", "krishna-sudama-friendship",
    "krishna-draupadi-vastraharan", "krishna-arjuna-vishwaroop",
]
existing_slugs = {s["slug"] for s in data}
missing = [s for s in expected if s not in existing_slugs]
print(f"\nMissing slugs: {missing}")
