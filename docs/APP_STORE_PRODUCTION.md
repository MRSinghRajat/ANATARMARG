# App Store production checklist (Antar Marg)

Use this together with [TESTFLIGHT_DEPLOY.md](./TESTFLIGHT_DEPLOY.md) for TestFlight and App Store submission.

## Before each upload

1. **Version** — Bump `version:` in `pubspec.yaml` (`x.y.z+build`). The **build number** after `+` must increase for every App Store / TestFlight upload.
2. **Align `AppConfig.appVersion`** — Keep the `x.y.z` part consistent with `pubspec.yaml` for any in-app “About” or support text.
3. **Signing** — Xcode → Runner → Signing & Capabilities → correct **Team**, **Release** profile valid.
4. **Distributable configuration** — Generate `.env.app` from local `.env` using `scripts/prepare_app_config.py`. Only allowlisted public client configuration is bundled; private tooling credentials stay outside the app. Verify configuration and scan the exact IPA before upload. Never upload an old build that still contains `.env`.
5. **RevenueCat** — Use **production** API keys and App Store products in App Store Connect; Test Store keys are for sandbox only.
6. **Firebase** — `ios/GoogleService-Info.plist` matches the App Store bundle ID (`com.antarmarg.app`) and the Xcode resource reference. Run `bash scripts/check_ios_release_config.sh`.
7. **Build** — `bash scripts/build_testflight.sh` from a reviewed release baseline. The script generates configuration, runs tests, builds and scans the IPA. Archive `build/debug-info/` with the release so Crashlytics can symbolicate. A direct Xcode archive must undergo the same configuration and exported-IPA checks.

## App Store Connect (metadata)

- **Privacy policy URL** — Required; host and link in App Store Connect.
- **App Privacy questionnaire** — Declare data collected (analytics, account, purchases, etc.) to match actual SDK usage (Firebase, Supabase, RevenueCat, etc.).
- **Export compliance** — `ITSAppUsesNonExemptEncryption` is set to `false` in `Info.plist` for standard HTTPS-only crypto; if you add custom encryption, update this and the questionnaire.
- **Subscriptions / IAP** — Link subscription group and review notes if reviewers need a demo account.
- **Screenshots & description** — Required for the live App Store listing (TestFlight can ship with minimal listing first).

## iOS capabilities already in the project

- URL scheme `antarmarg` for auth callbacks.
- **Push** — Background modes `remote-notification` + `fetch`; APNs via Firebase.
- **Sign in with Apple** — Entitlement present.
- **Location** — `NSLocationWhenInUseUsageDescription` for Aangan day/night sky.
- **Camera / Photos** — Usage strings for profile and chat image pickers.
- **Local network** — Usage string for WebView / local content (required when the system prompts).

## Dev-only behavior

- **Subscription dev settings** — Only available in **debug** builds (`kDebugMode`). Release builds auto-dismiss that route if opened.

## Optional hardening (later)

- Add a **Privacy manifest** (`PrivacyInfo.xcprivacy`) in Xcode if Apple’s requirements or App Store warnings require declared API reasons beyond what Flutter/Pods ship.
- **Crash / analytics** — Firebase Crashlytics is already wired; keep `build/debug-info/` from each obfuscated IPA.
