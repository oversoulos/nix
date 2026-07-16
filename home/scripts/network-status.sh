#!/usr/bin/env bash
# Network status script

set -euo pipefail

echo "Network Status:"
echo "==============="
echo ""

# NetworkManager status
if command -v nmcli &>/dev/null; then
    echo "NetworkManager:"
    nmcli -t -f GENERAL.STATE general status
    echo ""
    
    echo "Active connections:"
    nmcli connection show --active | grep -v NAME | awk '{print "  " $0}'
    echo ""
    
    echo "WiFi networks:"
    nmcli device wifi list | grep -v SSID | head -10
fi

# IP addresses
echo ""
echo "IP Addresses:"
ip addr show | grep -E "inet " | grep -v 127.0.0.1 | awk '{print "  " $2}'

# Internet connectivity
echo ""
echo "Internet:"
if ping -c 1 1.1.1.1 &>/dev/null; then
    echo "  ✓ Connected (ping to 1.1.1.1)"
else
    echo "  ✗ No internet connectivity"
fi

# Bluetooth status
echo ""
echo "Bluetooth:"
if systemctl is-active --quiet bluetooth 2>/dev/null; then
    echo "  ✓ Bluetooth active"
    if command -v bluetoothctl &>/dev/null; then
        echo "  Connected devices:"
        bluetoothctl devices Connected | awk '{print "    " $0}'
    fi
else
    echo "  ✗ Bluetooth inactive"
fi
