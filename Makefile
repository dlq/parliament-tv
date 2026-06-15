.PHONY: bootstrap verify test build-tvos build-ios build-ipad build-macos format format-check lint

DERIVED_DATA_PATH ?= /tmp/ParliamentsDerivedData
XCODEBUILD_TEST_SETTINGS ?=

bootstrap:
	xcrun --find swift-format

verify:
	Scripts/verify.sh

test:
	xcodebuild test -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=macOS,arch=arm64' -derivedDataPath "$(DERIVED_DATA_PATH)" $(XCODEBUILD_TEST_SETTINGS)

build-tvos:
	xcodebuild build -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=tvOS Simulator,name=Apple TV,OS=latest' -derivedDataPath "$(DERIVED_DATA_PATH)"

build-ios:
	xcodebuild build -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' -derivedDataPath "$(DERIVED_DATA_PATH)"

build-ipad:
	xcodebuild build -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=latest' -derivedDataPath "$(DERIVED_DATA_PATH)"

build-macos:
	xcodebuild build -project Parliaments.xcodeproj -scheme Parliaments -configuration Debug -destination 'platform=macOS,arch=arm64' -derivedDataPath "$(DERIVED_DATA_PATH)"

format:
	xcrun swift-format format --in-place --recursive --parallel App Tests

format-check:
	xcrun swift-format lint --recursive --parallel --strict App Tests

lint:
	xcrun swift-format lint --recursive --parallel --strict App Tests
