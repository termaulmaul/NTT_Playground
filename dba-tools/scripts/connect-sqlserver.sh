#!/bin/bash
# =====================================================
# Connect to SQL Server
# Usage: ./connect-sqlserver.sh
# =====================================================

echo "Connecting to SQL Server..."
sqlcmd -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground