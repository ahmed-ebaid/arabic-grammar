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
  --export-options-plist=ios/ExportOptions.plist
```

The current beta version is `0.1.0+3`. App Store Connect metadata and the
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
