.PHONY: verify test build-tvos build-ios build-macos format format-check lint

DERIVED_DATA_PATH ?= /tmp/ParliamentsDerivedData

verify:
	Scripts/verify.sh

test:
	xcodebuild test -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=macOS,arch=arm64' -derivedDataPath "$(DERIVED_DATA_PATH)"

build-tvos:
	xcodebuild build -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=tvOS Simulator,name=Apple TV,OS=latest' -derivedDataPath "$(DERIVED_DATA_PATH)"

build-ios:
	xcodebuild build -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' -derivedDataPath "$(DERIVED_DATA_PATH)"

build-macos:
	xcodebuild build -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=macOS,arch=arm64' -derivedDataPath "$(DERIVED_DATA_PATH)"

format:
	swiftformat App Tests

format-check:
	swiftformat --lint App Tests

lint:
	swiftlint lint --strict
