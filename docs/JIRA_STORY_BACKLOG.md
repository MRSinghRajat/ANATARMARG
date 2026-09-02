# Antar Marg — Production Readiness Backlog

Source: `docs/PROJECT_STATUS_AND_WORKING_FEATURES.md` is stale — this backlog is derived from a live code/backend/monetization audit on 2026-08-29 (see the published "Antar Marg Readiness" artifact for the narrative version). Each story below is written to be picked up cold by a human or an AI coding agent with no other context, and stories within an epic are written to touch disjoint files so multiple agents can run in parallel without merge conflicts — cross-epic conflicts are called out explicitly where they exist.

**Conventions used below**
- `Priority`: P0 = blocks submission/revenue integrity, P1 = fix soon, P2 = later.
- `Parallel-safe with`: which other story IDs can run at the same time without file conflicts.
- `Requires human action`: something only the developer can do (console access, credentials) — an agent should stop and hand this back rather than guess.

---

## EPIC A — iOS Release Blockers

### AM-1 · Restore Firebase iOS config
**Priority:** P0 · **Labels:** ios, blocker · **Parallel-safe with:** everything (touches only `ios/Runner/` and one new script)

**Context:** `ios/Runner.xcodeproj/project.pbxproj` (lines ~60, 124, 270) references `GoogleService-Info.plist` as a build resource, and `lib/main.dart:81` plus `lib/core/services/push_notification_service.dart:14` call `Firebase.initializeApp()` unconditionally. The file does not exist in `ios/Runner/`. Archive will fail, or the app will crash on first launch if the build somehow completes.

**Requires human action:** Download the real `GoogleService-Info.plist` for bundle ID `com.antarmarg.app` from the Firebase console (or from whoever set up the Firebase project) and place it at `ios/Runner/GoogleService-Info.plist`.

**Acceptance criteria:**
- [ ] `ios/Runner/GoogleService-Info.plist` exists, its `BUNDLE_ID` value matches `com.antarmarg.app`, and it is a real (non-placeholder) config.
- [ ] A preflight check script (`scripts/check_ios_release_config.sh`) exists that fails loudly with a clear message if the file is missing or its bundle ID doesn't match, and is invoked at the top of `scripts/build_testflight.sh` before `flutter build ipa` runs.
- [ ] `flutter build ipa` (or Xcode Archive) completes without a missing-resource error.

**Verification:** Run `scripts/build_testflight.sh` end to end on a machine with valid signing; confirm no Firebase-related crash on a simulator/device launch (watch `flutter logs` for `[core/no-app]` or similar Firebase init errors).

---

## EPIC B — Supabase Schema Integrity

### AM-2 · Recover missing production-table migrations
**Priority:** P0 · **Labels:** backend, supabase, blocker · **Parallel-safe with:** AM-3, AM-5 (touches new migration files only, no overlap) · **Conflicts with:** none, but should land before AM-4/AM-6 since they assume these tables exist

**Context:** `sacred_stories`, `sacred_texts`, `daily_task_templates`, `push_tokens`, `user_journeys`, and `user_daily_tasks` are referenced/altered by tracked migrations (e.g. `supabase/migrations/20240101000019_story_pages.sql` references `sacred_stories(id)`; `SUPABASE_MANIFESTATION_TASK.sql` inserts into `daily_task_templates`; `SUPABASE_PUSH_TOKENS.sql` creates `push_tokens` outside the tracked migrations folder entirely) but none has a `CREATE TABLE` anywhere in `supabase/migrations/`. A fresh environment built from migrations alone cannot reproduce production.

**Requires human action first:** Run `supabase link --project-ref qyikatemonzykqamtvod` (confirm this is actually the production ref before linking — cross-check against the app's `.env` `SUPABASE_URL`) then `supabase db pull` to diff live schema against tracked migrations. An agent can execute this step if given `SUPABASE_ACCESS_TOKEN`/DB credentials, but must **stop and report the diff for review before writing any new migration** — do not silently apply anything to production.

**Acceptance criteria:**
- [ ] `supabase db pull` output (or an equivalent manual schema dump) is captured and reviewed.
- [ ] New numbered migrations (e.g. `20240101000041_recover_sacred_stories.sql` etc.) are added to `supabase/migrations/` that `CREATE TABLE IF NOT EXISTS` for each of the six tables, matching the live schema exactly (columns, types, defaults, foreign keys).
- [ ] Each new migration also brings over the correct RLS policy for that table (cross-reference `SUPABASE_ALLOW_SACRED_STORIES_INSERT.sql`, `SUPABASE_FIX_SACRED_STORIES_SELECT.sql`, `SUPABASE_ALLOW_SACRED_TEXTS_SEED.sql`, `SUPABASE_SEED_SACRED_TEXTS.sql`, `SUPABASE_PUSH_TOKENS.sql` as reference material — see AM-4 for what "correct" RLS means here, don't just copy the old permissive policies forward uncritically).
- [ ] Running the full `supabase/migrations/` folder against a brand-new empty Supabase project succeeds end to end with no errors.

**Verification:** `supabase db reset` (or a scratch project) + replay all migrations top-to-bottom; confirm the resulting schema matches `supabase db pull` output from production.

---

### AM-3 · Fix migrations that fail on a clean run
**Priority:** P0 · **Labels:** backend, supabase, blocker · **Parallel-safe with:** AM-2, AM-4, AM-5

**Context:** Two concrete syntax/ordering bugs will break a fresh migration replay:
1. `supabase/migrations/20240101000020_garbh_sanskar_planning_mode.sql:10` uses `CREATE POLICY IF NOT EXISTS ...` — not valid PostgreSQL syntax (`CREATE POLICY` has no `IF NOT EXISTS` clause).
2. `supabase/migrations/20240101000035_journey_milestones_is_required.sql` does `ALTER TABLE public.journey_milestones ADD COLUMN ...` but the table is only created later, in `supabase/migrations/20240101000036_journey_schema_completeness.sql`. The migration's own comment admits "Migration 35 assumes this table exists."

**Acceptance criteria:**
- [ ] `20240101000020_garbh_sanskar_planning_mode.sql` is rewritten to the correct idempotent pattern: `DROP POLICY IF EXISTS "<name>" ON <table>; CREATE POLICY "<name>" ON <table> ...` (or wrap in a `DO $$ ... $$` block checking `pg_policies`).
- [ ] Either reorder migration 35 to run after 36 (rename/renumber so the sequence is correct), or move the `CREATE TABLE IF NOT EXISTS journey_milestones` block from 36 into 35 (whichever preserves the existing production migration history best — check which one has actually run in prod before deciding, since renumbering an already-applied migration is a bigger deal than moving a CREATE TABLE earlier).
- [ ] Fresh `supabase db reset` replay of the full migrations folder no longer errors on either file.

**Verification:** Same as AM-2 — full replay on an empty database.

---

### AM-4 · Lock down public-write RLS policies
**Priority:** P0 · **Labels:** backend, supabase, security, blocker · **Parallel-safe with:** AM-2, AM-3, AM-5

**Context:** Several tables carry "temporary seed" write policies that were never revoked:
- `verses`, `verse_translations` — `supabase/migrations/20240101000009_allow_seed.sql` created permanent `FOR INSERT WITH CHECK (true)` / `FOR UPDATE USING (true)` policies "for one-time seeding," with a comment suggesting they be dropped afterward. They weren't.
- `story_pages` — `supabase/migrations/20240101000019_story_pages.sql` has the same `(true)` insert/update policies, never revoked.
- `prayers` — `supabase/migrations/20240101000006_prayers_schema.sql` comment claims "admin only in production," but the actual policy is `WITH CHECK (auth.role() = 'authenticated')` — any logged-in user, not an admin.
- `parvas`, `quest_stages` — created in `supabase/migrations/20240101000000_tables.sql`, RLS is **never enabled** at all.

Anyone holding the app's anon key (bundled in the client, also hardcoded in ~25 scripts under `scripts/`) can currently insert/overwrite Gita verse content, story pages, and prayers, and write directly to `parvas`/`quest_stages`.

**Acceptance criteria:**
- [ ] New migration drops the `(true)` insert/update policies on `verses`, `verse_translations`, `story_pages` and replaces writes with service-role-only (i.e., no policy for `authenticated`/`anon` roles at all — writes go through the service role key from trusted scripts/admin tooling only).
- [ ] `prayers` insert/update policy is changed from `auth.role() = 'authenticated'` to a real admin check (e.g. a `is_admin` claim/column, or service-role-only if there's no admin concept yet — confirm which with the developer if ambiguous, don't invent a role system that doesn't exist elsewhere in the schema).
- [ ] RLS is enabled on `parvas` and `quest_stages`, with a public-`SELECT`-only policy matching the pattern already used correctly on `books`/`deities`/`chapters` (`USING (true)` for select, no insert/update/delete policy for `anon`/`authenticated`).
- [ ] Confirm no legitimate app flow (check `lib/` for any client-side insert/update calls to these tables) depends on the removed permissive policies — the app should only ever read these tables, never write them, from the client.

**Verification:** After applying, attempt an insert into `verses` and `parvas` using only the anon key (e.g. via `curl` against the PostgREST endpoint or the Supabase JS/Dart client with anon key) and confirm it's rejected with a permissions error. Confirm the app still reads these tables fine.

---

### AM-5 · Verify and fix Storage RLS
**Priority:** P0 · **Labels:** backend, supabase, security, blocker · **Parallel-safe with:** AM-2, AM-3, AM-4 · **Requires human action:** confirming live bucket state before writing the fix, since this touches `storage.objects` directly

**Context:** `scripts/disable_storage_rls.sql` does `ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY` — a global, all-buckets disable — with no companion script re-enabling it anywhere in the repo. `scripts/fix_storage_rls.sql` exists as a narrower alternative (public insert/update/select scoped to the `sacred-stories` bucket only) but it's unclear from the repo alone which one was actually run against production last.

**Acceptance criteria:**
- [ ] Query the live project directly (`select * from pg_policies where tablename = 'objects' and schemaname = 'storage';` and check `pg_class.relrowsecurity` for `storage.objects`) to determine current state — report findings before changing anything.
- [ ] If RLS is currently disabled project-wide on Storage: re-enable it, then add bucket-scoped policies matching `scripts/fix_storage_rls.sql`'s pattern (public read where appropriate, e.g. audio/image buckets meant to be public; owner-scoped write for any user-upload buckets like avatars).
- [ ] Delete or clearly mark `scripts/disable_storage_rls.sql` as historical/do-not-run — it should not be runnable again by accident.
- [ ] Document the final intended policy per bucket in a comment at the top of whichever script becomes the source of truth.

**Verification:** Attempt an anonymous write to a bucket that should be read-only, confirm rejection; confirm legitimate app reads (chant audio, deity images, sacred story images) still work.

---

### AM-6 · Archive redundant SQL files and consolidate migration folders
**Priority:** P1 · **Labels:** backend, supabase, tech-debt, cleanup · **Parallel-safe with:** everything except AM-2 (run after AM-2 lands, so nothing gets archived before its content is confirmed captured)

**Context:** 13 of the 20 root-level `SUPABASE_*.sql` files are byte-identical to a migration already in `supabase/migrations/` (`SUPABASE_TABLES_SQL.sql`, `SUPABASE_BOOKS_SCHEMA.sql`, `SUPABASE_AANGAN_SCHEMA.sql`, `SUPABASE_AVATARS_SCHEMA.sql`, `SUPABASE_DEITIES_SCHEMA.sql`, `SUPABASE_GRANTHALAYA_SCHEMA.sql`, `SUPABASE_PRAYERS_SCHEMA.sql`, `SUPABASE_USER_NOTES.sql`, `SUPABASE_FIX_RLS.sql`, `SUPABASE_ALLOW_SEED_INSERT.sql`, `SUPABASE_GITA_DATA.sql`, `SUPABASE_GITA_TRANSLATIONS.sql`, `SUPABASE_VERIFY_DATA.sql`). There's also a stray `supabase_migrations/` folder (singular, different from `supabase/migrations/`) containing one file the Supabase CLI never reads: `supabase_migrations/add_is_premium_to_books_and_stories.sql`.

**Acceptance criteria:**
- [ ] The 13 confirmed-duplicate root SQL files are moved to a new `archive/legacy-sql/` folder (not deleted outright — keep history) with a short `archive/legacy-sql/README.md` explaining they're superseded by `supabase/migrations/`.
- [ ] `supabase_migrations/add_is_premium_to_books_and_stories.sql` is folded into a properly numbered file in `supabase/migrations/` (only after confirming, per AM-2, that `sacred_stories` now has a real migration source to alter).
- [ ] The stray `supabase_migrations/` folder is removed once empty.
- [ ] `SUPABASE_CHANTS_SCHEMA.sql` (the one file that differs from its migration counterpart — it has a seed `INSERT` for a "Shiva Chant" row that `20240101000013_chants_schema.sql` dropped) is reviewed: either add that seed row to a migration if it's still wanted in prod, or archive with a note that it was intentionally dropped.

**Verification:** `git status`/repo root no longer has loose `SUPABASE_*.sql` clutter; `supabase/migrations/` is the single source of truth.

---

## EPIC C — Monetization Security (highest business priority)

> **Superseded for AM-7, AM-10, AM-12, and the AI-Guru portion of AM-16:** AI Guru feature removed entirely — see `docs/AI_GURU_REMOVAL_SPEC.md`. AM-8 journey premium gates remain in place.

### AM-7 · Close the AI Guru credit self-grant bypass
**Priority:** P0 · **Labels:** security, monetization, backend, critical · **Parallel-safe with:** AM-8, AM-9, AM-10 (different files) · **Blocks:** AM-14 (tests depend on this being fixed first)

**Context:** `supabase/migrations/20240101000034_guru_ai_weekly_credits.sql` (lines ~27-211) defines `sync_guru_ai_tier_to_profile(p_tier)`, `grant_guru_ai_purchased_credits(p_amount)`, and `consume_guru_ai_credit()` as `SECURITY DEFINER` functions `GRANT`ed to the `authenticated` role, with no check against an actual RevenueCat entitlement/receipt. Any authenticated user can call `supabase.rpc('sync_guru_ai_tier_to_profile', {p_tier: 'pro'})` directly (Postman, curl, a patched client) and grant themselves Pro-tier weekly AI credits, or call `grant_guru_ai_purchased_credits` for free top-up packs — bypassing RevenueCat and payment entirely. This is the single highest-impact fix in the whole backlog: it's a live, working way to get the paid product for free.

**Design approach (pick one, document the choice):**
- **Option A (recommended, matches how RevenueCat is meant to be used server-side):** Stand up a Supabase Edge Function that receives RevenueCat webhook events (`INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `EXPIRATION`, etc.), verifies the webhook signature/auth header RevenueCat sends, and is the *only* caller allowed to invoke `sync_guru_ai_tier_to_profile`/`grant_guru_ai_purchased_credits` (call them with the service role key from the Edge Function, and revoke the `authenticated` grant on those two functions in Postgres so the client literally cannot call them anymore).
- **Option B (faster, weaker):** Keep client-callable but require the client to pass a RevenueCat receipt/transaction id, and have the RPC verify it server-side via RevenueCat's REST API (`GET /subscribers/{app_user_id}`) before applying the tier change.

**Acceptance criteria:**
- [ ] `REVOKE EXECUTE ON FUNCTION sync_guru_ai_tier_to_profile, grant_guru_ai_purchased_credits FROM authenticated;` (or equivalent) — these are no longer directly callable by any logged-in user.
- [ ] A Supabase Edge Function (or the receipt-verification RPC variant) exists that performs the actual tier/credit grant only after confirming the entitlement really exists in RevenueCat.
- [ ] `consume_guru_ai_credit()` remains callable by `authenticated` (that's the legitimate per-message spend, fine as-is) but is reviewed to confirm it can't be abused to go negative or bypass the weekly cap.
- [ ] `lib/features/ai_guru/services/guru_ai_credits_service.dart` and `lib/features/chat/presentation/screens/spiritual_chat_screen.dart` (lines ~87, ~399, where `syncTierToProgile`/similar is called) are updated to call the new secured path instead of the raw RPC, if the call signature changes.
- [ ] Manual test: attempt to call `sync_guru_ai_tier_to_profile('pro')` directly via the Supabase client with only an authenticated user's JWT (no purchase made) — must fail.

**Verification:** Scripted test hitting the RPC directly with a free-tier test account's JWT and no RevenueCat purchase; confirm rejection. Then confirm a real (sandbox) RevenueCat purchase still results in the correct tier being applied end to end.

---

### AM-8 · Add premium checks inside the journey screens themselves
**Priority:** P0 · **Labels:** security, monetization, flutter, critical · **Parallel-safe with:** AM-7, AM-9, AM-10

**Context:** `lib/features/journey/presentation/screens/journey_home_screen.dart`, `journey_setup_screen.dart`, `journey_task_detail_screen.dart`, and `journey_milestone_detail_screen.dart` contain **no** premium/`isPremium` check anywhere (confirmed via grep — zero matches). Gating currently exists only at *some* entry points: `lib/features/books/presentation/screens/books_library_screen.dart:143-148` (`_tryOpenJourneySetup`) correctly checks `t.isPremium && !_isPremium` before navigating, but `lib/features/ai_guru/services/guru_link_navigation.dart:11-28` pushes the same routes directly with no check at all. A free user who receives a journey deep-link from an AI Guru chat reply can start/progress a Pro journey (e.g. a `required_plan: 'pro'` Garbh Sanskar milestone) for free.

**Acceptance criteria:**
- [ ] `journey_home_screen.dart`, `journey_setup_screen.dart`, `journey_task_detail_screen.dart`, and `journey_milestone_detail_screen.dart` each check the relevant `JourneyType.isPremium`/`requiredPlan` (or `JourneyTask.isPremium`) against the current user's premium/tier status at entry (`initState`/build guard), and redirect to the paywall (reuse the existing paywall screen/route) if the user doesn't qualify — matching the pattern already used correctly in `books_library_screen.dart:143-148`.
- [ ] `guru_link_navigation.dart` no longer needs its own check (defense-in-depth means the destination screen is now safe regardless of entry point), but add one there too for a fast, friendly redirect instead of letting the user navigate in and immediately bounce back out.
- [ ] Existing entry points (`books_library_screen.dart`) keep working exactly as before for non-premium users — this is additive, not a behavior change for the already-correct path.

**Verification:** As a free-tier test account, tap a premium journey link from an AI Guru chat reply; confirm it now redirects to the paywall instead of opening the journey.

---

### AM-9 · Guard `PREMIUM_GRANT_ALL` against release builds
**Priority:** P0 · **Labels:** security, monetization, flutter, quick-fix · **Parallel-safe with:** AM-7, AM-8, AM-10

**Context:** `lib/core/config/app_config.dart:43-48` reads `PREMIUM_GRANT_ALL` straight from the bundled `.env` at runtime with no `kReleaseMode`/`kDebugMode` check. `.env` ships as a release asset (`pubspec.yaml` → `assets: - .env`). If this flag is ever left `true` in the `.env` used for a release build (e.g. after a beta test), every user gets Pro for free with nothing in the code stopping it.

**Acceptance criteria:**
- [ ] `app_config.dart`'s `premiumGrantAll` getter is changed to `return !kReleaseMode && (dotenv.env['PREMIUM_GRANT_ALL']?.toLowerCase() == 'true');` (or equivalent) so it is hard-`false` in any release build regardless of `.env` contents.
- [ ] Add a one-line comment explaining why (so a future edit doesn't "simplify" it back out).
- [ ] Confirm existing debug/beta workflows that rely on this flag still work in debug/profile builds.

**Verification:** Build in release mode with `PREMIUM_GRANT_ALL=true` in `.env` and confirm `AppConfig.premiumGrantAll` evaluates `false` (e.g. via a quick print/test in a release-mode smoke test, or a unit test that mocks `kReleaseMode`... note Flutter's `kReleaseMode` isn't mockable directly, so this may need a wrapper — see AM-14 for the broader test-coverage story).

---

### AM-10 · Move OpenAI calls behind a Supabase Edge Function
**Priority:** P0 · **Labels:** security, monetization, backend, cost-risk · **Parallel-safe with:** AM-7, AM-8, AM-9 (different files; coordinate only if AM-7's Edge Function work wants to share infra/deployment setup)

**Context:** `GPT_API_KEY` is loaded client-side via `dotenv.env['GPT_API_KEY']` (`lib/core/config/app_config.dart:17-18`) and the app calls `api.openai.com` directly from `lib/features/ai_guru/services/guru_api_service.dart:103-161` and `lib/features/content/data/datasources/gpt_api_service.dart:347-367`. Because `.env` ships inside the release IPA as a bundled asset, the key is extractable from the shipped binary — anyone who pulls it can spend against the developer's OpenAI account with zero relationship to the app's credit system.

**Acceptance criteria:**
- [ ] A new Supabase Edge Function (e.g. `guru-chat`) accepts the chat request payload, holds `GPT_API_KEY` as an Edge Function secret (never shipped to the client), calls OpenAI server-side, and returns the response.
- [ ] The Edge Function checks/consumes the user's AI Guru credit (via `consume_guru_ai_credit()`, see AM-7) as part of the same request — so credit-spend and the actual API call happen atomically server-side, closing another potential race/bypass.
- [ ] `guru_api_service.dart` is updated to call the new Edge Function instead of `api.openai.com` directly.
- [ ] `GPT_API_KEY` is removed from `.env`/`.env.example` and from anything bundled into the client; it lives only as a Supabase secret from this point on.
- [ ] Note for a follow-up story (not required here): `lib/features/content/data/datasources/gpt_api_service.dart` is part of the dead `content` module (see AM-11) — if AM-11 removes that module first, this file's direct-OpenAI-call problem disappears with it; don't duplicate effort.

**Verification:** Confirm chat still works end to end through the Edge Function; confirm `GPT_API_KEY` no longer appears anywhere in a built IPA (`strings` the binary or inspect the bundled `.env` asset post-build).

---

## EPIC D — Dead Code & Orphaned Module Cleanup

> **Before starting any story in this epic:** re-run the greps described below yourself — this backlog was written from two separate audit passes that disagreed slightly on `ai_guru`. Trust a fresh grep on the current tree over this document if they conflict.

### AM-11 · Remove the dead `content` (verse-of-day) module
**Priority:** P1 · **Labels:** tech-debt, cleanup, flutter · **Parallel-safe with:** AM-12, AM-13, AM-14, AM-15, AM-16

**Context:** `lib/features/content/data/repositories/verse_of_day_repository.dart:29-49` never calls Supabase or GPT — it returns one hardcoded fallback verse every day. The real, live verse-of-the-day path is `lib/features/ashram/data/repositories/ashram_daily_verse_repository.dart`. `lib/features/content/data/datasources/gpt_api_service.dart` (including its `getVerseOfTheDay()` at line 265) has no callers outside its own file.

**Acceptance criteria:**
- [ ] `grep -r "features/content" lib/` (and check `verse_full_screen.dart` specifically, since the app-status doc mentions it as the "Obsidian Gold" verse display) — confirm what, if anything, outside `lib/features/content/` imports from it. If `verse_full_screen.dart` is still used elsewhere for its UI style, keep that one file (or extract the widget) and delete the rest.
- [ ] Delete `lib/features/content/data/repositories/verse_of_day_repository.dart` and `lib/features/content/data/datasources/gpt_api_service.dart` once confirmed unreferenced.
- [ ] `AppConfig.splashGifPath` (`lib/core/config/app_config.dart:12`) is also removed — it's an unused constant pointing at a non-existent asset (`assets/animations/splash.gif`).
- [ ] `flutter analyze` and a full app smoke run (`flutter test` + manual launch) show no broken imports.

**Verification:** App builds and runs; verse-of-the-day still shows correctly via the Ashram path.

---

### AM-12 · Reconcile and clean up the `ai_guru` module — do not delete blindly
**Priority:** P1 · **Labels:** tech-debt, cleanup, flutter, needs-verification · **Parallel-safe with:** AM-11, AM-13, AM-14, AM-15, AM-16 · **⚠️ Depends on:** re-verification before any deletion — see below

**Context — the discrepancy to resolve first:** One audit pass reported the entire `lib/features/ai_guru/` tree (config/, constants/, models/, repositories/, presentation/providers/ — ~1,235 lines) as having zero imports from outside itself. A separate audit pass, while tracing the monetization/paywall logic, found `lib/features/ai_guru/services/guru_api_service.dart`, `lib/features/ai_guru/services/guru_ai_credits_service.dart`, `lib/features/ai_guru/services/guru_link_navigation.dart`, and `lib/features/ai_guru/services/guru_user_tier.dart` **actively called from** `lib/features/chat/presentation/screens/spiritual_chat_screen.dart` (lines ~87, ~399) — i.e. these specific files back the real, live AI Guru chat tab.

**Acceptance criteria:**
- [ ] Run a fresh, careful grep (`grep -rn "package:antarmarg/features/ai_guru" lib/` or equivalent relative-import search) against the current tree and produce a definitive list of which files under `lib/features/ai_guru/` have zero external references and which don't.
- [ ] **Do not delete** `services/guru_api_service.dart`, `services/guru_ai_credits_service.dart`, `services/guru_link_navigation.dart`, or `services/guru_user_tier.dart` unless the fresh grep genuinely shows them unreferenced — these likely back live functionality.
- [ ] Delete only the subfolders/files the fresh grep confirms are truly dead (candidates: `config/`, `constants/`, `models/`, `repositories/`, `presentation/providers/` — verify each individually, don't batch-assume).
- [ ] If the `chat` module and the surviving `ai_guru/services/*` files represent a confusing split (one feature's logic spread across two feature folders), leave a short comment or a follow-up note rather than restructuring as part of this cleanup story — restructuring is out of scope here.

**Verification:** App builds; AI Guru chat tab still fully functional (send a message, confirm credit deduction, confirm chat link navigation still works).

---

### AM-13 · Remove the dead standalone `garbh_sanskar` screens and routes
**Priority:** P1 · **Labels:** tech-debt, cleanup, flutter · **Parallel-safe with:** AM-11, AM-12, AM-14, AM-15, AM-16

**Context:** `GarbhSanskarSetupScreen`, `GarbhSanskarHomeScreen`, and 3 other screens under `lib/features/garbh_sanskar/` (~5,406 lines total) have router entries in `lib/core/utils/app_router.dart:146-151` (routes `/garbh-sanskar-setup`, `/garbh-sanskar-home`) but **no caller anywhere** pushes those named routes. The live Garbh Sanskar path goes entirely through the generic journey engine (`lib/features/journey/`), entered via `books_library_screen.dart:181` with a `slug` argument, resolved by `journey_repository.dart:549-586` against the `garbh_sanskar_content`/`garbh_sanskar_samskaras` tables.

**Acceptance criteria:**
- [ ] Confirm via grep that `AppRouter.garbhSanskarSetup`/`AppRouter.garbhSanskarHome` are never referenced in a `Navigator.pushNamed` call anywhere in `lib/`.
- [ ] Delete the two route entries from `app_router.dart:146-151`.
- [ ] Delete the entire `lib/features/garbh_sanskar/` presentation layer (screens) confirmed unreferenced; check whether any data-layer files under the same feature folder (models/repositories) are still used by the generic journey engine before deleting those — the journey engine may share models with this folder, don't assume the whole feature directory is dead without checking.
- [ ] `flutter analyze` shows no broken imports.

**Verification:** App builds; the real Garbh Sanskar journey (via Granthalaya → Journey tab) still opens and functions correctly.

---

### AM-14 · Decide the fate of Quests, Gamification, Shop, and Stats
**Priority:** P1 · **Labels:** product-decision, cleanup, flutter · **Parallel-safe with:** AM-11, AM-12, AM-13, AM-15, AM-16 · **Requires human decision:** this story starts with a product call, not just code

**Context:** `lib/features/quests/` (`QuestsScreen`, `ParvaQuestPathScreen`, `ParvaTimelineScreen`, ~1,161 lines), `lib/features/gamification/` (`LeaderboardScreen`, ~287 lines), `lib/features/shop/` (`ShopScreen`, ~624 lines), and `lib/features/stats/` (`StatsScreen`, ~291 lines) are all fully built with real Supabase datasources behind them, but **none are reachable from the app's 5-tab navigation** (`main_navigation_screen.dart:42-46, 294-302`). They also ship visible mock data if ever opened directly (e.g. `quests_screen.dart:29-32` hardcodes `_userName = 'Bala Sadhu'`, `leaderboard_screen.dart:275` hardcodes `rank: 42`).

**This story needs a decision from the developer before code work starts:** (a) wire these into real navigation with real data before launch, (b) ship v1 without them and delete the code, or (c) ship v1 without them but keep the code (git history preserves it either way, so "delete" isn't really destructive — but keeping ~2,300 lines of unreachable code around invites confusion for future contributors/agents).

**Acceptance criteria (assuming decision = remove for v1, the default recommendation):**
- [ ] Confirm via grep that none of `QuestsScreen`, `ParvaQuestPathScreen`, `ParvaTimelineScreen`, `LeaderboardScreen`, `ShopScreen`, `StatsScreen` are referenced from any reachable navigation path.
- [ ] Delete `lib/features/quests/`, `lib/features/gamification/`, `lib/features/shop/`, `lib/features/stats/` presentation layers (screens); check whether the coin/currency data layer (`lib/shared/services/coin_service.dart` and similar) is shared with the sanctuary shop (which IS live — `sanctuary_shop_sheet.dart`) before deleting anything in `lib/shared/`.
- [ ] Delete the corresponding unused datasources (`supabase_quest_stage_datasource.dart`, `supabase_parva_datasource.dart`) only if nothing else reads from `parvas`/`quest_stages` — cross-check against AM-4, which touches RLS on those same tables; if these tables become fully unused after this story, note that back to whoever owns AM-4 so the tables themselves can eventually be dropped too (not required in this story).

**Acceptance criteria (if decision = wire in instead):** out of scope for this backlog — would need its own set of stories with real navigation entries and mock data replaced by live services.

**Verification:** App builds and runs; 5-tab navigation unaffected; no dangling references.

---

### AM-15 · Remove minor dead files
**Priority:** P2 · **Labels:** tech-debt, cleanup, flutter · **Parallel-safe with:** AM-11, AM-12, AM-13, AM-14, AM-16

**Context:** `lib/features/home/presentation/screens/test_ui_screen.dart` (a "3D WebView test UI" screen) has zero references anywhere in the app and duplicates asset-serving logic that the real Aangan 3D temple screen also uses.

**Acceptance criteria:**
- [ ] Confirm zero references via grep.
- [ ] Delete `test_ui_screen.dart`.
- [ ] Sweep for any other single-file dead screens missed by the main audit (a quick `flutter analyze` combined with an unused-file check, e.g. `dart run dart_code_metrics` or manual grep of each screen file's class name across the tree, is enough — this is a small mop-up story, don't scope-creep into a full re-audit).

**Verification:** App builds; no missing-file errors.

---

## EPIC E — Test Coverage & Release Hygiene

### AM-16 · Add automated tests for premium/purchase gating
**Priority:** P1 · **Labels:** testing, monetization, flutter · **Parallel-safe with:** AM-11 through AM-15 · **Should follow:** AM-7, AM-8, AM-9 (test the fixed behavior, not the old bug)

**Context:** There are currently zero automated tests anywhere covering `PremiumService`, RevenueCat entitlement checks, `PREMIUM_GRANT_ALL` behavior, or paywall gating logic — the app's only monetized path is completely untested. `test/` currently has 7 files, none touching this.

**Acceptance criteria:**
- [ ] Unit tests for `PremiumService` covering: premium-true path, premium-false path, and the dev-mode override (`enableDevMode`/`setPremiumOverride`) confirming it only activates in debug builds.
- [ ] A test (or documented manual-QA step, if `kReleaseMode` truly can't be mocked in a unit test — verify this rather than assuming) confirming `AppConfig.premiumGrantAll` resolves `false` when release-mode, per AM-9's fix.
- [ ] Widget/integration test confirming a free-tier user is redirected to the paywall when opening a premium journey (post-AM-8 fix) and a premium-tier user is not.
- [ ] Tests added to `test/` following the existing project structure/conventions (check `test/config_test.dart` and `test/widget_test.dart` for the house style before adding new files).

**Verification:** `flutter test` passes, including the new tests; confirm the new tests actually fail against the pre-fix code (temporarily revert AM-8/AM-9 locally and confirm the new tests catch the regression) before considering this story done.

---

### AM-17 · Release hygiene: debug flags and logging
**Priority:** P1 · **Labels:** tech-debt, ios, flutter · **Parallel-safe with:** AM-11 through AM-16

**Context:** `REVENUECAT_DEBUG_MODE=true` is currently left on in `.env` (verbose RevenueCat SDK logging in the shipped build — not a security issue, just noisy). Separately, a meaningful number of ungated `print()` calls will run in release builds too: `lib/core/repositories/daily_streak_repository.dart:28,71,95`, `lib/core/services/supabase_service.dart:36,80,239`, `lib/features/quests/data/datasources/supabase_quest_stage_datasource.dart:25,53`, `supabase_parva_datasource.dart:24,44,71,102`, `lib/features/ashram/data/repositories/achievement_repository.dart` (6 spots), `spiritual_progress_repository.dart` (5 spots), `lib/features/home/data/services/user_presence_service.dart:30,126`, `lib/features/chat/data/repositories/feeling_repository.dart:31,52`. (Note: several of these files may be deleted entirely by AM-14's quest/stats cleanup — check that epic's outcome first to avoid duplicate work.)

**Acceptance criteria:**
- [ ] `.env` (and `.env.example`) sets/documents `REVENUECAT_DEBUG_MODE=false` as the release default.
- [ ] All listed `print()` calls that survive AM-14's cleanup are converted to `debugPrint()` (which is automatically stripped in release) or wrapped in `if (kDebugMode)`.
- [ ] `.env.example` is also updated to document the keys it's currently missing: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_AUTH_REDIRECT_URL`, `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID` (and remove `GPT_API_KEY` from this list if AM-10 has already moved it server-side by the time this story runs).

**Verification:** `grep -rn "print(" lib/ | grep -v debugPrint` returns nothing outside genuinely-gated `kDebugMode` blocks; a release build produces no console spam under normal use.

---

## EPIC F — Documentation Refresh

### AM-18 · Update stale project docs to match the current app
**Priority:** P1 · **Labels:** docs · **Parallel-safe with:** everything

**Context:** `docs/PROJECT_STATUS_AND_WORKING_FEATURES.md` and `docs/MVP_ROADMAP_ONE_PAGE.md` both describe an old 5-tab layout (Aangan / Prayer / Ashram / Granthalya / Self) and a SharedPreferences-only `PremiumService.instance.setPremium(true)` model. Neither matches the current app (Aangan / AI Guru / Ashram / Granthalaya / Profile tabs; RevenueCat-backed premium).

**Acceptance criteria:**
- [ ] Both docs are rewritten to describe the actual current tab structure, feature set, and premium model — or explicitly marked `ARCHIVED — see docs/CONFLUENCE_APP_OVERVIEW.md` at the top if superseded rather than updated in place.
- [ ] `docs/CONFLUENCE_APP_OVERVIEW.md` (produced alongside this backlog) becomes the canonical current-state reference; cross-link it from these files.

**Verification:** A new contributor (or agent) reading `docs/` gets an accurate picture of the app with no contradictions between files.

---

## Suggested execution order for parallel agents

Round 1 (fully independent, launch together): **AM-1, AM-3, AM-7, AM-8, AM-9, AM-11, AM-15**
Round 2 (after Round 1 lands — some depend on schema/human input from Round 1's investigation steps): **AM-2, AM-4, AM-5, AM-10, AM-12, AM-13**
Round 3 (cleanup/decision-dependent/testing, benefits from Round 1+2 being settled): **AM-6, AM-14, AM-16, AM-17, AM-18**

Total: 18 stories across 6 epics. 8 are P0 (AM-1, 2, 3, 4, 5, 7, 8, 9, 10 — actually 9 P0s, see priority field per story), 6 are P1, 2 are P2, 1 is a product decision (AM-14) that gates its own scope.
