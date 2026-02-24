# Apple Push Notifications — Exact Steps

Use this checklist in order. Your app bundle ID is **`com.antarmarg.app`**.

---

## Step 1: Firebase — Create project and add iOS app

1. Open: **https://console.firebase.google.com/**
2. Click **Create a project** (or select an existing one).
3. Enter a project name (e.g. **Antar Marg**) → **Continue** → turn off Google Analytics if you want → **Create project** → **Continue**.
4. On the project overview, click the **iOS** icon (or **Add app** → **iOS**).
5. **iOS bundle ID:** enter exactly: **`com.antarmarg.app`**
6. **App nickname:** e.g. **Antar Marg iOS** (optional).
7. **App Store ID:** leave blank.
8. Click **Register app**.
9. **Download GoogleService-Info.plist** → click **Download GoogleService-Info.plist** and save the file.
10. Click **Next** → **Next** → **Continue to console**.

---

## Step 2: Add GoogleService-Info.plist to Xcode

1. Open the project in Xcode:  
   **`ANATARMARG/ios/Runner.xcworkspace`** (double‑click the `.xcworkspace` file).
2. In the left sidebar, right‑click the **Runner** folder (under the Runner project).
3. Click **Add Files to "Runner"...**
4. Select the **GoogleService-Info.plist** file you downloaded.
5. Leave **Copy items if needed** checked.
6. Under **Add to targets**, ensure **Runner** is checked.
7. Click **Add**.

---

## Step 3: Apple Developer — Enable Push on App ID

1. Open: **https://developer.apple.com/account/**
2. Sign in → go to **Certificates, Identifiers & Profiles**.
3. In the left menu, click **Identifiers**.
4. Click your app’s identifier (**com.antarmarg.app**).  
   If it doesn’t exist: click **+** → **App IDs** → **App** → Description: **Antar Marg** → Bundle ID: **Explicit** → **com.antarmarg.app** → **Continue** → **Register**.
5. In the **Capabilities** list, enable **Push Notifications** (check the box).
6. Click **Save** → confirm.

---

## Step 4: Apple Developer — Create APNs key

1. In the left menu, click **Keys**.
2. Click the **+** button (next to **Keys**).
3. **Key name:** e.g. **APNs Antar Marg**
4. Under **Key Services**, check **Apple Push Notifications service (APNs)**.
5. Click **Continue** → **Register**.
6. On the confirmation screen, click **Download** to get the **.p8** file.  
   **Important:** you can download it only once. Save it and note:
   - **Key ID** (shown on the same page, e.g. `ABC123XYZ`).
7. In the top right, click your **Team name** or **Account** and note your **Team ID** (10 characters, e.g. `ABCD123456`).

---

## Step 5: Firebase — Upload APNs key

1. Go back to **https://console.firebase.google.com/** → select your project.
2. Click the **gear** icon next to **Project Overview** → **Project settings**.
3. Open the **Cloud Messaging** tab.
4. Scroll to **Apple app configuration**.
5. Click **Upload** under **APNs Authentication Key**.
6. Upload your **.p8** file.
7. Enter:
   - **Key ID:** (from Step 4, e.g. `ABC123XYZ`)
   - **Team ID:** (from Step 4, e.g. `ABCD123456`)
   - **Bundle ID:** **`com.antarmarg.app`**
8. Click **Upload**.

---

## Step 6: Xcode — Add Push capability

1. In Xcode, with **Runner.xcworkspace** open, select the **Runner** project in the left sidebar (blue icon).
2. Under **TARGETS**, select **Runner**.
3. Open the **Signing & Capabilities** tab at the top.
4. Click **+ Capability**.
5. Search for **Push Notifications** → double‑click it to add.
6. Click **+ Capability** again.
7. Search for **Background Modes** → double‑click it.
8. Under **Background Modes**, check **Remote notifications**.

---

## Step 7: Supabase — Create push_tokens table

1. Open your Supabase project: **https://supabase.com/dashboard** → select your project.
2. In the left menu, click **SQL Editor**.
3. Click **New query**.
4. Open the file **`ANATARMARG/SUPABASE_PUSH_TOKENS.sql`** in your project and copy its full contents.
5. Paste into the Supabase SQL Editor.
6. Click **Run** (or press Cmd+Enter).
7. You should see **Success. No rows returned.**

---

## Step 8: Build and test on a real device

1. Connect an **iPhone** (push does not work in the simulator).
2. In terminal:  
   **`cd ANATARMARG`** then **`flutter run`**  
   (or in Xcode: select your iPhone as destination and run).
3. In the app: sign in → open **Profile** → **Notifications**.
4. Turn **on** any notification toggle (e.g. **Daily Reminders**).
5. When iOS asks **“Antar Marg” Would Like to Send You Notifications**, tap **Allow**.
6. The app will save the device token to Supabase in the **push_tokens** table.

---

## Step 9: (When you ship to TestFlight/App Store) Use production APNs

1. In your project, open **`ios/Runner/Runner.entitlements`**.
2. Find:  
   `<key>aps-environment</key>`  
   `<string>development</string>`
3. Change to:  
   `<string>production</string>`
4. Save. Use this when archiving for **TestFlight** or **App Store**.

---

## Quick reference

| What | Value |
|------|--------|
| Bundle ID | `com.antarmarg.app` |
| Firebase | Add iOS app → download **GoogleService-Info.plist** → add to **ios/Runner/** in Xcode |
| Apple | Identifiers → enable **Push Notifications**; Keys → create APNs key → download **.p8** |
| Firebase Cloud Messaging | Project settings → Cloud Messaging → upload **.p8** + Key ID, Team ID, Bundle ID |
| Xcode | Signing & Capabilities → **Push Notifications** + **Background Modes** → **Remote notifications** |
| Supabase | SQL Editor → run **SUPABASE_PUSH_TOKENS.sql** |
| Release | **Runner.entitlements** → `aps-environment` = **production** |

If anything fails, check the Xcode console and device logs for Firebase or push‑related errors.
