#!/usr/bin/env bash
set -euo pipefail

repo_root="${DOTFILES_REPO:-$HOME}"
packages_dir="$repo_root/packages"
hostname_short="${HOSTNAME_OVERRIDE:-$(hostnamectl --static 2>/dev/null || hostname -s)}"

mkdir -p "$packages_dir"

tmp_native="$(mktemp)"
tmp_foreign="$(mktemp)"
tmp_excludes="$(mktemp)"
trap 'rm -f "$tmp_native" "$tmp_foreign" "$tmp_excludes"' EXIT

pacman -Qqen | sort -u >"$tmp_native"
pacman -Qqem | sort -u >"$tmp_foreign"

exclude_file="$packages_dir/excludes/${hostname_short}.txt"
if [[ -f "$exclude_file" ]]; then
    grep -Ev '^(#|$)' "$exclude_file" >"$tmp_excludes" || true
else
    : >"$tmp_excludes"
fi

if [[ -s "$tmp_excludes" ]]; then
    while read -r pkg; do
        if pacman -Sp "$pkg" &>/dev/null; then
            echo "$pkg" >>"$tmp_native"
        else
            echo "$pkg" >>"$tmp_foreign"
        fi
    done <"$tmp_excludes"
fi

sort -u "$tmp_native" >"$packages_dir/pacman.txt"
sort -u "$tmp_foreign" >"$packages_dir/aur.txt"

printf 'Host: %s\n' "$hostname_short"
printf 'Wrote %s\n' "$packages_dir/pacman.txt"
printf 'Wrote %s\n' "$packages_dir/aur.txt"
printf 'pacman packages: %s\n' "$(wc -l <"$packages_dir/pacman.txt")"
printf 'aur packages: %s\n' "$(wc -l <"$packages_dir/aur.txt")"
