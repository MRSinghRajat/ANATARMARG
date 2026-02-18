#!/usr/bin/env python3
import requests

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}

# Delete ALL test stories
r = requests.delete(f"{URL}/rest/v1/sacred_stories?slug=like.test*", headers=H)
print(f"Delete test*: {r.status_code}")
r = requests.delete(f"{URL}/rest/v1/sacred_stories?title=like.Test*", headers=H)
print(f"Delete Test*: {r.status_code}")

r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug&order=order_index.asc", headers=H)
data = r.json()
print(f"\nStories remaining: {len(data)}")
for s in data:
    print(f"  {s['slug']}")
