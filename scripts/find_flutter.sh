#!/bin/bash
# Run this in Terminal to find Flutter and add it to PATH for this session.
# Usage: source scripts/find_flutter.sh   OR   . scripts/find_flutter.sh

echo "Searching for Flutter..."
FLUTTER_BIN=""

# Common locations
for dir in \
  "$HOME/flutter/bin" \
  "$HOME/development/flutter/bin" \
  "/opt/homebrew/bin" \
  "/usr/local/bin" \
  "$HOME/fvm/default/bin" \
  "$HOME/.fvm/default/bin" \
  ; do
  if [[ -x "$dir/flutter" ]]; then
    FLUTTER_BIN="$dir"
    break
  fi
done

if [[ -z "$FLUTTER_BIN" ]]; then
  # Slower search
  found=$(find "$HOME" -name "flutter" -type f 2>/dev/null | grep "bin/flutter" | head -1)
  if [[ -n "$found" ]]; then
    FLUTTER_BIN=$(dirname "$found")
  fi
fi

if [[ -n "$FLUTTER_BIN" ]]; then
  export PATH="$FLUTTER_BIN:$PATH"
  echo "Found Flutter at: $FLUTTER_BIN"
  echo "Added to PATH for this terminal session."
  flutter --version
  echo ""
  echo "To run the app: flutter pub get && flutter run"
else
  echo "Flutter not found. Install it first: https://docs.flutter.dev/get-started/install/macos"
  echo "Or with Homebrew: brew install --cask flutter"
  exit 1
fi
