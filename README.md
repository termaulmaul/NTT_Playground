# 🎓 NTT Playground - Oracle DBA Docker Environment

**Docker Compose Stack untuk Presentasi & Belajar Oracle Database, SQL Server, dan Linux DBA Tasks**

> 🍎 **Apple Silicon Ready!** Native ARM64 support  
> 📺 **Untuk Presentasi:** Lihat [NASKAH.md](ntt_playground/NASKAH.md) - Script presentasi 15 menit  
> 📋 **Quick Reference:** Lihat [CHEATSHEET.md](CHEATSHEET.md) - Semua command dalam 1 halaman

---

## 📋 Table of Contents

- [System Requirements](#-system-requirements)
- [What's New](#-whats-new)
- [Quick Start](#-quick-start)
- [Workflow Presentasi](#-workflow-presentasi)
- [Services Overview](#-services-overview)
- [Demo Scenarios](#-demo-scenarios)
- [Troubleshooting](#-troubleshooting)

---

## 🍎 System Requirements

### Minimum
- **CPU:** Apple Silicon (M1/M2/M3) atau Intel x86_64
- **RAM:** 4 GB (8 GB recommended)
- **Disk:** 20 GB free
- **Docker:** Version 20.10+ with Docker Compose

### Apple Silicon Notes
- ✅ Native ARM64 containers (no Rosetta emulation needed)
- ✅ dba-tools: Debian Slim 130MB (90% smaller than Ubuntu)
- ✅ Oracle connection via container exec (not Oracle Client)

---

## 🆕 What's New

### v2.0 - Apple Silicon Support
- **dba-tools**: Switched to Debian Slim (130MB vs 1.5GB)
- **Oracle Client**: Removed from dba-tools (use `docker-compose exec oracle-primary` instead)
- **SQL Server tools**: Removed from dba-tools (use sqlserver container directly)
- **Architecture**: Full ARM64 native support

### Workflow Changes
**Before (x86_64 only):**
```bash
docker-compose exec dba-tools sqlplus app_user/app_pass123@ORACLE_PRIMARY
```

**Now (Apple Silicon compatible):**
```bash
docker-compose exec oracle-primary sqlplus app_user/app_pass123@XEPDB1
```

---

## 🚀 Quick Start

### 1. Start Environment
```bash
./start.sh
```

### 2. Wait for Oracle Ready (2-3 menit)
```bash
docker-compose logs -f oracle-primary | grep "DATABASE IS READY"
```

### 3. Test Connection
```bash
# Test Oracle
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Test SQL Server
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -Q "SELECT @@VERSION"
```

### 4. Access Web Interfaces
- **Adminer**: http://localhost:8080
- **Portainer**: http://localhost:9000

---

## 🎬 Workflow Presentasi

### Timeline 15 Menit

| Fase | Durasi | Command Example |
|------|--------|----------------|
| **Opening** | 30s | `./start.sh` |
| **Oracle Architecture** | 3m | `docker-compose exec oracle-primary sqlplus ... @01_architecture_monitoring.sql` |
| **Data Guard** | 2m | Check primary/standby status |
| **SQL Server** | 1.5m | Compare with Oracle |
| **Linux Tasks** | 2m | `docker-compose exec dba-tools bash` |
| **Hands-On SQL** | 3m | `./scripts/run-sql-examples.sh` |
| **Closing** | 30s | Summary |

### Terminal Setup
```bash
# Terminal 1: Main presentation
cd ~/github/NTT_Playground
./start.sh

# Terminal 2: Oracle logs
docker-compose logs -f oracle-primary

# Terminal 3: Testing commands
```

---

## 📦 Services Overview

| Service | Description | Port | Image Size | Platform |
|---------|-------------|------|------------|----------|
| **oracle-primary** | Oracle Database XE 21c | 1521 | ~500MB | AMD64 (emulated) |
| **oracle-standby** | Oracle Standby/DR | 1522 | ~500MB | AMD64 (emulated) |
| **sqlserver** | SQL Server 2022 Express | 1433 | ~500MB | AMD64 (emulated) |
| **dba-tools** | Linux utilities only | - | **130MB** | **ARM64 native** |
| **adminer** | Database GUI | 8080 | ~100MB | Multi-platform |
| **portainer** | Container management | 9000 | ~80MB | Multi-platform |

---

## 🎯 Demo Scenarios

### 1. Oracle Architecture Monitoring
```bash
# Connect to Oracle and run monitoring script
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/dba-scripts/01_architecture_monitoring.sql

# Or interactive
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba
SQL> SELECT name, value/1024/1024 as size_mb FROM v$sga;
SQL> SELECT pname, spid FROM v$process WHERE pname IS NOT NULL;
```

### 2. SQL Examples (Hands-On)
```bash
# Run all examples at once
./scripts/run-sql-examples.sh

# Or run manually
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba <<EOF
SELECT * FROM sys.employees;
SELECT e.emp_name, d.dept_name, l.location
FROM sys.employees e
JOIN sys.departments d ON e.dept_id = d.dept_id
JOIN sys.locations l ON d.location_id = l.location_id;
EXIT;
EOF
```

**Note:** Tables are owned by SYS, use `sys.table_name` prefix.

### 3. Linux DBA Tasks
```bash
# Access dba-tools container
docker-compose exec dba-tools bash

# Run monitoring commands
df -h
ps -ef | grep oracle
free -h
```

### 4. Oracle vs SQL Server Comparison
```bash
# Oracle query
docker-compose exec oracle-primary bash -c "echo 'SELECT * FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# SQL Server query
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -Q "SELECT TOP 5 * FROM employees"
```

---

## 🔧 Command Reference

### Oracle Connection
```bash
# As SYSDBA
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# As app_user
docker-compose exec oracle-primary sqlplus app_user/app_pass123@XEPDB1

# Via helper script
./scripts/connect-oracle.sh
```

### SQL Server Connection
```bash
# Direct
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -d NTTPlayground

# Via helper script
./scripts/connect-sqlserver.sh
```

### Docker Compose
```bash
# Lifecycle
docker-compose up -d                    # Start
docker-compose down                     # Stop (keep data)
docker-compose down -v                  # Stop + delete data

# Monitoring
docker-compose ps                       # Status
docker-compose logs -f oracle-primary   # Logs
docker-compose exec oracle-primary healthcheck.sh  # Health check
```

---

## 🗄️ Database Schema

### Tables (Owned by SYS)
- `sys.employees` (emp_id, emp_name, salary, dept_id, hire_date)
- `sys.departments` (dept_id, dept_name, location_id)
- `sys.locations` (location_id, location, city, country)

### Users
- `sys` / `oracle` (SYSDBA)
- `app_user` / `app_pass123` (with SELECT ANY TABLE permission)

---

## 🆘 Troubleshooting

### Oracle won't start
```bash
# Check logs
docker-compose logs oracle-primary | tail -50

# Check if healthy
docker-compose exec oracle-primary healthcheck.sh
```

### Tables not found
```bash
# Verify tables exist
docker-compose exec oracle-primary sqlplus -S sys/oracle@XEPDB1 as sysdba <<< "SELECT owner, table_name FROM dba_tables WHERE table_name='EMPLOYEES';"

# Run init script manually
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/container-entrypoint-initdb.d/01_create_tables.sql
```

### Permission denied
```bash
# Grant permissions to app_user
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba <<EOF
GRANT SELECT ANY TABLE TO app_user;
GRANT INSERT ANY TABLE TO app_user;
GRANT UPDATE ANY TABLE TO app_user;
GRANT DELETE ANY TABLE TO app_user;
EXIT;
EOF
```

### Reset Everything
```bash
docker-compose down -v
./start.sh --reset
```

---

## 📝 License

Docker images use their respective vendor licenses:
- Oracle XE: Oracle License
- SQL Server: Microsoft License
- Other: Open Source

---

**Selamat Presentasi! 🎉**