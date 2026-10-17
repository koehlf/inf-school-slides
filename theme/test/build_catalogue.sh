#!/bin/sh
# Temporary (M0-2/M0-3): builds the catalogue light and dark and renders
# overview PNGs. Replaced by tools/build/build.py in M0-8.
# Output: build/catalogue/catalogue-{light,dark}.pdf, overview-{light,dark}.png, pages/
set -e
repo=$(cd "$(dirname "$0")/../.." && pwd)
out=$repo/build/catalogue
mkdir -p "$out/pages"
export TEXINPUTS="$repo/theme//:$repo/images//:"
cd "$repo/theme/test"
for p in light dark; do
  latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir="$out" \
    "-usepretex=\\def\\slidepalette{$p}" -jobname="catalogue-$p" catalogue.tex >"$out/latexmk-$p.txt" 2>&1 \
    || { tail -30 "$out/catalogue-$p.log"; exit 1; }
  rm -f "$out/pages/$p"-*.png
  pdftoppm -png -r 96 "$out/catalogue-$p.pdf" "$out/pages/$p"
  montage "$out/pages/$p"-*.png -tile 6x -geometry 400x225+6+6 -background '#888888' "$out/overview-$p.png"
done
grep -c 'Overfull' "$out"/catalogue-*.log || true
