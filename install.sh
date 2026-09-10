#!/usr/bin/env bash
set -euo pipefail
# One-line installer for port-forward-manager (portfwd)
# Usage: curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/port-forward-manager/main/install.sh | bash

DEST="${DEST:-/usr/local/bin}"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

curl -fsSL "https://github.com/fabiocicerchia/port-forward-manager/releases/latest/download/portfwd" -o "$TMP"
install -m 0755 "$TMP" "$DEST/portfwd"

echo "portfwd installed to $DEST/portfwd"
echo "Run: portfwd up"
