# Claude Code handoff — Antar Marg launch

Handoff date: 2026-09-14. Claude is now the requested lead developer/integrator. The user asked to continue the solution through Claude while the prior development session is usage-limited. This is an execution handoff, not a request to write another generic plan.

**User intent and authorization**

Make the existing Flutter app a focused, sellable iOS MVP and prepare it for TestFlight and Apple App Store launch. Audience: Indians in India and abroad, initially Hindi/English adults interested in Hindu daily spiritual practice. User authorized implementation and AI delegation, including sending a sanitized architecture/strategy/security brief to Anthropic. Never send private credentials, account tokens, user records, private notes, or raw environment files to an AI service. Use local redacted validation where configuration is needed. Account access, 2FA, contracts and qualified editorial review can require owner involvement.

**Read first**

Current execution status (2026-09-17): read `docs/REMAINING_LAUNCH_WORK.md` before the historical reviews below. It accounts for subsequent implementation, interrupted agent work and remaining verification.

0. `docs/L06_L07_SECOND_REVIEW.md` — latest review (2026-09-15), remaining backend defects and executable diagnostic probes. Then read `docs/L06_L07_DEPLOYMENT_REVIEW.md` for the first review. These supersede the initial task order below.
1. `docs/MVP_LAUNCH_PLAN.md` — product choices, work IDs L01–L16, dependency order, acceptance criteria and QA gates.
2. `docs/LAUNCH_AGENT_TASKS.md` — ownership ledger; Claude now assumes primary integration ownership.
3. `docs/LAUNCH_OWNER_ACTIONS.md` — latest confirmed account dependencies.
4. `docs/CURSOR_LAUNCH_TASK_01.md` — isolated optional Cursor task.
5. Applicable AGENTS.md/CLAUDE.md if any; then git status and current diffs. Older project docs can be stale; verify against code.

**Current product direction**

Preserve the four-tab architecture and distinctive branding. Put a 5–10 minute daily practice first. Offer a complete free seven-day starter journey, curated Hindi/English reading, bookmarks, dependable practice progress and a lightweight Aangan. Finish one or two paid programs (existing Hanuman 40-day and a reviewed workday-reflection program) before adding more. Hide unfinished discovery cards and Listen until useful audio is ready. Defer elaborate 3D, inaccurate local Panchang timings, and pregnancy/newborn guidance pending appropriate review. Preserve current users' existing journeys and purchases when simplifying discovery.

One Pro entitlement; no new lifetime tier. Monthly/annual prices in the plan are hypotheses only. Two finite programs alone do not establish recurring subscription value. Ensure the paid offer describes only what ships and test renewal value. Never guarantee sales, health, wealth, religious outcomes, or Apple approval.

**Completed changes already present — inspect rather than redo**

- `pubspec.yaml` now bundles ignored `.env.app`, not the original `.env`.
- `lib/main.dart` loads `.env.app`.
- `scripts/prepare_app_config.py` generates only allowlisted public client settings from local source configuration.
- `scripts/verify_app_config.py` checks generated config and supports `--release` and IPA scanning. It rejects non-allowlisted settings, original `.env` assets, invalid/non-anonymous Supabase keys, release test-store keys and enabled debug/premium overrides. Offline JWT checks validate payload format/role, not signature authenticity. Artifact scanning is bounded and does not prove absence of every arbitrary encoded secret.
- Root `run_app.sh`, `scripts/run_app.sh`, and `scripts/build_testflight.sh` are wired to config generation; release script verifies before and after building.
- `.gitignore` ignores `.env.app`; README and main release instructions explain the changed workflow.
- `scripts/check_ios_release_config.sh` now checks `ios/GoogleService-Info.plist`, matching Xcode's actual top-level resource path. No plist download is needed: the file exists and has the correct bundle ID.
- Launch plan, task ledger, owner actions and Cursor prompt are on disk.

There are additional current changes to `.env.example`, `.env.confluence.example`, `.gitignore`, and `scripts/publish_confluence_overview.py` from concurrent work. Do not overwrite or claim authorship of these without inspecting their intent. Never display environment values while reviewing them.

**Verification evidence and limits**

Last direct handoff checks, 2026-09-14:

```sh
python3 -m unittest scripts/tests/test_app_config.py
# 14 tests passed, synthetic credentials only
python3 scripts/verify_app_config.py --release
# passed against local generated config, no values printed
bash scripts/check_ios_release_config.sh
# passed for com.antarmarg.app
git diff --check
# passed
```

Earlier in this session, all 25 existing Flutter tests passed after initial config isolation. The later config-validator tightening was checked with the 14 Python tests above; do not claim a new complete device or release test from those results. Earlier full analysis had zero errors, 52 warnings and 1,030 informational findings. These counts may change with ongoing edits.

No new signed IPA was built or uploaded in this work. No production migrations were applied. No current release purchase/restore test, full signed-in visual walkthrough, or physical-device QA was completed. Old build folders may contain unsafe original `.env` assets; do not upload them. Rebuild and scan the exact candidate.

**Owner confirmations**

- Exposed Confluence API token: owner replied **done** to revocation on 2026-09-14. Record as owner-confirmed, not independently verified. Do not rotate it again or request it in chat.
- Paid Apple Developer setup reported; local signing team `7UKFX7T5ZS`, bundle `com.antarmarg.app`.
- Firebase project `antarmarg-8308e`; iOS plist exists at `ios/GoogleService-Info.plist`. Release crash/analytics/push delivery still need verification.
- RevenueCat uses an Apple public SDK key, Test Store off, entitlement `Antar marg Pro`. Owner reports simulator offering `Antarmarg Live` with two packages. Actual App Store product status and dashboard mapping remain unverified. Do not infer that a lifetime product is required just because legacy constants exist.
- Owner reports `antarmarg.app` is not owned/registered. Existing legal URLs must be replaced by verified public hosting or the owner must acquire the domain. Do not assume website control or buy a domain without a specified purchase authorization.
- Connected Chrome was checked. App Store Connect and RevenueCat both showed login screens. Two tabs were left for sign-in. No passwords were entered. Owner was asked to sign in and reply “dashboards ready”; no such confirmation had arrived at handoff.
- Owner explicitly approved exporting the sanitized brief to Claude. The final attempt was blocked by the previous session's automatic approval reviewer **usage limit**, not an outstanding user denial. No successful Claude response exists from that attempt.

**Known defects and starting priorities**

1. Validate existing security/config changes with the checks above. Confirm production build wiring and preserve private development-only configuration separation. Do not spend time rebuilding work that is already correct.
2. Implement L04: journey recurrence and date behavior. Current `JourneyLogic.getTodaysTasks` passes daily/weekly/once identically; providers compare only today's completions. Live catalog contained 10 weekly and 23 once-only rows. Query required completion history, define week/calendar/time-zone semantics, and test duplicate completion/rewards, pause/resume, day one/final day and 21/40-day programs. The progress helper also defaults generic timed journeys to 90 days and starts at day zero; inspect actual visible usage before changing it. Do not confuse a helper defect with a verified visible screen defect.
3. Implement L05–L07: RevenueCat/Supabase identity synchronization, account isolation, authenticated deletion with Apple revocation, server entitlement enforcement. `RevenueCatService.identifyUser` exists but had no caller. Some premium task bodies were readable with the public anonymous API key. Public catalog browsing can remain, but protected paid bodies and private user data require correct server authorization. Verify existing remote schema first.
4. Implement L08–L12: reviewed starter content, focused discovery, guest usability, profile polish, transliteration/accessibility and analytics. Use current files as the baseline and keep paid promises truthful.
5. Run L13–L16: rebuilt device QA, legal/support hosting, store assets, TestFlight, beta evaluation, then submission. Ask for exact account access when it blocks the next action; continue independent local work meanwhile.

Critical backend note: repository docs describe divergent Supabase migration histories. Do not blindly `supabase db push`, run destructive migration repair, or delete data. Recover/read the schema, prepare explicit changes, test in isolation, preserve backups and review production application separately. Never solve a permission failure by broad public grants.

**Protect current work**

The working tree is dirty. At handoff, pre-existing edits included realtime notifications, book notes, library, sacred-text reader, journey home/setup, main navigation, notification settings and premium service; additional files changed during this session. Run git status yourself for the current truth. Do not reset, clean, stash, overwrite, or commit unrelated changes. A new worktree based only on HEAD omits uncommitted improvements; prepare a reviewed baseline before splitting work.

You are the single integrator. If delegating to Cursor or smaller agents, assign separate files/tasks and inspect each diff before merging. `docs/CURSOR_LAUNCH_TASK_01.md` is prepared but has NOT been dispatched. Its Profile file will overlap future account-deletion work: reserve it explicitly, or do the About task first, then hand the file back. Stop agents when their task ends; don't leave concurrent writers on the same checkout.

**First response and execution expected from Claude**

Briefly acknowledge the handoff, inspect current status and read this plan, run safe baseline checks, then start implementing L04 with focused behavioral tests. Maintain a short progress log in `docs/CLAUDE_EXECUTION_LOG.md` with task IDs, changed files, actual checks, remaining dependencies and next step. Do not return another lengthy plan and stop. Do not describe the app as launch-ready until the release gates have evidence. Owner decisions and final public release must be tied to a concrete reviewed artifact and the actual account/tool permissions available.
