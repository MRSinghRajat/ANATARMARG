# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

Antar Marg is a Flutter mobile/web app for gamified spiritual learning. It uses Riverpod for state management, Supabase as the cloud backend (optional — app degrades gracefully), and OpenAI GPT for AI features (also optional). See `README.md` for the full feature list.

### Running the app

- **Flutter SDK** is installed at `/opt/flutter`. Ensure `PATH` includes `/opt/flutter/bin`.
- The app runs on web (Chrome) in this cloud environment. Use `flutter build web` then serve `build/web/` with a static HTTP server, or use `flutter run -d chrome --web-port=8080` for dev mode (requires a display).
- A `.env` file must exist in the project root (it is listed in `pubspec.yaml` assets). An empty/placeholder `.env` is sufficient — the app handles missing values gracefully.

### Key commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Lint | `flutter analyze` |
| Test | `flutter test` |
| Build web | `flutter build web` |
| Serve built app | `cd build/web && python3 -m http.server 8080` |

### Non-obvious caveats

- `test/widget_test.dart` references `AshraePlaygroundApp` (old class name) instead of `AntarMargApp`, causing 2 compile errors. These are pre-existing and do not affect other tests.
- `flutter analyze` reports ~1000 info-level issues (mostly `avoid_print` and `deprecated_member_use` for `withOpacity`). No errors outside the widget test file.
- The app requires a `.env` file even if empty; without it, `flutter_dotenv` throws at startup. The `.env` file is gitignored — always create it before running.
- For web builds, some packages show Wasm incompatibility warnings (audioplayers, rive FFI). These are informational only and do not affect the JS-compiled web build.
- Google Fonts runtime fetching is disabled in `main.dart`; fonts are bundled locally in `assets/fonts/`.
