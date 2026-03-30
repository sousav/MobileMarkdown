# To Prod Checklist

Release only when every blocker is green.

## Current Snapshot

- `flutter analyze --fatal-infos`: passes
- `flutter test`: passes
- `dart format --set-exit-if-changed lib/ test/ integration_test/`: passes
- `flutter build ios --release --no-codesign`: passes
- `flutter build appbundle --release`: passes
- `flutter test integration_test -d macos`: fails 1 test
- `git status`: worktree is not clean; there are staged platform changes

## Blockers

- [x] Fix the Android release build.
  - `flutter build appbundle --release` now passes.
  - Added the generated Play Core `-dontwarn` rules to `app/android/app/proguard-rules.pro`.

- [ ] Configure real release signing on both platforms.
  - Android currently has a template at `app/android/key.properties.example`.
  - iOS currently only built with `--no-codesign`.
  - Create the real keystore, certificates, provisioning profiles, and signing setup.

- [x] Implement outbound file sharing or de-scope the feature.
  - De-scoped outbound native sharing in `app/lib/screens/viewer_screen.dart`.
  - The viewer now exposes an explicit clipboard copy action instead of a broken share button.
  - There is no longer a dead `MethodChannel('com.mobilemarkdown/share')` path without native implementations.

- [x] Resolve the offline/privacy/network contradiction.
  - Kept the offline-first product truth: no release `INTERNET` permission and no remote image fetching.
  - `app/lib/theme/markdown_theme.dart` now shows an offline placeholder for remote image URLs.
  - `store/listing.md` and `docs/planning/03-feature-spec-v1.md` now match that offline behavior.

- [ ] Run real-device acceptance testing for the core flows.
  - Runbook: `docs/release/android-real-device-acceptance.md`.
  - Android integration smoke passed on `Saga` (Android 14) via `flutter test integration_test/app_test.dart -d O1E1XT232302499`.
  - Android manual acceptance passed on `Saga` for picker open, direct file open, share receive, link opening, recents cleanup, theme persistence, and large-file warning.
  - Android phone: picker open, direct file open, share receive, link opening, recents cleanup, theme persistence, large-file warning.
  - iPhone: picker open, Files open-in flow, share receive, link opening, recents cleanup, theme persistence, large-file warning.
  - Confirm the new iOS share extension works end to end.

- [ ] Prepare store-submission materials.
  - Create screenshots.
  - Create the Play Store feature graphic.
  - Finalize privacy-policy text/page if required for store submission.
  - Confirm the listing copy in `store/listing.md` matches actual app behavior.

## High Priority

- [x] Normalize the product name and ASO direction.
  - Android label, iOS display name, and Flutter app title now align on `MobileMarkdown`.
  - ASO direction in `docs/planning/02-app-store-strategy.md` now keeps `MobileMarkdown` as the primary name and moves search intent into subtitle/keywords.

- [x] Expand Android file association coverage for `.markdown`.
  - Added `.markdown` to the generic MIME fallback filter in `app/android/app/src/main/AndroidManifest.xml`.
  - The Android manifest and supporting docs now align on both `.md` and `.markdown`.

- [ ] Narrow the iOS share extension to supported content only.
  - `app/ios/ShareExtension/Info.plist` currently advertises images, movies, URLs, and generic data.
  - The app mostly handles markdown, text files, and shared text.

- [x] Fix known doc and UX drift.
  - Replaced the starter `app/README.md` with project-specific app docs.
  - Added the GitHub repository link to the About dialog in `app/lib/screens/home_screen.dart`.

- [ ] Strengthen tests around critical paths.
  - Added real `FileService` coverage for file I/O, recents cleanup, and error handling.
  - Added share receive tests.
  - Added tests for clipboard copy behavior.
  - Add a real release-focused integration pass on device.

## Nice To Have

- [ ] Add a permanent release checklist under `docs/` or link this file from `README.md`.
- [ ] Add repo polish promised in launch docs: `CONTRIBUTING`, issue templates, and a privacy page.
- [ ] Replace or remove the placeholder iOS test target in `app/ios/RunnerTests/RunnerTests.swift`.
- [ ] Capture actual performance numbers against the targets in `docs/planning/03-feature-spec-v1.md`.
- [ ] Add lightweight release automation once the manual release path is stable.

## Release Gate

Do not ship until all of these are green:

- [ ] Clean worktree and reviewed release commit
- [ ] `flutter analyze --fatal-infos`
- [ ] `flutter test`
- [ ] `flutter test integration_test -d <device>`
- [ ] `flutter build appbundle --release`
- [ ] Signed iOS archive / `flutter build ipa`
- [ ] Manual QA passes on at least one Android phone and one iPhone
- [ ] Store assets ready
- [ ] Store copy, privacy copy, and feature list match the shipped app exactly
