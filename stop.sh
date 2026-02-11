#!/bin/bash
# =====================================================
# NTT Playground - Stop Script
# =====================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║         🛑 NTT PLAYGROUND - STOPPING           ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check command
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}[ERROR]${NC} Docker Compose not found"
    exit 1
fi

# Parse arguments
REMOVE_VOLUMES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            REMOVE_VOLUMES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --clean    Stop and remove all volumes (WARNING: deletes data)"
            echo "  --help, -h Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            exit 1
            ;;
    esac
done

# Stop services
if [ "$REMOVE_VOLUMES" = true ]; then
    echo -e "${YELLOW}[WARNING]${NC} Stopping services and removing volumes (data will be lost)..."
    $COMPOSE_CMD down -v
    echo ""
    echo -e "${GREEN}✓ Services stopped and volumes removed${NC}"
else
    echo -e "${BLUE}[INFO]${NC} Stopping services..."
    $COMPOSE_CMD down
    echo ""
    echo -e "${GREEN}✓ Services stopped (data preserved)${NC}"
fi

echo ""
echo "Use './start.sh' to restart the playground"