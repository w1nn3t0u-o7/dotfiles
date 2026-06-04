#!/usr/bin/env bash
set -euo pipefail

repo_root="${DOTFILES_REPO:-$HOME}"
packages_dir="$repo_root/packages"
hostname_short="${HOSTNAME_OVERRIDE:-$(hostnamectl --static 2>/dev/null || hostname -s)}"
exclude_file="$packages_dir/excludes/${hostname_short}.txt"

tmp_excludes="$(mktemp)"
tmp_pacman="$(mktemp)"
tmp_aur="$(mktemp)"
trap 'rm -f "$tmp_excludes" "$tmp_pacman" "$tmp_aur"' EXIT

if [[ -f "$exclude_file" ]]; then
    grep -Ev '^(#|$)' "$exclude_file" | sort -u >"$tmp_excludes" || true
else
    : >"$tmp_excludes"
fi

if [[ -s "$tmp_excludes" ]]; then
    grep -Fvx -f "$tmp_excludes" "$packages_dir/pacman.txt" >"$tmp_pacman" || true
    grep -Fvx -f "$tmp_excludes" "$packages_dir/aur.txt" >"$tmp_aur" || true
else
    cp "$packages_dir/pacman.txt" "$tmp_pacman"
    cp "$packages_dir/aur.txt" "$tmp_aur"
fi

if [[ -s "$tmp_pacman" ]]; then
    sudo pacman -S --needed - <"$tmp_pacman"
fi

if [[ -s "$tmp_aur" ]]; then
    paru -S --needed - <"$tmp_aur"
fi
