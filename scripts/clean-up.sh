#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning temporary files..."
rm -rf /tmp/* "$HOME"/.cache/* || true

echo "Collecting nix garbage..."
nix-collect-garbage -d || true

echo "Vacuuming logs (3d)..."
sudo journalctl --vacuum-time=3d || true

echo "Done."
