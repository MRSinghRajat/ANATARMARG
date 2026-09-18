# L06/L07 implementation review and next execution order

Reviewed 2026-09-14 against local source and `CLAUDE_EXECUTION_LOG.md`.

**Follow-up:** the revised implementation was reviewed on 2026-09-15. Read [the second review](L06_L07_SECOND_REVIEW.md) for current defects, diagnostic evidence and execution order. Findings below describe the first draft.

**Decision: continue implementation; do not deploy the current L06/L07 drafts as-is.** The reported environment deployment restriction is separate from these code defects. Claude remains lead integrator. This review does not change production, rerun the Flutter suite, or claim a new Claude execution.

## Findings to resolve before deployment

1. **A failed entitlement write becomes permanently deduplicated.** In `supabase/functions/revenuecat-webhook/index.ts:88`, the event ledger insert commits before the entitlement upsert at line 129. If that upsert fails, the request returns 500, but its retry returns success at the duplicate-key branch without applying the entitlement. Make the database update and completion marker atomic, or implement a durable pending/processing/completed job with safe retries and recovery. Only completed work may be acknowledged as already processed. Test injected failure between those two operations and concurrent duplicate deliveries. RevenueCat documents [retries and duplicate deliveries](https://www.revenuecat.com/docs/integrations/webhooks).

2. **Transfer events are parsed incorrectly.** The handler requires `app_user_id` before inspecting the event type, then treats `TRANSFER` as an ordinary activation. RevenueCat transfer payloads instead identify `transferred_from` and `transferred_to`. Reconcile both sides, including previous-owner removal, using verified subscriber identity. Cover restore/transfer, anonymous aliases, and account switching. Also cover non-renewing purchases if any were sold, refunds, grace periods and deferred product changes; the current event allowlist is insufficient. See [RevenueCat's event definitions](https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields).

3. **Entitlement state can regress, and its scope is too broad.** The handler blindly replaces state using delivery order. A delayed expiration can overwrite a newer renewal. The SQL helper accepts any active entitlement, and the webhook has no app/environment allowlist. Reconcile authoritative subscription state with per-customer concurrency control and recovery; RevenueCat [recommends fetching subscriber state](https://www.revenuecat.com/docs/integrations/webhooks). Enforce the exact configured Pro entitlement. Explicitly separate production grants from test grants while supporting TestFlight and Apple review purchases through a documented sandbox policy. Reject malformed dates rather than converting them into unlimited access.

4. **The RLS coverage is incomplete as a reviewed design.** The migration changes parent tables, chapters, verses and one view. It does not establish protection for all child-body paths, such as `story_pages`, `verse_translations`, `journey_content_pool`, or media storage. The app directly queries story pages and the journey content pool. Task policies also inspect only the task's premium flag, not its parent journey. Inspect actual grants/policies and prove protection for every direct table, view, RPC and media path. These omissions require verification; this review does not claim each path was separately exploited against production.

5. **The proposed RLS removes paid discovery for free users.** Filtering premium `books` and `journey_types` rows also hides their catalog cards from existing queries. Provide a safe metadata projection for browsing and upgrade prompts, separate from protected content bodies. Verify that free users can discover the paid offer without downloading paid bodies.

6. **Deletion is not complete across the new backend.** The deletion SQL predates L07 and does not remove `user_entitlements`; the webhook ledger retains raw payloads with subscriber identifiers. Inventory storage and third-party records too, define minimal retention with an explicit duration, and prevent late webhooks from recreating deleted-account records. The two-step deletion flow can leave an auth account after app-data deletion; implement a recoverable, idempotent completion process with accurate user status. Test both failure stages using disposable accounts.

7. **Apple token revocation remains required work.** The deletion function explicitly omits it. Implement and test the server-side flow for Sign in with Apple, with private keys held only in server secrets. Request owner assistance only for missing account configuration. Apple's [account deletion guidance](https://developer.apple.com/support/offering-account-deletion-in-your-app) calls for revoking Sign in with Apple tokens. Deletion and cancellation of an App Store subscription are separate actions; preserve clear subscription-management guidance.

## Required implementation and deployment sequence

1. Claude fixes the above locally and adds backend tests. Run Deno type checking plus meaningful function/SQL integration tests; Flutter tests do not exercise these Edge Functions or RLS policies.
2. Reconcile local migration history with the target schema. Split additive entitlement infrastructure from restrictive policy activation so backfill can happen first. Do not blindly push the historical migration directory.
3. Validate the corrected schema, webhook and deletion flow in an isolated backend using synthetic/disposable accounts. Include anonymous, signed-in free, current paid, expired paid and a second unrelated account.
4. Prepare a dry-run backfill from authoritative RevenueCat subscriber state. Report counts and unresolved identity mappings without exporting customer records into AI prompts. Preserve existing subscriptions and any previously sold lifetime access. Do not guess mappings from similar names or emails. A verified zero-existing-customers result is acceptable evidence; an assumption is not.
5. Through the authorized deployment process, deploy additive infrastructure and the corrected webhook, backfill, reconcile events arriving during backfill, then enable reviewed content policies. Confirm paid access, free catalog visibility and direct-content denial immediately. Prepare recovery that repairs entitlements without broadly reopening paid content. A tool approval rejection is not permission to use another route to evade it.
6. Complete release-device purchase, restore, account-switch and deletion checks before marking L05–L07 accepted.

## Parallel assignments

| Owner | Work now | Acceptance evidence |
|---|---|---|
| Claude | L05 verification and L06/L07 fixes above | Backend tests, migration/backfill plan, failure recovery, device evidence where available |
| Cursor | L10 About/support/profile polish; then L11 reader accessibility | Working destinations, loading/error states, large-text layout and VoiceOver results |
| Claude after backend work, or a separately assigned reviewer | L09 discovery audit and L08 draft content manifest | Finished products discoverable, unfinished offerings hidden, preserved existing progress; source/rights/review status for every launch item |
| Owner | Account-only steps and human review | Apple/RevenueCat configuration, hosted legal/support identity, content reviewer and physical-device participation |

Cursor must coordinate profile-file ownership with Claude's deletion UI changes; sequential handoff is preferable to concurrent edits. These are task assignments for the next sessions, not claims that an external agent has been started.

## Corrected status and launch gate

- L01–L04: previously reported implementation/verification evidence remains in the existing log; L02 is owner-confirmed.
- L05: implemented in part; the execution log itself labels this partial. Four new guard tests do not establish native SDK identity, restore or account isolation.
- L06/L07: drafts needing the fixes and verification above, in addition to deployment access.
- L08–L11: continue independent work. Human editorial approval blocks publication, not preparing a reviewable draft. Cursor ownership does not mean the task has run.
- L12–L16: release build observability, device QA, real legal/support hosting and store assets, TestFlight, then submission remain outstanding.

The product plan is executable. The release is not ready. Completion requires a verified release candidate and store prerequisites, not merely a passing Flutter unit-test count.

## Message for Claude

Continue as lead integrator. Read this review and the existing launch plan. Fix and test L06/L07 before proposing production deployment, including retry-safe entitlement synchronization, transfer handling, complete content access coverage, subscriber backfill and Apple token revocation. Keep L05 partial until identity/restore evidence exists. Prepare the smallest independently deployable stages and a recovery runbook. Continue L09/content preparation when independent; coordinate Cursor's L10/L11 file ownership. Preserve current changes and customer access. Update the execution log with actual checks, precise remaining blockers and required owner actions. Do not mark a deployment or device test complete from local code alone.
