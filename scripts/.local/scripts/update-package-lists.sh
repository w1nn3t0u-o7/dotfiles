#!/usr/bin/env bash
set -euo pipefail

repo_root="${DOTFILES_REPO:-$HOME}"
packages_dir="$repo_root/packages"

mkdir -p "$packages_dir"

tmp_native="$(mktemp)"
tmp_foreign="$(mktemp)"
trap 'rm -f "$tmp_native" "$tmp_foreign"' EXIT

pacman -Qqen | sort -u >"$tmp_native"
pacman -Qqem | sort -u >"$tmp_foreign"

cp "$tmp_native" "$packages_dir/pacman.txt"
cp "$tmp_foreign" "$packages_dir/aur.txt"

printf 'Wrote %s\n' "$packages_dir/pacman.txt"
printf 'Wrote %s\n' "$packages_dir/aur.txt"
printf 'pacman packages: %s\n' "$(wc -l <"$packages_dir/pacman.txt")"
printf 'aur packages: %s\n' "$(wc -l <"$packages_dir/aur.txt")"
