#!/usr/bin/env bash
# Render a document the two ways DESIGN.md compares:
#   <name>-amsthm.pdf  the filter's LaTeX output, typeset by amsthm
#   <name>-baked.pdf   the filter's own rendering (the path every non-LaTeX
#                      format takes), written as LaTeX without the filter
# and, if pdftoppm and ImageMagick are installed, <name>-<page>.png with
# the two side by side, amsthm on the left.
#
# Usage: tools/bake.sh doc.md [pandoc options...]
# The options go to every pandoc run, e.g. -N --top-level-division=chapter.
# Output goes to $BAKE_DIR (default: build/bake). Needs a LaTeX install.
set -euo pipefail

filter=$(cd "$(dirname "$0")/.." && pwd)/_extensions/amsthm/amsthm.lua
in=${1:?usage: tools/bake.sh doc.md [pandoc options...]}
shift
out=${BAKE_DIR:-build/bake}
name=$(basename "${in%.*}")
mkdir -p "$out"

pandoc -L "$filter" "$in" -s "$@" -o "$out/$name-amsthm.pdf"
pandoc -L "$filter" "$in" -s "$@" -t native |
  pandoc -f native -s "$@" -o "$out/$name-baked.pdf"
echo "wrote $out/$name-amsthm.pdf and $out/$name-baked.pdf"

if command -v pdftoppm >/dev/null && command -v magick >/dev/null; then
  for v in amsthm baked; do
    rm -f "$out/$name-$v"-*.png
    pdftoppm -r 80 -png "$out/$name-$v.pdf" "$out/$name-$v"
  done
  for a in "$out/$name-amsthm"-*.png; do
    page=${a##*-amsthm-}
    b="$out/$name-baked-$page"
    [ -f "$b" ] && magick "$a" "$b" +append "$out/$name-$page"
    rm -f "$a" "$b"
  done
  echo "wrote $out/$name-<page>.png (amsthm left, baked right)"
fi
