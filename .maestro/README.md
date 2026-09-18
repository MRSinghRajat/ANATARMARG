# Maestro E2E flows

## Setup (already done on this machine, documented for a new machine/CI)

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
brew install openjdk
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH:$HOME/.maestro/bin"   # add to ~/.zshrc
```

Maestro needs a booted simulator/device with the app already installed (`flutter build ios --simulator --debug` + `xcrun simctl install`, or a real signed build on device).

**Source edits are not a verified fix.** After any Dart/Semantics change:

```bash
flutter build ios --simulator --debug
xcrun simctl install <device-id> build/ios/iphonesimulator/Runner.app
xcrun simctl terminate <device-id> com.antarmarg.app
xcrun simctl launch <device-id> com.antarmarg.app
maestro test .maestro/flows/<flow>.yaml
```

Device used here: iPhone 17 Pro, `ABB1F131-9FB5-4B1A-9FCD-DEAE41313A6C`.

## Running

```bash
maestro test .maestro/flows/01_smoke_tabs.yaml
maestro test .maestro/flows/                      # whole suite (skips nothing; 02 is destructive)
```

Recommended suite order on a signed-in sim: `01`–`17`, `19`–`21`, `24`, then `18` or `22` last (they sign out / clear prefs). Run `03` before `02`/`02b` when you need a fresh Little Sadhu journey.

Shared helpers: `_goto_granthalaya.yaml` (double-tap GRANTHALYA), `_sign_out_from_profile.yaml`, `_dismiss_coach_overlay.yaml`, `_skip_app_tour.yaml`. Do not use Maestro `--analyze`.

## Flows

| File | Covers | Status on rebuilt binary (2026-09-02) |
|---|---|---|
| `01_smoke_tabs.yaml` | 4 bottom-nav tabs | ✅ |
| `02_journey_switch_and_remove.yaml` | Switch + **Remove** journey | Destructive — skip on a real account |
| `02b_journey_switch_only.yaml` | Switch journey stays on Journey tab | ✅ (needs active journey — run `03` first on a clean account) |
| `03_start_little_sadhu_journey.yaml` | Setup wizard | ✅ (`journey_setup_field_child_name` Semantics; not idempotent if Little Sadhu already active) |
| `04_aangan_atma_mandir.yaml` | Aatma ↔ Mandir | ✅ |
| `05_granthalaya_listen_coming_soon.yaml` | AM-40 Listen Coming Soon | ✅ |
| `06_granthalaya_read_deities_stories.yaml` | AM-45 Vishnu + no test stories | ✅ |
| `07_paywall_copy.yaml` | AM-48/49 no Quests / loot copy | ✅ |
| `08_ashram_hub.yaml` | Ashram tab loads | ✅ |
| `09_profile_hub.yaml` | Profile + Settings | ✅ |
| `10_ashram_practices.yaml` | Today's Path + Practice Tools + Japa | ✅ |
| `11_journey_catalog.yaml` | Catalog + Little Sadhu | ✅ |
| `12_granthalaya_sacred_library.yaml` | Sacred Library/Stories, no test rows | ✅ |
| `13_aangan_shop_tiers.yaml` | Aatma shop; no loot-tier words | ✅ |
| `14_profile_bookmarks.yaml` | Bookmarks + Language | ✅ |
| `15_aangan_mandir_no_crash.yaml` | Mandir tab, AM-25 no crash | ✅ |
| `16_paywall_restore.yaml` | Restore visible in Customer Center | ✅ |
| `17_journey_flagship_listed.yaml` | AM-46 flagship journeys listed (not Coming Soon yet) | ✅ |
| `18_onboarding_language_persists.yaml` | AM-54 onboarding → Profile language | ✅ (`clearState`; ~3 min; ends logged out) |
| `19_journey_free_tier_gate.yaml` | AM-41 catalog + premium gate | ✅ |
| `20_granthalaya_book_reader.yaml` | Book list → chapter reader | ✅ |
| `21_sacred_text_reader.yaml` | Sacred text reader HI/EN toggle | ✅ |
| `22_profile_session_reset.yaml` | AM-27 sign out → login screen | ✅ |
| `24_offline_tabs.yaml` | AM-28 offline tab smoke | ✅ (`toggleAirplaneMode` works on this sim) |

## Gotchas (do not rediscover)

1. Duplicate-text traps (AppBar "Start Journey" vs button) — use `id: start_journey_submit`.
2. Accessibility gaps that were real VoiceOver bugs (fixed in source, prove with rebuild): Gender radios, Continue Journey, journey overflow menu. Semantics **label + child Text** becomes `"Read\nRead"` and Maestro `tapOn: "Read"` fails — use `excludeSemantics: true` or tap by `id`.
3. Nav-intent frame-timing: `_navigateTo()` setState is next-frame.
4. `inputText` can silently fail — always `assertVisible` the typed text. Journey setup name field: tap `id: journey_setup_field_child_name`, not the hint label.
5. Verify with rebuild + reinstall, not a code read.
6. `launchApp: stopApp: false` resumes leftover screen. After tapping GRANTHALYA once, the visible page can still be Profile — **tap GRANTHALYA twice** (`_goto_granthalaya.yaml`). Merged InkWell labels (`Today's Path\n2 Sep…`) need regex `.*Today's Path.*`. Pushed routes (Japa, Language) hide the tab bar — don't tap ASHRAM/PROFILE to go back.
7. Onboarding option tiles expose merged a11y labels (`🪔\nDaily`) — use regex `.*Daily.*`. Age options use en-dash (`26–35`).
8. Sign-out dialog has two "Sign Out" nodes — confirm with `index: 1` after `Are you sure you want to sign out?`.
9. Sacred Library / Sacred Texts horizontal rows — scroll `RIGHT` and prefer ids `sacred_library_book_*` / `sacred_text_tile_*`.

## AM-46 note

Live `journey_types` as of 2026-09-02 still have `is_coming_soon=false` for `hanuman-chalisa-40`, `work-stress-21`, and `gayatri-sadhana-40`. Do not add a failing Coming Soon assert until that data change is applied. Flow `17` only asserts the three titles are listed.

## AM-28 offline manual checklist

If `24_offline_tabs.yaml` fails on `toggleAirplaneMode` (some iOS Simulator builds), run manually:

1. Enable Airplane Mode on the simulator (Control Center or Settings).
2. Force-quit Antar Marg, relaunch.
3. Open each tab: AANGAN, ASHRAM, GRANTHALYA (Read), PROFILE.
4. Confirm: no infinite spinner, no blank white screen, no crash within 10s per tab.
5. Disable Airplane Mode and confirm tabs still load.

## Destructive flows

- **`02`**: removes an active journey — disposable test account only.
- **`18`**: `clearState` + full onboarding — ends logged out via Skip for now (~3 min).
- **`22`**: signs out — use `index: 1` on the confirmation dialog; run near end of session.
