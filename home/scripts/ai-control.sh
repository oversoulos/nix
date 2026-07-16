#!/usr/bin/env bash
# AI Control script - Start/stop/kill KoboldCPP

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SERVICE="koboldcpp"
API_URL="http://localhost:5001"

start_ai() {
    echo -e "${YELLOW}Starting KoboldCPP AI service...${NC}"
    if systemctl is-active --quiet $SERVICE 2>/dev/null; then
        echo -e "${GREEN}KoboldCPP is already running${NC}"
        return 0
    fi
    
    # Check if model exists
    if [ ! -f ~/models/current-model.gguf ]; then
        echo -e "${RED}Error: No model found at ~/models/current-model.gguf${NC}"
        echo -e "${YELLOW}Please place your .gguf model file there${NC}"
        return 1
    fi
    
    systemctl start $SERVICE
    sleep 2
    
    if systemctl is-active --quiet $SERVICE; then
        echo -e "${GREEN}✓ KoboldCPP started successfully${NC}"
        echo -e "  API URL: $API_URL"
        echo -e "  Web UI: http://localhost:5001"
    else
        echo -e "${RED}✗ Failed to start KoboldCPP${NC}"
        systemctl status $SERVICE --no-pager
        return 1
    fi
}

stop_ai() {
    echo -e "${YELLOW}Stopping KoboldCPP AI service...${NC}"
    if systemctl is-active --quiet $SERVICE 2>/dev/null; then
        systemctl stop $SERVICE
        echo -e "${GREEN}✓ KoboldCPP stopped${NC}"
    else
        echo -e "${YELLOW}KoboldCPP is not running${NC}"
    fi
}

kill_ai() {
    echo -e "${RED}Force killing KoboldCPP...${NC}"
    pkill -9 koboldcpp || true
    systemctl stop $SERVICE 2>/dev/null || true
    echo -e "${GREEN}✓ KoboldCPP killed${NC}"
}

status_ai() {
    if systemctl is-active --quiet $SERVICE 2>/dev/null; then
        echo -e "${GREEN}✓ KoboldCPP is running${NC}"
        if curl -s "$API_URL/v1/models" 2>/dev/null >/dev/null; then
            echo -e "  API: ${GREEN}responding${NC}"
            MODEL=$(curl -s "$API_URL/v1/models" | jq -r '.data[0].id' 2>/dev/null || echo 'Unknown')
            echo -e "  Model: $MODEL"
        else
            echo -e "  API: ${RED}not responding${NC}"
        fi
    else
        echo -e "${RED}✗ KoboldCPP is not running${NC}"
    fi
}

case "${1:-}" in
    start)
        start_ai
        ;;
    stop)
        stop_ai
        ;;
    kill)
        kill_ai
        ;;
    status)
        status_ai
        ;;
    restart)
        stop_ai
        sleep 2
        start_ai
        ;;
    *)
        echo "Usage: $0 {start|stop|kill|status|restart}"
        echo ""
        echo "  start   - Start KoboldCPP service"
        echo "  stop    - Gracefully stop KoboldCPP"
        echo "  kill    - Force kill KoboldCPP"
        echo "  status  - Check service status"
        echo "  restart - Restart KoboldCPP"
        exit 1
        ;;
esac
