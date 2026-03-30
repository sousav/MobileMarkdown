# MobileMarkdown

A free, no-ads, cross-platform markdown viewer for Android and iOS. Opens `.md` files and renders them beautifully. That's it.

## The Problem

There is no simple, free, cross-platform app that just opens and renders markdown files on mobile. Every existing option is either an editor, a knowledge management platform, paid, platform-specific, or abandoned. Tapping a `.md` file on your phone either shows raw text or "no app can open this."

## The Solution

MobileMarkdown does for `.md` files what a PDF reader does for PDFs: open them, render them beautifully, and get out of the way.

## Features (v1.0)

- Open `.md` files from file picker, share sheet, or file manager
- Beautiful markdown rendering (CommonMark + GFM)
- Syntax highlighting for code blocks
- Tables, checkboxes, images, links
- Light / Dark / System theme
- Recent files list
- No ads. No accounts. No tracking. No upsells.

## Technical Stack

- **Framework:** Flutter
- **Markdown:** `markdown_widget` (CommonMark + GFM + syntax highlighting)
- **File handling:** `file_picker` + `share_handler`
- **Target size:** < 15 MB

## Documentation

| Document | Description |
|---|---|
| [Competitive Analysis](docs/research/01-competitive-analysis.md) | Exhaustive review of every existing markdown app on mobile |
| [Market Study](docs/research/02-market-study.md) | TAM/SAM/SOM, user segments, demand validation, risk assessment |
| [Stack Decision](docs/technical/01-stack-decision.md) | Comparison of 6 frameworks, decision rationale |
| [Architecture](docs/technical/02-architecture.md) | App architecture, data model, project structure, platform config |
| [Implementation Plan](docs/planning/01-implementation-plan.md) | 15-day phased development roadmap |
| [App Store Strategy](docs/planning/02-app-store-strategy.md) | ASO, organic growth, distribution plan |
| [Feature Spec v1](docs/planning/03-feature-spec-v1.md) | Detailed feature specification with error handling and performance targets |
| [Android Real-Device Acceptance](docs/release/android-real-device-acceptance.md) | Manual runbook for validating the Android release build on a phone |
| [Privacy Policy Source](privacy.html) | Public privacy policy page intended for GitHub Pages and store submission |

## Key Findings

**The gap is real.** No free, no-ads, cross-platform, view-only markdown app exists. The closest competitors:

| App | Why it fails for this use case |
|---|---|
| Obsidian | Vault-locked, can't open arbitrary files, complex, heavy |
| Markor | Android-only, editor-first, dated UI |
| Joplin | Database-locked, can't open arbitrary files |
| Simple Markdown | Android-only, editor-first, buggy |
| Bear | Apple-only, subscription |
| iA Writer | No Android, $50/platform |

## Project Status

**Status: v1.0 implementation complete.**

- `flutter analyze`: 0 issues
- `flutter test`: 21/21 passing
- Custom app icon and splash screen configured
- CI via GitHub Actions (analyze + test + format)

## Building

The Flutter app source code lives in the `app/` subdirectory. Documentation remains at the repository root in `docs/`.

### Requirements
- Flutter 3.38+ (stable channel)
- Android SDK (for Android builds)
- Xcode 15+ (for iOS builds)

### Development

```bash
cd app
flutter pub get
flutter run
```

### Running tests

```bash
cd app
flutter test                              # Unit + widget tests
flutter analyze                           # Static analysis
dart format --set-exit-if-changed lib/     # Format check
flutter test integration_test             # Integration tests (requires device)
```

### Release builds

**Android:**
```bash
# 1. Create app/android/key.properties from the example
#    or export the MOBILEMARKDOWN_UPLOAD_* environment variables
# 2. Fill in your upload keystore path, alias, and passwords
# 3. Build a signed bundle:
cd app
flutter build appbundle --release   # For Play Store (AAB)
flutter build apk --release         # For sideloading (APK)

# Optional: local release-like APK build without a real upload keystore
MOBILEMARKDOWN_ALLOW_DEBUG_RELEASE_SIGNING=true flutter build apk --release
```

**iOS:**
```bash
# 1. Copy app/ios/Flutter/Signing.xcconfig.example to app/ios/Flutter/Signing.xcconfig
# 2. Set MOBILEMARKDOWN_DEVELOPMENT_TEAM
# 3. If you use manual signing, set the Runner and ShareExtension profile specifiers too
cd app
flutter build ipa --no-codesign    # Unsigned (for manual signing)
flutter build ipa                   # Signed (requires provisioning profile)
```

## Project Structure

```
MobileMarkdown/
  docs/                         # Research, planning, and technical docs
  app/                          # Flutter application
    lib/
      main.dart                 # App entry, ThemeController, routing
      screens/
        home_screen.dart        # File picker, recent files, About dialog
        viewer_screen.dart      # Markdown rendering, copy, error states
      services/
        file_service.dart       # File I/O, recent files (SharedPrefs)
        share_receiver.dart     # Cold/warm start intent handling
      widgets/
        empty_state.dart        # "No files yet" placeholder
        recent_file_tile.dart   # Dismissible recent file entry
      theme/
        app_theme.dart          # Material 3 light/dark ThemeData
        markdown_theme.dart     # Custom markdown rendering configs
    test/                       # Unit + widget tests (21 tests)
    integration_test/           # Integration tests (device required)
    assets/                     # App icon source PNGs
  scripts/
    generate_icon.py            # Icon generator (Pillow)
  .github/workflows/ci.yml     # GitHub Actions CI
```

## License

MIT - see [LICENSE](LICENSE)
