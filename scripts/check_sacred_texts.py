import requests, sys
sys.stdout.reconfigure(encoding='utf-8')
URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}
r = requests.get(f"{URL}/rest/v1/sacred_texts?select=slug,text_english&order=order_index.asc", headers=H)
with open("scripts/verify_final.txt", "w", encoding="utf-8") as f:
    for row in r.json():
        eng = (row.get('text_english') or 'NULL')[:150]
        f.write(f"=== {row['slug']} ===\n{eng}\n\n")
print("Done")
