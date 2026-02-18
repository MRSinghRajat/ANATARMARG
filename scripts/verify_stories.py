#!/usr/bin/env python3
"""Clean up test records and verify final list."""
import requests

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}

# Delete test records
for slug in ["test-story-001", "test-story-002"]:
    r = requests.delete(f"{URL}/rest/v1/sacred_stories?slug=eq.{slug}", headers=H)
    print(f"Delete {slug}: {r.status_code}")

# Show all stories
r = requests.get(
    f"{URL}/rest/v1/sacred_stories?select=title,slug,deity_slug,category&order=order_index.asc",
    headers=H,
)
data = r.json()
print(f"\nTotal stories: {len(data)}")
slugs = set()
for i, s in enumerate(data):
    slugs.add(s["slug"])
    print(f"  {i+1}. [{s['deity_slug']}] {s['title']} | {s['slug']}")

need = [
    "shiva-halahala-poison", "shiva-ganga-descent", "shiva-ardhanarishvara",
    "shiva-destroys-tripura", "shiva-nandi-devotion",
    "krishna-butter-thief", "krishna-kalia-naag", "krishna-sudama-friendship",
    "krishna-draupadi-vastraharan", "krishna-arjuna-vishwaroop",
]
missing = [s for s in need if s not in slugs]
print(f"\nMissing from batch 1: {missing}")
