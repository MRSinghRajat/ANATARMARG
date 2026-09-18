# Claude Execution Log

Progress log for the Claude lead-developer handoff (see `docs/CLAUDE_HANDOFF.md`,
`docs/MVP_LAUNCH_PLAN.md`, `docs/LAUNCH_AGENT_TASKS.md`). One entry per task ID.
Append new entries; do not rewrite prior ones.

---

## 2026-09-14 — Handoff verification (no code change)

**Task:** Verify claimed baseline state before touching anything, per
`docs/CLAUDE_HANDOFF.md`.

**Checks run (all passed, matching the handoff's claimed evidence):**
- `python3 -m unittest scripts/tests/test_app_config.py` → 14/14 OK
- `python3 scripts/verify_app_config.py --release` → "Verified allowlisted app configuration."
- `bash scripts/check_ios_release_config.sh` → "OK: GoogleService-Info.plist present for com.antarmarg.app"
- `git diff --check` → clean
- `flutter analyze --no-fatal-infos` → 0 errors (info-level lints only, pre-existing)
- `flutter test` → 25/25 passed

**Conclusion:** Handoff's claimed state confirmed independently. Working tree
left untouched (many pre-existing modified/untracked files from prior
sessions are present and were not claimed or reset).

**Next step:** Implement L04.

---

## 2026-09-14 — L04: journey recurrence and date behavior

**Task ID:** L04 (`docs/MVP_LAUNCH_PLAN.md`)

**Defect confirmed by reading code (not assumed from the handoff description):**
`JourneyLogic.getTodaysTasks`'s frequency `switch` returned `true` for every
case (`daily`, `once`, `weekly`, `default`), so `frequency` had no effect.
Combined with `JourneyRepository.getCompletedTaskIdsToday` only ever checking
"today," `once`/`weekly` tasks reappeared and stayed completable indefinitely,
granting duplicate coin/karma rewards on every re-completion. Separately,
`JourneyLogic.journeyDayProgress` hardcoded a 90-day denominator for any
journey identified only by `startDate` (i.e. every non-pregnancy program),
which is a real, visibly-rendered defect on two live screens (confirmed via
call-site grep), not a dead helper — 21-day and 40-day programs showed
"day X of 90". Day-based phase unlocks (`day_offset` trigger) and both
progress displays also ignored `paused_at`/`resumed_at` entirely, so time
kept advancing while a journey was paused.

**Schema:** No migration needed. `user_journey_task_completions` already
stores one row per `(user_id, task_id, completed_date)` via upsert conflict
key `user_id,task_id,completed_date` — full history, not just "today" — so
the fix is a broader read query against existing schema, per the handoff's
instruction to treat schema changes as a separate, reviewed step and avoid
one here since it isn't required.

**Changed files:**
- `lib/features/journey/data/journey_logic.dart` — added `dateOnly`,
  `weekStart` (Monday-anchored local week), `effectiveDaysSinceStart`
  (pause-aware elapsed days, single pause/resume cycle precisely handled —
  see in-code doc comment on the schema limitation for multiple cycles).
  `getTodaysTasks`/`getTasksForDisplayedPhase` now take optional
  `completedOnceTaskIds`/`completedThisWeekTaskIds` sets and actually filter
  by `task.frequency`. `canCompleteTaskToday`/`taskCompletionBlockedReason`
  take the same sets and block re-completion with a user-facing reason.
  `journeyDayProgress` takes optional `durationDays` (falls back to 90 only
  when not supplied, so existing callers are unaffected until updated) and
  uses `effectiveDaysSinceStart` for the `startDate` branch. `day_offset`
  phase trigger now uses `effectiveDaysSinceStart` instead of raw calendar
  difference. `getCurrentPhase`/`getCurrentPhaseFromTasks` take an optional
  `{DateTime? now}` for deterministic testing. Pregnancy branches
  (`due_date`, `child_dob`) deliberately left untouched — confirmed out of
  scope by inspection, not assumption.
- `lib/features/journey/data/repositories/journey_repository.dart` — added
  `getCompletedTaskIds(userId, userJourneyId, {sinceDate})`, additive only;
  the existing `getCompletedTaskIdsToday` was not modified, to avoid risking
  the already-working "today" flow.
- `lib/features/journey/presentation/providers/journey_providers.dart` —
  added `journeyCompletedOnceTaskIdsProvider` (all-time) and
  `journeyCompletedThisWeekTaskIdsProvider` (since `JourneyLogic.weekStart`),
  wired into `todaysJourneyTasksProvider`, `displayedJourneyTasksProvider`,
  and the existing bulk-invalidation helper.
- `lib/features/journey/presentation/screens/journey_home_screen.dart` —
  invalidates the two new providers after a checkbox complete/uncomplete;
  `_JourneyProgressBanner` now takes and forwards `durationDays`.
- `lib/features/journey/presentation/screens/journey_task_detail_screen.dart`
  — **the actual reward-granting enforcement point.** Previously called
  `canCompleteTaskToday` without passing any completion history, so this
  screen alone would still have let `once`/`weekly` tasks be re-completed for
  coins even after the domain-logic fix. Now fetches both new providers and
  passes them into the check, and invalidates them after a successful
  completion.
- `lib/features/ashram/presentation/screens/ashram_screen.dart` — passes
  `journeyType?.durationDays` into its `journeyDayProgress` call (already had
  `journeyType` in scope).
- `test/features/journey/data/journey_logic_test.dart` — new, 28 tests (see
  below).

**Checks run:**
- `flutter analyze lib/features/journey/ lib/features/ashram/presentation/screens/ashram_screen.dart` → 0 errors
- `flutter analyze --no-fatal-infos` (whole project) → 0 errors (1083
  pre-existing info-level lints, none in touched files)
- `flutter test test/features/journey/data/journey_logic_test.dart` → 28/28 passed
- `flutter test` (whole suite) → 53/53 passed (25 pre-existing + 28 new, zero
  regressions)
- `git diff --check` → clean
- Re-ran the four baseline checks from the handoff (`test_app_config.py`,
  `verify_app_config.py --release`, `check_ios_release_config.sh`) → still
  all pass, confirming this work did not disturb unrelated config.

**Test coverage** (`journey_logic_test.dart`, pure-function, no
Supabase/widgets):
- `weekStart`: Monday/Sunday/mid-week/time-stripping.
- `effectiveDaysSinceStart`: never-paused, currently-paused (frozen),
  resumed-after-pause (span excluded), no start date.
- `journeyDayProgress`: real `durationDays` used when passed; falls back to
  90 when not passed (no regression for not-yet-updated callers); frozen
  `currentDay` while paused.
- `getTodaysTasks`: daily always included; once included until any
  completion then excluded permanently; weekly included/excluded by
  this-week completion and correctly reappears next week; unrecognized
  frequency fails open as daily; phase filtering unaffected.
- `day_offset` phase trigger via `getCurrentPhase`: no advance while paused;
  correct unlock at day 21 and at the day-39/40 boundary; paused span shifts
  a later boundary forward by the pause length.
- `taskCompletionBlockedReason`: blocks an already-completed once/weekly task
  even when today's set is empty (i.e., completed on a prior day/week);
  allows a fresh daily task; blocks on completed/paused journey status.

**Known, disclosed limitations (not fixed — out of scope for this task):**
- Only the most recent pause/resume pair is stored on `user_journeys`, so a
  journey paused and resumed more than once will have only its latest pause
  window excluded precisely from `effectiveDaysSinceStart`; earlier cycles on
  the same journey are not tracked. Documented in code; would need a schema
  change (new pause-history table) to fix fully.
- `pickTodaysContent` still uses raw `DateTime.now().difference(start)`
  without pause-awareness — not part of the L04 description's explicit
  scope (recurrence + day-based phase/progress), left as-is; flagging here so
  it isn't silently forgotten if it turns out to be user-visible.
- Week semantics for `weekly` tasks are local-calendar-day, Monday-anchored,
  device-timezone based — consistent with the existing `completed_date`
  convention already used elsewhere in the codebase, but not configurable
  per user/region.

**Remaining dependencies:** None blocking — this task required no schema
migration, no third-party account access, and no owner action.

---

## 2026-09-14 — L05: account lifecycle and RevenueCat identity (partial — see scope note)

**Task ID:** L05 (`docs/MVP_LAUNCH_PLAN.md`) — "Guest, sign-in, restored
session, sign-out, account switch and purchase restore use correct identity
without inherited premium/progress."

**Defect confirmed by reading code (traced every call site, not assumed):**
`RevenueCatService.identifyUser(userId)` existed but was called from
**nowhere** in the app. `Purchases.configure()` runs once at cold start
(`main.dart` → `_deferredInit`), before any Supabase auth state is known, and
nothing ever afterward told RevenueCat which Supabase user was signed in —
not after Google/Apple sign-in (`login_screen.dart` just does
`pushReplacementNamed` to home), not after OTP/magic-link sign-in (completes
via the deep-link/PKCE listeners in `main.dart`, which only navigate), and
not for a session restored at cold start (`SupabaseService().currentUserId`
was never read by anything RevenueCat-related). Only explicit sign-out was
wired correctly: `AppSessionReset.onSignOut()` already called
`RevenueCatService.instance.logOut()` before `auth.signOut()`, confirmed
correct and left untouched.

Practical effect: RevenueCat's app-user identity stayed on whichever
anonymous alias existed at first launch for the life of the install (until
a sign-out forced a fresh anonymous alias) — never actually becoming "this
Supabase user." Purchases could not be attributed to an account in the
RevenueCat dashboard, and — the sharper case — signing out and a different
person signing in on the same device left RevenueCat's identity anonymous
rather than linked to the new account, so any dashboard-side identity
resolution, support lookup, or future server-side entitlement check
(L07) keyed on app-user-id would not reflect who was actually signed in.

**Verified NOT broken (checked, not assumed) while tracing this:**
`CoinService` reads `SupabaseService().currentUserId` fresh on every
operation (no stale cached id), and `DailyStreakService` namespaces every
SharedPreferences key by `_userId ?? 'device'` and is re-pointed via
`setUserId()` on both sign-out (`AppSessionReset`) and app-nav-level sign-in
(`main_navigation_screen.dart`'s `_checkDailyStreak`, which re-runs because
sign-in navigates via `pushReplacementNamed`/`pushNamedAndRemoveUntil`,
remounting `MainNavigationScreen`). Local progress/coin caching was already
account-isolated; the gap was specifically RevenueCat identity.

**Changed files:**
- `lib/core/services/revenuecat_service.dart` — added `syncIdentity(String?
  userId)`: no-ops on null/empty (sign-out already handled explicitly via
  `logOut`, so this never forces a guest into a churny fresh anonymous
  alias); queues the request if called before `initialize()` completes and
  applies it automatically once `initialize()` finishes (`_pendingIdentitySync`);
  otherwise calls the existing `identifyUser` once per distinct userId
  (`_lastSyncedUserId` dedup, avoiding a redundant `Purchases.logIn` on every
  auth-state event). `logOut()` now resets `_lastSyncedUserId` so a later
  sign-in — including a different account — re-links correctly.
- `lib/main.dart` — two call sites, chosen to cover every path without
  patching each sign-in screen individually (a screen-by-screen approach
  risks silently missing a future sign-in method):
  1. `_deferredInit()`: after RevenueCat+PremiumService init, if
     `SupabaseService().currentUserId` is already non-null (a session
     restored at cold start), sync identity and refresh premium status once.
  2. `_AntarMargAppState`: new persistent `client.auth.onAuthStateChange`
     listener (alongside, not replacing, the existing one-shot deep-link
     listener) that calls `syncIdentity` + `refreshPremiumStatus` on every
     `AuthChangeEvent.signedIn` — covers Google, Apple, OTP/magic-link, and
     account switching (sign-out already cleared `_lastSyncedUserId`, so the
     next `signedIn` re-links to the new account) uniformly.
- `test/core/services/revenuecat_service_test.dart` — new, 4 tests (see
  below).

**Checks run:**
- `flutter analyze lib/main.dart lib/core/services/revenuecat_service.dart` → 0 errors
- `flutter analyze --no-fatal-infos` (whole project) → 0 errors
- `flutter test` (whole suite) → 57/57 passed (53 prior + 4 new, zero regressions)
- `git diff --check` → clean

**Test coverage — and its explicit limit:** `RevenueCatService` wraps the
`purchases_flutter` platform channel; there is no platform-channel mock in
this codebase (checked — no prior test exercises it), so a plain `flutter
test` cannot drive a real `Purchases.configure`/`logIn` call. The 4 new
tests cover only the pure guard logic that runs before any native call:
null/empty userId is a no-op; a userId requested before `initialize()`
completes without throwing (queued, not sent to the SDK prematurely,
important because `identifyUser` force-unwraps `_customerInfo!` after
`Purchases.logIn` and must never be reached uninitialized); `isAnonymous()`/
`getAppUserId()` report safe defaults pre-initialization.

**What this does NOT prove, per `docs/MVP_LAUNCH_PLAN.md`'s own QA gates
table ("Authentication", "Account isolation", "Purchases" rows) — explicitly
not claiming this here:** that a live Google/Apple/OTP sign-in actually
calls `Purchases.logIn` with the right id and it shows up linked in the
RevenueCat dashboard; that switching accounts on one physical device does
not hand one account's entitlement to another when "Restore Purchases" is
tapped (this is bounded by Apple's own App-Store-receipt-is-per-Apple-ID
model, not fully fixable in-app — worth the owner's attention as a known
shared-device caveat, not a bug this change introduces or fully closes);
that a cold-start restored session actually reaches RevenueCat before the
user can interact with paid content. These require a physical device or
TestFlight build with real Sign in with Apple/Google and a sandbox Apple ID
purchase — code-level fix and guard-level tests only get this to "the known
identity-sync gap is closed and the change doesn't crash," not to
launch-ready evidence for this row of the QA gate table.

**Remaining dependencies:** Device/TestFlight verification (owner or
tester, not obtainable from this environment). No schema migration; no
account access needed for the code change itself.

**Next step:** L06 (authenticated account deletion) builds directly on L05's
identity work and is next per `docs/MVP_LAUNCH_PLAN.md`. Before starting it,
re-verify current deletion-related code (if any exists) rather than assume
none does, per standing instructions — do not begin without that check.

---

## 2026-09-14 — L06: authenticated account deletion (code complete, NOT deployed)

**Task ID:** L06. Verified first (repo-wide search) that no account-deletion
code existed anywhere in `lib/` — this is a from-scratch build, not a fix.
Apple requires in-app account deletion for any app that supports account
creation (docs/MVP_LAUNCH_PLAN.md §9 links Apple's guideline directly).

**Schema investigation (live project, read-only, via Supabase MCP —
confirmed the MCP connector points at the app's actual configured project
by comparing its URL against the local `.env`, without printing either
value):** no foreign key in this schema references `auth.users` at all
(checked via information_schema), so deleting the auth user would NOT
cascade any app data — an explicit sweep is the only correct mechanism.
Found 33 public-schema tables with a `user_id uuid` column (checked via
information_schema, not guessed), several already linked to each other by
their own `ON DELETE CASCADE` (e.g. `user_journeys` → its completion
tables) — the new function deletes all 33 explicitly anyway, redundant
with those cascades but correct even if a cascade is ever changed.

**Design:** two-step deletion, matching Supabase's own recommended pattern
for exactly this case:
1. `public.delete_own_account_data()` — a `SECURITY DEFINER` Postgres
   function, following the codebase's existing convention (matches
   `consume_guru_ai_credit()` etc. in style), scoped strictly to
   `auth.uid()` — it never accepts a caller-supplied user id, so by
   construction it can only ever delete the caller's own data. Sweeps all
   33 tables, then inserts one row into a new `account_deletions` audit
   table (the retention exception the plan's "done when" asks for —
   deliberately just a former user id and a timestamp, nothing else
   personal, and RLS-locked so only this function or the dashboard can read
   it). Granted to `authenticated` only.
2. `supabase/functions/delete-account` (Edge Function) — calls step 1
   through a client carrying the caller's own forwarded JWT (so
   `auth.uid()` still resolves correctly inside that function), and only if
   that succeeds, uses the service-role Admin API to actually remove the
   auth user (`auth.admin.deleteUser`) — a raw SQL delete on `auth.users`
   would not clean up sessions/identities/refresh tokens the way the Admin
   API does, so this step must be server-side with the service role, never
   embeddable in the client. If step 1 fails, step 2 never runs — nothing
   is deleted. If step 1 succeeds but step 2 fails, the response carries
   `partial: true` so the client shows "contact support" instead of falsely
   claiming success.

**Changed / new files:**
- `supabase/migrations/20260914010000_l06_account_deletion_support.sql` —
  the audit table + function above. Purely additive.
- `supabase/functions/delete-account/index.ts` — the Edge Function, reusing
  the existing `supabase/functions/_shared/{cors,supabase}.ts` helpers
  already established in this repo (`supabaseAdmin`, `supabaseUserClient`)
  rather than reinventing them.
- `lib/core/services/supabase_service.dart` — `deleteAccount()` calling the
  function via `functions.invoke('delete-account')`, plus a small
  `AccountDeletionResult` result type (`success`/`partial`/`errorCode`).
- `lib/features/profile/presentation/screens/profile_screen.dart` — a
  "Delete Account" action below Sign Out (hidden for guests — nothing to
  delete), matching the existing sign-out dialog's exact style. Requires
  typing "DELETE" to confirm (more friction than sign-out, deliberately).
  Explicitly states the deletion does **not** cancel an active subscription
  and tells the user to cancel it separately in iPhone Settings — the plan
  is explicit that this must not misleadingly promise subscription
  cancellation, and deleting the Supabase account structurally cannot reach
  Apple's billing system. On success (or partial success — app data is
  already gone either way, so there is nothing left worth staying signed
  into) reuses the existing `AppSessionReset.onSignOut()` +
  `auth.signOut()` flow and routes to login, identical to manual sign-out.

**NOT DEPLOYED.** Applying the migration via the Supabase MCP tool and
deploying the Edge Function were both explicitly denied by this
environment's own safety classifier as "Production Deploy" actions — I did
not attempt to route around this (e.g. via raw `execute_sql`, which would
defeat the same safeguard). This is a deliberate environment boundary, not
a task failure to hide: the code is written, reviewed, and locally
consistent with the live schema I inspected, but has never run against the
live database. See the consolidated verification list delivered in chat
for the exact commands to deploy this.

**Explicit gap, disclosed rather than glossed over:** this does not call
Apple's Sign in with Apple token-revocation endpoint — Supabase's Admin API
does not do this automatically, and building that call requires an Apple
private key most easily configured by the account owner. Per L06's own
"done when" wording ("Apple revocation handled"), this is not fully closed
until that's added; flagged here so it isn't silently assumed done.

**Checks run:** `flutter analyze` (0 errors on changed files and whole
project), `flutter test` (57/57, no regressions), `git diff --check`
(clean). No Deno/TypeScript type-check was possible — `deno` is not
installed in this environment — so the Edge Function's TypeScript has been
read carefully but not compiler-verified; flagged in the verification list.

**Remaining dependencies:** owner must run the deploy commands (see chat),
then exercise the flow on a disposable test account before this can be
called verified, per the plan's own QA gate ("Privacy" row: "verified on
disposable accounts").

---

## 2026-09-14 — L07: server entitlement enforcement (fix designed and written, NOT deployed)

**Task ID:** L07. Audited via live, read-only Supabase inspection (MCP) —
not assumed from the client code or from any prior claim.

**Headline finding, confirmed against the actual live schema:**
`books`, `journey_types`, `journey_tasks`, `sacred_stories` and
`garbh_sanskar_content` all have an `is_premium` (or `is_active`-only)
column, but **not one existing RLS SELECT policy on any of them checked
it** — every one found was `USING (true)` or `USING (is_active = true)`
only (queried directly from `pg_policies`). Paid content — including the
Hanuman Chalisa 40-day program — is therefore fully readable today by
anyone holding the app's public anon key, signed in or not, paying or not,
via a direct Supabase REST call. `PremiumService.isPremium` in the Flutter
client is a UI gate only; there was no server enforcement behind it at all.
This is the exact "no client-only grants" gap L07 exists to close, now
concretely evidenced rather than suspected.

**A second, sharper finding that would have made a naive RLS-only fix
silently ineffective:** `public.v_journey_tasks_full` — the view
`JourneyTask.fromJson` actually reads from, per its own doc comment in
`lib/features/journey/data/models/journey_task.dart` — has no
`security_invoker` reloption set (confirmed via `pg_class.reloptions`,
`null`), meaning it runs with the view owner's privileges and bypasses the
querying user's RLS on `journey_tasks` entirely. This was flagged
independently by Supabase's own security advisor (`security_definer_view`,
ERROR level). A prior migration (`20260226053650_fix_view_security_invoker`,
visible in `list_migrations`) fixed this correctly for the sibling view
`v_journey_content_resolved` (confirmed: `security_invoker=true` present)
but missed this one. Fixing `journey_tasks`' RLS alone, without also fixing
this view, would not have changed what the app's actual read path returns.

**Design:** no entitlement state existed anywhere in Postgres before this —
RevenueCat and Supabase were completely disconnected systems, so RLS had no
way to know "is this user a paying subscriber." Added:
- `public.user_entitlements` (user_id, entitlement_id, is_active,
  expires_at) — written only by a new webhook, self-readable via RLS.
- `public.revenuecat_webhook_events` — an idempotency/replay ledger keyed
  by RevenueCat's own event id; RLS-locked (no policies) to service-role
  only.
- `public.has_active_entitlement(uuid)` — `SECURITY DEFINER`, `STABLE`,
  granted to `anon`+`authenticated` (must be, since RLS policies evaluate
  it under the querying role, not as a separately privileged call).
- `ALTER VIEW public.v_journey_tasks_full SET (security_invoker = true)`.
- Replaced the SELECT policy on each of the five tables above with
  `is_active = true AND (is_premium = false OR has_active_entitlement(...))`
  (or the `books`-only equivalent), each with the exact prior policy quoted
  in a comment for auditability. `sacred_stories` had two overlapping
  permissive policies (Postgres ORs them together), so the always-true one
  would have silently defeated the other's `is_active` check even before
  touching `is_premium` — both dropped, replaced with one correct policy.
- `chapters`/`verses` have no `is_premium` of their own; gated by a join to
  their parent `books.is_premium` instead (both confirmed to have a
  `book_id` column directly).
- `supabase/functions/revenuecat-webhook` — verifies a shared-secret
  `Authorization` header (RevenueCat's own configurable header value,
  compared against a `REVENUECAT_WEBHOOK_SECRET` function secret — neither
  side of that secret is something this session can set), inserts the
  event id first for idempotency (a retry/duplicate delivery hits the
  primary key and is reported already-processed without reapplying),
  upserts `user_entitlements` for `INITIAL_PURCHASE`/`RENEWAL`/
  `UNCANCELLATION`/`PRODUCT_CHANGE`/`SUBSCRIPTION_EXTENDED`/`TRANSFER`
  (activating) and `EXPIRATION` (deactivating) — `CANCELLATION` and
  `BILLING_ISSUE` are deliberately no-ops, matching RevenueCat's own
  semantics (access continues until the entitlement actually expires, not
  the moment a renewal is cancelled).

**Disclosed limitation, tied directly to L05:** `event.app_user_id` is only
a Supabase user id (UUID) for a user who has been through `syncIdentity`.
An event for RevenueCat's original anonymous alias (not a UUID) is detected
and skipped rather than guessed at — recorded in
`revenuecat_webhook_events` regardless, so it's auditable if this turns out
to matter for real purchases made before L05 shipped.

**Hygiene follow-up, same audit pass:** the security advisor separately
flagged six leftover AI-Guru-feature `SECURITY DEFINER` functions
(`consume_guru_ai_credit`, `grant_guru_ai_purchased_credits`,
`peek_guru_ai_credits`, `sync_guru_ai_tier_to_profile`,
`get_consultation_count`, `increment_consultation_count`) as callable by
`anon` — confirmed via each function's own body that they already refuse
to act without `auth.uid()`, so not independently exploitable, and
confirmed via a repo-wide search that no client code calls any of them
anymore. `supabase/migrations/20260914030000_revoke_unused_ai_guru_rpc_grants.sql`
revokes the grants without dropping the functions/tables (a separate,
later decision if the feature stays permanently removed).

**New / changed files:**
- `supabase/migrations/20260914020000_l07_server_entitlement_enforcement.sql`
- `supabase/migrations/20260914030000_revoke_unused_ai_guru_rpc_grants.sql`
- `supabase/functions/revenuecat-webhook/index.ts`

**NOT DEPLOYED**, same environment boundary as L06 — the migration apply
and function deploy were both denied as "Production Deploy" actions; not
routed around. See the consolidated verification list delivered in chat
for exact deploy commands and the two RevenueCat-dashboard/Supabase-secret
values the owner must set (not something this session can set — they are
credentials).

**What this does NOT do, stated plainly:** enforce entitlement on every
possible content surface in one pass (e.g. `granthalaya_audio_wisdom_cards`
and other Granthalaya tables were not individually re-audited for a
premium concept — the Listen tab is deferred per the launch plan's own v1
scope, so this was not chased further this pass); rotate/backfill
`user_entitlements` for any user who already purchased before this ships
(a one-time backfill from RevenueCat's own subscriber list would be needed
so an existing paying customer isn't locked out the moment this goes live —
not built here, flagged in the verification list); replace the client's
own `PremiumService.isPremium` UI check (still correct and still needed —
this is the belt-and-suspenders server side, not a client-side change).

**Checks run:** all read-only Supabase inspection (`list_tables`,
`execute_sql` against `information_schema`/`pg_policies`/`pg_class`,
`get_advisors`) — no write reached the live database. `flutter analyze`
and `flutter test` are unaffected (no Dart changed in this task).

**Remaining dependencies:** owner deploys both migrations + both Edge
Functions, sets `REVENUECAT_WEBHOOK_SECRET`, configures the matching
RevenueCat dashboard webhook, and backfills existing subscribers' rows in
`user_entitlements` before this goes live — see the verification list.

---

## 2026-09-14 — L06/L07 corrected per docs/L06_L07_DEPLOYMENT_REVIEW.md

**Task:** the review at `docs/L06_L07_DEPLOYMENT_REVIEW.md` found seven real
defects in the L06/L07 drafts above, independent of the deployment
restriction. Each was verified against actual code, live data, or
RevenueCat's own docs (fetched, not assumed) before fixing — not accepted
on the review's word alone, matching this session's standing practice.

**Verified externally before coding (WebFetch against revenuecat.com):**
TRANSFER events carry `transferred_from`/`transferred_to`, NOT
`app_user_id` or `entitlement_ids` — confirming finding 2 exactly (the
first draft's `if (!appUserId) return malformed_event` meant every TRANSFER
was rejected outright). RevenueCat's own webhook docs recommend calling
`GET /v1/subscribers/{id}` after any webhook rather than trusting payload
fields, and confirm at-least-once delivery with up to 5 retries
(5/10/20/40/80 min backoff) — the basis for the redesign below. Also
confirmed the exact endpoint, auth header format, and response field names
(`expires_date`, `product_identifier`).

**Verified live against the database before coding:** `journey_tasks.is_premium`
does NOT reliably reflect its parent journey's premium status —
`garbh-sanskar` (37 tasks), `garbh-taiyari` (18 tasks) and
`navjaat-sannidhi` (33 tasks) are premium `journey_types` whose tasks are
ALL individually marked `is_premium = false`. A task-only check (the first
draft) would have let those 88 tasks' instructions be read for free.
`sacred_stories`/`story_pages`/`verse_translations`/`journey_content_pool`
policies were all confirmed `USING (true)`, unconditionally open, matching
finding 4. Zero `sacred_stories` rows are currently `is_premium = true`
(confirmed, not assumed) — relevant to a residual gap noted below.

**Findings and fixes:**

1. **Non-atomic idempotency (webhook `index.ts:88` vs `:129` in the first
   draft).** Fixed structurally: both the replay-ledger insert and every
   entitlement write now happen inside one new SQL function,
   `apply_revenuecat_event`, in one transaction. If any entitlement write
   raises, the ledger insert rolls back too — a retry of the same event is
   correctly reprocessed rather than permanently marked done.
2. **TRANSFER mishandled.** The webhook no longer requires `app_user_id`
   before checking event type. TRANSFER resolves both
   `transferred_from`/`transferred_to` ids and resyncs each.
3. **State could regress / helper too permissive / no allowlist.** Replaced
   hand-parsed deltas entirely: every event now triggers a fresh
   `GET /subscribers/{id}` fetch and writes that authoritative snapshot,
   so out-of-order delivery cannot regress state, and every event type
   (non-renewing purchases, refunds, grace periods, deferred product
   changes included) is handled uniformly instead of an allowlist.
   `has_active_entitlement` now requires a specific entitlement id
   (defaulting to `'Antar marg Pro'`, matching the Flutter app's own
   fallback) instead of accepting any active row — and exists as exactly
   one function signature, deliberately, since a leftover one-argument
   overload would have silently resolved over the new default-parameter
   version. Malformed/unparseable expiry dates fail closed (`NaN > now`
   evaluates false) rather than granting unlimited access. Sandbox vs
   production is recorded (`environment` column) but not used to deny
   access — disclosed, deliberate, since TestFlight testers need working
   purchases; a stricter split can filter on that column later without a
   schema change. An optional `REVENUECAT_EXPECTED_APP_ID` allowlist check
   was added, skipped when unset rather than guessing at a field's
   presence across every event type.
4. **RLS coverage incomplete.** Added policies for `verse_translations`,
   `story_pages`, and `journey_content_pool` (all confirmed live as
   unconditionally open), and fixed `journey_tasks` to check the parent
   journey_type's `is_premium` as well as the task's own (see the
   garbh-sanskar finding above).
5. **Restrictive RLS hid the paid catalog from free users.** Split the
   single L07 migration into 07a (additive infrastructure — deploy first,
   safe) and 07b (restrictive policy activation — deploy only after
   backfill). 07b no longer touches `books`, `journey_types` or
   `sacred_stories` at all — confirmed each has no body/instruction column
   of its own (pure catalog: title/description/cover), so they stay
   exactly as originally, unconditionally browsable. `garbh_sanskar_content`
   is the one exception kept gated: confirmed it has no separate catalog
   row elsewhere — `body_text`/`translation`/media columns live directly on
   it. **Disclosed, not fixed:** `sacred_stories.pages` (a legacy inline
   fallback the datasource still reads when no `story_pages` rows exist)
   is not column-gated — Postgres RLS is row-level only. Verified zero
   premium rows rely on it today; flagged as a residual gap if a future
   premium story skips `story_pages`.
6. **Deletion incomplete.** `delete_own_account_data()` now also deletes
   `user_entitlements` and `apple_auth_tokens`. Made idempotent
   end-to-end: the audit insert has an `ON CONFLICT (deleted_user_id) DO
   NOTHING` guard (new unique constraint), so the whole function is safe to
   call twice. The Edge Function and Flutter UI no longer treat a partial
   failure (data gone, auth user still exists) as a dead end — the client
   now offers Retry, since re-invoking the entire flow is safe by
   construction rather than requiring bespoke per-step recovery.
7. **Apple token revocation.** Built end-to-end: `apple-auth-store` (new
   Edge Function, `verify_jwt: true`) captures the Sign in with Apple
   authorization code right after native sign-in and exchanges it
   server-side for a refresh token (stored in new, RLS-locked
   `apple_auth_tokens`, never client-readable); `delete-account` now looks
   up that token and calls Apple's revoke endpoint before deleting the auth
   user — best-effort and non-blocking (logged either way; a user's
   ability to delete their account must not depend on Apple's API being
   reachable at that moment). `supabase_service.dart`'s `signInWithApple()`
   now captures and forwards the authorization code, fire-and-forget,
   never failing sign-in itself. Needs four new owner secrets
   (`APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_CLIENT_ID`,
   `APPLE_PRIVATE_KEY`) — none settable from this session.

**New/changed files:**
- `supabase/migrations/20260914010000_l07a_entitlement_infrastructure.sql` (rewritten)
- `supabase/migrations/20260914015000_apple_token_revocation_support.sql` (new)
- `supabase/migrations/20260914020000_l06_account_deletion_support.sql` (rewritten)
- `supabase/migrations/20260914030000_l07b_activate_premium_rls.sql` (rewritten, split from the old single L07 file)
- `supabase/migrations/20260914040000_revoke_unused_ai_guru_rpc_grants.sql` (unchanged content, renumbered to sort last)
- `supabase/functions/revenuecat-webhook/index.ts` (rewritten)
- `supabase/functions/delete-account/index.ts` (rewritten)
- `supabase/functions/apple-auth-store/index.ts` (new)
- `supabase/functions/_shared/apple.ts` (new — client-secret JWT, token exchange, revoke)
- `lib/core/services/supabase_service.dart` — `signInWithApple()` now captures/forwards the Apple authorization code
- `lib/features/profile/presentation/screens/profile_screen.dart` — delete-account flow now offers Retry on a partial failure instead of forcing sign-out immediately

**Checks run:** `flutter analyze` (0 errors, whole project), `flutter test`
(57/57, no regressions — no existing test touches these Edge
Functions/RLS, exactly as the review noted), `git diff --check` (clean).
No SQL or Deno/TypeScript execution was possible or attempted against the
live project — this remains **not deployed**, per the user's explicit
instruction to fix before deploying, and per this environment's own
deploy restriction. `deno` is not installed locally, so the TypeScript was
hand-reviewed, not compiler-checked — still an open item.

**Still not done, stated plainly (do not treat as closed):**
- L05 stays labeled partial, exactly as the review requires — nothing here
  changes that; native-SDK identity, restore and account-isolation
  evidence still requires a real device.
- Subscriber backfill (dry run first, per the review's step 4) is not
  built — needed before 07b can safely go live.
- The `sacred_stories.pages` residual gap above.
- No Deno type-check or integration test against a real/synthetic backend
  was possible from this environment.

**Remaining dependencies:** owner deploys in the order documented at the
top of each migration file, sets the RevenueCat + Apple secrets (none
settable from here), runs the backfill dry run, then 07b, then completes
device-based purchase/restore/switch/deletion checks before L05–L07 can be
marked accepted — matching the review's own required sequence exactly.
