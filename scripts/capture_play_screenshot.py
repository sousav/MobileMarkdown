#!/usr/bin/env python3
"""Capture a Play Store-ready Android screenshot from adb.

By default this grabs a raw device screenshot with `adb exec-out screencap -p`,
then center-crops it to a 9:16 portrait frame and exports a 1080x1920 PNG.
That keeps the result inside the Play Console screenshot constraints for both
phone and 7-inch tablet listings.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image


PRESETS = {
    "phone": (1080, 1920),
    "tablet7": (1080, 1920),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "output",
        help="Output PNG path, for example screenshots/play/android/phone/01-home.png",
    )
    parser.add_argument(
        "--serial",
        help="ADB device serial, for example emulator-5554",
    )
    parser.add_argument(
        "--preset",
        choices=sorted(PRESETS.keys()),
        default="phone",
        help="Named export size preset (default: phone)",
    )
    parser.add_argument(
        "--width",
        type=int,
        help="Custom output width in pixels",
    )
    parser.add_argument(
        "--height",
        type=int,
        help="Custom output height in pixels",
    )
    parser.add_argument(
        "--adb",
        default=os.environ.get("ADB", "adb"),
        help="ADB executable path (default: adb or $ADB)",
    )
    return parser.parse_args()


def build_adb_command(adb_path: str, serial: str | None, *args: str) -> list[str]:
    command = [adb_path]
    if serial:
        command.extend(["-s", serial])
    command.extend(args)
    return command


def capture_raw_screenshot(
    adb_path: str, serial: str | None, destination: Path
) -> None:
    command = build_adb_command(adb_path, serial, "exec-out", "screencap", "-p")
    with destination.open("wb") as output_file:
        result = subprocess.run(command, stdout=output_file, stderr=subprocess.PIPE)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.decode("utf-8", errors="replace").strip())


def crop_to_aspect(
    image: Image.Image, target_width: int, target_height: int
) -> Image.Image:
    source_width, source_height = image.size
    if source_width > source_height:
        raise ValueError(
            f"Expected a portrait screenshot, got {source_width}x{source_height}. "
            "Rotate the emulator/device to portrait and try again."
        )

    target_ratio = target_width / target_height
    source_ratio = source_width / source_height

    if abs(source_ratio - target_ratio) < 0.0001:
        return image

    if source_ratio > target_ratio:
        cropped_width = int(round(source_height * target_ratio))
        left = (source_width - cropped_width) // 2
        return image.crop((left, 0, left + cropped_width, source_height))

    cropped_height = int(round(source_width / target_ratio))
    top = (source_height - cropped_height) // 2
    return image.crop((0, top, source_width, top + cropped_height))


def export_processed_screenshot(
    raw_path: Path, output_path: Path, width: int, height: int
) -> None:
    image = Image.open(raw_path)
    processed = crop_to_aspect(image, width, height)
    if processed.size != (width, height):
        processed = processed.resize((width, height), Image.Resampling.LANCZOS)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    processed.save(output_path, "PNG", optimize=True)


def main() -> int:
    args = parse_args()
    if bool(args.width) != bool(args.height):
        print("Both --width and --height are required together.", file=sys.stderr)
        return 2

    width, height = (
        (args.width, args.height)
        if args.width and args.height
        else PRESETS[args.preset]
    )

    output_path = Path(args.output).expanduser().resolve()
    with tempfile.TemporaryDirectory() as temp_dir:
        raw_path = Path(temp_dir) / "raw-screenshot.png"
        try:
            capture_raw_screenshot(args.adb, args.serial, raw_path)
            export_processed_screenshot(raw_path, output_path, width, height)
        except Exception as error:
            print(f"Screenshot capture failed: {error}", file=sys.stderr)
            return 1

    print(f"Saved {output_path} ({width}x{height}, preset={args.preset})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
