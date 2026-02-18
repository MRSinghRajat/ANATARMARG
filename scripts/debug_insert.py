#!/usr/bin/env python3
"""Debug: try inserting a single test story."""
import requests
import json

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {
    "apikey": KEY,
    "Authorization": f"Bearer {KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal",
}

test = {
    "slug": "test-story-001",
    "title": "Test Story",
    "title_hindi": "परीक्षण कथा",
    "deity_slug": "shiva",
    "source": "Test",
    "category": "mythology",
    "pages": json.dumps([{"text_english": "Hello", "text_hindi": "नमस्ते"}]),
    "key_teaching": "Test",
    "reflection_prompt": "Test",
    "estimated_minutes": 3,
    "is_featured": False,
    "is_active": True,
    "order_index": 99,
}

r = requests.post(f"{URL}/rest/v1/sacred_stories", headers=H, json=test)
print(f"Status: {r.status_code}")
print(f"Response: {r.text[:500]}")

# Also try without json.dumps on pages
test2 = dict(test)
test2["slug"] = "test-story-002"
test2["pages"] = [{"text_english": "Hello", "text_hindi": "नमस्ते"}]
r2 = requests.post(f"{URL}/rest/v1/sacred_stories", headers=H, json=test2)
print(f"\nTest2 Status: {r2.status_code}")
print(f"Test2 Response: {r2.text[:500]}")
