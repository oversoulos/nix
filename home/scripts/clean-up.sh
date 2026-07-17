#!/usr/bin/env bash
# System cleanup script

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting system cleanup...${NC}"

# Temp files
echo -e "Cleaning /tmp..."
sudo rm -rf /tmp/* 2>/dev/null || true

# User cache
echo -e "Cleaning ~/.cache..."
rm -rf ~/.cache/* 2>/dev/null || true

# Journal logs
echo -e "Vacuuming journal logs..."
sudo journalctl --vacuum-time=3d 2>/dev/null || true

# Nix garbage collection
echo -e "Collecting Nix garbage..."
nix-collect-garbage -d 2>/dev/null || true

# Browser cache (optional - commented out)
# echo -e "Cleaning browser cache..."
# rm -rf ~/.cache/google-chrome 2>/dev/null || true
# rm -rf ~/.cache/Brave-Browser 2>/dev/null || true

# Snapshots cleanup (optional)
# echo -e "Cleaning old BTRFS snapshots..."
# sudo btrfs subvolume delete /.snapshots/* 2>/dev/null || true

echo -e "${GREEN}✓ Cleanup complete${NC}"
