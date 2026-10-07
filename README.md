# إعراب

A bilingual Flutter application that teaches beginners why Arabic word endings
change and how to read unvocalized Arabic more accurately.

The first release is curriculum-first: lessons, worked examples, practice, and
local progress work offline without an account. AI-powered إعراب is planned
after the learning MVP is validated.

## Requirements

- Flutter 3.44 or newer
- Dart 3.12 or newer
- Xcode with iOS 15 SDK support
- Android SDK with API 24 or newer

## Setup

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=APP_ENV=development
```

Supported `APP_ENV` values are `development`, `staging`, and `production`.

### إعراب Plus subscriptions

Level 1 remains free; Level 2 and later levels require the active `plus`
entitlement. The paywall loads monthly and/or annual packages and localized
prices from the current RevenueCat offering. Configure the `plus` entitlement,
attach the store products to it, and add the available monthly/annual packages
to the current offering.

Configure RevenueCat with the matching public SDK key for each store:

```bash
flutter run \
  --dart-define=REVENUECAT_IOS_API_KEY=appl_your_ios_public_key \
  --dart-define=REVENUECAT_ANDROID_API_KEY=goog_your_android_public_key
```

Purchases and restoration use the Apple App Store or Google Play account on the
device. Restore is available from **More → Restore purchases** and the paywall.
No learner account or custom subscription database is required. If the platform
key is missing or invalid, the app keeps running but Plus remains unavailable.

For **real Apple/Google sandbox testing**, first create the subscription
products in App Store Connect and Google Play, connect them to RevenueCat, and
provide the platform-specific `appl_` and `goog_` keys to the build. A RevenueCat
Test Store key cannot purchase those store products.

Local iOS or Android development runs can use
`--dart-define=REVENUECAT_TEST_API_KEY=...` with `APP_ENV=development`.
Test Store keys are rejected in release mode or with
`APP_ENV=production`, including when placed in a platform-specific key setting.
Production store builds must use `appl_` and `goog_` keys. Keep keys out of
source control; provide them through the build environment or GitHub Actions
secrets. Public SDK keys are embedded in the app and can be extracted from it.
The TestFlight workflow reads the `REVENUECAT_IOS_API_KEY` Actions secret.
Android release builds must pass `REVENUECAT_ANDROID_API_KEY` as a Dart define.

The manually triggered **RevenueCat Test Store build** workflow uses the
`REVENUECAT_TEST_API_KEY` Actions secret to produce a short-retention Android
debug APK for direct installation. It does not publish to Google Play or
TestFlight and is not a substitute for real store sandbox testing.

## Validation

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
dart run tool/validate_content.dart
flutter build apk --debug --dart-define=APP_ENV=production
flutter build ios --debug --simulator --dart-define=APP_ENV=production
```

Before a tagged release, teacher approval is enforced with:

```bash
dart run tool/validate_content.dart --release
```

Create an App Store archive with:

```bash
flutter build ipa --release \
  --dart-define=APP_ENV=production \
  --dart-define="REVENUECAT_IOS_API_KEY=$REVENUECAT_IOS_API_KEY" \
  --export-options-plist=ios/ExportOptions.plist
```

Create a Google Play internal-test bundle with:

```bash
flutter build appbundle --release \
  --dart-define=APP_ENV=production \
  --dart-define="REVENUECAT_ANDROID_API_KEY=$REVENUECAT_ANDROID_API_KEY"
```

Upload the resulting AAB through Google Play Console's internal testing track.

The current beta version is `0.1.0+23`. App Store Connect metadata and the
external-beta release gate are documented in `docs/app-store-connect.md`.

## Project Structure

```text
lib/
├── core/       # Configuration, localization state, storage, and theme
├── features/   # Home, lessons, practice, progress, and settings
├── l10n/       # English and Arabic ARB resources
└── shared/     # Reusable presentation components
```

The implementation plan is at
`thoughts/arabic-grammar/plans/implementation-plan.md`.

Lesson authors should follow `docs/content-authoring.md`. Qualified Arabic
grammar reviewers should use `docs/teacher-review-checklist.md`.

## Font License

Arabic examples use the Amiri Quran font from the Amiri Project, distributed
under the SIL Open Font License 1.1. The license is included at
`assets/fonts/OFL-Amiri.txt`.
