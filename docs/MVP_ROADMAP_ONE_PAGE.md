# ARCHIVED — superseded by docs/CONFLUENCE_APP_OVERVIEW.md and docs/JIRA_WORK_PLAN.md (2026-08-29).

# ANTAR MARG – MVP Roadmap (1 page)

**One-line:** Gamified spiritual learning app – home (Aangan), Prayer, Ashram, Books (Granthalya), Profile, with sequential chapter/verse unlock and premium full access.

---

## ✅ DONE (MVP scope so far)

| # | Area | What’s done |
|---|------|-------------|
| 1 | **Navigation** | 5-tab bottom nav (Aangan, Prayer, Ashram, Granthalya, Self). Back-twice-to-exit. Tab labels no overflow (FittedBox). |
| 2 | **Home (Aangan)** | Home screen, “Begin” → Prayer. Dust widget safe if texture missing. |
| 3 | **Prayer** | Prayer dashboard screen. |
| 4 | **Ashram** | Screen with OM (solid gold, 2 rotating rings), diagonal-line background, draggable bottom sheet (handle-only drag, content scrolls). Daily affirmations (dynamic completed/total), daily verse card → AshramVerseDetailScreen. No ParentDataWidget / shadow / droplet issues. |
| 5 | **Books (Granthalya)** | Library, book detail (Progress Hub), chapter list with **sequential unlock** (ch 0 open, then ch 1 after ch 0 complete). Books & Chapters modal with **locked** chapters (lock icon, no tap unless unlocked or premium). Chapter reader (verses), chat, notes. Deity chants sheet (handle-only drag). Mini player, progress sync. |
| 6 | **Chapter & verse gating** | **Chapters:** Unlock only after previous chapter completed. **Verses:** Can’t open next verse until current marked read; swipe-to-lock reverted + SnackBar. **Next Chapter** button disabled until chapter completed. |
| 7 | **Premium** | `PremiumService` (SharedPreferences). Premium = all chapters & verses unlocked; Next Chapter always enabled. Book detail + Books modal + chapter screen respect premium. |
| 8 | **Verse of the day** | Verse full-screen (Obsidian Gold style), optional Devanagari + daily insight. Model + GPT JSON wiring. Draggable verse card (handle vs content scroll). |
| 9 | **Profile (Self)** | Profile screen, bookmarks, language & notification settings. |
|10 | **Data & config** | Supabase (verses, translations, progress, affirmations, daily verse, books). Local progress fallback. GPT verse-of-the-day when key set. Docs: DATA_FETCH_FLOW, DATA_SETUP_AND_FETCH_FLOW. |

---

## 🔲 REMAINING (MVP to finish)

| # | Item | Notes |
|---|------|--------|
| 1 | **Auth** | Sign-in (e.g. Google) so progress syncs to Supabase; optional account screen. |
| 2 | **Premium purchase** | IAP or paywall that calls `PremiumService.instance.setPremium(true)` (flag exists; purchase flow TBD). |
| 3 | **Onboarding** | First-launch flow (welcome, permissions, optional tour) if required for MVP. |
| 4 | **Polish & QA** | End-to-end test: non-premium path (ch/verse lock), premium path (all open), progress persistence. Fix any crashes/UI glitches. |
| 5 | **Config checklist** | `.env` (Supabase, GPT), app config keys; document in README. |

---

## Quick reference

- **Unlock rule (non‑premium):** Chapter 0 open → complete it → Chapter 1 open. Inside chapter: verse N open only if verses 0…N−1 read.
- **Premium:** All chapters and verses open; set via `PremiumService.instance.setPremium(true)` (e.g. after IAP).
- **Key docs:** `PROJECT_STATUS_AND_WORKING_FEATURES.md`, `DATA_FETCH_FLOW.md`, `DATA_SETUP_AND_FETCH_FLOW.md`.

---

*MVP roadmap – single page. Last updated to include chapter/verse gating and premium.*
