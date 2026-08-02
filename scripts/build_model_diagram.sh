#!/usr/bin/env bash
# Build a site-palette copy of the PIONEER model-overview diagram.
#
# The diagram's source of truth is the paper's TikZ file in the `pioneer` repo.
# This DERIVES from that file at build time rather than keeping a forked copy
# here, so a change to the paper's diagram reaches the website by re-running
# this, and the two cannot silently disagree about what the model looks like.
#
# The recolouring is possible in one pass because the original defines exactly
# five named colours and expresses every fill as a tint of one of them
# (`azNavy!8`, `azPlat!10`, ...). Swapping the five definitions therefore
# repaints borders, fills and arrows together.
#
# `white` is redefined too, and that is the non-obvious part: xcolor's `!N`
# tint syntax means "N% of the colour, remainder WHITE", so on an unmodified
# file every tinted box would come out as a near-white panel sitting on the
# site's cream ground — visible as a rectangle of the wrong colour. Pointing
# `white` at $paper makes the tints mix against the page instead.
#
# Usage:  scripts/build_model_diagram.sh
# Output: writing/figures/model-overview-site.svg  (committed)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$HERE")"
PIONEER="${PIONEER_REPO:-$(dirname "$REPO")/pioneer}"
SRC="$PIONEER/writing/figures/model-overview.tex"
OUT_DIR="$REPO/writing/figures"
FONT_DIR="$REPO/scripts/.fonts"

[ -f "$SRC" ] || { echo "error: no diagram source at $SRC (set PIONEER_REPO)" >&2; exit 1; }
[ -f "$FONT_DIR/Newsreader-Regular.ttf" ] || {
  echo "error: Newsreader missing from $FONT_DIR — run a Quarto render or" >&2
  echo "       scripts/build_og_image.py first to populate the font cache" >&2
  exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
DERIVED="$WORK/model-overview-site.tex"

# theme.scss tokens. Mapped by ROLE, not by hue: azNavy carries the two
# submodel boxes (the structural centre of the diagram) so it takes the deep
# teal; azPlum marks endpoints and the feedback arrow, so it takes the site's
# oxblood accent.
sed -E \
  -e 's/\\definecolor\{azNavy\}\{HTML\}\{[0-9A-Fa-f]{6}\}/\\definecolor{azNavy}{HTML}{1F5673}/' \
  -e 's/\\definecolor\{azGold\}\{HTML\}\{[0-9A-Fa-f]{6}\}/\\definecolor{azGold}{HTML}{B07D2B}/' \
  -e 's/\\definecolor\{azTurq\}\{HTML\}\{[0-9A-Fa-f]{6}\}/\\definecolor{azTurq}{HTML}{6E9AA8}/' \
  -e 's/\\definecolor\{azPlum\}\{HTML\}\{[0-9A-Fa-f]{6}\}/\\definecolor{azPlum}{HTML}{7C2B1F}/' \
  -e 's/\\definecolor\{azPlat\}\{HTML\}\{[0-9A-Fa-f]{6}\}/\\definecolor{azPlat}{HTML}{8A7F70}/' \
  "$SRC" > "$DERIVED"

# Swap Helvetica for the site's body face. `sfmath` is dropped with it: it
# redirects math to the sans family, which would leave the formulae in
# Newsreader's non-existent sans and fall back unpredictably. Maths stays in
# LaTeX's own serif, which sits closer to Newsreader than Helvetica ever did.
python3 - "$DERIVED" "$FONT_DIR" <<'PY'
import pathlib, sys
p, fonts = pathlib.Path(sys.argv[1]), sys.argv[2]
t = p.read_text()
t = t.replace(r"\usepackage{helvet}", "")
t = t.replace(r"\renewcommand{\familydefault}{\sfdefault}", "")
t = t.replace(r"\usepackage{sfmath}", "")
t = t.replace(
    r"\usepackage{amsmath,amssymb}",
    r"\usepackage{amsmath,amssymb}" "\n"
    r"\usepackage{fontspec}" "\n"
    rf"\setmainfont{{Newsreader-Regular.ttf}}[Path={fonts}/,"
    r"BoldFont=Newsreader-Bold.ttf,ItalicFont=Newsreader-Italic.ttf,"
    r"BoldItalicFont=Newsreader-BoldItalic.ttf]")
# Must land AFTER the az* definitions so the tints below pick it up.
t = t.replace(r"\definecolor{azPlat}",
              "\\definecolor{white}{HTML}{FAF8F3}\n\\definecolor{azPlat}")
p.write_text(t)
PY

# xelatex, not lualatex: both drive fontspec, but the `standalone` class pulls
# in luatex85.sty on the lua path, and this machine's TinyTeX is a 2022 release
# that tlmgr will not extend from the 2026 remote ("cross release updates are
# only supported with update-tlmgr-latest"). xelatex needs nothing extra.
xelatex -interaction=nonstopmode -halt-on-error -output-directory="$WORK" "$DERIVED" >"$WORK/log" 2>&1 \
  || { echo "error: xelatex failed" >&2; tail -30 "$WORK/log" >&2; exit 1; }

mkdir -p "$OUT_DIR"
pdf2svg "$WORK/model-overview-site.pdf" "$OUT_DIR/model-overview-site.svg"
echo "wrote $OUT_DIR/model-overview-site.svg ($(stat -c%s "$OUT_DIR/model-overview-site.svg") bytes)"
