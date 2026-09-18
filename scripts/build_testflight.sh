#!/usr/bin/env bash
# Build a signed IPA for TestFlight / App Store Connect.
# Requires: Xcode signing (Team) and a valid local .env at project root.
# The build bundles the generated, allowlisted .env.app instead of .env.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/prepare_app_config.py
python3 scripts/verify_app_config.py --release
bash scripts/check_ios_release_config.sh
flutter pub get
flutter test
# split-debug-info is required to symbolicate Crashlytics reports after obfuscation.
# Keep build/debug-info/ somewhere durable (not only on the build machine).
mkdir -p build/debug-info
flutter build ipa --obfuscate --split-debug-info=build/debug-info
python3 scripts/verify_app_config.py --release --package build/ios/ipa

echo "IPA: build/ios/ipa/*.ipa — upload via Xcode Organizer or Transporter."
echo "Debug symbols: build/debug-info/ — archive this with the release for Crashlytics."
