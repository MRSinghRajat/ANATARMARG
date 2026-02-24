#!/bin/bash
# One-time iOS setup + run on connected iPhone or simulator.
# Run from project root: ./scripts/setup_ios_and_run.sh
# Requires: Xcode installed, iPhone connected via USB (or Simulator app open).

set -e
cd "$(dirname "$0")/.."
export PATH="/opt/homebrew/bin:$PATH"

echo "=== Flutter clean & pub get ==="
flutter clean
flutter pub get

echo ""
echo "=== iOS CocoaPods install ==="
(cd ios && pod install)

echo ""
echo "=== Devices ==="
flutter devices

echo ""
echo "=== Run on first iOS device (iPhone or Simulator) ==="
# Prefer physical iOS device, then simulator
DEVICE_ID=$(flutter devices --machine 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    for x in d:
        if x.get('platform') == 'ios':
            print(x.get('id', ''))
            break
except Exception:
    pass
" 2>/dev/null)
if [[ -n "$DEVICE_ID" ]]; then
  flutter run -d "$DEVICE_ID"
else
  flutter run
fi
