import requests
URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}
r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug,title,deity_slug&is_active=eq.true&order=order_index.asc", headers=H)
data = r.json()
print(f"Readable stories: {len(data)}")
for i, s in enumerate(data):
    print(f"  {i+1}. [{s['deity_slug']}] {s['title']}")
