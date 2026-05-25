#!/usr/bin/env bash

# Usage: konsave-sync.sh [profile_name]
#
# profile_name defaults to "plasma" if not provided

set -euo pipefail

PROFILE="${1:-plasma}"
EXPORT_DIR="$HOME/Projects/dotfiles/konsave/"
EXPORT_NAME="$PROFILE"

echo "==> Saving current Plasma config into konsave profile: '$PROFILE'"
konsave --save "$PROFILE" --force

echo "==> Exporting '$PROFILE' as ${EXPORT_NAME}.knsv to ${EXPORT_DIR}/"
konsave --export-profile "$PROFILE" \
    --export-directory "$EXPORT_DIR" \
    --export-name "$EXPORT_NAME" \
    --force

echo "==> Done! File: ${EXPORT_DIR}/${EXPORT_NAME}.knsv"
