# Android Real-Device Acceptance

Use this runbook before pushing an Android release to production.

## Prerequisites

- A physical Android phone with Developer Options and USB debugging enabled
- Flutter installed locally
- A successful release APK build from the current commit
- Test files available on the phone or easy to share from your computer

## Recommended Test Files

- `app/test_assets/sample.md`
- A copy of `app/test_assets/sample.md` renamed to `sample.markdown`
- A large markdown file over 10 MB for the warning flow

Generate a large file if needed:

```bash
python3 - <<'PY'
from pathlib import Path

target = Path("/tmp/mobilemarkdown-large.md")
payload = "# Large File\n\n" + ("Lorem ipsum dolor sit amet.\n" * 500000)
target.write_text(payload)
print(target, target.stat().st_size)
PY
```

## Install The Release Build

From the `app/` directory:

```bash
flutter devices
flutter build apk --release
flutter install --release -d <device-id>
```

Notes:

- The release APK is written to `app/build/app/outputs/flutter-apk/app-release.apk`.
- Until `app/android/key.properties` exists, local release installs use the debug signing fallback in `app/android/app/build.gradle.kts`.

## Acceptance Matrix

Record pass or fail for each flow:

| Flow | Steps | Expected Result |
|---|---|---|
| Picker open (`.md`) | Launch the app, tap `Open File`, choose `sample.md` | Viewer opens and renders the file correctly |
| Picker open (`.markdown`) | Repeat with `sample.markdown` | Viewer opens and renders the file correctly |
| Direct file open (`.md`) | Open `sample.md` from the Android file manager | MobileMarkdown appears as a handler and opens the file |
| Direct file open (`.markdown`) | Open `sample.markdown` from the Android file manager | MobileMarkdown appears as a handler and opens the file |
| Share receive (file) | Share `sample.md` from a file manager or another app into MobileMarkdown | App opens directly to the viewer with the shared file |
| Share receive (text) | Share plain markdown text into MobileMarkdown | App opens to the viewer with file name `Shared Text` |
| Link opening | Open `sample.md` and tap a link | The default browser opens to the tapped URL |
| Recents cleanup | Open a file, delete or move it outside the app, then tap it from `Recent Files` | Snackbar says the file could not be found and the stale recent entry disappears |
| Theme persistence | Cycle through theme modes in the viewer, close the app, then reopen it | The last selected theme mode persists |
| Large-file warning | Open the generated file over 10 MB | Large-file warning appears before opening |

## Suggested Execution Order

1. Install the release build.
2. Run both picker-open checks.
3. Run both direct-open checks.
4. Run both share-receive checks.
5. Verify links, recents cleanup, theme persistence, and the large-file warning.
6. Note device model, Android version, and any failures before release.

## Sign-Off Template

- Device:
- Android version:
- Build tested:
- Result:
- Notes:
