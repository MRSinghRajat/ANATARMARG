# ARCHIVED — superseded by docs/CONFLUENCE_APP_OVERVIEW.md and docs/JIRA_WORK_PLAN.md (2026-08-29).

# ANTAR MARG – What’s Done & What’s Working

This document summarizes what has been built so far and what is currently working in the app.

---

## 1. App overview

**ANTAR MARG** is a Flutter spiritual learning app with:

- **Bottom navigation:** 5 tabs – Aangan (home), Prayer, **Ashram** (center), Granthalya (books), Self (profile).
- **Tech:** Flutter, Riverpod, Supabase, Rive, GPT API, SQLite, AudioPlayers.

---

## 2. What you’ve done so far (by area)

### 2.1 Ashram tab (main focus of recent work)

- **Ashram screen** (`lib/features/ashram/presentation/screens/ashram_screen.dart`):
  - **Background:** Only diagonal lines (geometry overlay). No cosmic radial glow, no extra radial gradient behind the OM (removed to avoid shadow/circle look).
  - **OM area:** OM character in solid gold, no shadows, no breathing animation. Two rotating mandala rings (circles) only; third ring removed.
  - **No droplet/rain animation**, no energy-pulse circles, no ShaderMask on OM (avoids dark/transparent look).
  - **Draggable bottom sheet:** Min 40%, snap 40/60/95%. Content inside scrolls; sheet is moved by dragging the handle. **No black shadow** on the sheet.
  - **Completion count:** Shows `completed/total` (e.g. `2/5`) and progress bar from affirmation count; **no hardcoded `/3`**.
  - **Fixes applied:** ParentDataWidget error fixed (Positioned.fill at call site for overlays). Ashram tab label overflow fixed in bottom nav (FittedBox + ellipsis for all tab labels including ASHRAM / GRANTHALYA).

- **Daily verse (Ashram):** Tap daily verse card → **AshramVerseDetailScreen**. Today’s verse from repository with optional Devanagari and insight.

- **Affirmations:** Daily affirmations with checkmarks; completion persisted; quest-style cards in the sheet.

### 2.2 Verse-of-the-day & full-screen verse

- **Verse full-screen** (`lib/features/content/presentation/screens/verse_full_screen.dart`): “Obsidian Gold” style – dark background, gold/cream text, category pill, Devanagari + translation, “Sacred Action” card, footer. Used when opening the verse of the day from home/content.
- **Verse model** (`lib/features/content/data/models/verse_model.dart`): Optional `devanagariText` and `dailyInsight`; GPT verse-of-the-day returns JSON for these when configured.
- **API/config:** GPT verse-of-the-day prompt and JSON parsing in `api_config.dart` / `gpt_api_service.dart` for verse content.

### 2.3 Draggable cards (scroll vs drag)

- **Draggable verse card** (`lib/shared/widgets/draggable_verse_card.dart`): Only the **content** inside the card scrolls; the **card** moves only when the user drags the **drag handle** (sheet controller not driven by inner scroll).
- **Deity chants sheet** (`lib/features/books/presentation/widgets/granthalaya_audio_content.dart`): Same idea – list has its own scroll controller; only the handle moves the sheet.

### 2.4 Other fixes and tweaks

- **Dust texture** (`lib/features/home/presentation/widgets/dust_cleaning_widget.dart`): `Image.asset` uses `errorBuilder` so a missing `dust_texture.png` does not crash the app.
- **Bottom nav:** Tab labels (e.g. ASHRAM, GRANTHALYA) wrapped in `SizedBox` + `FittedBox` with `overflow: TextOverflow.ellipsis` and `maxLines: 1` to prevent pixel overflow.

---

## 3. What’s working (current behavior)

| Area | What works |
|------|------------|
| **Navigation** | All 5 tabs switch correctly. Ashram is the center tab. Back press twice to exit. |
| **Ashram screen** | Loads without ParentDataWidget errors. OM is solid gold with two rotating rings; diagonal lines in background; no droplet, no energy circles, no shadow behind/below OM. |
| **Ashram sheet** | Draggable sheet with handle; inner content scrolls; no black shadow on the card. |
| **Ashram affirmations** | Daily affirmations load; completion count is dynamic (e.g. 2/5); progress bar matches. |
| **Ashram daily verse** | Card shows today’s verse; tap opens AshramVerseDetailScreen. |
| **Verse full-screen** | Obsidian Gold layout with Devanagari/insight when data is provided. |
| **Draggable verse card** | Only handle resizes sheet; content scrolls independently. |
| **Deity chants sheet** | Same scroll-vs-drag behavior as above. |
| **Bottom nav labels** | No overflow on ASHRAM / GRANTHALYA; labels scale or ellipsize. |
| **Books / Granthalaya** | Library, chapters, audio (e.g. deity chants), mini player, progress sync as implemented. |
| **Home (Aangan)** | Home screen, “Begin” → Prayer tab, dust widget safe if texture missing. |
| **Prayer** | Prayer dashboard as implemented. |
| **Profile (Self)** | Profile screen, bookmarks, language/notifications settings. |
| **Data** | Verses/translations from Supabase; GPT verse-of-the-day when API key and config are set. |

---

## 4. Configuration required for full behavior

- **Supabase:** URL and anon key in config (e.g. `supabase_config.dart` / `.env`) for verses, affirmations, daily verse, books, etc.
- **GPT API:** Key and verse-of-the-day endpoint in `app_config.dart` / `api_config.dart` for AI verse content, Devanagari, and daily insight.
- **Environment:** Copy `.env.example` to `.env` and fill in any keys used by the app.

---

## 5. Key files (reference)

| Purpose | File(s) |
|--------|--------|
| Ashram UI & OM | `lib/features/ashram/presentation/screens/ashram_screen.dart` |
| Ashram verse detail | `lib/features/ashram/presentation/screens/ashram_verse_detail_screen.dart` |
| Main navigation & tabs | `lib/features/navigation/presentation/screens/main_navigation_screen.dart` |
| Bottom nav (labels, Ashram tab) | `lib/shared/widgets/bottom_nav_bar.dart` |
| Verse full-screen (Obsidian Gold) | `lib/features/content/presentation/screens/verse_full_screen.dart` |
| Draggable verse card | `lib/shared/widgets/draggable_verse_card.dart` |
| Deity chants sheet | `lib/features/books/presentation/widgets/granthalaya_audio_content.dart` |
| Verse model (Devanagari, insight) | `lib/features/content/data/models/verse_model.dart` |
| Data fetch flow | `docs/DATA_FETCH_FLOW.md`, `docs/DATA_SETUP_AND_FETCH_FLOW.md` |

---

## 6. Removed / simplified (no longer in use on Ashram)

- Cosmic background (full-screen radial gold glow).
- Radial gradient in the OM area (behind/below OM).
- Third mandala ring (only 2 circles now).
- Floating particles (droplet) animation.
- Energy pulse rings (expanding shadow circles).
- OM breathing animation and ShaderMask/shadows on OM.
- Black shadow on the draggable sheet.

---

*Last updated to reflect the current Ashram UI, completion count, nav overflow fix, and removal of extra backgrounds and animations.*
