#!/usr/bin/env bash
# Debug tools script - system diagnostics

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      SYSTEM DEBUG TOOLS              ${NC}"
echo -e "${BLUE}========================================${NC}"

show_network() {
    echo -e "\n${YELLOW}Network Debug:${NC}"
    echo -e "Interface status:"
    ip link show | grep -E "^[0-9]:" | awk '{print $2}'
    echo -e "\nRouting table:"
    ip route show
    echo -e "\nDNS servers:"
    cat /etc/resolv.conf 2>/dev/null || echo "  Not found"
}

show_logs() {
    echo -e "\n${YELLOW}Recent System Logs:${NC}"
    sudo journalctl -n 20 --no-pager 2>/dev/null || echo "  Cannot read journal"
}

show_processes() {
    echo -e "\n${YELLOW}Process List:${NC}"
    ps aux --sort=-%cpu | head -15
}

show_nix_debug() {
    echo -e "\n${YELLOW}Nix Debug:${NC}"
    echo -e "Nix version: $(nix --version 2>/dev/null || echo 'Unknown')"
    echo -e "Nix store verify:"
    nix-store --verify 2>/dev/null || echo "  Verify failed"
}

show_mode_debug() {
    echo -e "\n${YELLOW}Mode Debug:${NC}"
    if [ -d ~/modes ]; then
        for mode in ~/modes/*; do
            if [ -d "$mode" ]; then
                name=$(basename "$mode")
                echo -e "  $name:"
                if [ -f "$mode/.envrc" ]; then
                    echo -e "    .envrc: present"
                else
                    echo -e "    .envrc: missing"
                fi
            fi
        done
    else
        echo -e "  ~/modes directory not found"
    fi
}

show_ai_debug() {
    echo -e "\n${YELLOW}AI Debug:${NC}"
    if systemctl is-active --quiet koboldcpp 2>/dev/null; then
        echo -e "  KoboldCPP: running"
        if curl -s "http://localhost:5001/v1/models" 2>/dev/null >/dev/null; then
            echo -e "  API: responding"
        else
            echo -e "  API: not responding"
        fi
    else
        echo -e "  KoboldCPP: not running"
    fi
    if [ -f ~/models/current-model.gguf ]; then
        echo -e "  Model: $(ls -lh ~/models/current-model.gguf | awk '{print $5}')"
    else
        echo -e "  Model: not found"
    fi
}

case "${1:-}" in
    network)
        show_network
        ;;
    logs)
        show_logs
        ;;
    processes)
        show_processes
        ;;
    nix)
        show_nix_debug
        ;;
    modes)
        show_mode_debug
        ;;
    ai)
        show_ai_debug
        ;;
    all|*)
        show_network
        show_logs
        show_processes
        show_nix_debug
        show_mode_debug
        show_ai_debug
        ;;
esac

echo -e "\n${BLUE}========================================${NC}"
