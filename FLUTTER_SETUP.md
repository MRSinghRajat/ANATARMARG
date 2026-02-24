# Fix "Could not find Flutter"

Your terminal can't find the `flutter` command. Do one of the following.

---

## Option A: Flutter is already installed (add to PATH)

If you installed Flutter before, the app is in a folder like `~/flutter` or `~/development/flutter`.

### 1. Find Flutter on your Mac

In **Terminal** (or Cursor’s terminal), run:

```bash
find $HOME -name "flutter" -type f 2>/dev/null | grep "bin/flutter"
```

Or check common locations:

```bash
ls $HOME/flutter/bin/flutter
ls $HOME/development/flutter/bin/flutter
ls /opt/homebrew/bin/flutter
```

Note the **folder that contains** the `flutter` file (e.g. `$HOME/flutter/bin` or `/opt/homebrew/bin`). That folder is your **Flutter bin path**.

### 2. Add Flutter to PATH for current session

Replace `YOUR_FLUTTER_BIN_PATH` with the path from step 1 (e.g. `$HOME/flutter/bin`):

```bash
export PATH="$PATH:YOUR_FLUTTER_BIN_PATH"
```

Example:

```bash
export PATH="$PATH:$HOME/flutter/bin"
```

Then run:

```bash
flutter doctor
```

### 3. Add Flutter to PATH permanently

So every new terminal has `flutter`:

**If you use Zsh (default on macOS):**

```bash
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

**If you use Bash:**

```bash
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bash_profile
source ~/.bash_profile
```

Use your actual Flutter bin path instead of `$HOME/flutter/bin` if it’s different.

---

## Option B: Flutter is not installed (install it)

### Install via Homebrew (easiest on Mac)

1. Install Homebrew if you don’t have it: https://brew.sh  
2. Then run:

```bash
brew install --cask flutter
```

3. Restart the terminal and run:

```bash
flutter doctor
```

### Manual install

1. Download the SDK: https://docs.flutter.dev/get-started/install/macos  
2. Extract the zip (e.g. to `$HOME/flutter` — avoid paths with spaces).  
3. Add the `bin` folder to PATH (see Option A, steps 2 and 3):

```bash
export PATH="$PATH:$HOME/flutter/bin"
# then add the same line to ~/.zshrc or ~/.bash_profile
```

4. Run:

```bash
flutter doctor
```

---

## After Flutter is in PATH

From your project folder:

```bash
cd /Users/mrsingh/Documents/VibeCoding/AnatarMarg/ANATARMARG
flutter pub get
flutter run
```

Choose your connected iPhone when prompted, or run:

```bash
flutter run -d <your-iphone-device-id>
```

Use `flutter devices` to see the device id.
