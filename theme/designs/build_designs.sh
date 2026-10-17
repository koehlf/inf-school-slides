#!/bin/sh
# Builds the design options (M0-3): every design light and dark, plus colour
# scheme variants, into review/designs/ and an overview PNG per design.
#   theme/designs/build_designs.sh            all
#   theme/designs/build_designs.sh d03 d07    some designs (light and dark)
set -e
repo=$(cd "$(dirname "$0")/../.." && pwd)
work=$repo/build/designs; out=$repo/review/designs
mkdir -p "$work" "$out"
export TEXINPUTS="$repo/theme/designs//:$repo/theme//:$repo/images//:"
cd "$repo/theme/designs"
build() { # design palette scheme jobname
  latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir="$work" \
    "-usepretex=\\def\\slidedesign{$1}\\def\\slidepalette{$2}\\def\\slidescheme{$3}" \
    -jobname="$4" designs.tex >"$work/$4.txt" 2>&1 || { echo "FAILED $4"; grep -A5 '^!' "$work/$4.log" | head -20; return 1; }
  cp "$work/$4.pdf" "$out/$4.pdf"
  grep -q 'Overfull' "$work/$4.log" && echo "overfull: $4 $(grep -c Overfull "$work/$4.log")" || true
}
designs=${*:-"d01 d02 d03 d04 d05 d06 d07 d08 d09 d10"}
for d in $designs; do
  for p in dark light; do build "$d" "$p" algorithmik "$(echo "$d" | tr d D)-$p"; done
done
