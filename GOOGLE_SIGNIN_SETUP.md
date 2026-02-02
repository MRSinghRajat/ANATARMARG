# Fix Google Sign-In ApiException 10 (DEVELOPER_ERROR)

**Error:** `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)`

ApiException 10 means **DEVELOPER_ERROR** — your SHA-1 fingerprint or OAuth config is missing or wrong.

---

## Quick Fix Steps

### 1. Get your SHA-1 fingerprint

Run in project root:

```bash
cd android && ./gradlew signingReport
```

Or on Windows (Git Bash / WSL):

```bash
cd android && gradlew.bat signingReport
```

Find the **SHA-1** under `Variant: debug` (or `release` if testing release builds). Copy it.

**This project's debug SHA-1** (add to Google Cloud Console):
```
58:E3:84:AC:77:30:3F:A7:DE:8B:9D:B1:4A:7E:E8:39:4D:DB:BE:CF
```

### 2. Add SHA-1 to Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create one)
3. **APIs & Services** → **Credentials**
4. Under **OAuth 2.0 Client IDs**:
   - If you have an **Android** client: Edit it → add your SHA-1
   - If not: **Create Credentials** → **OAuth client ID** → Application type: **Android**
     - Package name: `com.example.antar_marg`
     - SHA-1: paste the fingerprint from step 1
5. Save

### 3. Create Web OAuth client (for Supabase)

1. **Create Credentials** → **OAuth client ID**
2. Application type: **Web application**
3. Name it (e.g. "Supabase Web")
4. Copy the **Client ID** — this is your `GOOGLE_WEB_CLIENT_ID`

### 4. Configure Supabase Auth

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) → your project
2. **Authentication** → **Providers** → **Google**
3. Enable Google
4. Paste the **Web Client ID** and **Client Secret** from Google Cloud
5. Save

### 5. Add to .env

Add to your `.env` file:

```
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

(You already have `SUPABASE_URL` and `SUPABASE_ANON_KEY` if Supabase is working.)

### 6. Rebuild

```bash
flutter clean
flutter pub get
flutter run -d emulator-5554
```

---

## If using Firebase

If you use Firebase for other features:

1. Add SHA-1 in **Firebase Console** → Project Settings → Your Android app
2. Add both **SHA-1** and **SHA-256**
3. Download the new `google-services.json` and replace `android/app/google-services.json`
4. Ensure `com.google.gms.google-services` plugin is applied in `android/app/build.gradle.kts`

---

## Emulator vs physical device

- **Emulator**: Use the **debug** SHA-1 from `signingReport`
- **Release / Play Store**: Use the **App Signing** SHA-1 from Google Play Console → App signing

---

## Continue without signing in

You can use the app without Google Sign-In: tap **"Continue without signing in"** on the login screen. The app works with local data; cloud sync and user-specific features require sign-in.
