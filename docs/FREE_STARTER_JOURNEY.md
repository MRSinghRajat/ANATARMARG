# Free 7‑day starter journey (`daily-practice-7`)

This PR wires a **free 7‑day starter journey** into the existing Journey framework and adds a **bundled fallback** so a fresh tester can start + complete Day 1 even when Supabase content isn’t imported yet.

## Production import (Supabase)

The canonical source of the starter copy is `docs/MVP_CONTENT_EDITORIAL_REVIEW.md`.

- **Migration**: `supabase/migrations/20260918043200_free_starter_daily_practice_7.sql`
  - Inserts `journey_types` row for `daily-practice-7` (non‑premium, 7 days)
  - Inserts a single `journey_tasks` row `starter_daily_practice` (daily)
  - Inserts 7 `journey_content_pool` rows (Day 1–7) with bilingual instructions

To import into your Supabase project:

1. Ensure the existing journey schema migrations are applied (notably `journey_schema_completeness` and `journey_content_pool`).
2. Apply migrations using your normal workflow (for example `supabase db push` in a configured environment).
3. Verify in the database:
   - `journey_types.slug = 'daily-practice-7'` exists and `is_premium = false`
   - `journey_tasks.slug = 'starter_daily_practice'` exists for that journey type
   - `journey_content_pool` has 7 rows for `task_slug = 'starter_daily_practice'`

No secrets are included in this repository. The `.env` values (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) must be supplied separately for the app to talk to Supabase.

## Bundled fallback (no CMS required)

If Supabase is not configured, or if the starter journey rows are not yet present in the database, the app falls back to a bundled definition:

- `lib/features/journey/data/starter/starter_journey_fallback.dart`
  - Defines `daily-practice-7` and provides a local rotating content pool for Day 1–7.
- `lib/features/journey/data/local/local_journey_store.dart`
  - Persists the starter journey + daily task completions locally (SharedPreferences) for simulator/TestFlight testing.

## Manual test (Day 1)

See `docs/testing/free_starter_day1.md`.

