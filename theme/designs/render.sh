#!/bin/sh
# Overview PNG of design PDFs: render.sh D02 [D03 …] -> build/designs/<D>.png (dark row, light row)
set -e
repo=$(cd "$(dirname "$0")/../.." && pwd)
png="$repo/build/designs/png"; mkdir -p "$png"
for d in "$@"; do
  for p in dark light; do
    find "$png" -name "$d-$p-*.png" -delete
    pdftoppm -png -r 60 "$repo/review/designs/$d-$p.pdf" "$png/$d-$p"
  done
  n=$(ls "$png/$d-dark-"*.png | wc -l)
  montage "$png/$d-dark-"*.png "$png/$d-light-"*.png -tile 7x -geometry +3+3 -background '#888' "$repo/build/designs/$d.png"
done
