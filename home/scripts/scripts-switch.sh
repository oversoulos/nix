
Skip to content

    oversoulos
    nix

Repository navigation

    Code
    Issues
    Pull requests1 (1)
    Agents
    Actions
    Projects
    Wiki
    Security and quality
    Insights
    Settings

    nix/deepnix/templates

/mode-switch.sh
tT
oversoulos
oversoulos
Add mode-switching script for user mode selection
956c5bc
 · 
1 minute ago

66 lines (55 loc) · 1.42 KB
#!/usr/bin/env bash
# Mode switching script

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODES=(
    "vibing:🎵 Vibing"
    "schooling:📚 Schooling"
    "building:🏗️ Building"
    "creating:🎨 Creating"
    "spiraling:🌀 Spiraling"
)

if [ -n "${1:-}" ]; then
    MODE="$1"
else
    # Display mode selection menu
    echo -e "${YELLOW}Select a mode:${NC}"
    for i in "${!MODES[@]}"; do
        echo "$((i+1)). ${MODES[$i]#*:}"
    done
    echo ""
    read -p "Enter number (1-${#MODES[@]}): " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#MODES[@]}" ]; then
        MODE="${MODES[$((choice-1))]%:*}"
    else
        echo -e "${RED}Invalid selection${NC}"
        exit 1
    fi
fi

# Validate mode exists
if [ ! -d "$HOME/modes/$MODE" ]; then
    echo -e "${RED}Mode '$MODE' not found in ~/modes/${NC}"
    exit 1
fi

# Set current mode
echo "$MODE" > /tmp/current-mode
export MODE_ACTIVE="$MODE"

# Run mode setup
if [ -f "$HOME/modes/$MODE/setup.sh" ]; then
    echo -e "${YELLOW}Running mode setup...${NC}"
    bash "$HOME/modes/$MODE/setup.sh"
fi

# Reload Sway
if command -v swaymsg &>/dev/null; then
    swaymsg reload
fi

# Reload Waybar
pkill -SIGUSR1 waybar || true

# Notification
if command -v notify-send &>/dev/null; then
    notify-send -t 3000 "Mode Switched" "Now in: ${MODE^}"
fi

echo -e "${GREEN}✓ Switched to mode: ${MODE^}${NC}"
No spaces found. You can create a new space to get started. 
