# Data Setup and Fetch Flow - ANTAR MARG

## 1. Database Setup (Supabase)

### Tables Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SUPABASE (PostgreSQL)                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  books                    chapters                  verses                   │
│  ┌──────────────┐         ┌──────────────┐          ┌──────────────┐         │
│  │ id           │         │ id           │          │ id           │         │
│  │ name         │◄───────│ book_id      │◄─────────│ chapter_id   │         │
│  │ description  │         │ chapter_num  │          │ book_id      │         │
│  └──────────────┘         │ title        │          │ verse_number │         │
│                           └──────────────┘          │ order_index  │         │
│                                                     └──────┬───────┘         │
│                                                            │                  │
│                                                            │ verse_id         │
│                                                            ▼                  │
│  verse_translations                                       ┌──────────────┐    │
│  ┌──────────────────────────────────────────────────────│ verse_id     │    │
│  │ id (UUID)                                              │ language_code│    │
│  │ verse_id  ────────────────────────────────────────────│ language_name│    │
│  │ language_code                                          │ text        │    │
│  │ language_name                                          │ is_primary  │    │
│  │ text (Hindi/English/Sanskrit)                          └──────────────┘    │
│  │ is_primary                                                                  │
│  └──────────────────────────────────────────────────────────────────────────┘
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Table Relationships

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| **books** | Bhagavad Gita, Mahabharat, etc. | id, name |
| **chapters** | Ch 1, Ch 2, ... per book | id (bg_chapter_1), book_id, chapter_number |
| **verses** | One row per verse (metadata) | id (bg_1_1), chapter_id, verse_number, order_index |
| **verse_translations** | Hindi/English/Sanskrit text per verse | verse_id, language_code, text |

### SQL Scripts to Run (in order)

1. **SUPABASE_BOOKS_SCHEMA.sql** - Creates tables + inserts books, chapters, verses 1-10
2. **SUPABASE_GITA_DATA.sql** - Inserts verses 11-47 (Ch 1), verses 1-53 (Ch 2)
3. **SUPABASE_GITA_TRANSLATIONS.sql** - Inserts Hindi + English text for each verse
4. **SUPABASE_FIX_RLS.sql** - Allows app (anon key) to read verses & verse_translations

---

## 2. App Configuration

### Supabase Config (`lib/core/config/supabase_config.dart`)

```dart
supabaseUrl: 'https://qyikatemonzykqamtvod.supabase.co'
supabaseAnonKey: 'eyJ...'  // Public key - used by app

// Table names (must match Supabase)
versesTable = 'verses'
verseTranslationsTable = 'verse_translations'
```

### Initialization (`lib/main.dart`)

```dart
void main() async {
  await SupabaseService().initialize();  // Connects to Supabase
  runApp(ProviderScope(child: AntarMargApp()));
}
```

---

## 3. Data Fetch Flow (When User Opens Chapter 1)

### Call Chain

```
BookChapterScreen (user taps Chapter 1)
    │
    └─► _loadChapter()
            │
            └─► _loadVerses()
                    │
                    └─► VerseRepository.getVersesWithAllTranslations('bg_chapter_1')
                            │
                            └─► SupabaseVerseDataSource.getVersesWithTranslations('bg_chapter_1')
```

### Step-by-Step Fetch (2 Queries)

#### Query 1: Get verses for chapter

**Code:**
```dart
_supabase.client!
  .from('verses')
  .select()
  .eq('chapter_id', 'bg_chapter_1')
  .order('order_index')
```

**Equivalent SQL:**
```sql
SELECT * FROM verses 
WHERE chapter_id = 'bg_chapter_1' 
ORDER BY order_index;
```

**Returns:** List of verse metadata (id, verse_number, order_index, etc.)

**Example row:**
```json
{
  "id": "bg_1_1",
  "book_id": "bhagavad_gita",
  "chapter_id": "bg_chapter_1",
  "verse_number": 1,
  "verse_number_display": "1.1",
  "order_index": 1
}
```

---

#### Query 2: Get translations for those verses

**Code:**
```dart
_supabase.client!
  .from('verse_translations')
  .select()
  .inFilter('verse_id', ['bg_1_1', 'bg_1_2', 'bg_1_3', ...])
  .order('is_primary', ascending: false)
```

**Equivalent SQL:**
```sql
SELECT * FROM verse_translations 
WHERE verse_id IN ('bg_1_1', 'bg_1_2', 'bg_1_3', ...)
ORDER BY is_primary DESC;
```

**Returns:** List of translations (Hindi, English, Sanskrit per verse)

**Example rows:**
```json
{"verse_id": "bg_1_1", "language_code": "hi", "text": "धृतराष्ट्र ने कहा..."},
{"verse_id": "bg_1_1", "language_code": "en", "text": "The King Dhritarashtra asked..."}
```

---

#### Step 3: Combine in app

```dart
// Group translations by verse_id
translationsByVerse['bg_1_1'] = [HindiTranslation, EnglishTranslation]

// Build VerseWithTranslations for each verse
VerseWithTranslations(verse: verse1, translations: [hi, en])
VerseWithTranslations(verse: verse2, translations: [hi, en])
...
```

---

## 4. Chapter ID Format

| User Opens | chapterId Used | verses.chapter_id |
|------------|----------------|-------------------|
| Gita Ch 1 | `bg_chapter_1` | `bg_chapter_1` |
| Gita Ch 2 | `bg_chapter_2` | `bg_chapter_2` |
| Gita Ch 5 | `bg_chapter_5` | `bg_chapter_5` |

---

## 5. File Locations

| Purpose | File |
|---------|------|
| Supabase connection | `lib/core/services/supabase_service.dart` |
| Table names config | `lib/core/config/supabase_config.dart` |
| Verse fetch logic | `lib/features/books/data/datasources/supabase_verse_datasource.dart` |
| Repository (calls datasource) | `lib/features/books/data/repositories/verse_repository.dart` |
| UI (displays verses) | `lib/features/books/presentation/screens/book_chapter_screen.dart` |
| Verse model | `lib/features/books/data/models/verse_model.dart` |
| Translation model | `lib/features/books/data/models/verse_translation_model.dart` |

---

## 6. Troubleshooting

| Issue | Check |
|-------|-------|
| "Supabase not initialized" | main.dart calls SupabaseService().initialize() |
| "No verses" but DB has data | Run SUPABASE_FIX_RLS.sql (RLS blocking anon) |
| Wrong table name | supabase_config.dart - verse_translations vs verse_translation |
| Empty response | _toList() / _toSingle() handle PostgrestResponse.data |
