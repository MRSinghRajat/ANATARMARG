# Fix: Xcode "Nonzero Exit Code" + Flutter "No Wireless Device Found"

**Project-side fixes are done:** Podfile added, CocoaPods installed and run, Debug/Release xcconfig include Pods, and DEVELOPMENT_TEAM cleared so Xcode will let you pick your Apple ID. After Xcode is fully installed and your iPhone is connected, run the script below once.

Do the steps below in order.

---

## Quick fix: Run on Simulator or Phone (recommended)

**Flutter only sees the iOS Simulator when the Simulator app is running.**

1. **Start the Simulator** (so Flutter can detect it):
   ```bash
   open -a Simulator
   ```
   Wait until the simulator window is fully booted (you see the home screen).

2. **Run the app** (auto-picks simulator or connected iPhone):
   ```bash
   cd /Users/mrsingh/Documents/VibeCoding/AnatarMarg/ANATARMARG
   ./scripts/run_app.sh
   ```

   Or prefer simulator only:
   ```bash
   ./scripts/run_app.sh --simulator
   ```

   Or prefer physical iPhone only (must be connected via USB):
   ```bash
   ./scripts/run_app.sh --device
   ```

3. If you still get "no device found", run and then pick a device by id:
   ```bash
   flutter devices
   flutter run -d <device-id-from-list>
   ```

---

## Part 1: Fix Flutter "no wireless device found" (use USB iPhone)

Flutter is looking for a **device**; that message often appears when no device is detected or only "wireless" is considered. Use your **USB‑connected iPhone** as the target.

### 1. Make sure the Mac sees your iPhone

1. Connect the iPhone with a **USB cable** (data-capable, not charge-only).
2. Unlock the iPhone.
3. If you see **"Trust This Computer?"** on the iPhone → tap **Trust** and enter your passcode.
4. On iPhone (iOS 16+): **Settings → Privacy & Security → Developer Mode** → turn **On** and restart if asked.

### 2. List devices and run on the USB iPhone

In **Terminal** (from the project folder):

```bash
cd /Users/mrsingh/Documents/VibeCoding/AnatarMarg/ANATARMARG
flutter devices
```

You should see your **iPhone** in the list (e.g. "iPhone (mobile)" or your device name). Note its **id** (e.g. `00008103-001A64A83E89801E`).

Then run on that device **by id** (replace with your device id from the list):

```bash
flutter run -d <device-id>
```

Example:

```bash
flutter run -d 00008103-001A64A83E89801E
```

If only one device is connected, you can also try:

```bash
flutter run -d iphone
```

Using the **device id** forces Flutter to use your USB iPhone and avoids the "no wireless device found" path.

---

## Part 2: Fix Xcode "Command failed with nonzero exit code"

Common causes: missing CocoaPods setup, stale build, or signing. Do the following.

### 1. Regenerate iOS deps and install Pods (required)

From the **project root** in Terminal:

```bash
cd /Users/mrsingh/Documents/VibeCoding/AnatarMarg/ANATARMARG
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

This creates/updates the **Podfile**, installs **CocoaPods** dependencies, and updates the Xcode workspace. After this, **always open the app in Xcode via the workspace**, not the `.xcodeproj`:

```bash
open ios/Runner.xcworkspace
```

### 2. In Xcode: clean and pick your iPhone

1. **Product → Clean Build Folder** (Shift+Cmd+K).
2. At the top, set the run destination to your **physical iPhone** (not "Any iOS Device").
3. **Product → Run** (Cmd+R).

### 3. Fix signing (if you see signing/team errors)

1. In the left sidebar, click the **Runner** project (blue icon).
2. Select the **Runner** target.
3. Open **Signing & Capabilities**.
4. Check **"Automatically manage signing"**.
5. Choose your **Team** (your Apple ID). If you don’t have one: **Xcode → Settings → Accounts → +** and add your Apple ID.
6. If the bundle ID is in red or "already in use", change it to something unique (e.g. `com.yourname.antarmarg`).
7. Run again (Cmd+R).

### 4. If Xcode still fails: see the real error

1. In Xcode, open the **Report navigator** (last icon in the left sidebar, or View → Navigators → Reports).
2. Select the latest **Build** entry.
3. Expand the failed step and read the **red error** (e.g. "No such module", signing, or script phase). Fix that specific error (Google the message if needed).

---

## One-time setup script (Terminal)

From the project folder you can run:

```bash
cd /Users/mrsingh/Documents/VibeCoding/AnatarMarg/ANATARMARG
./scripts/run_on_iphone.sh
```

That script runs `flutter clean`, `flutter pub get`, `pod install`, then runs the app on the **first connected iOS device** (your USB iPhone). Use it after connecting the iPhone and running `flutter devices` once to confirm the device appears.

---

## Summary

| Problem | Fix |
|--------|-----|
| **"No wireless device found"** | Connect iPhone via USB, trust the computer, run `flutter run -d <device-id>` (use id from `flutter devices`). |
| **Xcode "nonzero exit code"** | Run `flutter clean`, `flutter pub get`, `cd ios && pod install`, open `Runner.xcworkspace`, clean build (Shift+Cmd+K), fix signing/team, then Run. |

After that, you can either run from **Terminal** with `flutter run -d <device-id>` or from **Xcode** by opening `ios/Runner.xcworkspace`, selecting your iPhone, and pressing Run.
