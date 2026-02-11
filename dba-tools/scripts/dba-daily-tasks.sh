#!/bin/bash
# =====================================================
# Linux Daily Tasks for Oracle DBA
# Demonstrates common DBA monitoring commands
# =====================================================

echo "================================"
echo "NTT Playground - DBA Daily Tasks"
echo "================================"
echo ""

echo "1. Disk Usage (df -h):"
echo "----------------------"
df -h | grep -E "(Filesystem|oracle|data)"
echo ""

echo "2. Memory Usage:"
echo "----------------------"
free -h
echo ""

echo "3. Top Processes (CPU):"
echo "----------------------"
ps aux --sort=-%cpu | head -10
echo ""

echo "4. Check Oracle Processes:"
echo "----------------------"
ps -ef | grep ora_ | grep -v grep | head -10
echo ""

echo "5. Network Connections to Oracle:"
echo "----------------------"
netstat -tulpn 2>/dev/null | grep 1521 || echo "Using ss command:"
ss -tulpn | grep 1521
echo ""

echo "6. Check Container Status:"
echo "----------------------"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker not available in this container"
echo ""

echo "================================"
echo "Monitoring complete!"
echo "================================"