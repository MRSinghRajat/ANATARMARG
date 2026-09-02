# Jira backlog work plan (AM-1 … AM-18)

Split from `docs/jira_import.csv`. Run parallel tracks where noted; **human-first** items block production deploy.

## Track A — iOS release (human + script)
| ID | Owner | Status | Notes |
|----|-------|--------|-------|
| **AM-1** | Human + agent | Script ready | Download `GoogleService-Info.plist` from Firebase → `ios/Runner/` |

## Track B — Supabase schema
| ID | Status | Notes |
|----|--------|-------|
| **AM-3** | **Done** | Migration 20 + 35 ordering fixed |
| **AM-4** | **Not live** | 042 never applied; live policy names differ. Use `00045` in SQL editor (not `db push`). |
| **AM-43** | **Done (apply pending)** | `20240101000043_remove_ai_guru_feature.sql` — drops Guru chat schema |
| **AM-2** | **Local recover written** | `db pull` blocked (disjoint history). Recover files from live `pg_catalog`. Do not push the 20240101 chain. |
| **AM-5** | Blocked on human | Query live `storage.objects` RLS |
| **AM-6** | **Done** | 13 duplicates + chants + `add_is_premium` → `archive/legacy-sql/` |

## Track C — Monetization security
| ID | Status | Notes |
|----|--------|-------|
| **AM-9** | **Done** | `PREMIUM_GRANT_ALL` hard-off in release |
| **AM-8** | **Done** | Journey + premium gates (Guru link nav removed with feature) |
| **AM-7** | **Cancelled** | Superseded — AI Guru removed (`AI_GURU_REMOVAL_SPEC.md`) |
| **AM-10** | **Cancelled** | Superseded — AI Guru removed |

## Track D — Dead code cleanup
| ID | Status | Notes |
|----|--------|-------|
| **AM-11** | **Done** | Removed `gpt_api_service.dart`, `book_chat_screen.dart`; no client GPT |
| **AM-12** | **Done** | Entire `ai_guru/` + `chat/` folders removed |
| **AM-13** | **Done** | Removed garbh_sanskar presentation routes |
| **AM-15** | **Done** | Removed `test_ui_screen.dart` |
| **AM-14** | Needs product decision | Quests/Shop/Stats |

## Track E — Tests & hygiene
| ID | Status |
|----|--------|
| **AM-16** | Partial — `premium_grant_all_test.dart` (Guru tests N/A) |
| **AM-17** | Pending (after AM-14 scope) |

## Track F — Docs
| ID | Status |
|----|--------|
| **AM-18** | **Done** — stale docs archived |

**Do not** `supabase db push` the local `20240101*` folder onto ANTARMARG (disjoint remote `202602*` history). Apply one-off SQL in the dashboard if needed (`00045` for verses lockdown).

**App nav:** 4 tabs — Aangan, Ashram, Granthalaya, Profile.

## Go-live (AM-19 … AM-31)

| ID | Status | Notes |
|----|--------|-------|
| **AM-19** | **Code done** | Crashlytics wired; debug crash button on Profile (remove after console confirm). Needs `GoogleService-Info.plist` (AM-1). |
| **AM-20** | **Code done** | Funnel events; declare Analytics in App Store Privacy questionnaire. |
| **AM-21** | **Linked; pull blocked** | Histories diverge (see `docs/AM21_SUPABASE_LINK.md`). Do not `migration repair`. |
| **AM-22** | **Done (live)** | 045 applied via SQL (not `db push`). verses + parvas INSERT: HTTP 401 + `row-level security policy`. SELECT verses still 200. |
| **AM-23** | **Done (same as AM-6)** | Duplicates archived; leftover seed/allow files still at repo root. |
| **AM-24** | **Code sweep done** | No leftover AI Guru in `lib/`. README updated. Visual onboarding pass still yours. |
| **AM-25** | **Code done** | Mandir WebView pauses on background / inactive tab. |
| **AM-26** | **Done** | `test/core/services/daily_streak_service_test.dart` |
| **AM-27** | **Code done** | `AppSessionReset` + `docs/AM27_CACHE_AUDIT.md` |
| **AM-28** | **Partial** | Ashram spinner timeout; device airplane pass in `docs/AM28_OFFLINE_AUDIT.md` |
| **AM-29** | **Done** | `REVENUECAT_DEBUG_MODE=false`; `.env.example` documents Supabase + Google keys |
| **AM-30** | **Draft** | `web/legal/privacy.html`, `web/legal/terms.html` — lawyer/human review before host |
| **AM-31** | **Draft** | `docs/APP_REVIEW_NOTES.md` |
