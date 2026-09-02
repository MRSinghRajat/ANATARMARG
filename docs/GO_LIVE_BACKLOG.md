# Antar Marg — Go-Live Backlog (AM-19 onward)

Continues `docs/JIRA_STORY_BACKLOG.md` (AM-1–AM-18, mostly done — see that file's status) and `docs/AI_GURU_REMOVAL_SPEC.md` (done, verified). This backlog covers what's left to reach "production ready, end-to-end" per the Go-Live Plan artifact (compiled 2026-08-30).

**Split into two groups up front, because it matters for how you assign work:**
- **Agent-doable (AM-19–AM-31):** real code/config changes inside the repo. Hand these to your coding agent.
- **Human-only (bottom of this doc):** App Store Connect, RevenueCat dashboard, physical-device testing. No agent can do these — they require your Apple Developer account, a real iPhone, and your own hands.

---

## EPIC G — Observability (net-new gap, not in the original audit)

### AM-19 · Add Firebase Crashlytics
**Priority:** P0 for launch · **Labels:** observability, ios · **Parallel-safe with:** AM-20, AM-23–AM-31

**Context:** Firebase is already integrated (`Firebase.initializeApp()` in `lib/main.dart`, used for push). There is currently zero crash reporting anywhere in the app — confirmed via `grep -rl "crashlytics\|Sentry" pubspec.yaml lib/` returning nothing. If this ships and crashes for a real user, you won't know unless they email you.

**Acceptance criteria:**
- [ ] Add `firebase_crashlytics` to `pubspec.yaml` and run `flutter pub get` / `cd ios && pod install`.
- [ ] Initialize it in `lib/main.dart` alongside the existing Firebase init, with `FlutterError.onError` and `PlatformDispatcher.instance.onError` wired to `FirebaseCrashlytics.instance.recordFlutterFatalError` / `recordError` (standard Flutter+Crashlytics wiring).
- [ ] Disable Crashlytics collection in debug mode (`FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)`), so local dev noise doesn't pollute the dashboard.
- [ ] Force a test crash from a debug build once (a manual `throw` behind a hidden debug button, removed after confirming it appears in the Firebase console) to verify wiring actually works end to end — don't just trust that the SDK is "added."

**Verification:** Trigger a test crash, confirm it appears in the Firebase Crashlytics console within a few minutes.

---

### AM-20 · Add basic funnel analytics
**Priority:** P1 · **Labels:** observability, analytics · **Parallel-safe with:** AM-19, AM-23–AM-31

**Context:** No analytics SDK exists in the app at all (Firebase Analytics, Amplitude, Mixpanel — none). Without this you have no visibility into whether onboarding completes, whether people reach the paywall, or whether purchases actually happen relative to paywall views.

**Acceptance criteria:**
- [ ] Add `firebase_analytics` (same Firebase project already in use, lowest-friction choice).
- [ ] Log at minimum: `onboarding_complete`, `paywall_viewed`, `purchase_completed` (tie to the RevenueCat purchase success callback in `revenuecat_service.dart`/`paywall_screen.dart`), `tab_viewed` (with tab name) from `main_navigation_screen.dart`'s tab-switch handler.
- [ ] Do **not** log any PII (no raw email, no name) — user ID hash or Supabase `auth.uid()` only, consistent with what's already sent to Supabase.
- [ ] Update the App Store Connect Privacy questionnaire to declare analytics usage once this ships (a note for you, not the agent — the agent should just flag this in its completion report).

**Verification:** Confirm events show up in the Firebase Analytics DebugView during a manual test run (`adb`/Xcode console debug analytics mode).

---

## EPIC H — Backend finishing (continues Epic B from the original backlog)

### AM-21 · Finish Supabase project linking + prepare (don't run) the schema-diff tooling
**Priority:** P0 · **Labels:** backend, supabase · **Requires human action:** the actual `db pull` against production and reviewing its output

**Context:** `supabase/config.toml` exists now but has no project ref populated — the checkout is half-linked. This blocks AM-2 (recovering the 6 untracked production tables) from the original backlog.

**Acceptance criteria:**
- [ ] Agent prepares everything short of touching production: confirm the correct project ref by cross-checking `.env`'s `SUPABASE_URL` against `supabase projects list` output, and stage the exact commands needed (`supabase link --project-ref <ref>`, `supabase db pull`).
- [ ] **Stop here and hand back to you** — the agent should not run `db pull` against production and then unilaterally write migrations from it. Report the diff; you (or the agent, once you've reviewed and said go) writes the `CREATE TABLE` migrations for `sacred_stories`, `sacred_texts`, `daily_task_templates`, `push_tokens`, `user_journeys`, `user_daily_tasks` per the original AM-2 spec in `docs/JIRA_STORY_BACKLOG.md`.

---

### AM-22 · Confirm the RLS lockdown migration is actually live, add a repeatable check
**Priority:** P0 · **Labels:** backend, supabase, security

**Context:** `supabase/migrations/20240101000042_lock_down_public_write_rls.sql` exists and is correct, but there's no confirmation it's been pushed to production. "Written" and "deployed" are not the same thing for a security fix.

**Acceptance criteria:**
- [ ] Once AM-21 is linked, run `supabase migration list` to see which migrations show as applied remotely vs. only local.
- [ ] If 042 isn't applied remotely: push it (`supabase db push`), after confirming with you first since this touches production.
- [ ] Add a small verification script (`scripts/verify_rls_lockdown.sh` or similar) that attempts an anon-key insert against `verses` and `parvas` and asserts it's rejected — something you can re-run after any future migration to catch a regression, not just a one-time manual check.

**Status (2026-09-01):** **Done.** 045 applied via SQL (not `db push`). verses + parvas INSERT both HTTP 401 with `row-level security policy`. SELECT verses still 200. See `docs/AM21_PULL_REPORT.md`.

---

### AM-23 · Archive redundant root-level SQL files
**Priority:** P2 · **Labels:** tech-debt, cleanup · **Run after:** AM-21/AM-2 (so nothing is archived before its content is confirmed captured in a real migration)

Same as the original `AM-6` — unchanged, still pending, still low-risk. See `docs/JIRA_STORY_BACKLOG.md` for full detail.

---

## EPIC I — End-to-end robustness

### AM-24 · Sweep onboarding/tour content for AI Guru remnants
**Priority:** P1 · **Labels:** qa, cleanup

**Context:** The AI Guru removal (`docs/AI_GURU_REMOVAL_SPEC.md`) removed all code references, verified via grep and a clean `flutter analyze`/`flutter test`. This story is a lighter *visual* pass, not code archaeology: confirm no leftover copy, image asset, or CTA anywhere (home screen, empty states, notification strings, achievement copy) still alludes to "ask the Guru" or similar, since copy strings are easy for a grep-based removal to miss if worded differently than the exact strings already checked.

**Acceptance criteria:**
- [ ] Grep for "guru" one more time app-wide (case-insensitive) and manually eyeball every hit outside the known-fine religious content (Guru Drona, Guru mantra, Hanuman Chalisa, "gurukul", Panchang's Thursday=Guru/Jupiter references) — the same filter used during the removal.
- [ ] Manually launch the onboarding flow end to end and confirm nothing visually references a 5th tab or an "AI Guru" concept.

---

### AM-25 · Pause the 3D Mandir WebView when backgrounded
**Priority:** P1 · **Labels:** performance, stability

**Context:** `lib/features/home/presentation/screens/aangan_screen.dart` has many `AnimationController`s with proper `dispose()` calls, but **no `WidgetsBindingObserver`/`didChangeAppLifecycleState`** anywhere in the file. Standard Flutter `AnimationController`s tied to a visible route are already paused by the framework's ticker when backgrounded, so those are likely fine — but the embedded `webview_flutter` instance rendering the 3D temple (`temple.glb`) is **not** managed by Flutter's ticker. A WKWebView keeps its own render/JS loop running in the background unless explicitly told to pause, which risks battery drain and, on some iOS versions, being killed and returning in a broken state on resume.

**Acceptance criteria:**
- [ ] Add a `WidgetsBindingObserver` to the Mandir/WebView-owning widget in `aangan_screen.dart`.
- [ ] On `AppLifecycleState.paused`/`inactive`, pause the WebView (e.g. inject a JS call to pause any animation loop in `temple_room.html`/`aangan_3d.html`, or use the platform WebView's own pause capability if `webview_flutter` exposes one at the current pinned version).
- [ ] On `AppLifecycleState.resumed`, resume/reload as needed — test that resuming after a long background period (several minutes) doesn't show a frozen or corrupted 3D scene.

**Verification:** Open the Mandir view, background the app for 2+ minutes, foreground it — scene resumes correctly, and a device battery/energy log (Xcode Instruments, if available) shows no continued GPU activity while backgrounded.

---

### AM-26 · Add test coverage for daily streak rollover
**Priority:** P1 · **Labels:** testing, correctness

**Context:** `lib/core/services/daily_streak_service.dart` is reasonably well-built — keys are namespaced per user id (`_userPrefix`), and `lib/core/utils/app_clock.dart` already provides a debug-overridable clock specifically for testing date-boundary logic like this. This story is **verification, not an assumed bug**: confirm the rollover actually behaves correctly across a real midnight boundary and isn't just untested.

**Acceptance criteria:**
- [ ] Add unit tests using `AppClock`'s debug override (or dependency-inject a `Clock` from the `clock` package the same way the utility already does) that simulate: same-day re-open (streak unchanged), next-day open (streak +1), a gap of `missedYouThresholdDays` or more (streak resets, "missed you" path triggers), and a timezone-boundary edge case (user travels/device timezone changes near midnight).
- [ ] If any of these reveal an actual bug, fix `daily_streak_service.dart`/`daily_streak_repository.dart` — don't just document the gap.

**Verification:** New tests pass; manually confirmed by running `flutter test` and, if feasible, one real-device test across an actual midnight using the existing debug date override already in the app (`kShowDebugDateBanner` / debug date picker mentioned in the original code audit).

---

### AM-27 · Audit per-user local-cache isolation on sign-out
**Priority:** P1 · **Labels:** correctness, privacy

**Context:** Sign-out (`profile_screen.dart` → `SupabaseService().client?.auth.signOut()`) only calls Supabase's sign-out and navigates to the login screen — it does **not** clear any local cache. `DailyStreakService` already does the right thing (keys are suffixed per `_userId`, falling back to `'device'`), so it's *not* at risk of leaking between accounts. The open question is whether every other local cache (premium status cache, progress caches, achievement caches, coin balance, any `SharedPreferences` key not namespaced by user id) follows the same pattern — if any singleton holds unnamespaced state, a second person signing into the same device could see the first person's cached data before a fresh Supabase fetch overwrites it.

**Acceptance criteria:**
- [ ] Audit every `SharedPreferences`-backed service (grep for `SharedPreferences.getInstance()` across `lib/`) and classify each key as: (a) correctly namespaced per user already (like `DailyStreakService`), (b) intentionally device-global and fine to share across accounts (e.g. language preference, sound volume), or (c) user-scoped data that is **not** namespaced — a real bug.
- [ ] For every case (c), either namespace the key by user id (preferred, matches the existing pattern) or explicitly clear it on sign-out.
- [ ] Add a single `AppSessionReset` hook (or extend an existing one) called from the sign-out handler in `profile_screen.dart` that resets any in-memory singleton state (e.g. force `PremiumService` to drop its cached value and re-check on next access) so a freshly signed-in user never briefly sees the previous session's premium/UI state before the first real fetch completes.

**Verification:** Manually sign in as User A, generate some state (complete a task, unlock something), sign out, sign in as User B on the same device — confirm B sees none of A's cached data before Supabase's own fetch would naturally populate B's real data.

---

### AM-28 · Offline/airplane-mode audit across all 4 tabs
**Priority:** P1 · **Labels:** qa, resilience

**Context:** The app already has a good fallback pattern in places (`AntarmargPlaceholder`, `errorBuilder` on assets, try/catch startup sequence in `main.dart`) — but this hasn't been systematically verified tab-by-tab with the network actually off, only spot-checked in the original code audit.

**Acceptance criteria:**
- [ ] With the device/simulator in airplane mode (not just a mocked failed request), open each of the 4 tabs (Aangan, Ashram, Granthalaya, Profile) fresh and confirm every screen reaches a stable, readable state within a few seconds — no infinite spinner, no crash, no blank white screen.
- [ ] For any screen that fails this, add a proper offline/error state (reuse `AntarmargPlaceholder` or the existing pattern) rather than inventing a new one.
- [ ] Re-enable network mid-session (toggle airplane mode off while a tab is open) and confirm the screen recovers without requiring a restart.

**Verification:** A short written or recorded pass/fail list per tab; any fixed screen re-tested after the fix.

---

### AM-29 · Final release-hygiene pass
**Priority:** P1 · **Labels:** tech-debt, ios

**Context:** Same as the original `AM-17` — `REVENUECAT_DEBUG_MODE` is still on in `.env`, and `.env.example` is still missing documentation for several keys the app actually reads (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_AUTH_REDIRECT_URL`, `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`). `GPT_API_KEY` can now be removed from `.env.example` entirely — confirm no live consumer remains after the AI Guru removal (the optional bonus cleanup in `AI_GURU_REMOVAL_SPEC.md` — check whether `book_chat_screen.dart`/`content/gpt_api_service.dart` were also removed; if not, this is a good time to finish that).

**Acceptance criteria:** same as original AM-17, plus the `GPT_API_KEY` removal check above.

---

## EPIC J — Store submission drafts (agent drafts, you finalize)

### AM-30 · Draft privacy policy & terms of service
**Priority:** P1 · **Labels:** legal, docs

**Context:** `web/legal/*.html` or the `LegalUrls` defaults referenced in `.env.example` need real, accurate content — not boilerplate. The agent can draft accurate content by reading what's actually integrated: Supabase (auth, database, storage), Firebase (push notifications, and Crashlytics/Analytics if AM-19/20 land first), RevenueCat (purchases), Google/Apple Sign-In.

**Acceptance criteria:**
- [ ] Draft a privacy policy that accurately lists: what's collected (account email/name via Google/Apple sign-in, usage/progress data via Supabase, purchase data via RevenueCat, device push token, crash/analytics data if added), why, and that it's not sold to third parties (confirm this is actually true before stating it).
- [ ] Draft terms of service covering subscription terms (auto-renewal, cancellation via App Store, no refunds handled directly by the app).
- [ ] **You must have a lawyer or at least your own careful read** before this goes live — the agent's draft is a starting point, not a legal filing.

---

### AM-31 · Draft App Review notes for the subscription flow
**Priority:** P2 · **Labels:** docs

**Context:** Apple's reviewers need a fast path to test the paywall. A good App Review note saves a rejection-and-resubmit cycle.

**Acceptance criteria:**
- [ ] Draft notes describing exactly how to reach the paywall from a fresh install, what each tier unlocks, and (if you decide to provide one) a demo account with Pro pre-activated.

---

## Cannot be done by an agent — needs you, personally

These require your Apple Developer account, the RevenueCat dashboard, and/or a physical iPhone. No amount of code access substitutes for them:

1. **Create the real subscription products in App Store Connect** (monthly/annual/lifetime under the Pro subscription group).
2. **Attach those products to the default Offering in the RevenueCat dashboard.**
3. **Switch to the production RevenueCat Apple public SDK key** for the release build.
4. **Run a full sandbox purchase test on a real device** with an Apple Sandbox tester account — purchase, force-quit/relaunch, cancel, confirm expiry behavior.
5. **Test restore purchases** on a second device/reinstall.
6. **Host the privacy policy** at a real HTTPS URL once AM-30's draft is reviewed.
7. **Fill out the App Store Connect Privacy questionnaire.**
8. **Screenshots and store listing copy.**
9. **TestFlight with real testers**, then the actual App Store submission.

Everything above AM-19 through AM-31 can be handed to your coding agent right now. This section is the part that's on you.
