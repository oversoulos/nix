#!/usr/bin/env bash
set -euo pipefail

green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
reset='\033[0m'

mode="unknown"
if [[ -f "$HOME/.config/oversoul/active-mode" ]]; then
  mode="$(cat "$HOME/.config/oversoul/active-mode")"
fi

bt_status="unavailable"
if systemctl is-active --quiet bluetooth 2>/dev/null; then
  bt_status="active"
elif systemctl list-unit-files bluetooth.service >/dev/null 2>&1; then
  bt_status="inactive"
fi

ai_status="inactive"
if systemctl is-active --quiet koboldcpp 2>/dev/null; then
  ai_status="active"
fi

echo -e "${blue}== Oversoul Health Check ==${reset}"
echo -e "${yellow}Mode:${reset} $mode"
echo -e "${yellow}Uptime:${reset} $(uptime -p)"
echo -e "${yellow}Load:${reset} $(cut -d' ' -f1-3 /proc/loadavg)"
echo -e "${yellow}Memory:${reset} $(free -h | awk '/Mem:/ {print $3"/"$2}')"
echo -e "${yellow}Swap:${reset} $(free -h | awk '/Swap:/ {print $3"/"$2}')"
echo -e "${yellow}Disk /:${reset} $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"
echo -e "${yellow}Disk /nix:${reset} $(df -h /nix 2>/dev/null | awk 'NR==2 {print $3"/"$2" ("$5")"}' || echo n/a)"
echo -e "${yellow}Network:${reset} $(nmcli -t -f STATE general 2>/dev/null || echo unavailable)"
echo -e "${yellow}Bluetooth:${reset} $bt_status"
echo -e "${yellow}KoboldCPP:${reset} $ai_status"

actionable_json=$(cat <<JSON
{
  "mode": "$mode",
  "uptime": "$(uptime -p)",
  "memory": "$(free -h | awk '/Mem:/ {print $3"/"$2}')",
  "swap": "$(free -h | awk '/Swap:/ {print $3"/"$2}')",
  "koboldcpp": "$ai_status"
}
JSON
)

echo -e "${green}JSON:${reset} $actionable_json"
