# Why the app is large (and what we already cut)

Measured **1 Sep 2026** after AM-32 / AM-35 / AM-39 (fonts bundled+subset, deity WebP). These are **on-disk asset** numbers from this repo, not an App Store “download size” — that still needs a signed release IPA on a device (see AM-38).

## Bundled assets right now — **~72 MB** total (`du -sh assets`)

| Asset | Size | Notes |
|--------|------|--------|
| **`assets/html/temple.glb`** | **64 MB** | Single largest file. AM-36 (re-export with texture compression) is the remaining big lever. |
| **`assets/fonts/`** | **2.6 MB** | All 11 families the app actually uses, subset to used scripts/weights. Was ~2.8 MB for only 5 families. |
| **`assets/images/deities/`** | **2.3 MB** | 12 WebP files at max 1024px. Was **47.8 MB** of 2048px PNGs (−45.6 MB). |
| Other images / audio / html / onboarding | ~3 MB | |

Flutter engine + Dart AOT + native plugins (Firebase, Supabase, RevenueCat, Sign-In, WebView, …) still dominate **install** size. Asset work does not change that part.

## What we already fixed

- **Duplicate `temple.glb`** — a second 64 MB copy under `assets/models/` was removed earlier.
- **Deity images (AM-35)** — 2048px PNGs → 1024px WebP. Sanctuary `Image.asset` and the 3D Mandir WebView both use `.webp`.
- **Fonts (AM-32 + AM-39)** — Poppins, Tenor Sans, Outfit, Cinzel, Noto Sans/Serif Devanagari are bundled next to the original 5. `GoogleFonts.config.allowRuntimeFetching = false` so a missing file fails locally instead of hitting `fonts.gstatic.com`. Latin families are subset to Latin + punctuation; Devanagari families keep the Devanagari block. The `pubspec.yaml` `fonts:` section was removed so the same TTFs are not embedded twice.

## Remaining large lever

| Asset | Size | Option |
|--------|------|--------|
| **`assets/html/temple.glb`** | 64 MB | AM-36: re-export from the 3D source with KTX2/Basis textures and/or fewer polygons. Do not host-on-CDN until that is tried. |

## Release build (AM-38)

`scripts/build_testflight.sh` now runs:

```bash
flutter build ipa --obfuscate --split-debug-info=build/debug-info
```

Keep `build/debug-info/` with the release. Crashlytics (AM-19) cannot symbolicate obfuscated crashes without it. `build/` is gitignored — archive the folder outside the repo.

## How to measure install size

- **iOS**: archive via `./scripts/build_testflight.sh`, then App Store Connect → TestFlight → the build’s **install size**. Do not reuse the old ~340 / ~275 MB figures; they predate feature removal and this asset work.
- **Sanity check without signing**: `flutter build ios --release --no-codesign` then `du -sh build/ios/iphoneos/Runner.app`.
