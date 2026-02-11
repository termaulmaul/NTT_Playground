#!/bin/bash
# =====================================================
# Connect to Oracle Primary Database
# Usage: ./connect-oracle.sh [username]
# Default: app_user/app_pass123
# =====================================================

USER=${1:-app_user}
PASSWORD=${2:-app_pass123}
SERVICE=${3:-ORACLE_PRIMARY}

echo "Connecting to Oracle Primary as $USER..."
sqlplus $USER/$PASSWORD@$SERVICE