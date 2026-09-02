# AM-27 — Local cache isolation on sign-out

Classification of every `SharedPreferences.getInstance()` use under `lib/`.

## (a) Already namespaced per user — leave as-is

| Service | Pattern |
|---|---|
| `DailyStreakService` | `daily_streak_*_<uid\|device>` |
| `CoinService` | `coin_balance_<uid\|guest>` |
| `GranthalayaRecentService` | keys suffixed `_$_userPrefix` |
| Japa saved mantras | `japa_saved_custom_mantras_v1_<uid>` |

## (b) Intentionally device-global — not cleared on sign-out

| Key / service | Why |
|---|---|
| `language_code` | UI language |
| `sound_muted` + SoundManager volume | Device preference |
| Notification preference keys | Device-level opt-in |
| `onboarding_complete` | First-launch tour already seen on this device |
| Reader theme / font / layout | Reading chrome, not account data |
| Daily verse cache (`ashram_verse_*`) | Same public verse for every user that day |

## (c) User-scoped and **not** namespaced — cleared in `AppSessionReset`

| Key | Risk if left |
|---|---|
| `onboarding_user_name` | Previous user's display name |
| `sanctuary_customization_v2` + purchased/mandir keys | Previous sanctuary look + owned items |
| `granthalaya_bookmarks_sacred_*` | Previous bookmarks |
| `local_reading_progress` | Previous reading progress |
| `verse_bookmarks` / `verse_notes` | Previous notes |
| `user_items` / `user_avatar` | Orphaned gamification cache |
| `aangan_*_festival_bundle_*` | Owned festival cosmetics |
| `is_premium_override` | Dev override leaking Pro |

## In-memory reset (same hook)

On Profile sign-out, `AppSessionReset.onSignOut()` also:

1. `RevenueCatService.logOut()`
2. `PremiumService.resetSession()` (drops cached `isPremium`)
3. `CoinService.resetSession()`
4. `SanctuaryCustomizationService.resetSession()`
5. `DailyStreakService.setUserId(null)` (streak rows stay namespaced)

**Verify on device:** User A completes a task / buys a decor item → sign out → User B on the same phone should not see A's coins, sanctuary, bookmarks, or Pro badge before B's own fetch.
