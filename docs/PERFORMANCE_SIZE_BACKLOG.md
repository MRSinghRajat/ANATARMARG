# Antar Marg — Performance & Size Backlog (AM-32 onward)

Continues `docs/GO_LIVE_BACKLOG.md`. Every finding below is grounded in something actually measured in this repo just now — not generic "optimize your app" advice. Two goals, and they pull in opposite directions in a couple of places (called out explicitly): make startup feel smoother, and make the binary smaller.

---

## EPIC K — Startup smoothness ("the ping/jank on launch")

### AM-32 · Bundle the fonts the app actually uses, stop fetching them over the network
**Priority:** P0 — this is very likely the main cause of the jank you're seeing · **Labels:** performance, fonts

**Context:** `pubspec.yaml` bundles exactly **5** font families as local assets (Cormorant Garamond, Crimson Pro, Inter, Libre Baskerville, Plus Jakarta Sans). But a full grep of `lib/` for `GoogleFonts.*` calls shows the app actually uses **11** families, with these call counts:

| Font | Call sites | Bundled locally? |
|---|---|---|
| `GoogleFonts.inter` | 409 | ✅ yes |
| **`GoogleFonts.poppins`** | **361** | ❌ **no** |
| `GoogleFonts.crimsonPro` | 109 | ✅ yes |
| **`GoogleFonts.tenorSans`** | **63** | ❌ **no** |
| `GoogleFonts.cormorantGaramond` | 56 | ✅ yes |
| **`GoogleFonts.outfit`** | **36** | ❌ **no** |
| **`GoogleFonts.notoSerifDevanagari`** | **23** | ❌ **no** |
| **`GoogleFonts.cinzel`** | **21** | ❌ **no** |
| `GoogleFonts.plusJakartaSans` | 18 | ✅ yes |
| **`GoogleFonts.notoSansDevanagari`** | **11** | ❌ **no** |
| `GoogleFonts.libreBaskerville` | 5 | ✅ yes |

`lib/main.dart` explicitly sets `GoogleFonts.config.allowRuntimeFetching = true` — so every one of the ~515 call sites using an unbundled family fetches that font from Google's CDN the first time it's rendered (per device, until the OS-level cache holds it — which can be evicted). This causes: a visible fallback-font flash + reflow the first time each screen renders, a real network stall on a slow/cold connection, and on a first-launch-with-no-network case, broken/inconsistent typography with no bundled fallback.

**Acceptance criteria:**
- [x] For each of the 6 unbundled families (Poppins, Tenor Sans, Outfit, Noto Serif Devanagari, Cinzel, Noto Sans Devanagari), either:
  - (a) bundle them the same way the existing 5 are — download the actual font files and add them to `assets/fonts/` + declare in `pubspec.yaml`'s `fonts:` section, matching the existing pattern, **or**
  - (b) use the `google_fonts` package's own local-asset bundling convention (placing the exact `.ttf` under the path it expects) so the existing `GoogleFonts.poppins()` call sites don't need to change at all — check the installed `google_fonts` package version's README for the current mechanism before choosing this path.
- [x] Once all 11 are bundled, set `GoogleFonts.config.allowRuntimeFetching = false` in `main.dart`. This is the real fix, not just an optimization — it makes a missing-bundle regression fail loudly (fallback font, obviously wrong) instead of silently doing a network fetch that happens to work in your test environment but not everywhere.
- [x] Devanagari fonts are typically large (full script coverage) — see AM-39 below before finalizing, since bundling all 6 as-is could add meaningful size back. Do AM-32 and AM-39 together, not AM-32 alone.

**Verification:** Fresh install, airplane mode on, launch the app and navigate through every tab — no fallback-font flash anywhere, no crash, no blank text. Confirm via `flutter build ipa --analyze-size` (or equivalent) that no runtime font fetch is attempted (a debug-mode network log during first launch showing zero requests to `fonts.gstatic.com`/`fonts.googleapis.com` is the clearest proof).

---

### AM-33 · Parallelize independent startup awaits
**Priority:** P1 · **Labels:** performance

**Context:** `main.dart`'s `main()` currently does, in sequence, before `runApp`: `dotenv.load()` → `await SupabaseService().initialize()` → `await Firebase.initializeApp()` (+ its follow-on setup). The Supabase and Firebase initializations don't depend on each other's results — they're awaited sequentially only because that's how the code reads top to bottom, not because either needs to finish first.

**Acceptance criteria:**
- [x] After `dotenv.load()` (which both may depend on for config), run `SupabaseService().initialize()` and `Firebase.initializeApp()` concurrently via `Future.wait([...])`, keeping each in its own try/catch so a failure in one doesn't cancel the other (the existing per-service error handling — "app works without it" — must be preserved).
- [x] Everything already deferred to `addPostFrameCallback` (push notifications, RevenueCat, avatar service, image cache, sound manager) stays deferred — this story is only about the two blocking awaits before first frame.

**Verification:** Time-to-first-frame measurably drops (or at minimum doesn't regress) — check with `flutter run --profile` and the DevTools timeline, comparing before/after.

---

### AM-34 · Verify Aangan tab's animation cost at first paint (investigate, don't assume)
**Priority:** P2 · **Labels:** performance, verification

**Context:** `aangan_screen.dart` (the first tab shown on launch) creates 9 separate `AnimationController`s. Flutter's ticker mechanism should already pause/cheapen these when off-screen, and the heavier work (Mandir WebView, `_initializeServices()`) is already correctly deferred to a post-frame callback or gated behind an explicit user tab switch (confirmed — the 3D WebView does **not** load eagerly). This story is genuinely a verification task, not an assumed bug.

**Acceptance criteria:**
- [ ] Profile a cold launch with Flutter DevTools' timeline view, specifically looking at the frame(s) rendering the Aangan screen. If any of the 9 controllers show up as a real cost in the first few frames (jank bars in the timeline), stagger their start (e.g. via `Future.delayed` with small offsets) rather than starting all 9 in the same frame.
- [ ] If profiling shows this isn't actually a meaningful cost, close this out with the profiling data as evidence rather than making speculative changes.

---

## EPIC L — App size reduction

### AM-35 · Compress the deity images — biggest fast win
**Priority:** P0 · **Labels:** size, assets

**Context:** `assets/images/deities/` contains 13 PNG files, several enormous for what's rendered on a phone screen:

| File | Size |
|---|---|
| indra.png | 6.2 MB |
| narasimha.png | 6.0 MB |
| kartikeya.png | 5.3 MB |
| rama.png | 4.7 MB |
| lakshmi.png | 4.6 MB |
| saraswati.png | 4.0 MB |
| durga.png | 3.7 MB |
| hanuman.png | 3.2 MB |
| ganesha.png | 3.2 MB |
| shiva.png | 2.5 MB |
| krishna.png | 2.4 MB |
| vishnu.png | 2.0 MB |

That's **~48 MB** for 13 images — almost certainly shipped at a far higher resolution/bit depth than any phone screen displays them at. The app already has the right instinct for this elsewhere: `lib/core/services/compressed_image_cache.dart` resizes *network* images to a 1024px max — these bundled deity images just never went through an equivalent process before being added to the app.

**Acceptance criteria:**
- [x] For each deity image, determine the actual maximum display size in the app (check `deity_detail_screen.dart` and wherever else they're rendered) and resize to roughly 2x that (for retina displays), not larger.
- [x] Re-export as WebP (best compression, Flutter supports it natively) or, if WebP support needs verifying across all render paths first, a properly compressed PNG/JPEG at the reduced resolution.
- [x] Target: each file under ~200–400 KB with no visible quality loss at actual display size — a 90%+ reduction is realistic here given the current sizes.
- [ ] Visually compare before/after on a real device at the actual display size before calling this done — don't just trust the file-size number.

**Verification:** Total `assets/images/deities/` size drops from ~48 MB to a few MB; visual spot-check on-device shows no perceptible quality loss.

---

### AM-36 · Shrink the 3D temple model
**Priority:** P1 (bigger effort, biggest single asset) · **Labels:** size, assets, 3d

**Context:** `assets/html/temple.glb` is **64 MB** — the single largest asset in the app by far. `docs/APP_SIZE.md` already flagged this as the top lever and notes a duplicate copy was previously removed (saving another 64 MB) — this is the one that's left.

**Acceptance criteria — pick one path and document the choice:**
- [ ] **Option A (recommended first attempt):** re-export the model with texture compression (e.g. KTX2/Basis Universal, which glTF supports) and/or reduced polygon count / texture resolution from the original 3D source file. This keeps the model fully bundled (offline-capable, no added network dependency) and can often cut 60–80% of the size with careful texture work.
- [ ] **Option B (bigger change, only if A isn't enough):** host the model on Supabase Storage or a CDN and download-on-first-use with local caching, showing a one-time "downloading temple" state. This trades app size for a network dependency and added complexity (offline handling, download progress UI, cache invalidation on model updates) — don't take this path without confirming Option A was actually tried first.
- [ ] Whichever path: confirm the WebView-rendered scene still looks acceptable on a real device after the change — this is a visual asset, not just a number to shrink.

**Verification:** Install size drop of tens of MB; 3D Mandir view still renders correctly and at acceptable visual quality on-device.

---

### AM-37 · Audit for unused dependencies
**Priority:** P2 · **Labels:** size, tech-debt

**Context:** `pubspec.yaml` currently declares 55 dependencies. A lot of feature removal has happened recently (AI Guru, dead Garbh Sanskar screens, orphaned modules pending a decision in AM-14) — worth checking whether any package was only ever used by something that's now gone.

**Acceptance criteria:**
- [ ] For each dependency, grep for actual usage in `lib/`. Flag any with zero real call sites (test/dev-only tooling excluded).
- [ ] For each flagged package, confirm it's genuinely unused (not just imported indirectly) before removing it from `pubspec.yaml`.
- [ ] Re-run `flutter pub get` and the full test suite after removal.

**Verification:** `flutter analyze` and `flutter test` stay clean after removal; binary size doesn't need to be re-measured for this one specifically (native size impact varies by package, some are Dart-only with zero native footprint) — this story is about hygiene as much as size.

---

### AM-38 · Turn on release build size optimizations + get a real baseline
**Priority:** P1 · **Labels:** size, release

**Context:** `docs/APP_STORE_PRODUCTION.md` already lists `flutter build ipa --obfuscate --split-debug-info=...` as "optional hardening" — it's still not done. Separately, the existing `docs/APP_SIZE.md` numbers (~340 MB, then ~275 MB after de-duplicating `temple.glb`) predate all of the recent feature removal and asset work — they're stale.

**Acceptance criteria:**
- [ ] Build a real release IPA (`flutter build ipa --release`) and get the actual current install size — don't reuse old numbers.
- [x] Add `--obfuscate --split-debug-info=build/debug-info` to the release build process (`scripts/build_testflight.sh`), storing the split debug info somewhere safe (needed to symbolicate future crash reports from AM-19's Crashlytics — don't lose these files).
- [ ] Test thoroughly after enabling obfuscation — it can occasionally surface reflection-dependent bugs; a full manual smoke pass plus `flutter test` should both stay clean.
- [x] Update `docs/APP_SIZE.md` with the new real numbers after AM-35/36/37/39 land, so it stops being stale documentation.

**Verification:** New install size documented and compared against the pre-work baseline; obfuscated build installs and runs correctly on a real device.

---

### AM-39 · Subset bundled fonts to actually-used glyphs
**Priority:** P1 · **Labels:** size, fonts · **Do together with AM-32** — bundling more fonts without this will eat into the size wins from AM-35/36

**Context:** Full font files — especially Devanagari script fonts, which need to cover a much larger glyph set than Latin — can be several hundred KB to multiple MB each. Bundling all 6 currently-unbundled families (AM-32) at full size risks adding meaningful weight right back after AM-35/36 remove it elsewhere.

**Acceptance criteria:**
- [x] For every bundled font (the existing 5 plus the 6 being added in AM-32), subset to only the glyphs actually used — Latin text families need only Latin + basic punctuation; the Devanagari families need Devanagari script coverage but can likely drop unused weights/styles the app never calls (check which specific weights each `GoogleFonts.X()` call site actually requests before keeping every weight file).
- [x] Use a standard subsetting tool (e.g. `fonttools pyftsubset`, or the `google_fonts` package's own trimming guidance if it has one) rather than hand-editing font files.
- [ ] Confirm every weight/style actually called from code (grep for `GoogleFonts.poppins(fontWeight: ...)` etc. per family) still renders correctly after subsetting — don't drop a weight that's actually in use.

**Verification:** Total `assets/fonts/` size after AM-32 + AM-39 together is meaningfully smaller than "5 original fonts + 6 full unsubset fonts" would have been; no missing-glyph tofu boxes anywhere in the app, including Hindi/Hinglish text.

---

## Suggested order

1. **AM-32 + AM-39 together** (fonts — fixes the jank, and subsetting keeps the size fix from working against you).
2. **AM-35** (deity images — fastest, highest-confidence size win, no functional risk).
3. **AM-33** (parallelize startup awaits — small, safe, immediate).
4. **AM-38** (get a real size baseline once 32/35/39 have landed, turn on obfuscation).
5. **AM-36** (temple.glb — biggest remaining lever, but the most effort; do it once you can measure its impact against a clean baseline from AM-38).
6. **AM-37, AM-34** (lower-priority hygiene/verification, whenever).
