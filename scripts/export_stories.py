import urllib.request
import json
import ssl
import sys
import csv
import os

SUPABASE_URL = 'https://qyikatemonzykqamtvod.supabase.co'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA'

GET_HEADERS = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': f'Bearer {SUPABASE_ANON_KEY}'
}

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def export_to_csv():
    # 1. Fetch stories
    print("Fetching stories from database...")
    req_stories = urllib.request.Request(f'{SUPABASE_URL}/rest/v1/sacred_stories?select=id,title,title_hindi', headers=GET_HEADERS)
    try:
        with urllib.request.urlopen(req_stories, context=ctx) as r:
            stories_data = json.loads(r.read().decode())
    except Exception as e:
        print(f"Error fetching stories: {e}")
        return

    # Create a mapping of story_id to story data
    stories = {s['id']: {'title_english': s.get('title', ''), 'title_hindi': s.get('title_hindi', ''), 'pages': []} for s in stories_data}

    # 2. Fetch pages
    print("Fetching story pages...")
    req_pages = urllib.request.Request(f'{SUPABASE_URL}/rest/v1/story_pages?select=story_id,page_number,text_english,text_hindi&order=page_number', headers=GET_HEADERS)
    try:
        with urllib.request.urlopen(req_pages, context=ctx) as r:
            pages_data = json.loads(r.read().decode())
    except Exception as e:
        print(f"Error fetching pages: {e}")
        return

    # Append pages to their respective stories
    for p in pages_data:
        s_id = p.get('story_id')
        if s_id in stories:
            stories[s_id]['pages'].append(p)

    # 3. Combine text and write to CSV
    output_filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Sacred_Stories_Hindi_Only.csv')
    
    print(f"Writing data to {output_filepath}...")
    with open(output_filepath, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        # Header row
        writer.writerow(['Story Title (Hindi)', 'Complete Story Text (Hindi)'])

        for s_id, data in stories.items():
            title_hi = data['title_hindi']
            
            # Combine all pages
            # We add a newline between paragraphs for readability
            complete_hi = "\n\n".join([page.get('text_hindi', '') for page in data['pages'] if page.get('text_hindi')])
            
            # Write row
            writer.writerow([title_hi, complete_hi])

    print("Export complete! You can open this CSV file in Microsoft Excel or Google Sheets.")

if __name__ == '__main__':
    export_to_csv()
