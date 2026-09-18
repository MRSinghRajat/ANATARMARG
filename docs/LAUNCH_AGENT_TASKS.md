# Launch task ownership and delegation

Date: 2026-09-14. Main plan: MVP_LAUNCH_PLAN.md.

**Current status, 2026-09-17:** No delegated agent is running. Later implementation is present in this dirty working tree, including deletion jobs, reconciliation leases, content guards and UI changes. Use `docs/REMAINING_LAUNCH_WORK.md` for current proposed assignments and evidence. The ownership/status tables below are historical.

**Subsequent status update:** Claude's returned implementation is now present in `docs/CLAUDE_EXECUTION_LOG.md` and local source. L04 has reported test evidence; L05 remains partial; L06/L07 require corrections before deployment. Read `docs/L06_L07_DEPLOYMENT_REVIEW.md` for current assignments and acceptance gates. The initial handoff/launch-limit account below is historical, not the current implementation status. No new external agent session was started by this review.

**Current assignments**

| Agent/tool | Assigned work | Current status | Allowed writes |
|---|---|---|---|
| Prior primary agent | Product scope, integration, owner dependencies, launch plan and handoff | Handing lead ownership to Claude at user request | Completed local plan and release-preflight changes; no ongoing implementation claim |
| Smaller coding agent (`secure_packaging`) | L01 safe distributable config, generator/checker, regression tests, run/build wiring | Changes present; primary verified 14 synthetic tests and release config check; agent later usage-limited | No further active assignment; Claude reviews existing files |
| Smaller review agent (`release_plan`) | Read-only iOS/account/subscription release audit | Completed; Firebase path mismatch confirmed and corrected | None |
| Claude Code | Lead integration and execution of L04 onward; see CLAUDE_HANDOFF.md | User requested takeover; handoff ready; automatic launch blocked by prior session's usage limit | Owns next reviewed baseline after user starts Claude; preserve existing changes |
| Cursor | L10 bounded About/profile polish | Handoff prepared; not yet dispatched | Defined in CURSOR_LAUNCH_TASK_01.md only |

Neither an installed application nor a prepared prompt proves that an agent ran a task. Update this ledger using actual returned results.

User approved the sanitized brief export to Anthropic on 2026-09-14. The subsequent launch was blocked by automatic approval-review usage limits, so no Claude review or implementation result is claimed. See `CLAUDE_HANDOFF.md` for the exact takeover instructions and current verification evidence.

**Rules for all implementation agents**

1. Inspect git status and applicable AGENTS.md. Preserve unrelated changes. Do not reset, clean, stash or commit another person's work.
2. Use a separate worktree/copy based on the current reviewed baseline. A new worktree based on HEAD alone may omit uncommitted user changes; primary must prepare baseline first.
3. Touch only the assigned files. Request a handoff if a dependency requires another agent's file; do not have multiple concurrent writers.
4. Never print, copy into prompts, or package private credentials. Do not read root .env or build assets unless the assigned task explicitly requires local redacted credential checks. Never send credentials to another AI service.
5. Do not deploy, delete user data, change remote RLS, configure paid products, rotate credentials or submit to Apple as a side effect of a local task.
6. Return changed files, behavior before/after, checks run and their results, unresolved dependencies, and any screenshots/build identifiers needed to verify the claim. Tests must exercise behavior, not merely repeat implementation.
7. Primary reviews and integrates each result. Run targeted checks after each merge; full release checks on the final candidate. No agent marks the entire app ready from a passing unit test.

**Next primary implementation task — L04**

Scope: journey date/recurrence behavior, domain models as necessary, repository completion query and provider contract, focused tests. Define once-per-journey, weekly calendar boundary, daily local-date behavior, pause/resume semantics and idempotency before coding. Existing week/once rows in the live catalog must be tested against history, not only today's completion set. Preserve historical completions; do not alter production during a local fix. Check 21/40-day start/end and daylight-saving transitions. Resolve schema changes as a separate reviewed migration.

**Claude follow-on contract — L08 content manifest**

After explicit export approval and successful connection, Claude receives only sanitized source references and public editorial content. Produce `docs/content/STARTER_JOURNEY_DRAFT.md` and a machine-readable editorial manifest, not production SQL. Draft seven short daily practices with Hindi/English copy, time estimate, optional adaptations, reflection prompt, source attribution requirements and review status. Do not invent scripture quotes or claim medical, financial or guaranteed spiritual outcomes. Every item remains draft until reviewed. Primary owns schema/import and navigation; Claude does not edit those files.

**Smaller QA follow-on — L13**

After implementation integration, run the maintained Flutter suite and scoped Maestro flows against a rebuilt candidate and disposable account. Do not invoke destructive flows on the owner's account. Report exact build, OS/device, passed/failed paths, logs with secrets redacted and remaining manual checks. Do not modify production access policies to make tests pass.
