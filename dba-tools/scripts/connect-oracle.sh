#!/bin/bash
# =====================================================
# Connect to Oracle Primary Database
# Usage: ./connect-oracle.sh [username]
# Default: app_user/app_pass123
# Note: Uses oracle-primary container directly
# =====================================================

USER=${1:-app_user}
PASSWORD=${2:-app_pass123}

echo "Connecting to Oracle Primary as $USER..."
echo "Command: docker-compose exec oracle-primary sqlplus $USER/$PASSWORD@XEPDB1"
docker-compose exec oracle-primary sqlplus "$USER/$PASSWORD@XEPDB1"