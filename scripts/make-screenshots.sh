#!/bin/sh
# Turn raw, bezel-free simulator captures into the web images an app page uses.
#
#   scripts/make-screenshots.sh <app-folder> <raw-capture-root> [locale]
#   scripts/make-screenshots.sh tepuy ../tepuy-marketing/screenshots/raw en
#
# <raw-capture-root> holds <device>/<locale>/<NN>-<slug>.png, as the capture
# pipeline writes them. Every iPhone capture becomes <app>/img/<slug>.webp at
# 660 px wide (2x for the 330 px CSS device frame); Apple Watch captures keep
# their native size and get a "watch-" prefix. Needs sips (macOS) and cwebp
# (brew install webp).
set -eu

app=${1:?app folder, e.g. tepuy}
raw=${2:?raw capture root}
locale=${3:-en}
out="$app/img"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$out"

convert() { # <source.png> <target.webp> <width, or 0 to keep>
  if [ "$3" -gt 0 ]; then
    sips --resampleWidth "$3" "$1" --out "$tmp/in.png" >/dev/null
  else
    cp "$1" "$tmp/in.png"
  fi
  cwebp -quiet -q 82 -m 6 "$tmp/in.png" -o "$2"
  printf '%8s  %s\n' "$(wc -c <"$2" | tr -d ' ')" "$2"
}

for f in "$raw/iphone/$locale"/*.png; do
  [ -e "$f" ] || continue
  slug=$(basename "$f" .png | sed 's/^[0-9]*-//')
  convert "$f" "$out/$slug.webp" 660
done

for f in "$raw/watch/$locale"/*.png; do
  [ -e "$f" ] || continue
  slug=$(basename "$f" .png | sed 's/^[0-9]*-//')
  convert "$f" "$out/watch-$slug.webp" 0
done
