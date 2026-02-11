#!/bin/bash
# =====================================================
# Connect to SQL Server
# Usage: ./connect-sqlserver.sh
# Note: Uses -C flag to trust server certificate (required for ODBC Driver 18)
# =====================================================

echo "Connecting to SQL Server..."
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -C -d NTTPlayground