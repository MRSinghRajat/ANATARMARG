#!/bin/bash
# Build and run the app on the first connected iPhone (USB).
# Usage: ./scripts/run_on_iphone.sh
# Make sure iPhone is connected via USB and "Trust" the computer.

set -e
cd "$(dirname "$0")/.."

echo "=== Cleaning and fetching dependencies ==="
flutter clean
flutter pub get

echo ""
echo "=== Installing iOS CocoaPods ==="
cd ios
pod install
cd ..

echo ""
echo "=== Connected devices ==="
flutter devices

echo ""
echo "=== Running app — select your iPhone when prompted ==="
echo "If you see 'no wireless device found', run: flutter devices"
echo "Then run: flutter run -d <your-iphone-device-id>"
echo ""
flutter run
