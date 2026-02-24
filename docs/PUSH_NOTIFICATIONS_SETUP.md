# Apple Push Notifications Setup

The app is wired for push via **Firebase Cloud Messaging (FCM)**, which uses Apple APNs on iOS. Follow these steps to enable delivery.

## 1. Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/) and create or select a project.
2. Add an **iOS app** with your bundle ID (e.g. `com.antarmarg.app`).
3. Download **GoogleService-Info.plist** and add it to `ios/Runner/` in Xcode (drag into Runner, ensure “Copy items” and Runner target are checked).

## 2. Apple Developer (APNs)

1. In [Apple Developer](https://developer.apple.com/account/) → **Certificates, Identifiers & Profiles**:
   - **Identifiers** → your App ID → enable **Push Notifications**.
2. Create an **APNs key**:
   - **Keys** → **+** → name it (e.g. “APNs”), enable **Apple Push Notifications service (APNs)** → Continue → Register.
   - Download the **.p8** key (only once). Note the **Key ID**.
3. In Firebase:
   - **Project settings** → **Cloud Messaging** → **Apple app configuration**.
   - Upload the **.p8** file and enter **Key ID**, **Team ID**, and **Bundle ID**. Save.

## 3. Xcode capabilities

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Click **+ Capability** and add **Push Notifications** (and **Background Modes** → **Remote notifications** if not already there).

The project already has:
- `Runner.entitlements`: `aps-environment` = `development`.
- For **TestFlight / App Store**, change `aps-environment` in `Runner.entitlements` to **`production`** (or use a separate entitlements file for Release).

## 4. Supabase (store tokens)

1. In Supabase **SQL Editor**, run the script: **`SUPABASE_PUSH_TOKENS.sql`** (creates `push_tokens` table and RLS).
2. Tokens are saved when the user has notifications enabled and is signed in.

## 5. Sending push from your backend

Use the **FCM HTTP v1 API** (or Firebase Admin SDK) to send messages. Target users by reading `token` from `public.push_tokens` for the desired `user_id`.  
Example: Supabase Edge Function that calls FCM with the token from `push_tokens` for a given user.

## Summary

| Step | What |
|------|------|
| Firebase | Create project, add iOS app, add **GoogleService-Info.plist** to `ios/Runner/`. |
| Apple | Enable Push on App ID; create APNs key; upload .p8 + Key ID/Team ID/Bundle ID in Firebase. |
| Xcode | Add Push Notifications (and Remote notifications) capability. |
| Release | Set `aps-environment` to `production` in Runner.entitlements for store builds. |
| Supabase | Run `SUPABASE_PUSH_TOKENS.sql` to create the token table. |

If Firebase or **GoogleService-Info.plist** is missing, the app still runs; push init is wrapped in try/catch and will log that setup is needed.
