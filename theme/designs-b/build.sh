#!/bin/sh
# Builds the five comparison designs B1-B5, light and dark, into
# review/designs-b/B<n>-<palette>.pdf. Usage: theme/designs-b/build.sh [B1 ...]
set -e
here=$(cd "$(dirname "$0")" && pwd)
wt=$(cd "$here/../.." && pwd)
out="$wt/review/designs-b"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$out"
export TEXINPUTS="$wt/theme/designs-b//:$wt/theme//:$wt/images//:"
designs=${*:-B1 B2 B3 B4 B5}
for d in $designs; do
  for p in light dark; do
    echo "== $d $p"
    (cd "$here" && latexmk -pdf -interaction=nonstopmode -halt-on-error -quiet \
      -outdir="$work/$d-$p" -jobname="$d-$p" \
      -usepretex="\\def\\slidepalette{$p}" "$d.tex" >"$work/$d-$p.out" 2>&1) \
      || { tail -40 "$work/$d-$p.out"; grep -A5 '^!' "$work/$d-$p/$d-$p.log" | head -30; exit 1; }
    grep -E 'Overfull|Missing character|Warning: Reference|undefined' "$work/$d-$p/$d-$p.log" | sort -u || true
    cp "$work/$d-$p/$d-$p.pdf" "$out/"
  done
done
