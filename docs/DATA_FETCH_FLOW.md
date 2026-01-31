# How Verse Data is Fetched in ANTAR MARG

## Overview

When you open a chapter (e.g. Gita Ch 1), the app fetches verses in **2 steps**:

### Step 1: Fetch verses from `verses` table

```
Query: SELECT * FROM verses WHERE chapter_id = 'bg_chapter_1' ORDER BY order_index
```

- **Table:** `verses`
- **Filter:** `chapter_id` must match the chapter (e.g. `bg_chapter_1` for Chapter 1)
- **Returns:** List of verse metadata (id, verse_number, order_index, etc.)

**Important:** If this returns empty, the app shows "No verses" - even if `verse_translations` has data. **Both tables must have data.**

### Step 2: Fetch translations from `verse_translations` table

```
Query: SELECT * FROM verse_translations WHERE verse_id IN ('bg_1_1', 'bg_1_2', ...) ORDER BY is_primary DESC
```

- **Table:** `verse_translations`
- **Filter:** `verse_id` must match verse IDs from Step 1
- **Returns:** Hindi (hi), English (en), Sanskrit (sa) text for each verse

## Required Tables in Supabase

| Table | Purpose | Required columns |
|-------|---------|------------------|
| `verses` | Verse metadata per chapter | id, book_id, chapter_id, verse_number, verse_number_display, order_index |
| `verse_translations` | Translation text per verse | id, verse_id, language_code, language_name, text, is_primary |

## Chapter ID Format

- **Bhagavad Gita Ch 1:** `bg_chapter_1`
- **Bhagavad Gita Ch 2:** `bg_chapter_2`
- **Bhagavad Gita Ch 5:** `bg_chapter_5`

## SQL Scripts to Run (in order)

1. `SUPABASE_BOOKS_SCHEMA.sql` - Creates tables (books, chapters, verses, verse_translations)
2. `SUPABASE_GITA_DATA.sql` - Inserts verses for Chapters 1 & 2
3. `SUPABASE_GITA_TRANSLATIONS.sql` - Inserts Hindi + English translations

## Troubleshooting

### "No verses loaded"
- **Check 1:** Does `verses` table have rows for your chapter? Run: `SELECT * FROM verses WHERE chapter_id = 'bg_chapter_1'`
- **Check 2:** Does `verse_translations` table have rows? Run: `SELECT * FROM verse_translations LIMIT 5`
- **Check 3:** Is Supabase connected? Check internet and Supabase URL/key in `lib/core/config/supabase_config.dart`

### "Supabase not connected"
- Ensure `main.dart` calls `SupabaseService().initialize()` before app starts
- Check Supabase project URL and anon key in config

### Table name mismatch
- If your table is `verse_translation` (singular), change `verseTranslationsTable` in `supabase_config.dart` to `'verse_translation'`
- If your table is `verse_translations` (plural), use `'verse_translations'`
