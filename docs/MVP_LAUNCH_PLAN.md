# Antar Marg — MVP launch execution plan

Current execution backlog and verified local status: [REMAINING_LAUNCH_WORK.md](REMAINING_LAUNCH_WORK.md), updated 2026-09-17. The product scope below remains the plan; its original status paragraph is historical.

Date: 2026-09-14. Owner: Claude takes over primary integration at user request; see `CLAUDE_HANDOFF.md`. Status: plan complete; initial packaging-security changes and Firebase preflight correction implemented locally. Fourteen config-security tests and release config/preflight checks pass. No new signed release artifact or App Store submission exists. This document sets v1 scope and work order, not evidence of a completed release. Existing source edits and user data must be preserved.

**1. Product decision**

Build a Hindi/English daily Hindu spiritual-practice companion for adults in India and abroad who want a consistent practice but need an approachable starting point.

Promise: **A meaningful daily spiritual practice in 5–10 minutes, wherever you live.**

The initial promise is intentionally narrower than all Indians or all spiritual needs. Success means a person finishes a useful first practice, returns independently, and understands why a finished paid program is worth purchasing. No health, pregnancy, wealth, or spiritual-outcome guarantees.

Keep the existing Flutter/Riverpod/Supabase/RevenueCat architecture. Preserve four tabs and branding. No broad rewrite, new chatbot, social network, or Android release in this milestone.

**2. Launch scope**

| Area | v1 behavior | Deferred from new-user discovery |
|---|---|---|
| Aangan | Lightweight sanctuary with prominent Start/Continue today's practice; a few cosmetic rewards | Bundled 3D temple and large decoration catalog |
| Ashram | One understandable daily plan, one completion action per activity, optional reminder, practice-based progress | Multiple competing scores; unvalidated precise Panchang timings |
| Granthalaya | Curated reading; available journeys only; useful Hindi/English copy; pronunciation support on launch texts | Listen tab until a complete audio set works; 13 Coming Soon journey cards |
| Free program | A complete 7-day starter journey; no payment required to finish it | Large new course catalog |
| Paid programs | Existing Hanuman Chalisa 40-day program and a reviewed 21-day workday-reflection program, only after all published days/routes pass content QA | Pregnancy, preconception, newborn and other specialist programs pending qualified review |
| Profile | Progress, bookmarks, language, reminders, About/support, restore/manage purchases, account deletion | Debug controls and technical setup guidance in release UI |

A current user's existing journey or purchase must not disappear when discovery is simplified. Audit existing entitlements/enrollments before hiding access; preserve existing records, provide continuation or a clearly explained transition. Do not delete tables, historical progress, content, or assets merely because they are deferred.

App startup should offer an obvious first useful action. Preserve a skippable guest path and let users create an account when they want cross-device sync. Guest-to-account migration must be explicit and tested. Paid/cross-device state must be associated with the correct account.

**3. What customers buy**

Free: the complete starter routine, basic daily practice, curated scripture, essential reading settings, bookmarks, basic progress, and a simple sanctuary.

Pro: completed guided programs and the ongoing practice/reading conveniences that actually ship. Explain the concrete benefit and program contents before checkout. Do not market Coming Soon audio, unsupported every-verse commentary, medical improvements, or artificial scarcity as paid value.

Start with one Pro entitlement. Preserve the existing purchase integration rather than adding Plus/Pro/Lifetime complexity. Monthly/annual prices below are experiments, not established demand or configured store prices:

| Storefront hypothesis | Monthly | Annual |
|---|---:|---:|
| India | INR 149 | INR 999 |
| US reference | USD 3.99 | USD 24.99 |

Use App Store localized prices for Canada, UK and other storefronts; do not hard-code currency or savings text. Validate actual product offerings and paid benefits before making either option available. Two finite programs alone do not prove recurring subscription value: beta interviews must test whether ongoing utility justifies renewal. If customers primarily want a single course, choose a one-time course purchase before public sale instead of promising unspecified future content. Do not add lifetime pricing at launch.

Competitive context: Sadhana advertises free guided rituals and practices, so catalog size and temple visuals alone are a weak paid distinction. Our differentiator is approachable structure, reviewed bilingual guidance, and reliable continuity. This is a product hypothesis, not a proven market position. Source: https://sadhana.app/ (checked 2026-09-14).

**4. Execution order and owners**

Each task has one implementation owner. The primary agent reviews all diffs and integration evidence. Claude/Cursor work in isolated copies or worktrees; do not run two writers against shared files. Uncommitted edits in the current checkout must be included in the baseline before any isolation/merge operation.

| ID | Work | Owner | Depends on | Done when |
|---|---|---|---|---|
| L01 | Safe distributable configuration and artifact scanning | Smaller coding agent; primary review | None | Private tooling credentials cannot enter generated app config; synthetic malicious cases rejected; packaged app scanned before upload |
| L02 | Revoke exposed Confluence token | User/account owner | None | Owner confirms revocation; replacement stays outside shipped configuration; old builds treated as unsafe |
| L03 | Record current changes and establish integration baseline | Primary | None | Existing edits preserved, task ownership recorded, no accidental resets or lost work |
| L04 | Repair journey recurrence and date behavior | Primary | L03 | Once means once per journey; weekly uses defined week boundaries; daily rollover works; duplicate completion cannot duplicate rewards; pause/resume and 21/40-day boundaries tested |
| L05 | Account lifecycle and RevenueCat identity | Primary | L01, L03 | Guest, sign-in, restored session, sign-out, account switch and purchase restore use correct identity without inherited premium/progress |
| L06 | Authenticated account deletion | Primary/backend | L05 | Reauthenticated request deletes account-associated data with clear retention exceptions; Apple revocation handled; deleting account does not misleadingly promise subscription cancellation |
| L07 | Server entitlement enforcement | Primary/backend | L05; remote schema inventory | Authenticated server-verified entitlement controls paid bodies/media; public catalog stays browsable; webhook verification, replay/idempotency and expiry tested; no client-only grants |
| L08 | Free 7-day starter and paid content readiness | Claude draft/review, human editorial review, primary import | Scope above | Full content manifest, rights/source records, reviewed Hindi/English, no dead links, correct durations and complete published programs |
| L09 | Focus main experience and discovery | Primary | L04, L08 | Start today's practice prominent; only ready programs promoted; guest usable; no misleading empty tabs; existing user continuity preserved |
| L10 | About, support and bounded profile polish | Cursor handoff; primary if unavailable | Safe baseline; owner contact | About works in Hindi/English; support destination verified; no fabricated contact or production debug copy |
| L11 | Reader pronunciation and accessibility | Smaller agent after L09 | L08, L09 | Launch texts have reviewed transliteration where needed; readable text scaling/contrast; VoiceOver labels; preferences persist |
| L12 | Observability and production configuration | Primary + account owner | L01, L05 | Firebase plist valid; release crash and funnel events observed; data disclosures match actual SDK behavior; failures do not silently lose progress |
| L13 | Release-candidate device QA | Smaller QA agent + primary + user device | L04–L12 | Matrix below passes on rebuilt candidate, defects recorded against build number |
| L14 | Store assets, legal/support pages and review notes | Primary prepares; owner supplies identity/rights | Final scope, L10, L12 | Public URLs load; truthful screenshots/copy; privacy questionnaire and age rating match shipped app; reviewer access works |
| L15 | TestFlight and beta evaluation | Primary coordinates; owner/testers | L13, required L14 metadata | Candidate distributed, feedback triaged, technical and product exit conditions reviewed |
| L16 | App Store submission and monitored launch | Primary prepares/submits with available account access; owner handles agreements/2FA | L15, all blockers closed | Uploaded binary and configured products match QA evidence; submission accepted for review; approval tracked separately from submission |

Apple approval and customer willingness to pay cannot be guaranteed. Submission is not approval. No agent should claim completion from a source edit alone.

**5. Milestones**

M0 — Safe development: L01–L03. Never distribute old artifacts containing private credentials.

M1 — Trustworthy core: L04–L07 and Firebase setup. Test identity, recurrence and backend protection before UI polish makes them harder to inspect.

M2 — Focused MVP: L08–L12. At least one complete free journey and one fully reviewed paid program are release conditions. The second paid program is cut if it delays quality. A paid subscription still requires a defensible ongoing benefit; reduced content cannot silently weaken the advertised offer.

M3 — Candidate: L13–L14. Run current tests, focused new integration tests and physical-device checks. Capture build version, configuration checks, and artifact-scan output. Publish no placeholders.

M4 — Pilot and launch: L15–L16. Plan a minimum 14-day pilot to observe repeat use; longer if investigating renewal or longer-program completion. Engineering effort and delivery dates should be estimated after M0/M1 reveal backend migration and account setup constraints. External review timelines are not development commitments.

**6. QA and release gates**

| Area | Required evidence |
|---|---|
| Install/onboarding | Fresh install, guest first practice, Hindi/English, short screens and larger text, interruption/relaunch |
| Authentication | Apple and Google on intended build; cancelled login; expired session; deep link; cold start; guest migration |
| Account isolation | User A progress/premium/notes cannot appear for user B; logout clears relevant caches |
| Journeys | Day 1, final day, daily/weekly/once, midnight and time-zone changes, DST, duplicate taps, pause/resume, expired premium mid-program |
| Data integrity | Offline completion queues or clearly reports failure; reconnect is idempotent; progress survives kill/relaunch |
| Content | Every launch card opens; every promised day exists; Hindi/English and transliteration reviewed; source/rights manifest; audio only if playable |
| Purchases | Store-localized pricing, cancel checkout, purchase, restore on reinstall/second device, renewal/expiry, refund/revocation and account switch |
| Backend | Anonymous/free access denied paid bodies as designed; users isolated; valid entitled access succeeds; retry/replay cannot grant extra access |
| Privacy | In-app deletion and Apple revocation verified on disposable accounts; data inventory matches disclosures; no private text in analytics |
| Performance | Physical older supported iPhone plus current iPhone; background/resume, poor network, offline cold start; measure startup and jank |
| Binary | Correct bundle/version/signing, no test-store keys or premium overrides in release, no private token artifacts, Firebase and legal URLs verified |

Release requires zero unresolved critical/high-impact security, billing, account or data-loss defects. Analyzer errors must be zero; existing style warnings are triaged separately. The earlier 25 passing tests are a baseline, not release proof. Maestro records from September 2 do not verify later source changes.

Internal beta hypotheses, not industry benchmarks: 30–50 target testers split across India/diaspora and Hindi/English; at least 70% finish first practice without help; at least 30% of activated users complete a practice in days 6–8; interview users who leave; obtain actual purchase evidence from unrelated users once safe billing is available. TestFlight sandbox purchases prove billing mechanics, not willingness to spend real money. Do not interpret a small pilot as market proof. If users do not return, improve the routine before buying ads.

**7. User help required**

See `LAUNCH_OWNER_ACTIONS.md`. Owner reports paid Apple signing and a RevenueCat live offering with two packages. The correct Firebase plist exists at `ios/GoogleService-Info.plist`; the release script's path mismatch has been fixed and its check passes. App Store Connect and RevenueCat require Chrome sign-in before dashboard status can be verified. Owner reports antarmarg.app is not owned; use verified public hosting or obtain the domain before advertising it. Other dependencies are token revocation, safe test account and physical iPhone, named editorial reviewer, and real legal business/support identity. Secrets are entered in dashboards or local credential storage, never pasted into chat or agent task files.

**8. Deployment discipline**

The repository documents divergent Supabase migration histories. Do not blindly run `supabase db push` or rewrite remote migration history. Inspect the live schema, prepare narrowly scoped reversible migrations and backups, validate on a test database, then apply the reviewed release change. Avoid granting broad public access to make a failing screen work.

Broad authorization covers implementation and preparation. Account contracts, payment details, 2FA, qualified content review and App Review decisions may still require the owner or an external party. Ask for specific missing access only when needed; keep independent work moving.

**9. External requirements checked**

- Apple review guidelines: https://developer.apple.com/app-store/review/guidelines/ — complete working submission, truthful metadata, subscription value, privacy and religious-content accuracy.
- Account deletion: https://developer.apple.com/support/offering-account-deletion-in-your-app/ — in-app initiation and associated account data handling.
- TestFlight workflow: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/ — test candidate through Apple's beta distribution process.

Recheck the applicable requirements when preparing the actual submission; this plan is not legal advice or a promise of acceptance.
