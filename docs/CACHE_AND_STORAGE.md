# Cache and storage policy

This doc describes how the app keeps storage low and what does (or doesn’t) affect it.

## Current policy: compressed image disk cache

- **Images** use `AppNetworkImage` → `CachedNetworkImage` with a **bounded, compressed** disk cache.
- **Compression**: Images are stored on disk at **max 1024×1024 px** (`maxWidthDiskCache` / `maxHeightDiskCache`), so each cached file is much smaller than the original.
- **Bounded**: Max **100 files**, **7-day** stale period (`CompressedImageCache` / `_BoundedImageCacheManager`). Typical total size ~20–80 MB.
- **Profile → Clear image cache** clears the cache to free space.

## What counts toward "app storage"

1. **Images** – no disk cache; only in-memory during session.
2. **WebView cache** – 3D/Mandir and test WebView screens can add browser cache. User can clear via system Settings → Storage → App.
3. **SharedPreferences / sqflite** – small (settings, progress).
4. **Assets** – bundled fonts, images, sounds, Lottie; fixed size.

## Debug logs – do they cause storage bloat?

**No.** `print()` and `debugPrint()` go to the **system log** (e.g. logcat / OS console), not to the app’s document or cache directory. They do **not** write files to disk, so they are not the cause of large “app storage” (e.g. 38 GB). To keep release builds quiet and avoid leaking env/key info, startup logs in `main()` are wrapped in `kDebugMode` so they only run in debug.

## Compressing images or videos before saving to local disk

- **Right now we don’t save images or videos to app disk.** There is no image cache and no offline video download, so there is nothing to compress before “saving.”
- **User-picked image (e.g. palmistry):** We already compress on pick: `pickImage(maxWidth: 1024, maxHeight: 1024, imageQuality: 85)`. The file lives in the system temp/cache for the session and is sent as base64 to the API; we don’t persist it to app documents.
- **If you add image cache or offline video later:**  
  - **Images:** Decode, resize/compress (e.g. with the `image` package), then write the bytes to the cache file.  
  - **Videos:** Compressing before save usually needs native code or FFmpeg; consider storing lower-quality or shorter clips, or streaming only.

## If you reintroduce image disk cache

- Use a **bounded** cache (e.g. `flutter_cache_manager` with `maxNrOfCacheObjects` and `stalePeriod`).
- **Compress before storing:** e.g. resize to max 1024px and encode JPEG at 80–85% before writing to the cache file, so each cached image stays small.
