# New Mac Setup – Run Antar Marg on Your iPhone

Use this guide on a **new Mac** to install everything needed to build and run this Flutter app on your **iPhone**. Do the steps in order; some steps take a while (especially Xcode).

---

## 1. Xcode (required for iOS)

Needed to build and run on iPhone. **~12 GB**, so do this first.

1. Open **App Store** on your Mac.
2. Search for **Xcode** and click **Get** / **Install**.
3. When it’s installed, open **Xcode** once.
4. Accept the license and wait for “Installing additional components” to finish.
5. Set the command line tools:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```

---

## 2. Homebrew (recommended – makes installing Flutter easy)

1. Open **Terminal** (Spotlight: Cmd+Space, type “Terminal”).
2. Run the install command from [brew.sh](https://brew.sh):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Follow the on-screen steps. At the end it will tell you to add Homebrew to your PATH. It will show two lines like:
   ```bash
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
   Run those two lines in Terminal (copy-paste exactly what it prints for your Mac).

---

## 3. Flutter

**Option A – Using Homebrew (easiest)**

```bash
brew install --cask flutter
```

Then close and reopen Terminal (or open a new tab) and run:

```bash
flutter doctor
```

**Option B – Manual install**

1. Download the macOS SDK: [Flutter macOS install](https://docs.flutter.dev/get-started/install/macos).
2. Unzip to a folder **without spaces**, e.g. `~/development/flutter` or `~/flutter`.
3. Add Flutter to your PATH. If you use the default Mac shell (Zsh), run (change the path if you used a different folder):
   ```bash
   echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```
4. Run:
   ```bash
   flutter doctor
   ```

---

## 4. CocoaPods (needed for iOS/Flutter)

Flutter’s iOS build uses CocoaPods. Install it:

```bash
sudo gem install cocoapods
```

If that fails (e.g. permission or Ruby version), use Homebrew:

```bash
brew install cocoapods
```

---

## 5. Fix anything `flutter doctor` reports

Run:

```bash
flutter doctor
```

Then fix what it says:

- **Xcode**: Install or open Xcode and accept the license (step 1).
- **Android toolchain**: Only needed if you want to run on Android. You can ignore for “iPhone only” or install Android Studio later.
- **CocoaPods**: Install as in step 4.
- **VS Code / Android Studio**: Optional. Use Cursor/VS Code for editing; you don’t need Android Studio for iPhone.

Run `flutter doctor` again until the iOS-related items are OK (no red X for Xcode/CocoaPods).

---

## 6. Project setup on your Mac

1. Open Terminal and go to the project:
   ```bash
   cd /Users/mrsingh/Documents/VibeCoding/AnatarMarg/ANATARMARG
   ```

2. Get Flutter packages:
   ```bash
   flutter pub get
   ```

3. Install iOS CocoaPods (first time only):
   ```bash
   cd ios && pod install && cd ..
   ```

4. If the project has a `.env.example`, copy it and add your keys later:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your Supabase/API keys when you have them (app may run with defaults or show auth errors until then).

---

## 7. Run on your iPhone

1. Connect your **iPhone** with a USB cable.
2. On the iPhone: if it asks **“Trust This Computer?”** → tap **Trust** and enter your passcode.
3. On iPhone (iOS 16+): **Settings → Privacy & Security → Developer Mode** → turn **On** and restart if asked.
4. In Terminal (still in the project folder):
   ```bash
   flutter devices
   ```
   You should see your iPhone in the list.

5. Run the app:
   ```bash
   flutter run
   ```
   When asked, choose your iPhone. The first time, you may need to set up **signing** in Xcode (see below).

---

## 8. First-time code signing (if build fails)

If you see signing/team errors when running on the device:

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In the left sidebar, click **Runner** (the project, not the folder).
3. Select the **Runner** target → **Signing & Capabilities**.
4. Check **“Automatically manage signing”**.
5. Choose your **Team** (sign in with your Apple ID if needed: Xcode → Settings → Accounts).
6. If the bundle ID is taken, change it to something unique (e.g. `com.yourname.antarmarg`).
7. Close Xcode and run again:
   ```bash
   flutter run
   ```

---

## Quick checklist

| Step | What | Done |
|------|------|------|
| 1 | Xcode from App Store + open once + `sudo xcode-select -s ...` | ☐ |
| 2 | Homebrew | ☐ |
| 3 | Flutter (`brew install --cask flutter` or manual) | ☐ |
| 4 | CocoaPods (`sudo gem install cocoapods` or `brew install cocoapods`) | ☐ |
| 5 | `flutter doctor` and fix issues | ☐ |
| 6 | `flutter pub get`, `ios/pod install`, copy `.env` if needed | ☐ |
| 7 | iPhone: Trust computer, Developer Mode, `flutter run` | ☐ |
| 8 | Xcode signing (Team + bundle ID) if first device run fails | ☐ |

---

## Optional later

- **Android**: Install [Android Studio](https://developer.android.com/studio), then run `flutter doctor` and fix Android toolchain.
- **Editor**: You’re already using Cursor; install the “Flutter” and “Dart” extensions if you want better Dart/Flutter support.

Once everything is installed, you only need: `cd` to the project → `flutter run` → choose your iPhone.
