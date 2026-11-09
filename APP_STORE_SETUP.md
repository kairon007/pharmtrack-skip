# PharmTrack - App Store Setup Guide

## iOS App Store

### Basic Information
- **App Name**: PharmTrack
- **Subtitle**: Medication & Health Tracking
- **Bundle ID**: `com.pharmtrack.ios` (update in Xcode)
- **Version**: 1.0.0
- **Build**: See `Darwin/AppCore.xcodeproj`

### Required Info in Xcode

1. **Update Bundle Identifier**
   - Open `Darwin/AppCore.xcodeproj` in Xcode
   - Select target "AppCore"
   - Under "General", set Bundle Identifier to: `com.pharmtrack.ios`

2. **Update Display Name**
   - In `Darwin/AppCore.xcodeproj`:
   - Build Settings → Product Name → `PharmTrack`
   - Or in Info.plist: Add key `CFBundleDisplayName` with value `PharmTrack`

3. **App Icons & Launch Screen**
   - Place app icon (1024x1024) in `Darwin/Assets.xcassets/AppIcon.appiconset/`
   - Configure launch screen in `Darwin/Sources/AppDelegate.swift`

### Screenshots (Required for App Store)
Create 6 screenshots for each device (iPhone Pro Max recommended):
1. Dashboard/Home screen
2. Medication tracking
3. Consultation records
4. Appointments view
5. Vitals tracking
6. Features overview

### Description
```
PharmTrack - Your personal medication and health management assistant.

Track medications, consultations, appointments, and vital signs all in one place. 
PharmTrack helps you stay organized and informed about your health journey.

Features:
• Easy medication tracking and reminders
• Store consultation records with doctors
• Manage appointments efficiently
• Track vital signs (blood pressure, temperature, weight, etc.)
• Works offline - access your health data anytime
• Clean, intuitive interface

Privacy: Your health data is stored locally on your device.
```

### Keywords
`medication, health, tracker, pharmacy, vitals, appointments, medical`

### Category
Medical

### Support URL
`https://your-domain.com/support`

### Privacy Policy URL
`https://your-domain.com/privacy`

---

## Android Play Store

### Basic Information
- **App Name**: PharmTrack
- **Package Name**: `com.pharmtrack.android` (in `build.gradle.kts`)
- **Version Code**: 3
- **Version Name**: 1.0.0
- **Min SDK**: 24
- **Target SDK**: 34

### Required Files

1. **Update Build Configuration**
   - Edit `Android/app/build.gradle.kts`:
   ```kotlin
   group = "com.pharmtrack"
   version = "1.0.0"
   
   android {
       namespace = "com.pharmtrack.android"
   }
   ```

2. **Update AndroidManifest.xml**
   - File: `Android/app/src/main/AndroidManifest.xml`
   - Verify `android:label="${PRODUCT_NAME}"` is set
   - Ensure `android:icon="@mipmap/ic_launcher"` points to correct icon

3. **App Icons**
   - Place icon files in `Android/app/src/main/res/`:
     - `drawable/ic_launcher_foreground.xml` (adaptive icon foreground)
     - `drawable/ic_launcher_background.xml` (adaptive icon background)
     - `mipmap-*/ic_launcher.png` (legacy icons)

4. **Screenshot Assets**
   - Create 4-8 screenshots (1080x1920 or higher)
   - Place in Play Console during upload

5. **Feature Graphic**
   - Size: 1024x500 px
   - Showcase key features

### Play Store Description
```
PharmTrack - Medication & Health Management

Your personal health assistant for tracking medications, doctor consultations, 
appointments, and vital signs.

Key Features:
✓ Medication Tracker - Never miss a dose with easy tracking
✓ Consultation Records - Keep detailed notes from doctor visits
✓ Appointment Manager - Organize and track medical appointments
✓ Vitals Log - Monitor blood pressure, temperature, weight, and more
✓ Offline Access - All data stored locally, no internet required
✓ Dark Mode - Comfortable viewing anytime

PharmTrack puts you in control of your health information. All data is stored 
securely on your device with no cloud upload or third-party sharing.

Perfect for managing chronic conditions, medication schedules, and staying 
organized with your healthcare journey.

Privacy Policy: https://your-domain.com/privacy
```

### Play Store Keywords
`medication tracker, health tracking, pharmacy, vitals, appointments, medical records`

### Content Rating
- Medical/Health Apps
- Rating: Suitable for all ages

### Target Audience
- Age: 12+
- Health conscious users
- People managing medications

### App Signing

Generate signing key:
```bash
# For Android release build
keytool -genkey -v -keystore pharmatrack-release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias pharmatrack-key

# Store in: Android/app/keystore.properties
```

### Checklist Before Submission

- [ ] All TextFields render natively (no custom borders on Android)
- [ ] Icons display correctly on both platforms
- [ ] Onboarding flow works smoothly
- [ ] App name is "PharmTrack" (no spaces in middle)
- [ ] Bundle/Package ID set correctly
- [ ] Version numbers match across platforms
- [ ] Screenshots uploaded (min 2, recommended 4-8)
- [ ] Description and keywords added
- [ ] Privacy policy URL set
- [ ] Test on actual devices (iOS 14+ and Android 7+)
- [ ] Offline functionality verified
- [ ] Dark mode tested
- [ ] Performance tested with various data loads

---

## Next Steps

1. Register Apple Developer Account (if not done)
   - Visit: https://developer.apple.com
   
2. Register Google Play Developer Account (if not done)
   - Visit: https://play.google.com/console
   
3. Create apps in respective stores
   - iOS: App Store Connect
   - Android: Google Play Console
   
4. Update Bundle ID/Package Name in code
   
5. Generate app icons and screenshots
   
6. Set up signing certificates (iOS) and keystores (Android)
   
7. Build release versions:
   ```bash
   just ios-build   # For iOS
   just android-build  # For Android
   ```
   
8. Upload and submit for review
