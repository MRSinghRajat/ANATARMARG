# L06/L07 second review — 2026-09-15

**Decision: fix the remaining backend defects before building the backfill writer.** A read-only subscriber inventory/dry-run design can proceed independently. Neither L07a nor L07b is approved for production by this review. Claude remains implementation lead; this turn reviewed source and produced diagnostic evidence, without starting another Claude session or changing production.

The revision improves transaction atomicity, parses transfer identity arrays, specifies the Pro entitlement, adds child-content policies, and separates infrastructure from restrictive policies. Those improvements do not yet close all seven original findings.

## Blocking findings

### R2-01: cleanup removes the Apple token before revocation reads it

`supabase/functions/delete-account/index.ts:61` calls cleanup first. `supabase/migrations/20260914020000_l06_account_deletion_support.sql:111` deletes `apple_auth_tokens`. The handler then queries that table at line 83. On the normal successful cleanup path there is no token left, so Apple is never called and the result says `not_applicable`.

The SQL comment says revocation happens before cleanup, which contradicts the actual handler. Merely reversing the calls is insufficient for outage recovery: the handler also deletes the token after a false revocation result. Persist a minimal, restricted revocation job before erasing the credential, retain it only as needed for retry, and report pending versus complete accurately. Cover Apple outage, missing credentials, previously registered Apple users with no stored token, and a lost response after successful deletion. Apple's [account-deletion technote](https://developer.apple.com/documentation/technotes/tn3194-handling-account-deletions-and-revoking-tokens-for-sign-in-with-apple) describes token revocation.

**Acceptance:** stored-token deletion calls Apple; transient failure remains recoverable after app/auth data removal; retries do not require an auth account that has already been removed.

### R2-02: a full snapshot is applied as upserts only

`supabase/functions/revenuecat-webhook/index.ts:130` can produce an empty entitlement array. The SQL at `supabase/migrations/20260914010000_l07a_entitlement_infrastructure.sql:138` only loops over supplied rows and upserts them. It never clears absent entitlements. A transferred-away or removed entitlement can therefore remain active, indefinitely for an old lifetime grant. Correct transfer parsing alone does not fix previous-owner access.

Pass an explicit affected-user set, including users with empty snapshots, and atomically reconcile the complete managed entitlement set for each user. Distinguish a validated empty response from malformed responses and API failures. Do not erase entitlements belonging to another provider or scope.

**Acceptance:** current paid → empty snapshot revokes Pro; transfer removes the losing account's grant and grants the receiving account; retries and duplicate events preserve correct state.

### R2-03: concurrent snapshot requests can still regress state

Fresh fetching improves delayed-event handling but is not concurrency control. Request A can fetch the older state, pause, and write after request B fetches and writes newer state. Both have different event IDs, so the replay ledger admits both. The SQL has no freshness fence and unconditionally replaces the row.

Serialize reconciliation per subscriber across fetch and commit using a durable job/lease with fencing and recovery, or implement an equivalently demonstrated freshness protocol. A database lock acquired only after fetching does not fix an already-stale snapshot. Backfill and webhook processing must use the same protocol. Transfers require deterministic coordination of the affected users.

**Acceptance:** force the older fetch to complete after a newer reconciliation; final state must remain current. Also test lease expiry/crash recovery and overlapping transfers.

### R2-04: privileged RPC permissions are not established explicitly

The migration ends with `REVOKE ... FROM PUBLIC` for `apply_revenuecat_event`, but does not revoke direct `anon`/`authenticated` grants or explicitly grant `service_role` execution. Its comment that the service role bypasses grants is incorrect. Depending on target default privileges, client roles might still execute a function that writes arbitrary grants, or the webhook might lack execution permission. Actual target ACLs were not queried in this review, so this is an unresolved deployment/security gate, not a claim of a demonstrated live exploit.

Revoke execution from PUBLIC, anon and authenticated for this exact function signature; grant it to service_role. Inspect inherited/default privileges too. Prove anonymous and authenticated RPC calls fail and service-role calls succeed. Apply the same explicit permission review to new secret tables and the separate RPC-revocation migration. Supabase documents [function privileges and role-specific revocation](https://supabase.com/docs/guides/database/functions#function-privileges).

### R2-05: snapshot validation and access semantics remain incomplete

At webhook lines 135–136, a missing `expires_date` is converted to null and interpreted as active forever. The local probe reproduced this with an empty entitlement object. A malformed date string instead reaches the database as an invalid timestamp, failing the whole transaction rather than producing the claimed inactive snapshot. Validate the response schema and dates before applying any update; explicit legitimate lifetime null must be distinguished from a missing field.

The implementation ignores grace-period fields, and labels the entire fetched snapshot with the triggering event's environment. That event may describe a different transaction from the current snapshot. RevenueCat's [customer response](https://www.revenuecat.com/docs/api-v1/customers) includes grace dates and transaction-level sandbox information. Establish and test the intended access semantics and environment provenance instead of claiming every lifecycle case is automatically covered by fetching alone. Enforce configured app scope with explicit handling for events lacking app_id.

### R2-06: account-deletion and content boundaries still need completion

- `apply_revenuecat_event` has no deleted-user check or auth-user foreign key. A later webhook can recreate an entitlement row after cleanup. Reconciliation and deletion need coordinated state and tests for in-flight and subsequent events.
- Raw webhook payload retention is unchanged. Define deletion/redaction and bounded retention for identifiers, aliases and subscriber attributes, including any minimal deletion/revocation records.
- `apple-auth-store` stores an exchanged token under whichever Supabase user calls it. `_shared/apple.ts` discards the returned identity token. Validate the Apple identity and bind its subject to the caller's verified linked Apple identity before storing a credential. Add a mismatched-account rejection test and observable recovery for failed fire-and-forget capture.
- `sacred_stories.pages` remains publicly readable. Use a protected body path and safe catalog projection, or enforce a database invariant prohibiting premium inline bodies. A projection alone is insufficient if the original table remains readable. Do not rely solely on today's zero-premium count.
- Test hidden/inactive parents and missing parents: the new `NOT EXISTS(premium parent)` policies can treat an RLS-hidden parent as absent. Prefer proving an eligible visible parent rather than granting access because a premium parent was not visible. Audit media URLs/storage separately.

## Evidence and limits

Ran `node docs/reviews/l06_l07_revision_probe.mjs` from the repo root. Four diagnostic probes confirmed the current handler behavior:

1. Cleanup followed by token lookup returns deletion success with zero revocation calls.
2. Empty subscriber state sends zero rows, with no explicit affected-user parameter; static SQL inspection confirms no removal operation.
3. A delayed older snapshot reaches the RPC after the newer snapshot; static SQL inspection confirms no freshness check.
4. An entitlement object missing expiry generates an unlimited active grant.

The probe executes actual handler source with Node's TypeScript syntax stripping, mocked external services, and synthetic identifiers. SQL cleanup behavior is mocked from the reviewed SQL statement; PostgreSQL itself was not executed. This is a diagnostic reproduction of defects, not a green acceptance suite, Deno type check, native-device test, or production audit. After fixes, replace these defect assertions with behavioral regression tests of the corrected contract.

## Next instruction for Claude

Fix R2-01 through R2-06 locally, prioritizing Apple cleanup ordering, snapshot removal, concurrency control and explicit RPC permissions. Add executable backend tests before claiming closure. Set up Deno/PostgreSQL checking in an isolated local or CI environment if this workstation cannot run them; do not substitute the 57 Flutter tests. Keep L05–L07 partial.

Then build the subscriber backfill using the SAME tested reconciliation contract: dry-run by default, authoritative account mapping, pagination, rate-limit retries, checkpoints, idempotent resume, production/sandbox distinction, deleted-account exclusion, legacy-purchase preservation and redacted discrepancy totals. Never log credentials or customer records into AI prompts. The backfill must not overwrite newer webhook state. Resolve unmatched paid identities before restrictive RLS activation. Continue independent Cursor UI/accessibility work without overlapping file writers.

No owner decision is needed to correct these code defects. Account-only configuration remains a later dependency; deployment restrictions remain separate from code readiness.
