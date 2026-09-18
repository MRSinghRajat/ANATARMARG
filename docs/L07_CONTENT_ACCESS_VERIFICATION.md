# L07 content access implementation and activation checks

Updated 2026-09-15. Local source changes only; no claim of production deployment or media protection verification.

## What the migration now enforces

`supabase/migrations/20260914030000_l07b_activate_premium_rls.sql` adds restrictive SELECT guards for the `anon` and `authenticated` roles. Historical permissive read policies may have different names, and an extra permissive policy otherwise reopens content through OR semantics. These guards AND with existing policies. Shared-content writes also have restrictive client-role guards and revoked editorial privileges, so old seed policies or accidental column grants cannot let an app user reclassify paid content as free. See [PostgreSQL's policy rules](https://www.postgresql.org/docs/15/sql-createpolicy.html).

Tasks require an active, visible journey and phase and either explicitly free task + free journey or Pro access. Books/chapters/verses require consistent, visible parents; if an optional `is_active` field exists it must be true. Story pages require active, visible stories. Content-pool rows require an active, visible journey and a visible matching task in that journey, so a premium task inside a free journey cannot disclose its pool body. Null, orphan, inactive or RLS-hidden parents fail closed even for Pro users. Existing shared/unlinked pool rows need explicit ownership before release; the preflight reports them rather than guessing their access rights.

The public catalog stays readable for discovery. Validated constraints prohibit inline `sacred_stories.pages` and full story audio/video on premium catalog rows, and full book audio on premium book catalog rows. Existing violations stop activation without deleting content. Move full bodies/media to protected children before retrying. Free inline stories remain supported. Cover images, cover video and trailers are public promotional assets; never put paid full media in those fields.

Both known journey views use the querying role's RLS. This does not prove unknown views, security-definer RPCs or storage endpoints are safe; the verification inventory exposes those for review.

## Executable local policy tests

Run `psql -X -v ON_ERROR_STOP=1 -f supabase/tests/l07_content_rls.sql` against an EMPTY, disposable PostgreSQL 15+ database. The fixture refuses a database with `public.books`, uses synthetic identities/content and rolls everything back. It applies the actual migration twice and tests anonymous/free/Pro roles, legacy permissive policies, direct child queries, both journey views, hidden/inactive/missing/null parents, inconsistent book/chapter references, premium tasks inside free journeys, catalog visibility and rejected inline premium body/media writes.

Local verification: the fixture passed on the actual PostgreSQL engine in PGlite (WASM), including applying the migration twice, legacy broad write policies, a later accidental column UPDATE grant, rejected client insertion/TRUNCATE and premium catalog invariants. It can also run with `PGLITE_MODULE=/absolute/path/to/@electric-sql/pglite/dist/index.js node supabase/tests/run_content_rls.mjs`. The PGlite dependency was installed outside the repo in a temporary tool directory; no project runtime dependency changed.

The entitlement function is deliberately a synthetic fixture: this tests content policy decisions, not RevenueCat reconciliation or production schema parity. Entitlement lifecycle and native app purchase tests remain separate requirements. The production schema must be compared against this migration before activation because tracked and remote histories differ.

## Media boundary and release evidence

Run `docs/reviews/l07_content_preflight.sql` as a trusted operator. It emits aggregate violations and media-reference counts, bucket public flags, applicable policy definitions, journey view settings and privileged RPC names. It does not print customers, object paths, credentials or full URLs. Required invariant and orphan counts must be zero (or the content deliberately removed from launch and inaccessible).

Repository media paths that require verification:

| App/read path | Storage or URL boundary |
| --- | --- |
| `supabase_granthalaya_datasource.dart` `_resolveAudioUrl` / chant loading | Calls `getPublicUrl` for the configured bucket/path. This is a public delivery path, not entitlement enforcement. Keep only free/preview audio there until private delivery is implemented. |
| `chapters.audio_url*`, `story_pages.audio_url*`, `journey_content_pool.audio_url*` | Hiding rows prevents discovering URLs through that query, but does not revoke already-known public media URLs. |
| `garbh_sanskar_content.audio_storage_path`, `video_url` | Check the corresponding bucket or external origin separately. |
| `sacred_stories.pages` JSON | Only free stories may use inline bodies after this migration. Review nested media independently. |
| Catalog `cover_image_url`, `card_image_url`, `cover_video_url`, `trailer_url` | Intentionally public marketing assets; verify they contain only previews. |
| Task/pool `content_ref`, `ref_type`, `ref_id` | Following references to sacred texts, other books or external pages must preserve the intended access class. Public religious texts can be free while the surrounding guided journey is paid. |

For each paid full-media reference, use a controlled staging content fixture and test the exact known object URL without credentials, with a free account, with Pro, and after expiration. Public object URLs must not return the paid body to an anonymous request; guessing resistance is not access control. Private Supabase objects need a short-lived signed URL issued only after server entitlement verification, or an authenticated download governed by storage policies. External origins need equivalent access enforcement. Do not make a shared bucket private blindly: first inventory its free/preview consumers and implement the paid delivery path.

Record status and byte counts or content hashes, never access tokens or signed URLs. Verify expired signed URLs deny reads; previously downloaded offline copies cannot be remotely erased by RLS. No premium-media launch claim is valid until these HTTP tests pass. Restrictive row policies alone do not meet this gate.

After staging migration, also test real PostgREST reads of each protected table/view using anonymous, free, current Pro, expired Pro and unrelated-entitlement accounts. Check a premium catalog card remains visible and the app offers upgrade while its full body is denied. Confirm editorial clients cannot mutate premium flags through public seed/write policies. Test migrations within a transaction with error-stop enabled, and keep L07b last, after verified subscriber backfill.
