# Play Store Screenshots

Use one phone-sized Android device and one 7-inch tablet Android device. Capture the app in portrait, then export Play-ready PNGs at `1080x1920` so every image is `9:16` and accepted by Play Console.

## Recommended Devices

- Phone: `Pixel_8`
- 7-inch tablet: `Nexus 7 (2013)` if Android Studio still offers that hardware profile
- Fallback 7-inch tablet: create a custom hardware profile named `Play_7_Tablet` with:
  - screen size: `7.0"`
  - resolution: `1200 x 1920`
  - density: `320 dpi`
  - system image: latest Google Play x86_64 image

Notes:

- The repository already has a phone AVD named `Pixel_8`.
- If you create a tablet AVD with a taller or wider native aspect ratio, that is still fine. The screenshot script center-crops the raw image to a Play-safe `9:16` export.

## One-Time Setup

1. Create or confirm the AVDs in Android Studio Device Manager.
2. Boot the emulator you want to capture.
3. Run `adb devices` and note the serial, for example `emulator-5554`.
4. Start the app on that device.

Example:

```bash
cd app
flutter run -d emulator-5554
```

## Capture Commands

Phone example:

```bash
python3 scripts/capture_play_screenshot.py \
  --serial emulator-5554 \
  --preset phone \
  screenshots/play/android/phone/01-home.png
```

7-inch tablet example:

```bash
python3 scripts/capture_play_screenshot.py \
  --serial emulator-5556 \
  --preset tablet7 \
  screenshots/play/android/tablet-7in/01-home.png
```

Both presets currently export `1080x1920`. This is intentional:

- it fits Play's portrait screenshot requirements
- it avoids relying on raw emulator dimensions
- it keeps the workflow the same for phone and tablet captures

## Suggested Shot List

Capture the same scenes on phone and 7-inch tablet:

1. Home screen with recent files
2. Markdown article rendering
3. Code block rendering
4. Tables and task lists
5. Dark theme
6. Direct file-open flow or share-open flow

## Helpful Commands

List AVDs:

```bash
bun run emu:list
```

Boot the default phone emulator:

```bash
bun run emu:boot
```

List connected Android devices:

```bash
adb devices
```

## Tips

- Capture in portrait only.
- Hide debug banners by using a normal release/profile build when possible.
- Keep screenshots clean and focused on one feature at a time.
- Do not upscale random desktop images to fake tablet screenshots; capture them from a real tablet-class AVD.
