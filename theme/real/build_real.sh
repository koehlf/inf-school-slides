#!/bin/sh
# Builds the real decks (sorting, euler) in the shortlisted designs, light and dark,
# into review/real/<deck>-<design>-<palette>.pdf.
#   theme/real/build_real.sh               all
#   theme/real/build_real.sh D01 B5        some designs
set -e
repo=$(cd "$(dirname "$0")/../.." && pwd)
work=$repo/build/real; out=$repo/review/real
mkdir -p "$work" "$out"
export TEXINPUTS="$repo/theme/real//:$repo/theme/designs//:$repo/theme/designs-b//:$repo/theme//:$repo/images//:"
cd "$repo/theme/real"
build() { # driver design palette deck jobname
  latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir="$work" \
    "-usepretex=\\def\\slidedesign{$2}\\def\\slidepalette{$3}\\def\\realdeck{$4}" \
    -jobname="$5" "$1" >"$work/$5.txt" 2>&1 || { echo "FAILED $5"; grep -A5 '^!' "$work/$5.log" | head -20; return 1; }
  cp "$work/$5.pdf" "$out/$5.pdf"
  grep -q 'Overfull' "$work/$5.log" && echo "overfull: $5 $(grep -c Overfull "$work/$5.log")" || true
}
designs=${*:-"D01 D02 D06 B1 B2 B5"}
for d in $designs; do
  for deck in sorting euler; do
    for p in dark light; do
      case $d in
        D*) build real-d.tex "$(echo "$d" | tr D d)" "$p" "$deck" "$deck-$d-$p" ;;
        B*) build real-b.tex "$d" "$p" "$deck" "$deck-$d-$p" ;;
      esac
    done
  done
done
