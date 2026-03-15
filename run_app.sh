#!/bin/bash
# Run Antar Marg app from the correct directory.
# Usage: ./run_app.sh [device]
#   device: chrome | iphone (or ios) | or any device id (optional - picks first available)
#   Your iPhone ID: 00008120-001434E40C53C01E

set -e
cd "$(dirname "$0")"

echo "→ Flutter project: $(pwd)"
echo "→ Checking devices..."
flutter devices

echo ""
echo "→ Running app (use Ctrl+C to stop)..."
echo "  Tip: If this hangs at 'Installing and launching', allow Local Network on your iPhone when prompted."
echo ""

if [ "$1" = "chrome" ]; then
  flutter run -d chrome
elif [ "$1" = "iphone" ] || [ "$1" = "ios" ]; then
  flutter run -d "00008120-001434E40C53C01E"
elif [ -n "$1" ]; then
  flutter run -d "$1"
else
  flutter run
fi
