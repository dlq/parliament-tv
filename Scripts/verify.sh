#!/usr/bin/env bash
set -euo pipefail

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/ParliamentsDerivedData}"

require_tool() {
  local name="$1"

  if ! command -v "$name" >/dev/null 2>&1; then
    echo "error: $name is required." >&2
    exit 127
  fi
}

require_tool xcrun

git diff --check
xcrun swift-format lint --recursive --parallel --strict App Tests

xcodebuild test \
  -project Parliaments.xcodeproj \
  -scheme Parliaments \
  -configuration Debug \
  -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath "$DERIVED_DATA_PATH"

xcodebuild build \
  -project Parliaments.xcodeproj \
  -scheme Parliaments \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' \
  -derivedDataPath "$DERIVED_DATA_PATH"

xcodebuild build \
  -project Parliaments.xcodeproj \
  -scheme Parliaments \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=latest' \
  -derivedDataPath "$DERIVED_DATA_PATH"

xcodebuild build \
  -project Parliaments.xcodeproj \
  -scheme Parliaments \
  -configuration Debug \
  -destination 'platform=tvOS Simulator,name=Apple TV,OS=latest' \
  -derivedDataPath "$DERIVED_DATA_PATH"
