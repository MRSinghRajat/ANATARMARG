# Bhagavad Gita Data for Supabase

## Overview

This folder contains scripts and data for populating Supabase with the complete Bhagavad Gita (18 chapters, 700 verses).

## Files

- **gita_full_cleaned.json** - Complete Gita data (chapters 1-18, verses with Hindi and English translations)
- **gita_data_full.json** - Partial data (chapters 1-2, 100 verses) - fallback if gita_full_cleaned.json doesn't exist
- **generate_gita_supabase.py** - Python script to generate Supabase SQL files from JSON

## How to Generate Supabase SQL

### 1. Add Complete Data (700 verses)

To use the complete Gita data (all 18 chapters):

**Option A - From file:**
```bash
# Save your JSON to a file (e.g. my_gita_data.json), then:
python scripts/update_gita_from_user_data.py my_gita_data.json
```

**Option B - From clipboard/stdin:**
```bash
# Paste your JSON and press Ctrl+D (Unix) or Ctrl+Z+Enter (Windows):
python scripts/update_gita_from_user_data.py
```

**Option C - Manual:** Save your complete JSON data to `scripts/gita_full_cleaned.json`

The JSON format should be:
```json
[
  {"chapter": 1, "verse": 1, "hindi": "धृतराष्ट्र ने कहा...", "english": "The King Dhritarashtra asked..."},
  {"chapter": 1, "verse": 2, "hindi": "...", "english": "..."},
  ...
  {"chapter": 18, "verse": 78, "hindi": "...", "english": "..."}
]
```

### 2. Run the Generator

```bash
python scripts/generate_gita_supabase.py
```

This generates:
- **SUPABASE_GITA_DATA.sql** - Inserts for the `verses` table
- **SUPABASE_GITA_TRANSLATIONS.sql** - Inserts for the `verse_translations` table

### 3. Run in Supabase

1. Run `SUPABASE_BOOKS_SCHEMA.sql` first (creates tables, books, chapters)
2. Run `SUPABASE_GITA_DATA.sql` (inserts verses)
3. Run `SUPABASE_GITA_TRANSLATIONS.sql` (inserts Hindi/English translations)

## Current Status

- **gita_full_cleaned.json**: Currently contains 100 verses (chapters 1-2)
- **To add complete 700 verses**: Save your JSON to a file (e.g. `my_gita.json`) and run:
  ```bash
  python scripts/update_gita_from_user_data.py my_gita.json
  ```
  The script extracts the JSON array even if your file has a prefix like "gita_full_cleaned.json"
- The generator uses `ON CONFLICT DO NOTHING` / `DO UPDATE` for idempotent inserts

## Quick Start (Complete Data)

1. Save your complete Gita JSON (700 verses) to `scripts/gita_full_cleaned.json`
2. Run: `python scripts/generate_gita_supabase.py`
3. Run the generated SQL files in Supabase SQL Editor (in order):
   - SUPABASE_BOOKS_SCHEMA.sql (if not already run)
   - SUPABASE_GITA_DATA.sql
   - SUPABASE_GITA_TRANSLATIONS.sql
