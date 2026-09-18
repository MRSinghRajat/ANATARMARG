# Full-App Maestro Testing & Fix Initiative

Goal: test every major screen/flow in Antar Marg with Maestro, find what's broken, fix it, and prove the fix by rebuilding — not by re-reading the source and assuming it works.

---

## 0. Already done — don't redo this part

- **Maestro + Java are installed on this machine**, PATH persisted in `~/.zshrc`:
  ```bash
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH:$HOME/.maestro/bin"
  ```
- **`.maestro/config.yaml`** exists (`appId: com.antarmarg.app`).
- **24 numbered flows** (plus `_goto_granthalaya.yaml`) live under `.maestro/flows/`. **Pass/fail matrix and gotchas: read [`.maestro/README.md`](../.maestro/README.md) first** — it is more current than this section.
- Core regression flows already proven on a rebuilt binary include tab smoke (`01`), journey switch/remove (`02`), Aangan/Granthalaya/Profile hubs (`04`–`17`), and inventory gaps filled in `18`–`24` (onboarding language, free-tier journey gate, readers, session reset, offline smoke).

**If setting up on a new machine:**
```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
brew install openjdk
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH:$HOME/.maestro/bin"   # add to ~/.zshrc too
xcrun simctl list devices available   # find/boot a simulator
cd /path/to/ANATARMARG
flutter build ios --simulator --debug
xcrun simctl install <device-id> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <device-id> com.antarmarg.app
maestro test .maestro/flows/
```
No API tokens, no cost — this is a local, free, open-source tool. The only paid feature is the optional `--analyze` flag; don't use it unless explicitly asked.

---

## 1. Gotchas already learned — do not rediscover these

1. **Duplicate-text traps.** Any screen where the AppBar title matches a button's own text (e.g. the journey "Start Journey" screen) — `tapOn: "text"` hits the *first* match, usually the title, not the button. Use a `point:` percentage tap instead, or better: add the widget a `key`/testID so this stops being fragile.
2. **Real accessibility gaps, not Maestro bugs.** Two elements were found completely invisible to `tapOn` text matching despite rendering visibly on screen: the Gender radio rows on the journey setup wizard (Step 3/5), and the "Continue Journey" button on an active-journey card. These are likely missing `Semantics` wrappers on custom-painted widgets — **this affects real VoiceOver users too**, not just test automation. Treat as a real bug to fix (see Epic C below), not just something to work around with coordinates forever.
3. **Frame-timing rule for this app's nav-intent pattern.** `MainNavigationScreen._navigateTo()`'s `setState()` only schedules a rebuild for the *next* frame — it does not synchronously build a newly-shown lazy tab. Any provider write meant to be picked up by that tab's `initState` listener (the `xPendingTabProvider` pattern used for Aangan and now Granthalaya) must be deferred one extra `addPostFrameCallback`, or the listener won't exist yet to catch it. This bit the first version of the AM-fix for Switch/Remove journey — it looked correct in code review and silently didn't work until this was found by actually rebuilding and testing.
4. **`inputText` can silently fail right after `tapOn` on this simulator/driver combo.** Confirmed intermittent (~1-in-3) on the journey setup's "Child's name" field — the step reports `COMPLETED` but the text never lands. A short `waitForAnimationToEnd` before `inputText` did not fully fix it. Always add `assertVisible: "<the text you just typed>"` immediately after any `inputText` step, so a silent failure fails loudly right there instead of cascading into a confusing failure three steps later. If this needs solving properly: try `eraseText` before `inputText`, or consider Patrol (Dart-native driver) for text-heavy screens specifically.
5. **Verifying a fix requires an actual rebuild — editing source is not enough.** The installed app on the simulator is a separate binary from the source tree. The loop that actually proves something is fixed:
   ```bash
   flutter build ios --simulator --debug
   xcrun simctl install <device-id> build/ios/iphonesimulator/Runner.app
   xcrun simctl launch <device-id> com.antarmarg.app
   maestro test .maestro/flows/<the flow that caught the bug>.yaml
   ```
   Re-editing source and re-running Maestro against the *old* binary will "prove" a bug still exists when it's actually already fixed in source — this happened once already this session.
6. **When a flow gets stuck mid-screen from a previous manual test run**, `launchApp: stopApp: false` resumes wherever the app was left, not the tab bar — leading to confusing "tab not found" failures that have nothing to do with the flow itself. `xcrun simctl terminate <device> com.antarmarg.app` before a clean run avoids this.

---

## 2. Full-app flow inventory to build

Organized by the app's 4 tabs, based on everything mapped across this project's audits. Each row is a candidate Maestro flow file. Use the gotchas above while writing every one of them.

### Aangan (home)
- Aatma ↔ Mandir toggle switches correctly, both render without crash.
- 3D Mandir: temple loads, "Start Arti" is tappable, backgrounding the app mid-scene doesn't crash on resume (this exact behavior was fixed earlier this project as AM-25 — a regression flow here is high value).
- Sanctuary customization shop opens; item tier labels read "Traditional/Festival/Sacred/Exclusive" (post-AM-49 fix) — **not** "Common/Rare/Epic/Legendary", which would mean that fix regressed.

### Ashram
- Daily tasks list loads and a task can be marked complete (coin/karma reward).
- Habit creation (add a custom habit, confirm it appears).
- Practice sub-screens open without crash: gratitude, dana, evening aarti.
- Daily verse card opens the verse detail screen.

### Granthalaya — Read mode
- Books list → book detail → chapter reader opens; Hindi/English content shows per the `localized()` system (AM-32/60 work) — verify no fallback-font flash, verify Hindi actually renders when language is set to Hindi.
- Sacred Texts list → reader opens, HI/EN toggle works.
- Sacred Stories list → reader opens (verify the 3 deleted test rows — "Test mythology/leela/moral" plus the 2 "Test Story" rows from AM-53 — do **not** appear anywhere in the list).
- Deities list shows all 12 (post-AM-45 addition of Vishnu/Narasimha/Kartikeya/Indra) with real content on each detail page.

### Granthalaya — Listen mode
- Confirm it shows the Coming Soon state (AM-40), not the old sparse real audio screens. If this regresses back to showing real screens with near-zero content, that's a real bug to catch.

### Granthalaya — Journey mode
- Catalog list: the 3 currently-broken "flagship" journeys (Hanuman Chalisa 40-Day, 21-Day Stress-Free Working Life, 40-Day Gayatri Sadhana — confirmed live via direct DB query to have 0 tasks) should show a Coming Soon treatment once `AM-46`'s data fix (`is_coming_soon = true` for those 3 slugs) actually lands — **verify this is applied**; it was proposed but not yet confirmed done as of this doc.
- Journey setup wizard (5 steps) completes and creates an active journey — reuse/fix `03_start_little_sadhu_journey.yaml`.
- Active journey home screen: tasks list, phases, milestones all render.
- **Switch journey** and **Remove journey** — already covered by `02_journey_switch_and_remove.yaml`; keep this as a permanent regression guard, this exact bug already slipped through once.
- Free-tier journey access (`AM-41`, if implemented): a free-tier test account can open Journey mode and see the free journeys (Navratri, Shravan Maas, Kartik Maas, Little Sadhu, Pitru Paksha) without hitting a paywall redirect, while premium ones correctly redirect.

### Profile
- Streak/level/XP display renders.
- Achievements and bookmarks screens open.
- Language settings screen: switching Hinglish ↔ Hindi actually changes visible text elsewhere in the app (cross-screen check, not just the settings screen itself).
- Sign out → sign in as a different account: confirm no stale data from the first account appears before real data loads (this is what `AM-27`'s `AppSessionReset` was built to prevent — a Maestro flow here is a strong permanent regression guard for a subtle bug class).
- Subscription/Customer Center screen opens.

### Auth / Onboarding
- Fresh install → onboarding flow → language toggle → sign-in screen. Confirm the language choice made during onboarding is still in effect once the main app loads (this is exactly the `AM-54` bug: onboarding's language toggle used to be silently discarded).
- Google Sign-In and Apple Sign-In both reach the main app (these may need manual/device testing rather than full simulator automation, depending on how much of the native flow Maestro can drive in this environment — note that rather than force it).

### Paywall
- Paywall screen opens from an upgrade prompt.
- Feature list shown does **not** include "Quests" or "18 parvas" (AM-48 — that feature isn't reachable from navigation, advertising it would be selling something that doesn't exist).
- Feature list uses devotional tier language, not "rare/epic/legendary" (AM-49).
- Restore Purchases button is present and tappable (full purchase-flow testing needs a real device + sandbox account — out of scope for simulator Maestro flows, note this rather than skip silently).

### Cross-cutting
- Airplane-mode pass: toggle network off, open each of the 4 tabs fresh, confirm no infinite spinner/blank screen/crash (this was flagged as `AM-28` — a good candidate for an actual Maestro flow using device network toggling if the driver supports it, otherwise document as a manual step).

---

## 3. Process to follow

1. Pick one area from the inventory above. Check `.maestro/README.md` and this doc's gotcha list first — don't rediscover a known issue.
2. Write the flow. Run it against the **current** installed build to get a real baseline (don't assume the code is right — this project has repeatedly found that "looks right in review" and "actually works" are different things).
3. For every failure, triage before touching code:
   - **Real app bug** → fix the source.
   - **Real accessibility gap** (element invisible to the accessibility tree despite being visible on screen) → fix the widget's semantics, don't just route around it in the test forever.
   - **Test flakiness** (timing, duplicate text, etc.) → fix the flow, using the gotchas list.
4. For every source fix: **rebuild, reinstall, relaunch, rerun the same flow** (see gotcha #5) before claiming it's fixed. Screenshot the before/after if reporting back, the way this session did for the Switch/Remove journey fix.
5. Report back per finding: what was broken, what the fix was, and confirmation the *rebuilt* app now passes the flow — not just "should be fixed now."
6. New backlog items from this work should continue the existing `AM-` numbering scheme used throughout `docs/JIRA_STORY_BACKLOG.md`, `docs/GO_LIVE_BACKLOG.md`, and `docs/PERFORMANCE_SIZE_BACKLOG.md` — check those files for the current highest number before assigning new ones.
