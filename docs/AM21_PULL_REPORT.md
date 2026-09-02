# AM-21 / AM-22 — live project report (2026-09-01)

Project: **ANTARMARG** `qyikatemonzykqamtvod` (matches `.env` `SUPABASE_URL`).
Linked locally. **Did not** run `migration repair` and **did not** `db push`.

`supabase db pull --linked` still refuses: remote history is `20260208*`…`20260226*`; local files are `20240101*`. CLI suggests `migration repair` — **do not run that**.

## AM-22 — not proven (re-run after script fix)

Public SELECT:

```
anon SELECT verses → HTTP 200
[{"id":"bg_1_1","book_id":"bhagavad_gita","chapter_id":"bg_chapter_1"}]

anon SELECT parvas → HTTP 200
[{"id":1,"name":"ADI PARVA"}]
```

Schema-valid INSERT probes (`Prefer: return=minimal`):

**verses** — HTTP **201**, body empty.

```
anon INSERT verses → HTTP 201
FAIL: anon insert into verses succeeded. RLS lockdown is NOT live.
```

**parvas** — HTTP **401**:

```
{"code":"42501","details":null,"hint":null,"message":"new row violates row-level security policy for table \"parvas\""}
```

**Update:** 045 applied via SQL editor (not `db push`). Re-run: verses + parvas INSERT both HTTP **401** with `row-level security policy`. SELECT verses still 200 (`bg_1_1`). **AM-22 is done.**

Live cause: policy `Allow public all on verses` `FOR ALL USING (true) WITH CHECK (true)`. Local 042 drops different names (`Allow anon insert verses`) and was never applied. Closing the hole requires applying `20240101000045_drop_live_public_write_policies.sql` in the SQL editor (not `db push` of the whole 20240101 chain), then re-running `./scripts/verify_rls_lockdown.sh`.

## AM-2 recover files (local only — do not push this chain)

Live `pg_catalog` dump used for columns/FKs/indexes/CHECK constraints. Split so a fresh replay creates tables before later `ALTER`/`REFERENCES`:

| File | Why that slot |
|---|---|
| `202401010000181_recover_sacred_stories_and_texts.sql` | Before `00019` `story_pages` FK |
| `202401010000241_recover_user_journeys.sql` | Before `00025` `ALTER TABLE user_journeys` (no type/phase FKs yet) |
| `20240101000026_recover_user_journeys_fks.sql` | After `00026` creates `journey_types` / `journey_phases` |
| `202401010000321_recover_daily_tasks.sql` | Before `00033` adds `rewards_granted_at` |
| `20240101000044_recover_missing_production_tables.sql` | `push_tokens` only |

RLS on recover tables: public SELECT (or own-row), no public seed INSERT.
