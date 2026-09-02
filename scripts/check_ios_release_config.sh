#!/usr/bin/env bash
# Preflight for iOS release / TestFlight (AM-1).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="$ROOT/ios/Runner/GoogleService-Info.plist"
EXPECTED_BUNDLE="com.antarmarg.app"

if [[ ! -f "$PLIST" ]]; then
  echo "ERROR: Missing $PLIST"
  echo "Download GoogleService-Info.plist for bundle ID $EXPECTED_BUNDLE from Firebase Console"
  echo "and place it at ios/Runner/GoogleService-Info.plist"
  exit 1
fi

if ! /usr/libexec/PlistBuddy -c "Print :BUNDLE_ID" "$PLIST" 2>/dev/null | grep -qx "$EXPECTED_BUNDLE"; then
  ACTUAL="$(/usr/libexec/PlistBuddy -c "Print :BUNDLE_ID" "$PLIST" 2>/dev/null || echo 'unknown')"
  echo "ERROR: GoogleService-Info.plist BUNDLE_ID is '$ACTUAL' (expected '$EXPECTED_BUNDLE')"
  exit 1
fi

echo "OK: GoogleService-Info.plist present for $EXPECTED_BUNDLE"
