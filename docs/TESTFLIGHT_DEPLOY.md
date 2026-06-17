# Deploy a New Version to TestFlight (iOS)

Use this guide to ship a new build of **Antar Marg** to TestFlight for beta testing.

For App Store–specific checks (privacy, encryption, dev-only routes), see [APP_STORE_PRODUCTION.md](./APP_STORE_PRODUCTION.md).

---

## Prerequisites

- **Apple Developer account** (enrolled in the Apple Developer Program).
- **App already set up in App Store Connect** (app created with bundle ID `com.antarmarg.app`).
- **Mac with Xcode** and **Flutter** installed (see [NEW_MAC_SETUP.md](../NEW_MAC_SETUP.md)).
- **Signing**: In Xcode, Runner target → Signing & Capabilities → your **Team** selected, **Automatically manage signing** checked.

---

## TestFlight readiness (this project)

Do this **before** `flutter build ipa` or **Archive** in Xcode:

| Check | What to do |
|--------|------------|
| **`.env` file** | Copy from `.env.example` to **`.env`** in the project root. `pubspec.yaml` lists `.env` as an asset—**the file must exist** for release builds to bundle it. |
| **RevenueCat (iOS)** | Set **`REVENUECAT_API_KEY`** or **`REVENUECAT_API_KEY_IOS`** to RevenueCat’s **Apple public SDK key** (`appl_…`). **Do not** use Test Store keys (`test_…`) for TestFlight; the SDK rejects them in release. Keep **`REVENUECAT_USE_TEST_STORE=false`**. |
| **Pro access** | **Default:** Pro only via RevenueCat (unset or `PREMIUM_GRANT_ALL=false`). For a beta where everyone should be Pro without paying, set **`PREMIUM_GRANT_ALL=true`** in `.env`. |
| **Build number** | Increase **`version`** in `pubspec.yaml` (the `+N` part) for **every** upload to App Store Connect. |
| **Push notifications** | `ios/Runner/Runner.entitlements` uses **`aps-environment` = production** for release—correct for TestFlight and App Store. |

---

## Step 1: Bump version and build number

Edit **`pubspec.yaml`** at the top:

```yaml
version: 1.0.0+1   # change to e.g. 1.0.1+2
```

- **Left number** (`1.0.0`) = **version name** (user-facing, e.g. 1.0.1, 1.1.0).
- **Right number** (`+1`) = **build number**; must **increase for every upload** to TestFlight/App Store (e.g. +2, +3).

Example for a small update: `1.0.0+1` → `1.0.1+2`.  
Example for next TestFlight build: `1.0.1+2` → `1.0.1+3`.

---

## Step 2: Build the iOS app (IPA)

In the project root:

```bash
cd /Users/mrsingh/Documents/VibeCoding/AnatarMarg/ANATARMARG
flutter pub get
flutter build ipa
```

- This creates a **release** build and an **IPA**.
- Output is under: `build/ios/ipa/` (e.g. `build/ios/ipa/antarmarg.ipa`).

If you see signing errors, open the iOS project in Xcode and fix the Team / provisioning:

```bash
open ios/Runner.xcworkspace
```

Then: **Runner** target → **Signing & Capabilities** → choose your Team and ensure **Release** is signed.

---

## Step 3: Upload to App Store Connect

**Option A – Xcode (recommended)**

1. In Xcode: **Product → Archive** (scheme must be **Runner**, destination **Any iOS Device**).
2. When the archive finishes, the **Organizer** window opens.
3. Select the new archive → **Distribute App**.
4. Choose **App Store Connect** → **Upload**.
5. Follow the prompts (default options are usually fine; keep “Upload your app’s symbols” and “Manage version and build number automatically” if you want).
6. Sign in with your Apple ID if asked. Wait for the upload to complete.

**Option B – Command line (from the IPA)**

If you used `flutter build ipa`, you can upload that IPA with **Transporter** (Mac App Store) or with:

```bash
xcrun altool --upload-app --type ios --file build/ios/ipa/antarmarg.ipa --username "YOUR_APPLE_ID_EMAIL" --password "@keychain:AC_PASSWORD"
```

For `--password` you can use an [app-specific password](https://appleid.apple.com) or a keychain item (e.g. `AC_PASSWORD` for Apple ID credentials).

---

## Step 4: In App Store Connect (TestFlight)

1. Go to [App Store Connect](https://appstoreconnect.apple.com) → your app → **TestFlight**.
2. Wait for the new build to appear (processing can take **5–30 minutes**). You’ll get an email when it’s ready.
3. If asked, complete **Export Compliance** and **Content Rights** (and any other missing info) for the build.
4. Under **Internal Testing** or **External Testing**:
   - **Internal**: Add testers by email (up to 100); they get the build quickly.
   - **External**: Add a group, add testers; first build per version may need a short **Beta App Review**.
5. Testers install **TestFlight** from the App Store, accept your invite, and install the app from TestFlight.

---

## One-command build (local)

From the project root (runs tests then `flutter build ipa`):

```bash
./scripts/build_testflight.sh
```

---

## Quick checklist

| Step | Action |
|------|--------|
| 1 | Bump `version: x.y.z+build` in `pubspec.yaml` (build number must be new). |
| 2 | `flutter build ipa` (or Archive in Xcode). |
| 3 | Upload IPA via Xcode Organizer **Distribute App** or `xcrun altool`. |
| 4 | In App Store Connect → TestFlight, wait for processing, add testers. |

---

## Push notifications (production)

When you ship to TestFlight/App Store, use **production** APNs. See [PUSH_NOTIFICATIONS_EXACT_STEPS.md](PUSH_NOTIFICATIONS_EXACT_STEPS.md) (e.g. set `aps-environment` to **production** in `Runner.entitlements` for Release).

---

## Troubleshooting

### "No Accounts" / "No signing certificate 'iOS Distribution' found"

Xcode can't find an Apple Developer account or a distribution certificate.

1. **Add your Apple ID in Xcode** — **Xcode → Settings (⌘,)** → **Accounts** → **+** → add the Apple ID that's in the **Apple Developer Program**.
2. **Download signing certificates** — Select that account → **Manage Certificates…** → **+** → **Apple Distribution**. If you already have one in the portal, click **Download Manual Profiles** so Xcode has the right certificates.
3. **Confirm Team in the project** — Open `ios/Runner.xcworkspace` → select **Runner** target → **Signing & Capabilities** → for **Release**, choose your **Team** and leave **Automatically manage signing** on.

Your Apple ID must be enrolled in the [Apple Developer Program](https://developer.apple.com/programs/) (paid) to get an "iOS Distribution" certificate.

### "Provisioning profile doesn't include Push Notifications" / "aps-environment entitlement"

The distribution provisioning profile doesn't include Push Notifications, but the app's entitlements do.

1. **Enable Push on the App ID** — [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles** → **Identifiers** → select **com.antarmarg.app** → enable **Push Notifications** → **Save**.
2. **Regenerate the provisioning profile** — **Profiles** → find "iOS Team Store Provisioning Profile: com.antarmarg.app" (or create one for App Store distribution) → **Edit** → ensure **Push Notifications** is included → **Generate** / **Save** and download.
3. **Use it in Xcode** — **Runner** target → **Signing & Capabilities** → ensure **Push Notifications** is in the list. With "Automatically manage signing" on, Xcode should pull the updated profile; if not, in **Accounts** → **Download Manual Profiles**, then clean and archive again.
4. **Use production for release** — For TestFlight/App Store, `ios/Runner/Runner.entitlements` has `aps-environment` set to **production** (already set in this project).

### "Archive did not include a dSYM for objective_c.framework" (or other framework)

Xcode is warning that a dSYM (debug symbols) for a framework (e.g. **objective_c.framework**, from a Flutter/Dart dependency) is missing. This is common and usually **does not block** the upload.

**Option 1 — Proceed anyway**  
If the dialog has **Continue** or **Upload**, use it. Apple typically accepts the build; the missing dSYM only affects symbolication for that framework’s crashes.

**Option 2 — Upload without uploading symbols**  
When you click **Distribute App** → **Upload**, in the options step **uncheck “Upload your app’s symbols”**. The validation that checks for every framework’s dSYM is then skipped. Your main app’s symbols may still be in the IPA; you only skip Xcode’s strict dSYM upload step.

**Option 3 — Upload the IPA with Transporter**  
Build the IPA with `flutter build ipa`, then upload the IPA file with the **Transporter** app (Mac App Store). Transporter does not run Xcode’s dSYM check, so the warning won’t appear.

### Other issues

- **“No valid signing identity”** → Xcode → Runner → Signing & Capabilities: select Team, ensure Release is configured.
- **“Bundle ID doesn’t match”** → App in App Store Connect must use `com.antarmarg.app` (or whatever is in the Xcode project).
- **“Build already exists”** → Increase the **build number** in `pubspec.yaml` (the `+N` part) and build again.
- **Upload fails with auth error** → Use an [app-specific password](https://appleid.apple.com) for your Apple ID, or fix the keychain item used with `xcrun altool`.

### If `flutter build ipa` still fails at export

Use Xcode to archive and upload instead:

1. `open ios/Runner.xcworkspace`
2. **Product → Archive** (destination: **Any iOS Device**).
3. In the Organizer, select the archive → **Distribute App** → **App Store Connect** → **Upload**.

Xcode will use the same certificates/profiles but often gives clearer errors or can fix provisioning when automatic signing is on.
