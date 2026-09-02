# Color system (AM-50)

`AppColors` is a timeline of mockup palettes, not a design system. Canonical tokens exist; migrate screens onto them instead of inventing new golds.

## Canonical tokens (`lib/core/theme/app_colors.dart`)

| Token | Hex | Also currently named | Role |
|---|---|---|---|
| `AppColors.canvas` | `#0F1115` | `backgroundDark`, `ashramBackgroundDark` | Near-black canvas |
| `AppColors.brandGold` | `#D4AF37` | `journeyGold` | Primary gold |
| `AppColors.brandSaffron` | `#FF9933` | `journeyPrimary`, `ashramAccentSaffron`, `saffron` | Saffron accent |

Do **not** use `manuscriptDark` / `charcoalDark` (`#121212`) for new work. Do **not** add another gold.

Legacy section names (Panchang, Academic Dashboard, Prayer, Granthalaya Light) stay until that screen migrates. Remap those screens onto the three tokens; do not delete the old names in one shot.

## Phase 2 — screen order (living checklist)

One high-traffic surface at a time. Hardcoded hex on a screen → `canvas` / `brandGold` / `brandSaffron` (or zinc text tokens already in the file).

- [ ] Ashram (`ashram_screen.dart` + practice screens)
- [ ] Aangan / sanctuary (`aangan_screen.dart`, `customizable_om_sanctuary.dart`, `sanctuary_shop_sheet.dart`)
- [ ] Granthalaya Read (`books_library_screen.dart` and readers)
- [ ] Profile + paywall
- [ ] Journey screens
- [ ] Onboarding
- [ ] Remaining (Panchang, shop/quests if still reachable after AM-14)

Progress is this checklist, not 762 one-off tickets.
