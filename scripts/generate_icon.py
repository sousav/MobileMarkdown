#!/usr/bin/env python3
"""Generate app icon for MobileMarkdown.

Creates a simple, clean icon: white "MD" text on a blue rounded-rectangle
background. Produces a 1024x1024 PNG suitable for flutter_launcher_icons.
Also produces an adaptive icon foreground (with transparent padding).
"""

from PIL import Image, ImageDraw, ImageFont
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
ASSETS_DIR = os.path.join(PROJECT_DIR, "app", "assets")

# Material Blue 700 — matches colorSchemeSeed
BG_COLOR = (25, 118, 210)  # #1976D2
FG_COLOR = (255, 255, 255)  # white
ICON_SIZE = 1024
CORNER_RADIUS = 180


def draw_rounded_rect(draw, xy, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = xy
    # Four corner circles
    draw.ellipse([x0, y0, x0 + 2 * radius, y0 + 2 * radius], fill=fill)
    draw.ellipse([x1 - 2 * radius, y0, x1, y0 + 2 * radius], fill=fill)
    draw.ellipse([x0, y1 - 2 * radius, x0 + 2 * radius, y1], fill=fill)
    draw.ellipse([x1 - 2 * radius, y1 - 2 * radius, x1, y1], fill=fill)
    # Two rectangles to fill the rest
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)


def find_best_font(size):
    """Try to find a good bold font, fall back to default."""
    font_paths = [
        "/System/Library/Fonts/SFCompact.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    # Fall back to default
    return ImageFont.load_default()


def generate_standard_icon():
    """Generate the standard 1024x1024 app icon."""
    img = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Blue rounded rectangle background
    draw_rounded_rect(draw, (0, 0, ICON_SIZE, ICON_SIZE), CORNER_RADIUS, BG_COLOR)

    # "MD" text — try multiple font sizes to find the best fit
    target_width = ICON_SIZE * 0.65
    font_size = 420
    font = find_best_font(font_size)

    # Measure and adjust
    bbox = draw.textbbox((0, 0), "MD", font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    # Center the text
    x = (ICON_SIZE - text_w) // 2 - bbox[0]
    y = (ICON_SIZE - text_h) // 2 - bbox[1]

    # Draw the text
    draw.text((x, y), "MD", fill=FG_COLOR, font=font)

    # Add a subtle down-arrow or document hint below "MD"
    # Small horizontal line suggesting a document/markdown
    line_y = y + text_h + 40
    line_w = text_w * 0.8
    line_x = (ICON_SIZE - line_w) // 2
    line_h = 12
    for i in range(3):
        ly = line_y + i * (line_h + 18)
        lw = line_w if i == 0 else line_w * (0.7 if i == 1 else 0.5)
        lx = (ICON_SIZE - lw) // 2
        draw.rounded_rectangle(
            [lx, ly, lx + lw, ly + line_h],
            radius=line_h // 2,
            fill=(*FG_COLOR, 120),  # semi-transparent white
        )

    path = os.path.join(ASSETS_DIR, "icon.png")
    img.save(path, "PNG")
    print(f"Generated: {path}")
    return img


def generate_adaptive_foreground():
    """Generate Android adaptive icon foreground (with safe-zone padding).

    Adaptive icons use a 108dp canvas with 72dp safe zone centered.
    The foreground should be 1024x1024 with content in the center 66.7%.
    """
    canvas = 1024
    safe_zone = int(canvas * 72 / 108)  # ~682px
    padding = (canvas - safe_zone) // 2  # ~171px

    img = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # "MD" text centered in the safe zone
    font_size = 320
    font = find_best_font(font_size)

    bbox = draw.textbbox((0, 0), "MD", font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    x = (canvas - text_w) // 2 - bbox[0]
    y = (canvas - text_h) // 2 - bbox[1] - 30  # slightly above center

    draw.text((x, y), "MD", fill=FG_COLOR, font=font)

    # Small lines below
    line_y = y + text_h + 30
    line_h = 10
    for i in range(3):
        ly = line_y + i * (line_h + 14)
        lw = text_w * (0.8 if i == 0 else 0.6 if i == 1 else 0.4)
        lx = (canvas - lw) // 2
        draw.rounded_rectangle(
            [lx, ly, lx + lw, ly + line_h],
            radius=line_h // 2,
            fill=(*FG_COLOR, 120),
        )

    path = os.path.join(ASSETS_DIR, "icon_foreground.png")
    img.save(path, "PNG")
    print(f"Generated: {path}")


def generate_adaptive_background():
    """Generate a solid blue background for adaptive icons."""
    img = Image.new("RGBA", (1024, 1024), (*BG_COLOR, 255))
    path = os.path.join(ASSETS_DIR, "icon_background.png")
    img.save(path, "PNG")
    print(f"Generated: {path}")


if __name__ == "__main__":
    os.makedirs(ASSETS_DIR, exist_ok=True)
    generate_standard_icon()
    generate_adaptive_foreground()
    generate_adaptive_background()
    print("Done! Now run: flutter pub run flutter_launcher_icons")
