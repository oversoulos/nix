#!/usr/bin/env bash
# Health check script - comprehensive system status

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      SYSTEM HEALTH CHECK             ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print section header
section() {
    echo -e "${PURPLE}▶ $1${NC}"
    echo -e "${CYAN}----------------------------------------${NC}"
}

# CPU
section "CPU"
echo -e "Load average: $(cat /proc/loadavg | cut -d' ' -f1-3)"
if command -v sensors &> /dev/null; then
    echo -e "Temperature: $(sensors | grep -E 'Package id 0|Core' | head -1 | awk '{print $3}' | sed 's/+//')"
fi
echo -e "CPU frequency: $(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}') MHz"

# Memory
section "Memory"
MEMORY=$(free -h | grep -E '^Mem:' | awk '{print "Total: "$2", Used: "$3", Free: "$4", Available: "$7}')
echo -e "$MEMORY"
SWAP=$(free -h | grep -E '^Swap:' | awk '{print "Total: "$2", Used: "$3", Free: "$4}')
echo -e "Swap: $SWAP"

# Disk
section "Disk"
df -h / /home /nix | grep -v Filesystem | while read -r line; do
    echo -e "$line"
done

# BTRFS
section "BTRFS Status"
if command -v btrfs &> /dev/null; then
    echo -e "BTRFS subvolumes:"
    btrfs subvolume list / 2>/dev/null | head -5 || echo -e "  ${YELLOW}Not a BTRFS filesystem${NC}"
    echo -e "BTRFS usage:"
    btrfs filesystem usage / 2>/dev/null | grep -E "Device size|Used|Free" || echo -e "  ${YELLOW}Not a BTRFS filesystem${NC}"
fi

# Network
section "Network"
if command -v nmcli &> /dev/null; then
    echo -e "NetworkManager status: $(nmcli -t -f GENERAL.STATE general status)"
    echo -e "Active connection: $(nmcli -t -f NAME connection show --active | head -1 || echo 'None')"
fi
echo -e "IP address: $(ip addr show | grep -E 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1 || echo 'None')"
echo -e "Internet connectivity: $(curl -s -I https://1.1.1.1 2>/dev/null | head -1 | awk '{print $2}' || echo 'DOWN')"

# Services
section "Services"
SERVICES=("NetworkManager" "bluetooth" "pipewire" "koboldcpp")
for svc in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $svc 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $svc: running"
    elif systemctl is-failed --quiet $svc 2>/dev/null; then
        echo -e "  ${RED}✗${NC} $svc: failed"
    elif systemctl is-enabled --quiet $svc 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC} $svc: enabled but not running"
    else
        echo -e "  ${YELLOW}?${NC} $svc: unknown"
    fi
done

# AI Status
section "AI Service"
if curl -s "http://localhost:5001/v1/models" 2>/dev/null >/dev/null; then
    echo -e "  ${GREEN}✓${NC} KoboldCPP API: responding"
    echo -e "  Model: $(curl -s http://localhost:5001/v1/models | jq -r '.data[0].id' 2>/dev/null || echo 'Unknown')"
else
    echo -e "  ${RED}✗${NC} KoboldCPP API: not responding"
fi

# Mode
section "Current Mode"
if [ -f /tmp/current-mode ]; then
    MODE=$(cat /tmp/current-mode)
    echo -e "  Active mode: ${GREEN}$MODE${NC}"
else
    echo -e "  ${YELLOW}No active mode set${NC}"
fi
echo -e "  Available modes: $(ls -1 ~/modes 2>/dev/null | tr '\n' ' ' || echo 'None')"

# Systemd timers
section "System Timers"
systemctl list-timers --no-pager | grep -E "next run|btrfs" | head -5

# Last update
section "System Updates"
if [ -f /run/booted-system/kernel ]; then
    echo -e "Kernel: $(uname -r)"
    echo -e "System build: $(nixos-version 2>/dev/null || echo 'Unknown')"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Health check complete${NC}"
echo -e "${BLUE}========================================${NC}"
