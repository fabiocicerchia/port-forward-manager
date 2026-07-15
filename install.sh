#!/usr/bin/env bash
set -euo pipefail
# One-line installer for port-forward-manager (pfm)
# Usage: curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/port-forward-manager/main/install.sh | bash

DEST="${DEST:-/usr/local/bin}"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

curl -fsSL "https://github.com/fabiocicerchia/port-forward-manager/releases/latest/download/pfm" -o "$TMP"
install -m 0755 "$TMP" "$DEST/pfm"

echo "pfm installed to $DEST/pfm"
echo "Run: pfm up"
