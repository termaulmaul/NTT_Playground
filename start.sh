#!/bin/bash
# =====================================================
# NTT Playground - Quick Start Script
# =====================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║        🎓 NTT PLAYGROUND - QUICK START         ║"
echo "║    Oracle DBA Docker Environment               ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    print_error "Docker Compose is not installed"
    exit 1
fi

print_status "Using: $COMPOSE_CMD"

# Parse arguments
RESET=false
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --reset)
            RESET=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --reset          Reset all data (WARNING: destroys existing data)"
            echo "  --skip-build     Skip building dba-tools image"
            echo "  --help, -h       Show this help message"
            echo ""
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Reset if requested
if [ "$RESET" = true ]; then
    print_warning "Resetting all data..."
    $COMPOSE_CMD down -v
    print_success "Data reset complete"
fi

# Build dba-tools if needed
if [ "$SKIP_BUILD" = false ]; then
    print_status "Building dba-tools image..."
    $COMPOSE_CMD build dba-tools
    print_success "Build complete"
fi

# Start services
print_status "Starting NTT Playground services..."
echo ""
$COMPOSE_CMD up -d

echo ""
print_success "Services started!"
echo ""

# Wait for Oracle
print_status "Waiting for Oracle database to be ready (this may take 2-3 minutes)..."
echo ""

MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker-compose exec -T oracle-primary healthcheck.sh > /dev/null 2>&1; then
        echo ""
        print_success "Oracle database is ready!"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -ne "\r⏳ Checking... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 10
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo ""
    print_warning "Oracle is still starting. Please check logs: docker-compose logs -f oracle-primary"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           🎉 NTT PLAYGROUND READY!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo "📊 Services:"
echo "  • Oracle Primary:    localhost:1521   (sys/oracle)"
echo "  • Oracle Standby:    localhost:1522   (sys/oracle)"
echo "  • SQL Server:        localhost:1433   (sa/SqlServer2022!)"
echo "  • Adminer (GUI):     http://localhost:8080"
echo "  • Portainer:         http://localhost:9000"
echo ""
echo "🔧 Quick Commands:"
echo "  docker-compose exec dba-tools bash          # Access DBA tools"
echo "  ./scripts/connect-oracle.sh                 # Connect to Oracle"
echo "  ./scripts/connect-sqlserver.sh              # Connect to SQL Server"
echo "  ./scripts/dba-daily-tasks.sh                # Run DBA monitoring"
echo "  ./scripts/run-sql-examples.sh               # Run SQL examples"
echo ""
echo "📚 Documentation:"
echo "  cat README.md                                # Full documentation"
echo ""
echo -e "${YELLOW}Note: First startup may take 2-3 minutes for database initialization${NC}"
echo ""

# Show container status
print_status "Container Status:"
$COMPOSE_CMD ps