#!/usr/bin/env python3
"""Final verification of all sacred stories."""
import requests

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}

r = requests.get(
    f"{URL}/rest/v1/sacred_stories?select=title,slug,deity_slug,category&order=order_index.asc",
    headers=H,
)
data = r.json()

# Separate real vs test
real = [s for s in data if not s["slug"].startswith("test")]
test = [s for s in data if s["slug"].startswith("test")]

print(f"=== REAL Sacred Stories: {len(real)} ===")
by_deity = {}
for s in real:
    d = s["deity_slug"]
    if d not in by_deity:
        by_deity[d] = []
    by_deity[d].append(s)

for deity, stories in by_deity.items():
    print(f"\n  {deity.upper()} ({len(stories)} stories):")
    for s in stories:
        print(f"    - {s['title']} [{s['category']}]")

if test:
    print(f"\n=== Test records to clean up: {len(test)} ===")
    for s in test:
        print(f"  - {s['slug']}")
