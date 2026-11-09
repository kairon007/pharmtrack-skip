set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# List available commands
default:
	@just --list

# Setup project dependencies
setup:
	swift package resolve

# Build both platforms
build: build-android build-ios

# --- Android Commands ---

# Alias for android-build
build-android: android-build

# Build Android Debug APK
android-build:
	Android/gradlew -p Android bundleRelease

# Install and Launch Android App on connected device/emulator
android-run:
	Android/gradlew -p Android installDebug
	adb shell am start -n com.tunnxo.medtrack/pharm.track.MainActivity

# Install and Launch Android App on a specific device (e.g., if multiple connected)
# Usage: just android-device-run <SERIAL>
android-device-run device_id:
	Android/gradlew -p Android installDebug
	adb -s {{device_id}} shell am start -n com.tunnxo.medtrack/pharm.track.MainActivity

# --- iOS Commands ---

# Alias for ios-build
build-ios: ios-build

# Build iOS App for Simulator
ios-build:
	SKIP_ZERO=1 xcodebuild -scheme 'PharmTrack App' -destination 'generic/platform=iOS Simulator' -derivedDataPath build/ios/DerivedData build -workspace Project.xcworkspace -skipPackagePluginValidation

# Run iOS App on Simulator (Boots first if needed)
ios-run:
	@# Ensure a simulator is booted
	@if ! xcrun simctl list devices | grep -q "Booted"; then \
		echo "Booting simulator..."; \
		xcrun simctl boot "iPhone 16e" || true; \
		open -a Simulator; \
	fi
	@# Build
	just ios-build
	@# Install and Launch
	@echo "Installing to simulator..."
	xcrun simctl install booted build/ios/DerivedData/Build/Products/Debug-iphonesimulator/PharmTrack.app
	@echo "Launching..."
	xcrun simctl launch booted com.tunnxo.medtrack

# Run iOS App on a connected device
# Usage: just ios-device-run <UDID>
# NOTE: Requires Development Team to be set in Xcode -> PharmTrack App -> Signing & Capabilities
ios-device-run device_id:
	SKIP_ZERO=1 xcodebuild -scheme 'PharmTrack App' -destination 'id={{device_id}}' build -workspace Project.xcworkspace -skipPackagePluginValidation
	@echo "Installing and launching on device..."
	@# Note: devicectl is used for iOS 17+ devices
	xcrun devicectl device install app --device {{device_id}} $(xcodebuild -workspace Project.xcworkspace -scheme 'PharmTrack App' -destination 'id={{device_id}}' -showBuildSettings | grep -m 1 "CODESIGNING_FOLDER_PATH" | cut -d '=' -f 2 | xargs)
	xcrun devicectl device process launch --device 00008150-0011631C0228401C com.tunnxo.medtrack

# --- General ---

# Run tests on both platforms
test:
	swift test
	Android/gradlew -p Android test

# --- CI/CD & Release ---

# Setup Python environment for release scripts
setup-release:
	python3 -m venv scripts/release/venv
	scripts/release/venv/bin/pip install -r scripts/release/requirements.txt

# Generate all configuration files from .env
generate-configs:
	./scripts/generate-keystore-properties.sh
	./scripts/generate-ios-config.sh
	./scripts/generate-export-options.sh

# Show current version information
release-info:
	@scripts/release/venv/bin/python3 scripts/release/version_manager.py info

# Prepare a new release (fetch latest from stores and increment)
release-prepare:
	scripts/release/venv/bin/python3 scripts/release/version_manager.py prepare

# Bump semantic version (patch, minor, major)
release-bump type="patch":
	scripts/release/venv/bin/python3 scripts/release/version_manager.py bump {{type}}

# Build Android release App Bundle (AAB)
android-release: generate-configs
	Android/gradlew -p Android :app:bundleRelease

# Build and archive iOS app for App Store
ios-release: generate-configs
	xcodebuild -workspace Project.xcworkspace -scheme 'PharmTrack App' -sdk iphoneos -configuration Release archive -archivePath build/PharmTrack.xcarchive -skipPackagePluginValidation
	xcodebuild -exportArchive -archivePath build/PharmTrack.xcarchive -exportOptionsPlist Darwin/ExportOptions.plist -exportPath build/ios/ipa -allowProvisioningUpdates

# Upload Android release to Google Play (internal track)
upload-android:
	scripts/release/venv/bin/python3 scripts/release/uploader.py android --android-track internal

# Upload iOS release to TestFlight
upload-ios:
	scripts/release/venv/bin/python3 scripts/release/uploader.py ios

# Upload both platforms
upload-all:
	scripts/release/venv/bin/python3 scripts/release/uploader.py all

# Full release: prepare, build, and upload to both stores
release: release-prepare android-release ios-release upload-all

# --- Screenshots ---

# Process raw screenshots for store upload
screenshots-process:
	python3 scripts/screenshots/process_screenshots.py

# Capture iOS screenshots from simulator
screenshots-capture-ios:
	./scripts/screenshots/capture_ios.sh

# Capture Android screenshots from emulator/device
screenshots-capture-android:
	./scripts/screenshots/capture_android.sh

# Capture screenshots for both platforms
screenshots-capture: screenshots-capture-ios screenshots-capture-android

# Generate iOS screenshots with Koubou (requires: pip install koubou==0.16.0)
screenshots-generate-ios:
	kou generate screenshots.yaml

# Generate screenshots with Koubou (all platforms)
screenshots-generate: screenshots-generate-ios
