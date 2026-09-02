# Antar Marg — Current State Overview

*Living reference doc. Last compiled: 2026-08-30, from a direct code/backend audit — not from the older `PROJECT_STATUS_AND_WORKING_FEATURES.md` / `MVP_ROADMAP_ONE_PAGE.md`, which describe a prior app structure and are being retired (see `AM-18`). Intended destination: Confluence, as the parent page for the production-readiness epics tracked in Jira (`AM-1` … `AM-18`, see `docs/JIRA_STORY_BACKLOG.md`).*

---

## 1. What the app is

**Antar Marg** ("The Inner Path" / "Antar मार्ग") is a Hindu/Vedic spiritual-wellness and daily-practice app for iOS, built in Flutter with Supabase as the backend. It combines:

- A gamified daily ritual practice (Ashram)
- A sacred-text library (Granthalaya) with Read and Journey modes; Listen is Coming Soon until recorded audio is uploaded
- Structured multi-phase life journeys (pregnancy/parenting, devotional challenges)
- A customizable animated sanctuary and 3D temple (Aangan)
- A RevenueCat-powered subscription paywall and an in-app coin economy

Bundle ID: `com.antarmarg.app` · Current version: `1.0.0+12` · Target platform: iOS (Android exists only as an unconfigured Flutter template — not a real release target today).

> **Product change (2026-08-30):** The AI Guru chat tab was removed entirely. There is no live OpenAI integration in the client; `GPT_API_KEY` is not bundled in release builds.

## 2. Tech stack

| Layer | Choice |
|---|---|
| Client | Flutter (Dart), Riverpod for state management |
| Backend | Supabase — Postgres, Auth, Row Level Security, Storage |
| Auth | Google Sign-In, Sign in with Apple |
| Payments | RevenueCat (subscriptions: monthly / annual / lifetime, single "Antar marg Pro" entitlement today) |
| Push | Firebase Cloud Messaging + `flutter_local_notifications` |
| 3D | A bundled `.glb` temple model rendered via `webview_flutter` against a local asset server |
| Local storage | `sqflite`, `shared_preferences` |
| Localization | Hindi + Hinglish. Onboarding toggle writes `language_code` (AM-54). Functional UI switches; Read/scripture may show both (AM-58). |

## 3. Navigation — the 4 tabs (current, verified in code)

1. **Aangan** (home) — animated Om sanctuary ("Aatma": customizable rings/glow/particles/lotus via a coin shop) and a 3D Mandir (temple) WebView.
2. **Ashram** — daily practice hub: today's tasks, custom habits, daily story/verse, karma points, Panchang (Hindu calendar).
3. **Granthalaya** (library) — v1 is two working modes: **Read** (texts/stories/deities) and **Journey** (multi-phase life-stage programs). **Listen** remains visible as a Coming Soon state until chant/narration audio is recorded and uploaded (fast-follow; audio screens stay in the repo).
4. **Profile** — streak/level/XP, achievements, bookmarks, subscription management, settings.

> Older docs describe a 5-tab set with Prayer or AI Guru — those tabs no longer exist in the code.

## 4. Feature modules

| Module | Status | Notes |
|---|---|---|
| Auth, onboarding, navigation, splash | Live | Google/Apple sign-in, first-launch flow |
| Ashram (daily practice) | Live | Supabase-backed daily verse, affirmations, achievements |
| Sanctuary / Aangan 3D | Live | `temple.glb` via WebView + local asset server; coin-based customization shop |
| Books / Granthalaya | Live | Library, sequential chapter/verse unlock, 12 deities (bundled art + catalog in sync). Listen is Coming Soon (AM-40). Resource Library + Deep Dive cards are parked (AM-44) until destination screens exist. |
| Journey engine (generic) | Live | Catalog is free to browse. Per-journey `is_premium` gate (AM-8 / AM-41): free journeys (e.g. Navratri, Shravan Maas, Kartik Maas, Little Sadhu, Pitru Paksha) open for all; others require Pro. |
| Subscription / paywall | Live | RevenueCat integration; release-mode key safety enforced |
| Profile | Live | Dev-only tools properly gated behind `kDebugMode` |
| **AI Guru / chat** | **Removed** | Feature cut; schema drop in migration `20240101000043` |
| **content** GPT module | **Removed** | `gpt_api_service.dart` deleted; daily verse uses Ashram repository + Supabase |
| Standalone **garbh_sanskar** screens | Dead — removed | Superseded by the generic journey engine |
| Quests, Gamification, Shop, Stats | Orphaned — pending product decision (`AM-14`) | Fully built, zero navigation entry point |

## 5. Data model highlights (Supabase)

Schema history lives in `supabase/migrations/` plus legacy root-level `SUPABASE_*.sql` files (being reconciled — `AM-2`, `AM-6`). Key entities:

- **Content:** `books`, `chapters`, `verses`, `verse_translations`, `deities`, `chants`, `prayers`, `story_pages` — public-read; permissive write policies being locked down (`AM-4`).
- **Parked Read-home cards (AM-44):** Resource Library and Deep Dive widgets (including empty `onTap` handlers) are removed from `BooksLibraryScreen`. `granthalaya_resource_cards` / `granthalaya_deep_dive` rows and `resourceCardsProvider` / `deepDiveProvider` remain for when destination screens exist. `DeepDiveModel` still has no article body — only title, quote, and duration.
- **Journeys:** `journey_types`, `journey_phases`, `journey_tasks`, `garbh_sanskar_content`, plus per-user progress tables.
- **Gamification/streaks:** `user_daily_streak`, `daily_task_templates`.
- **Push:** `push_tokens` (missing tracked migration — `AM-2`).

AI Guru tables (`spiritual_chat_*`, `user_guru_ai_weekly`, etc.) are dropped by migration `20240101000043`.

## 6. Monetization model

**Single paid tier ("Antar marg Pro") via RevenueCat**, monthly/annual/lifetime, plus an in-app coin economy for cosmetic sanctuary customization.

**Freemium shape (current product):**

| Free | Pro |
|---|---|
| Full Ashram daily loop (tasks, habits, streaks, karma) | Everything in Free |
| Aangan sanctuary + coin shop (limited free decor count) | Exclusive sanctuary customizations, advanced practices |
| Sequential book/chapter unlock | Premium books & stories, skip-ahead chapters |
| Journey catalog + free journeys (5 of 20) | Premium journeys |
| Limited custom habits | AI Commentary on every verse (static pre-generated text in Supabase) |

There is **no metered AI chat** and **no OpenAI cost center** in the shipped app. Pro value is Granthalaya depth, premium journeys, sanctuary cosmetics, and static verse commentary — not live consultations. Full Listen audio is a fast-follow after content is recorded, not a launch Pro entitlement.

**Known gaps still tracked:** storage RLS audit (`AM-5`); schema reconciliation (`AM-2`). Journey per-item gates (`AM-8`) and Journey tab free-tier access (`AM-41`) are in the client.

## 7. Language / localization

**Onboarding → app setting (AM-54).** The Hindi/English toggle on `SpiritualOnboardingScreen` calls `languageProvider.setLanguage('hi'|'en')`, which writes SharedPreferences `language_code`. Onboarding defaults to Hindi; that default is persisted even if the user never taps the toggle, so a new user's first session matches the language they saw at first launch.

**Two-tier copy rule (AM-58).** This is intentional, not an inconsistency to "fix":

- **Functional UI** (setup flows, journey chrome, navigation, settings) **switches** to one language from `languageProvider`. Hindi DB fields are nullable — always fall back to English via `localized` / `localizedLang` (`docs/LOCALIZATION.md`).
- **Read / scripture surfaces** (deity names/mantras, Gita verse bodies and commentary) may **show both** languages. Seeing Devanagari alongside a translation is normal for religious texts. Catalog cards switch via `localized`; do not collapse verse/deity body stacks.

**Parked — setup questions (AM-57).** Extending `setup_schema` with `label_hindi` on every question/option, backfilling Garbh Sanskar, Garbh Taiyari, Navjaat Sannidhi, and Little Sadhu, then wiring `journey_setup_screen.dart` question copy is a separate content+schema phase. AM-56 only localized JourneyType title/subtitle/description intro copy.

## 8. Release status

iOS signing, entitlements, app icons, and the build script are in good shape. The one live blocker is a missing `ios/Runner/GoogleService-Info.plist` (`AM-1`). Full detail in the "Antar Marg Readiness" report and the linked Jira epics.

## 9. Related documents

- **Jira backlog (source):** `docs/JIRA_STORY_BACKLOG.md` — 18 stories across 6 epics.
- **Tab reference:** `docs/APP_TABS_DESCRIPTION.md` — 4-tab layout + free/Pro table.
- **Color system:** `docs/COLOR_SYSTEM.md` — AM-50 canonical tokens + screen migration checklist.
- **Typography:** `docs/TYPOGRAPHY.md` — AM-51 four-role house rule.
- **Localization:** `docs/LOCALIZATION.md` — AM-60 `localized` helper, AM-58 two-tier copy, AM-64 product calls.
- **AI Guru removal:** `docs/AI_GURU_REMOVAL_SPEC.md` — superseded AM-7/10/12.
- **iOS release checklists:** `docs/APP_STORE_PRODUCTION.md`, `docs/TESTFLIGHT_DEPLOY.md`.
- **RevenueCat setup:** `docs/REVENUECAT_TEST_STORE.md`.
