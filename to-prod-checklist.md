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

- [ ] Implement outbound file sharing or de-scope the feature.
  - `app/lib/screens/viewer_screen.dart` calls `MethodChannel('com.mobilemarkdown/share')`.
  - There is no native implementation in `app/android/app/src/main/kotlin/com/mobilemarkdown/mobile_markdown/MainActivity.kt`.
  - There is no native implementation in `app/ios/Runner/AppDelegate.swift`.
  - Right now the app effectively falls back to clipboard copy.

- [ ] Resolve the offline/privacy/network contradiction.
  - `store/listing.md` says the app works fully offline with no internet permission.
  - `docs/planning/03-feature-spec-v1.md` says remote images should load.
  - `app/android/app/src/main/AndroidManifest.xml` does not declare release `INTERNET` permission.
  - Pick one product truth and align code, docs, and store copy.

- [ ] Run real-device acceptance testing for the core flows.
  - Android phone: picker open, direct file open, share receive, link opening, recents cleanup, theme persistence, large-file warning.
  - iPhone: picker open, Files open-in flow, share receive, link opening, recents cleanup, theme persistence, large-file warning.
  - Confirm the new iOS share extension works end to end.

- [ ] Prepare store-submission materials.
  - Create screenshots.
  - Create the Play Store feature graphic.
  - Finalize privacy-policy text/page if required for store submission.
  - Confirm the listing copy in `store/listing.md` matches actual app behavior.

## High Priority

- [ ] Normalize the product name and ASO direction.
  - Android label: `app/android/app/src/main/AndroidManifest.xml`
  - iOS display name: `app/ios/Runner/Info.plist`
  - Flutter app title: `app/lib/main.dart`
  - ASO recommendation: `docs/planning/02-app-store-strategy.md`

- [ ] Expand Android file association coverage for `.markdown`.
  - Current fallback filter only matches `.md` in `app/android/app/src/main/AndroidManifest.xml`.
  - Docs and picker behavior promise both `.md` and `.markdown`.

- [ ] Narrow the iOS share extension to supported content only.
  - `app/ios/ShareExtension/Info.plist` currently advertises images, movies, URLs, and generic data.
  - The app mostly handles markdown, text files, and shared text.

- [ ] Fix known doc and UX drift.
  - `app/integration_test/app_test.dart` expects `No recent files`.
  - `app/lib/widgets/empty_state.dart` renders `No files yet`.
  - `app/README.md` is still the default Flutter starter README.
  - The About dialog in `app/lib/screens/home_screen.dart` still lacks the planned GitHub link.

- [ ] Strengthen tests around critical paths.
  - Add real `FileService` coverage for file I/O, recents cleanup, and error handling.
  - Add share receive tests.
  - Add tests for share fallback behavior.
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
