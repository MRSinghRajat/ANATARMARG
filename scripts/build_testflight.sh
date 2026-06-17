#!/usr/bin/env bash
# Build a signed IPA for TestFlight / App Store Connect.
# Requires: Xcode signing (Team) for Runner, valid .env at project root.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter test
flutter build ipa

echo "IPA: build/ios/ipa/*.ipa — upload via Xcode Organizer or Transporter."
