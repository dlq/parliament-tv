#!/usr/bin/env bash
set -euo pipefail

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/ParliamentsDerivedData}"

run_optional_tool() {
  local name="$1"
  shift

  if command -v "$name" >/dev/null 2>&1; then
    "$name" "$@"
  else
    echo "warning: $name not installed; skipping"
  fi
}

git diff --check
run_optional_tool swiftformat --lint App Tests
run_optional_tool swiftlint lint --strict

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
  -destination 'platform=tvOS Simulator,name=Apple TV,OS=latest' \
  -derivedDataPath "$DERIVED_DATA_PATH"
