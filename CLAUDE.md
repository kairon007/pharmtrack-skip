# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Skip** (skip.dev) dual-platform mobile application for healthcare/medical tracking.

- **Framework**: Swift/SwiftUI with Skip transpilation to Android (Kotlin)
- **Architecture**: MVVM with repository pattern
- **Package Manager**: Swift Package Manager

## Build Commands

| Command | Description |
|---------|-------------|
| `just setup` | Resolve Swift package dependencies |
| `just android-build` | Build Android Debug APK |
| `just android-run` | Install and launch on Android emulator |
| `just ios-build` | Build iOS App for Simulator |
| `just ios-run` | Run iOS App on Simulator |
| `just test` | Run tests on both platforms |

**Direct commands:**
- `swift test` - Run Swift tests
- `skip verify` - Validate Skip setup
- `skip checkup` - Check Skip prerequisites
- Open `Project.xcworkspace` in Xcode for iOS development

## Architecture

The codebase is organized into SPM targets:

- **AppCore** - App entry point and root view
- **AppModel** - Domain models, ViewModel, Repository (platform-neutral)
- **SharedUI** - SwiftUI views (transpiled to Android via Skip)

Key patterns:
- **MVVM**: ViewModels with `@Published` properties, views use `@StateObject`
- **Repository**: Repository protocol abstracts persistence
- **Data Models**: Domain models in `AppModel`

## Platform-Specific Code

- iOS/macOS: `Darwin/` directory with Xcode project and app delegate
- Android: Generated Kotlin in `Android/` directory (modify Swift sources to regenerate)
- Use `#if SKIP` conditional compilation for Android-specific code
- Keep domain logic in `AppModel` target for Android compatibility

## Development Notes

- Install Skip via Homebrew: `brew install skiptools/skip/skip`
- Skip converts Swift to Kotlin - core logic must remain platform-neutral
- Both platforms share `SharedUI` views transpiled by Skip
- Tests run via `skip test` for cross-platform parity validation

## Android Icons and Resources

**IMPORTANT:** Skip's built-in SF Symbol to Material Icon mapping does not support all icons. Always use native Android drawable resources for icons.

### Icon Implementation

1. **Use `AppIcon`** component from `SharedUI/Theme.swift` for all icons
2. **Add SVG/XML drawables** to `Android/app/src/main/res/drawable/`
3. **Map icons** in the `IconMapper.map()` function in `Theme.swift`

### Adding New Icons

1. Create SVG vector drawable in `Android/app/src/main/res/drawable/` (e.g., `ic_my_icon.xml`)
2. Add mapping in `IconMapper.map()`:
   ```swift
   "sf.symbol.name": "ic_my_icon",
   ```
3. Use in SwiftUI: `AppIcon(name: "sf.symbol.name", size: 24)`

### Current Icon Mappings

See `Theme.swift` for the complete list of SF Symbol to drawable name mappings.