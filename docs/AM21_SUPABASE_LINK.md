# AM-21 — Link + schema-diff report (2026-09-01)

Linked: `supabase link --project-ref qyikatemonzykqamtvod` (ANTARMARG, East US).  
`supabase/config.toml` was invalid (`[project]` key); replaced with `project_id = "antarmarg"` so the CLI can parse it.

## Migration history does **not** match

`supabase migration list` (abbreviated):

- **Local only** (never recorded on remote): `20240101000000` … `20240101000043` including **042 and 043**.
- **Remote only** (never in this repo): ~80 rows dated `20260208` … `20260226`.

Production was migrated under a **different timestamp series**. The 20240101 files in git were never applied through this project's `supabase_migrations.schema_migrations` table.

That matches AM-22: **042 is not live.**

## `db pull` did not produce a SQL file

```
supabase db pull remote_public_schema --schema public --yes
```

CLI refused: histories diverge, and it suggested `migration repair` to pretend local versions were applied / remote versions reverted.

**Do not run those repair commands.** Marking `20240101000042` as `applied` on remote would lie about RLS — we just proved anon INSERT into `verses` still succeeds.

`supabase db dump --schema public` also failed here: Docker Desktop is not running (CLI shells through Docker).

## Live tables (PostgREST, anon key)

All six AM-2 names **exist** (HTTP 200):

| Table | Anon SELECT |
|---|---|
| `sacred_stories` | row columns include `id, slug, title, title_hindi, is_premium, pages, audio_url, …` |
| `sacred_texts` | row columns include `id, slug, title, text_hindi, text_english, type, …` |
| `daily_task_templates` | row columns include `id, slug, title, karma_reward, coin_reward, is_system_task, …` |
| `push_tokens` | 200, empty (RLS or no rows) — no column list from a row |
| `user_journeys` | 200, empty |
| `user_daily_tasks` | 200, empty |

Live `pg_catalog` dump is captured in `docs/AM21_PULL_REPORT.md`. Recover `CREATE TABLE IF NOT EXISTS` files are in `supabase/migrations/` (`000181`, `000241`, `00026_recover_user_journeys_fks`, `000321`, `00044`). **Do not `db push` them onto this project.**

## AM-22 / 042

Do **not** `supabase db push` the whole 20240101 chain onto this project — remote already has the live schema; a full push would replay seeds and 043 drops.

042 drops policy names that **do not exist live**. To lock verses, run **only** `supabase/migrations/20240101000045_drop_live_public_write_policies.sql` in the dashboard SQL editor, then re-run `./scripts/verify_rls_lockdown.sh`.

AM-6 archived the 13 duplicate root SQL files plus `SUPABASE_CHANTS_SCHEMA.sql` to `archive/legacy-sql/`.
