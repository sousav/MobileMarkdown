# MobileMarkdown App

Flutter app for MobileMarkdown.

It opens local Markdown files, renders them cleanly on Android and iOS, and stays offline by default.

## Core Features

- Open `.md`, `.markdown`, and `.txt` files from the file picker
- Handle direct file opens and share-sheet imports
- Render CommonMark and GitHub Flavored Markdown with syntax highlighting
- Keep recent files and theme preference on device
- Copy markdown contents from the viewer
- Avoid ads, analytics, accounts, and network fetches

## Common Commands

Run these from the `app/` directory:

```bash
flutter pub get
flutter run
flutter test
flutter test integration_test/app_test.dart -d macos
flutter build appbundle --release
flutter build ios --release --no-codesign
```

## Important Paths

- `lib/` app source
- `test/` unit and widget tests
- `integration_test/` app smoke tests
- `android/key.properties.example` Android signing template
- `ios/Flutter/Signing.xcconfig.example` iOS signing template
- `../to-prod-checklist.md` production checklist
- `../store/listing.md` store listing copy

## Project

- Repository: `https://github.com/sousav/MobileMarkdown`
- License: MIT
