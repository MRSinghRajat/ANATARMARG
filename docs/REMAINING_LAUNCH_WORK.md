# Remaining launch work — agent handoff

Verified against local files on 2026-09-17. This is the current execution backlog; older handoffs and execution logs describe earlier drafts. No production deployment, finished subscriber backfill, new signed release candidate, TestFlight distribution or App Store submission has been verified. No delegated agent is currently running.

## Existing work: review and integrate, do not restart

| Area | Present in the checkout | Evidence and limit |
|---|---|---|
| L01–L03 | Public-only `.env.app` generation/scanning, Firebase preflight correction, launch plan | Earlier 14 config tests passed; exposed Confluence token revoked per owner. Recheck final binary. |
| L04 | Journey recurrence, pause/date and duration changes | Earlier 28 new tests and 53-test suite reported passing. Full device/data-integrity acceptance still outstanding. |
| L05 | Initial Supabase → RevenueCat identity wiring | Incomplete. Current code still records sync success after a failed identification and has no serialized identity transitions. |
| L06 | Apple identity verification/capture; durable deletion jobs, storage cleanup, retry worker, pending-state UI | Implementation and new tests exist. Agent work ended before a consolidated integration/test report; independently validate it. |
| L07 reconciliation | Shared `_shared/revenuecat.ts`, per-user fetch leases, fenced SQL writes, explicit Pro revocation, minimal event ledger, exact role grants | Earlier 9 Node tests passed; webhook Deno check passed; actual PostgreSQL/PGlite fixture passed permissions, isolation, transfers, rollback/retry, lease expiry and deletion exclusion. These were isolated tests, not production checks. |
| L07 content | Restrictive child-content policies, visible-parent checks, catalog body/media invariants, shared-content write guards | Agent reported actual PostgreSQL/PGlite suite passing, including legacy broad policies. Media delivery and production schema still need verification. |
| L08 | Original bilingual seven-day starter draft and editorial review packet | Not imported, approved or published. |
| L09–L11 | Focused journey discovery, Listen placeholder removed, bilingual About, scrollable reader settings, reader labels | Agent reported 6 focused Flutter tests and targeted analyzer passing. Final combined suite and physical accessibility checks not completed. |

The temporary Deno/PGlite installation under `/private/tmp/antarmarg-backend-tools` no longer exists. Recreate a reproducible test environment; do not cite the old path as usable. `docs/reviews/l06_l07_revision_probe.mjs` reproduces bugs in the previous draft and is not the acceptance suite for the current implementation.

## Assignment A — Flutter account and purchase correctness (L05, highest priority)

Suggested owner: Flutter agent/Cursor. Own `lib/core/services/revenuecat_service.dart`, relevant identity initialization/listeners in `lib/main.dart`, `lib/shared/services/premium_service.dart`, and associated tests. Coordinate changes to `app_session_reset.dart` with the deletion owner.

Remaining implementation:

- Only mark a user synchronized after SDK identification actually succeeds. Preserve retryability after failures.
- Serialize sign-in, logout and account-switch SDK calls. A delayed result for user A must never replace user B's customer information.
- Clear/suppress cached premium and customer information during identity transitions and after failed logout. Review SDK listener callbacks and asynchronous status refreshes for stale results.
- Handle restored sessions, signed-out/expired sessions, guest transitions and initialization races consistently.
- Require the intended account identity before purchase/restore operations that grant account-linked access. Preserve guest reading and the intended guest-to-account journey.
- Ignore persisted premium developer overrides in release builds. `PremiumService` currently reads `premium_dev_mode` without a release guard.
- Confirm paywall offers only the intended live monthly/annual products, uses localized prices, accurately describes current benefits, and retains previously purchased rights without introducing a new lifetime offer.

Done when: meaningful mocked SDK/platform-channel tests cover A → B, sign-out during pending sign-in, failed identification then retry, SDK initialization, stale callbacks, restore, and release override rejection. Finish with purchase/restore/account isolation on an actual signed build; mock tests alone do not close L05.

## Assignment B — Finish and verify account deletion (L06, highest priority)

Suggested owner: backend agent. Own Apple/deletion functions, the Apple and L06 migrations, and deletion UI changes only. Existing work should be reviewed and repaired as necessary, not replaced blindly.

Files: `supabase/functions/_shared/apple.ts`, `apple-auth-store/`, `delete-account/`, `account-deletion-worker/`; migrations `20260914015000_*` and `20260914020000_*`; relevant methods in `supabase_service.dart` and deletion section of `profile_screen.dart`.

Remaining acceptance work:

- Type-check all functions and run both new deletion/Apple test files. Add real SQL integration tests for the job/RPC lifecycle, linked-Apple identity, role permissions, storage ownership and data cleanup against a representative schema.
- Prove the Apple credential moves to a durable revocation job before source deletion; successful revocation erases it; an Apple outage remains retryable after Auth removal.
- Verify missing legacy Apple credentials, cancellation or failure of reauthentication, incorrect Apple account, non-Apple users, and a lost successful deletion response.
- Validate the shared advisory-lock/tombstone contract against entitlement reconciliation, in-flight storage uploads and stale access tokens. Recreated user rows or entitlements must be rejected.
- Review the entire associated-data inventory, retention periods, backups and third-party records. Complete any required provider cleanup/retention handling rather than assuming Supabase cleanup covers every service.
- Configure the background worker schedule, authentication secret, retry monitoring and alerting. A worker source file without a working schedule is not recovery.
- Review recent-authentication behavior against L06's acceptance criteria; local typing confirmation alone is not reauthentication. Localize the newly added deletion/Apple dialogs and explain pending completion accurately.

Done when: disposable Apple and non-Apple accounts are deleted in the deployed test environment; transient errors recover without the user's session; stored credentials and retained records follow the documented policy; monitoring identifies stuck jobs.

## Assignment C — Subscriber backfill and billing integration (L07, highest priority)

Suggested owner: billing/backend agent. Backfill has not been implemented.

- Build a dry-run-first tool using the SAME `reconcile` contract in `_shared/revenuecat.ts` and the SQL lease/fencing RPCs. Do not create a separate direct-upsert implementation.
- Enumerate authoritative existing customers/purchases with pagination. Resolve RevenueCat aliases to exact Supabase account ownership; flag ambiguous/unmatched paid identities. Never infer ownership from a similar email or name.
- Preserve current paid, promotional and previously sold lifetime rights. Honor refunds, expiry, grace periods and the chosen sandbox policy.
- Exclude deleted/nonexistent accounts. Verify that late backfill work cannot overwrite newer webhook state.
- Add rate-limit handling, retry/backoff, checkpoints, resumability, a bounded apply mode and redacted aggregate results. Keep customer exports and secrets out of source control and AI prompts.
- Validate webhook HTTP authentication, expected app scope, transfer payloads, duplicate events, database/API failures and acknowledgement behavior. Existing shared-module tests do not fully exercise the HTTP entry point.
- Schedule `prune_revenuecat_events()` or equivalent verified maintenance; defining the function alone does not enforce 90-day retention.

Done when: a representative dry run accounts for every current paying subscriber, discrepancies are resolved, reruns are safe, and staging backfill plus overlapping webhook events preserve correct access. A verified zero-existing-payers result is acceptable; assuming none is not.

## Assignment D — Production schema and paid media boundary (L07)

Suggested owner: security/database reviewer; coordinate migration ownership with B/C.

- Run the aggregate, read-only `docs/reviews/l07_content_preflight.sql` against the actual target. Resolve orphan, inactive-parent, inconsistent-reference and catalog-invariant violations before enabling policies.
- Review all exposed views, RPCs, table/column grants and inherited privileges. The old Guru RPC revocation migration still revokes only `anon`/`authenticated`; inspect and remove any remaining PUBLIC/inherited execution route if the functions must be inaccessible.
- Check the new infrastructure migrations against actual schema/history. They are not a generic idempotent production patch. Do not blindly run `supabase db push` into the documented divergent history.
- Audit full audio/video URLs and bucket flags. Several client paths use `getPublicUrl`; hiding a database row does not prevent access through an already-known public URL.
- For paid media that ships, implement authorized private delivery and update its client paths; otherwise exclude it from the paid offer and expose only deliberately free/preview assets. Avoid silently breaking existing purchased content.
- Exercise anonymous, signed-in free, current paid, expired/refunded, deleted and unrelated-user reads/writes through the real API, including direct child tables and media URLs.

Done when: safe catalog discovery works for free users, protected content remains inaccessible through alternate paths, and entitled users can complete every advertised route. See `docs/L07_CONTENT_ACCESS_VERIFICATION.md` for the local policy work already done.

## Assignment E — Finish content and the free starter (L08/L09)

Suggested owner: content/product agent for preparation; qualified human for final language/religious/rights review.

- Use `docs/MVP_CONTENT_EDITORIAL_REVIEW.md`; it already contains the seven-day English/Hindi draft. Create a machine-readable content/rights/review manifest and a narrowly scoped, repeatable import with a rollback strategy.
- Implement the starter in the existing journey framework with a real free entry point, seven-day duration, verified reading destinations, completion/progress and guest behavior. Add its approved slug to discovery only when it is usable.
- Verify all 40 Hanuman days and all 21 workday days, route references, duration, recurrence and missing-language states.
- Remove unsupported physiological promises from the actual published workday rows after reviewing the update. The packet flags cortisol, hemisphere-balancing and “rewiring” claims. Editing historical seed files alone will not change live content.
- Record translation, transliteration, audio and artwork sources/rights. Obtain human sign-off before publication.
- Keep deferred specialist programs out of new discovery while preserving current users' progress and legitimate continuation.
- Demonstrate sufficient ongoing value for the subscription; ship only benefits actually implemented. Reduce the paid catalog if the second program is not ready.

Done when: a fresh user can finish the entire free journey without paying, at least one approved paid program works end-to-end, and store/paywall descriptions match the delivered content.

## Assignment F — Final UI, accessibility and device QA (L10–L13)

- Keep the new About/discovery/reader work. Finish genuine support navigation once the owner provides the destination.
- Verify maximum text scaling, VoiceOver traversal, contrast, tap targets and Hindi layout throughout onboarding, library, daily practice, paywall, profile and deletion. Settings widgets do not prove pronunciation content is correct.
- Recheck repeated pause/resume cycles, midnight/time-zone/DST rollover, duplicate completions and reward idempotency. Verify offline failure/retry and persistence after termination against actual backend behavior.
- Run the full combined Flutter suite and analyzer after integrating all agents, then backend type checks and SQL/function tests. Record exact commands/results and commit/build identifiers.
- Build a fresh signed release candidate using `.env.app` only; scan the resulting artifact, not just source configuration. Verify Firebase crash and funnel events from a real device without private reading/journal content in analytics.
- Run the device matrix in `MVP_LAUNCH_PLAN.md`: fresh install, Apple/Google sign-in, cancellation, restore, A/B account switching, offline/resume, notifications, reader preferences, deletion and performance on older/current supported iPhones.

Done when: one identified release candidate has recorded evidence, no unresolved critical/high billing/security/account/data-loss issues, and an accurate residual-issue list. Existing tests or September 2 screenshots do not verify the final candidate.

## Assignment G — Legal/support hosting, store package and launch (L14–L16)

Agent can prepare: data/SDK inventory, revised legal drafts, support page, store description/keywords, subscription explanations, review notes/access instructions, screenshot shot list and screenshots from the final app, release checklist and tester instructions.

Owner inputs still needed: actual legal/business identity, support contact, controlled hosting/domain, content rights/reviewer, signed-in Apple/RevenueCat/Firebase access where required, agreements/tax/banking/2FA, disposable test accounts, physical iPhone and testers. Earlier owner report says `antarmarg.app` is not controlled; do not assume those URLs work now.

Verify current Apple submission requirements at submission time. Complete privacy/data disclosures and ratings against the real binary, confirm configured IAP products and review access, then distribute through TestFlight. Run the planned beta, resolve findings, and submit the same verified build. Submission and Apple approval are separate states. Sandbox purchases prove checkout mechanics, not actual demand.

## Integration order

1. Establish a baseline containing all current uncommitted/untracked changes. Never create a worktree from HEAD alone and accidentally omit the implementation.
2. A (Flutter identity), B (deletion) and E/F preparation can proceed in parallel with non-overlapping file ownership. C/D coordinate with B on schema and identity contracts.
3. Recreate pinned backend test tooling and run all local suites; retire the old bug-reproduction probe as an acceptance command.
4. Validate target schema and staging deployment, schedules, permissions and content routes.
5. Deploy reviewed additive infrastructure/functions through the authorized process; configure and verify worker/webhook delivery; backfill and reconcile existing access.
6. Enable restrictive content policies only after billing reconciliation and content/media preflight pass. Recovery must repair grants without reopening all paid content.
7. Complete final content, app/device QA, hosted support/legal and store setup; TestFlight; submission.

Each agent must return changed files, before/after behavior, actual test results, unresolved dependencies and any required owner actions. Do not route around an approval rejection. Do not label local source changes deployed or passing unit tests launch-ready.

## Paste into the next lead-agent session

> Take over Antar Marg from the current working tree. Read docs/REMAINING_LAUNCH_WORK.md first, then docs/MVP_LAUNCH_PLAN.md. Preserve all current tracked and untracked changes; older handoff documents contain stale status. Finish assignments A–G in dependency order, delegating independent work with explicit file ownership. Start with RevenueCat identity correctness, deletion integration tests and a dry-run subscriber backfill using the existing reconciliation contract. Recreate reproducible backend tooling. Continue content, accessibility and store preparation independently. Do not publish unreviewed content or activate restrictive RLS before backfill/preflight pass. Keep secrets and customer records out of prompts and logs. Record exact test/build evidence, deployment state and concrete owner-only blockers. Continue authorized implementation; do not stop at writing another plan.
