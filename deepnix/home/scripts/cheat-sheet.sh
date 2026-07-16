#!/usr/bin/env bash
# Cheat sheet overlay

set -euo pipefail

CHEAT_DIR="$HOME/.cheatsheets"

# Create cheat sheet directory if it doesn't exist
mkdir -p "$CHEAT_DIR"

# Global cheat sheet
cat > "$CHEAT_DIR/global.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    GLOBAL CHEAT SHEET                      ║
╠══════════════════════════════════════════════════════════════╣
║                                                            ║
║  SYSTEM MANAGEMENT                                         ║
║  ─────────────────                                         ║
║  health-check      → Full system health report             ║
║  status            → One-line system status                ║
║  clean-up          → Clean temporary files                ║
║  debug-tools       → System diagnostics                    ║
║                                                            ║
║  MODE SWITCHING                                            ║
║  ──────────────                                            ║
║  mode-switch       → Switch workspaces                     ║
║  $mod+Tab          → Mode switcher                        ║
║  $mod+c            → Cheat sheet                          ║
║  $mod+h            → Health check                         ║
║                                                            ║
║  AI CONTROL                                                ║
║  ────────────                                             ║
║  ai-start          → Start KoboldCPP                      ║
║  ai-stop           → Stop KoboldCPP                       ║
║  ai-kill           → Force kill KoboldCPP                 ║
║  ai-status         → Check AI status                      ║
║  $mod+a            → Toggle AI                            ║
║                                                            ║
║  NIX COMMANDS                                              ║
║  ────────────                                             ║
║  nixos-rebuild switch → Apply system changes              ║
║  nix-collect-garbage   → Clean Nix store                  ║
║  nix-store --verify    → Verify Nix store                 ║
║                                                            ║
║  NETWORK                                                  ║
║  ─────────                                                ║
║  network-status    → Network status report                ║
║  nmcli             → NetworkManager CLI                   ║
║  nmtui             → NetworkManager TUI                   ║
║                                                            ║
╚══════════════════════════════════════════════════════════════╝
EOF

# Display cheat sheet with wofi or less
if command -v wofi &>/dev/null; then
    cat "$CHEAT_DIR/global.txt" | wofi --dmenu --prompt "Cheat Sheet:" --cache-file /dev/null
else
    less "$CHEAT_DIR/global.txt"
fi
