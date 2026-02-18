#!/usr/bin/env python3
"""Check sacred_stories schema by examining one row."""
import requests
import json

SUPABASE_URL = "https://qyikatemonzykqamtvod.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": SUPABASE_ANON_KEY, "Authorization": f"Bearer {SUPABASE_ANON_KEY}"}

r = requests.get(f"{SUPABASE_URL}/rest/v1/sacred_stories?select=*&limit=1", headers=H)
data = r.json()[0]

# Print columns and types
print("COLUMNS:")
for k, v in data.items():
    if k == "pages":
        print(f"  {k}: list of {len(v)} pages")
        if v:
            print(f"    page keys: {list(v[0].keys())}")
            print(f"    sample page (text truncated):")
            p = dict(v[0])
            if "text_english" in p:
                p["text_english"] = p["text_english"][:80] + "..."
            if "text_hindi" in p:
                p["text_hindi"] = p["text_hindi"][:80] + "..."
            print(f"    {json.dumps(p, ensure_ascii=False)}")
    else:
        val = str(v)[:80] if v else "null"
        print(f"  {k}: {val}")
