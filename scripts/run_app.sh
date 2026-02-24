#!/bin/bash
# Run the app on iOS Simulator or connected iPhone — fixes "device not found".
# Usage: ./scripts/run_app.sh
#        ./scripts/run_app.sh --simulator   (prefer simulator)
#        ./scripts/run_app.sh --device     (prefer physical iPhone)

set -e
cd "$(dirname "$0")/.."

PREFER=""
[[ "$1" == "--simulator" ]] && PREFER="simulator"
[[ "$1" == "--device" ]] && PREFER="device"

echo "=== Flutter pub get ==="
flutter pub get

# Ensure iOS CocoaPods are installed (needed for iOS build)
if [[ -d "ios" ]] && [[ ! -d "ios/Pods" ]] && [[ -f "ios/Podfile" ]]; then
  echo "=== Installing iOS CocoaPods (first time) ==="
  (cd ios && pod install)
fi

# If user wants simulator, ensure Simulator app is running so Flutter can see it
if [[ "$PREFER" == "simulator" || "$PREFER" == "" ]]; then
  if ! pgrep -x "Simulator" >/dev/null 2>&1; then
    echo "=== Starting iOS Simulator ==="
    open -a Simulator
    echo "Waiting 10s for simulator to boot..."
    sleep 10
  fi
fi

echo ""
echo "=== Available devices ==="
flutter devices

# Pick first available device: prefer iOS (simulator or physical)
DEVICE_ID=""
if command -v python3 >/dev/null 2>&1; then
  JSON=$(flutter devices --machine 2>/dev/null || true)
  if [[ -n "$JSON" ]]; then
    # Prefer simulator if --simulator or no preference; else prefer device
    if [[ "$PREFER" == "device" ]]; then
      DEVICE_ID=$(python3 -c "
import json, sys
try:
    devices = json.load(sys.stdin)
    for d in devices:
        if d.get('platform') == 'ios' and not d.get('emulator', True):
            print(d.get('id', ''))
            break
    else:
        for d in devices:
            if d.get('platform') == 'ios':
                print(d.get('id', ''))
                break
except Exception:
    pass
" <<< "$JSON")
    else
      # Prefer simulator (emulator=True for iOS simulator)
      DEVICE_ID=$(python3 -c "
import json, sys
try:
    devices = json.load(sys.stdin)
    for d in devices:
        if d.get('platform') == 'ios':
            print(d.get('id', ''))
            break
except Exception:
    pass
" <<< "$JSON")
    fi
  fi
fi

echo ""
if [[ -n "$DEVICE_ID" ]]; then
  echo "=== Running on device: $DEVICE_ID ==="
  flutter run -d "$DEVICE_ID"
else
  echo "=== No device selected automatically — choose one when prompted ==="
  echo "Tip: If nothing appears, start Simulator: open -a Simulator"
  echo "     Or connect your iPhone via USB and trust this computer."
  echo ""
  flutter run
fi
