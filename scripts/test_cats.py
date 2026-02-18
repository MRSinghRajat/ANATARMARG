#!/usr/bin/env python3
import requests

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}

# Check existing categories
r = requests.get(f"{URL}/rest/v1/sacred_stories?select=category", headers=H)
cats = set(s["category"] for s in r.json())
print(f"Existing categories: {cats}")

# Try inserting with each potential category
for cat in ["mythology", "leela", "devotion", "dharma", "philosophy", "moral"]:
    H2 = {**H, "Content-Type": "application/json", "Prefer": "return=minimal"}
    story = {"slug": f"test-{cat}", "title": f"Test {cat}", "deity_slug": "shiva",
             "source": "Test", "category": cat, "pages": [],
             "is_active": True, "order_index": 99, "estimated_minutes": 1}
    r = requests.post(f"{URL}/rest/v1/sacred_stories", headers=H2, json=story)
    status = "OK" if r.status_code in (200, 201) else "FAIL"
    print(f"  {cat}: {status} ({r.status_code})")
    # Clean up
    if r.status_code in (200, 201):
        requests.delete(f"{URL}/rest/v1/sacred_stories?slug=eq.test-{cat}", headers=H)
