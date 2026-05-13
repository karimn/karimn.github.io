#!/usr/bin/env python3
"""Generate og-image.png for the site's social card.

Edit the constants near the top of this file, then run:

    scripts/.venv/bin/python scripts/build_og_image.py
    cp og-image.png docs/og-image.png   # so quarto's render output ships it

The script downloads Fraunces, Newsreader, and IBM Plex Mono into
scripts/.fonts/ on first run (via curl) and writes the result to
og-image.png in the repo root. It needs Pillow; if scripts/.venv is
missing, bootstrap it with:

    python3 -m venv scripts/.venv
    scripts/.venv/bin/pip install Pillow

Both scripts/.venv/ and scripts/.fonts/ are gitignored.
"""
from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# ---------------------------------------------------------------------------
# Content — edit these to change the card.
# ---------------------------------------------------------------------------

EYEBROW = "ECONOMIST  ·  APPLIED BAYESIAN STATISTICIAN"
TITLE = "Karim Naguib"
LEDE_LINES = [
    "Hierarchical Bayesian models for",
    "longitudinal & survival data.",
]
FOOTER_LEFT = "KARIMN.GITHUB.IO"
FOOTER_RIGHT_TAGS = [
    "DIGITAL-TWIN ONCOLOGY",
    "CAUSAL INFERENCE",
    "SURVIVAL ANALYSIS",
]

# ---------------------------------------------------------------------------
# Visual style — palette mirrors theme.scss.
# ---------------------------------------------------------------------------

WIDTH, HEIGHT = 1200, 630
PAPER = (250, 248, 243)        # $paper
INK = (26, 22, 18)             # $ink
INK_SOFT = (61, 53, 48)        # $ink-soft
INK_MUTED = (138, 127, 112)    # $ink-muted
ACCENT = (124, 43, 31)         # $accent
RULE = (217, 209, 192)         # $rule

PAD_X = 80
EYEBROW_Y = 80
RULE_Y = 500

# ---------------------------------------------------------------------------
# Fonts — fetched from Google Fonts on first run.
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent.parent
FONT_DIR = Path(__file__).resolve().parent / ".fonts"
FONT_DIR.mkdir(exist_ok=True)

FONT_URLS = {
    # Fontsource mirrors every Google font as plain .ttf files, which is
    # the most reliable CDN for scripted builds.
    "Fraunces-Regular.ttf":
        "https://cdn.jsdelivr.net/fontsource/fonts/fraunces@latest/latin-400-normal.ttf",
    "Newsreader-Regular.ttf":
        "https://cdn.jsdelivr.net/fontsource/fonts/newsreader@latest/latin-400-normal.ttf",
    "IBMPlexMono-Medium.ttf":
        "https://cdn.jsdelivr.net/fontsource/fonts/ibm-plex-mono@latest/latin-500-normal.ttf",
    "IBMPlexMono-Regular.ttf":
        "https://cdn.jsdelivr.net/fontsource/fonts/ibm-plex-mono@latest/latin-400-normal.ttf",
}


def ensure_font(name: str) -> Path:
    path = FONT_DIR / name
    if path.exists():
        return path
    url = FONT_URLS[name]
    if shutil.which("curl") is None:
        raise RuntimeError("curl is required to bootstrap font files")
    print(f"  fetching {name} …", file=sys.stderr)
    subprocess.run(
        ["curl", "-fsSL", "-o", str(path), url],
        check=True,
    )
    return path


def load(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(ensure_font(name)), size=size)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def text_width(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont) -> int:
    return int(draw.textlength(text, font=font))


def draw_eyebrow(draw: ImageDraw.ImageDraw, font: ImageFont.FreeTypeFont) -> None:
    # Tracking via spaces in EYEBROW; first segment ("ECONOMIST") gets an
    # underline in accent color to echo the masthead treatment.
    draw.text((PAD_X, EYEBROW_Y), EYEBROW, font=font, fill=INK_MUTED)
    first = EYEBROW.split("·")[0].rstrip()
    underline_w = text_width(draw, first, font)
    underline_y = EYEBROW_Y + font.size + 6
    draw.line(
        [(PAD_X, underline_y), (PAD_X + underline_w, underline_y)],
        fill=ACCENT,
        width=3,
    )


def draw_right_marker(draw: ImageDraw.ImageDraw) -> None:
    # Slim oxblood vertical bar in the upper-right — visual anchor.
    x = WIDTH - PAD_X
    draw.line([(x, EYEBROW_Y - 10), (x, EYEBROW_Y + 60)], fill=ACCENT, width=4)


def draw_title(draw: ImageDraw.ImageDraw, font: ImageFont.FreeTypeFont, y: int) -> int:
    draw.text((PAD_X, y), TITLE, font=font, fill=INK)
    return y + font.size


def draw_lede(draw: ImageDraw.ImageDraw, font: ImageFont.FreeTypeFont, y: int) -> int:
    line_height = int(font.size * 1.25)
    for line in LEDE_LINES:
        draw.text((PAD_X, y), line, font=font, fill=INK_SOFT)
        y += line_height
    return y


def draw_footer(
    draw: ImageDraw.ImageDraw,
    rule_y: int,
    left_font: ImageFont.FreeTypeFont,
    right_font: ImageFont.FreeTypeFont,
) -> None:
    draw.line([(PAD_X, rule_y), (WIDTH - PAD_X, rule_y)], fill=RULE, width=1)

    foot_y = rule_y + 40
    draw.text((PAD_X, foot_y), FOOTER_LEFT, font=left_font, fill=INK_MUTED)

    tag_text = "  ·  ".join(FOOTER_RIGHT_TAGS)
    tag_w = text_width(draw, tag_text, right_font)
    draw.text((WIDTH - PAD_X - tag_w, foot_y), tag_text, font=right_font, fill=INK_SOFT)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def build() -> Path:
    img = Image.new("RGB", (WIDTH, HEIGHT), PAPER)
    draw = ImageDraw.Draw(img)

    eyebrow_font = load("IBMPlexMono-Medium.ttf", 22)
    title_font = load("Fraunces-Regular.ttf", 124)
    lede_font = load("Newsreader-Regular.ttf", 38)
    foot_left_font = load("IBMPlexMono-Medium.ttf", 20)
    foot_right_font = load("IBMPlexMono-Medium.ttf", 18)

    draw_eyebrow(draw, eyebrow_font)
    draw_right_marker(draw)

    title_y = 180
    cursor = draw_title(draw, title_font, title_y)
    cursor += 70
    draw_lede(draw, lede_font, cursor)
    draw_footer(draw, RULE_Y, foot_left_font, foot_right_font)

    out = REPO_ROOT / "og-image.png"
    img.save(out, "PNG", optimize=True)
    return out


if __name__ == "__main__":
    print(f"writing {build().relative_to(REPO_ROOT)}")
