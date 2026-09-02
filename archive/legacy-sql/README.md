# Archived root-level SQL

These files are byte-for-byte (or superseded) copies of numbered migrations under `supabase/migrations/`. Kept for history; do not run them against production.

`SUPABASE_CHANTS_SCHEMA.sql` also lived at repo root. It differs from `20240101000013_chants_schema.sql` only by a sample Shiva-chant `INSERT` that the numbered migration dropped. Archived here; that seed was intentionally not part of the tracked schema.

`supabase_migrations/add_is_premium_to_books_and_stories.sql` is folded into `supabase/migrations/202401010000181_recover_sacred_stories_and_texts.sql`.

Still at repo root (not duplicates of a numbered CREATE): `SUPABASE_PUSH_TOKENS.sql` (now in `00044`), `SUPABASE_MANIFESTATION_TASK.sql`, `SUPABASE_SEED_SACRED_TEXTS.sql`, and the old allow/fix seed helpers. Those were left in place because they are not byte-identical copies of tracked migrations.
