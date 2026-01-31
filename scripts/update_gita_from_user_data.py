#!/usr/bin/env python3
"""
Update gita_full_cleaned.json with complete Bhagavad Gita data.

Usage:
  1. From file:  python update_gita_from_user_data.py path/to/your_data.json
  2. From stdin: python update_gita_from_user_data.py < your_data.json
  3. Interactive: python update_gita_from_user_data.py
     (paste JSON, then Ctrl+D / Ctrl+Z+Enter)

JSON format: [{"chapter":1,"verse":1,"hindi":"...","english":"..."}, ...]
"""
import json
import sys
import os

def extract_json_from_text(text):
    """Extract JSON array from text that may have prefix/suffix (e.g. 'gita_full_cleaned.json\\n[')"""
    # Find the first [ and last ]
    start = text.find('[')
    end = text.rfind(']')
    if start >= 0 and end > start:
        return text[start:end+1]
    return text

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "gita_full_cleaned.json")
    
    if len(sys.argv) > 1:
        # Read from file
        input_path = sys.argv[1]
        with open(input_path, "r", encoding="utf-8") as f:
            data_str = f.read()
        data_str = extract_json_from_text(data_str)
    elif not sys.stdin.isatty():
        data_str = sys.stdin.read()
        data_str = extract_json_from_text(data_str)
    else:
        print("Paste your complete Gita JSON array")
        print("(format: [{\"chapter\":1,\"verse\":1,\"hindi\":\"...\",\"english\":\"...\"}, ...])")
        print("Press Ctrl+D (Unix) or Ctrl+Z+Enter (Windows) when done:")
        data_str = sys.stdin.read()
        data_str = extract_json_from_text(data_str)
    
    try:
        data = json.loads(data_str)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        return 1
    
    if not isinstance(data, list):
        print("Error: Expected a JSON array", file=sys.stderr)
        return 1
    
    # Validate structure
    required = {"chapter", "verse", "hindi", "english"}
    for i, item in enumerate(data):
        if not isinstance(item, dict):
            print(f"Error: Item {i} is not an object", file=sys.stderr)
            return 1
        missing = required - set(item.keys())
        if missing:
            print(f"Error: Item {i} missing keys: {missing}", file=sys.stderr)
            return 1
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Saved {len(data)} verses to {output_path}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
