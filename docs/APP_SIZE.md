# Why the app is ~340 MB (and how to reduce it)

## What adds up to ~340 MB

Rough breakdown:

| Source | Approx size | Notes |
|--------|-------------|--------|
| **Flutter engine + Dart AOT** | ~25–40 MB | Framework + your compiled code. |
| **Native plugins** | ~80–150 MB | Firebase, Supabase, RevenueCat, Google/Apple Sign-In, WebView, etc. Each adds native libs. |
| **Bundled assets** | ~75–80 MB | After removing duplicate (see below). |
| **App Store / Play packaging** | +overhead | Bitcode, symbols, encryption – can add 20–50 MB. |

So **~340 MB** is normal for a Flutter app with auth, push, IAP, and rich assets.

---

## What we already fixed

- **Duplicate `temple.glb`** – The same 3D model (~64 MB) was in both `assets/html/` and `assets/models/`. The WebView only uses `assets/html/temple.glb`. The copy in `assets/models/` was removed and `assets/models/` was dropped from `pubspec.yaml`. **Saves ~64 MB** → you should see install size drop to around **~275 MB** after a clean build.

---

## Remaining large assets (optional to shrink)

| Asset | Size | Option to reduce |
|-------|------|-------------------|
| **assets/html/temple.glb** | ~64 MB | Re-export from 3D tool with fewer polygons or LOD; or host online and load at runtime (adds network). |
| **Rive (.riv)** | ~5 MB total | Remove unused animations; simplify in Rive editor. |
| **Sounds (MP3/WAV)** | ~4 MB | Re-encode at lower bitrate (e.g. 96 kbps) or use shorter clips. |
| **Fonts** | ~2.8 MB | Subset fonts to used glyphs; or drop a font family you don’t use. |

---

## Plugin impact

These add noticeable native size:

- **Firebase** (Core + Messaging)
- **Supabase**
- **RevenueCat** (Purchases)
- **Google Sign-In** / **Sign in with Apple**
- **WebView** (for 3D Mandir)
- **Rive**

Removing a whole feature (e.g. one auth or IAP SDK) can save tens of MB, but only if you’re willing to drop that feature.

---

## Quick checks

- **Debug vs release**: Release builds are smaller. Measure install size with a **release** build (e.g. `flutter build apk --release` or archive in Xcode for iOS).
- **ABI (Android)**: `flutter build apk --split-per-abi` produces one smaller APK per CPU type; the store may show a lower “download size” per device.
- **iOS**: App Thinning and bitcode can reduce the size users actually download.

After the duplicate-removal fix, do a clean build and check the new size; further reductions come from shrinking the GLB, Rive, sounds, and fonts as above.
