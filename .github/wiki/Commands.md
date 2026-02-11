# Commands Reference

Referensi lengkap semua command untuk NTT Playground.

## 📁 Table of Contents

- [Docker Compose](#docker-compose-commands)
- [Oracle Database](#oracle-database-commands)
- [SQL Server](#sql-server-commands)
- [Linux DBA](#linux-dba-commands)
- [Helper Scripts](#helper-scripts)
- [Monitoring](#monitoring-commands)

---

## 🐳 Docker Compose Commands

### Lifecycle

```bash
# Start all services
./start.sh

# Start manual (jika tidak pakai script)
docker-compose up -d

# Stop services (keep data)
./stop.sh
# atau
docker-compose down

# Stop and remove volumes (delete data)
./stop.sh --clean
# atau
docker-compose down -v

# Restart specific service
docker-compose restart oracle-primary
docker-compose restart sqlserver

# View all services
docker-compose ps

# View logs
docker-compose logs -f                    # All services
docker-compose logs -f oracle-primary     # Oracle only
docker-compose logs -f sqlserver          # SQL Server only
```

### Access Containers

```bash
# DBA Tools (Linux utilities)
docker-compose exec dba-tools bash

# Oracle Primary
docker-compose exec oracle-primary bash

# Oracle Standby
docker-compose exec oracle-standby bash

# SQL Server
docker-compose exec sqlserver bash

# Adminer/Portainer (no shell, web only)
```

---

## 🛢️ Oracle Database Commands

### Connection

```bash
# As SYSDBA (full access)
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# As app_user (application user)
docker-compose exec oracle-primary sqlplus app_user/app_pass123@XEPDB1

# Non-interactive (single command)
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM dual;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Via helper script
./scripts/connect-oracle.sh
./scripts/connect-oracle.sh app_user app_pass123
```

### Check Status

```bash
# Database status
docker-compose exec oracle-primary healthcheck.sh

# Instance info
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT instance_name, host_name, version, status FROM v\$instance;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Database role (Primary/Standby)
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT database_role, open_mode FROM v\$database;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Run SQL Scripts

```bash
# Architecture monitoring
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/dba-scripts/01_architecture_monitoring.sql

# SQL Examples
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/dba-scripts/02_sql_examples.sql

# Performance monitoring
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/dba-scripts/03_performance_monitoring.sql

# Backup/Recovery
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/dba-scripts/04_backup_recovery.sql
```

### Query Examples

```bash
# List tables
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT table_name FROM dba_tables WHERE owner=\"SYS\";' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Select employees
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM sys.employees;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Join 3 tables
docker-compose exec oracle-primary sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SELECT e.emp_name, d.dept_name, l.location
FROM sys.employees e
JOIN sys.departments d ON e.dept_id = d.dept_id
JOIN sys.locations l ON d.location_id = l.location_id;
EXIT;
EOF

# Aggregates
docker-compose exec oracle-primary sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SELECT d.dept_name, COUNT(e.emp_id), AVG(e.salary)
FROM sys.departments d
LEFT JOIN sys.employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
EXIT;
EOF
```

### Memory & Performance

```bash
# SGA size
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT name, value/1024/1024 as mb FROM v\$sga;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Background processes
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT pname, spid FROM v\$process WHERE pname IS NOT NULL;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Tablespace usage
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT tablespace_name, ROUND(bytes/1024/1024,2) as mb FROM dba_data_files;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

---

## 🗄️ SQL Server Commands

### Connection

```bash
# Interactive
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022!

# Non-interactive (single command)
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -Q "SELECT @@VERSION"

# Via helper script
./scripts/connect-sqlserver.sh
```

### Query Examples

```bash
# List databases
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -Q "SELECT name FROM sys.databases"

# Use database and query
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -d NTTPlayground \
  -Q "SELECT * FROM employees"

# Join query
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -d NTTPlayground \
  -Q "SELECT e.emp_name, d.dept_name FROM employees e JOIN departments d ON e.dept_id = d.dept_id"
```

### Check Status

```bash
# SQL Server version
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -Q "SELECT @@VERSION"

# Database files
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -Q "SELECT name, physical_name, size*8/1024 as mb FROM sys.master_files WHERE database_id = DB_ID('NTTPlayground')"
```

---

## 🐧 Linux DBA Commands

### System Monitoring

```bash
# Access dba-tools container
docker-compose exec dba-tools bash

# Inside container:
# Disk usage
df -h

# Memory usage
free -h

# CPU and processes
top
# atau
htop

# Check Oracle processes (from dba-tools)
ps -ef | grep -E "(oracle|sql)"

# Network connections
ss -tulpn
netstat -tulpn 2>/dev/null || echo "Use ss instead"

# Test connectivity
ping oracle-primary -c 3
ping sqlserver -c 3

# Test ports
nc -zv oracle-primary 1521
nc -zv sqlserver 1433
```

### Oracle-Specific (from oracle container)

```bash
# Listener status
docker-compose exec oracle-primary lsnrctl status

# Alert log (follow)
docker-compose exec oracle-primary tail -f \
  /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log

# Check datafiles location
docker-compose exec oracle-primary ls -lh /opt/oracle/oradata/XE/
```

---

## 📜 Helper Scripts

### Oracle
```bash
# Connect to Oracle
./scripts/connect-oracle.sh
./scripts/connect-oracle.sh [username] [password]
```

### SQL Server
```bash
# Connect to SQL Server
./scripts/connect-sqlserver.sh
```

### Run Examples
```bash
# Run all SQL examples
./scripts/run-sql-examples.sh

# From dba-tools container
docker-compose exec dba-tools bash -c "./scripts/run-sql-examples.sh"
```

### Daily Tasks
```bash
# Linux monitoring
./scripts/dba-daily-tasks.sh

# From dba-tools container
docker-compose exec dba-tools bash -c "./scripts/dba-daily-tasks.sh"
```

---

## 📊 Monitoring Commands

### Real-time Monitoring

```bash
# Watch Oracle logs
docker-compose logs -f oracle-primary | grep -E "(ORA-|Error|Started)"

# Watch all containers
docker-compose logs -f

# Watch resource usage
docker stats
```

### Health Checks

```bash
# Oracle health
docker-compose exec oracle-primary healthcheck.sh

# Container status
docker-compose ps

# Volume usage
docker system df -v
```

---

## 🎯 Common Patterns

### Pattern 1: Quick Oracle Query
```bash
QUERY="SELECT COUNT(*) FROM sys.employees;"
docker-compose exec oracle-primary bash -c \
  "echo '$QUERY' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Pattern 2: Save Output to File
```bash
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba" \
  > employees.txt
```

### Pattern 3: Run Script with Output
```bash
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/dba-scripts/01_architecture_monitoring.sql \
  | tee output.log
```

### Pattern 4: Check All Services
```bash
# One-liner status check
for svc in oracle-primary sqlserver dba-tools; do
  echo "=== $svc ==="
  docker-compose ps | grep $svc
done
```

---

## 🔗 Quick Links

- [Home](Home) - Kembali ke Home
- [Quick Start](Quick-Start) - Panduan cepat
- [Troubleshooting](Troubleshooting) - Solusi masalah

---

**Command terakhir diupdate: 2025**