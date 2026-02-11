# 🎓 NTT Playground - Oracle DBA Docker Environment

Docker Compose stack untuk belajar dan presentasi Oracle Database, SQL Server, dan Linux DBA tasks.

## 📦 Services Overview

| Service | Description | Port | Access |
|---------|-------------|------|---------|
| **oracle-primary** | Oracle Database XE 21c (Primary) | 1521 | sys/oracle |
| **oracle-standby** | Oracle Database XE 21c (Standby) | 1522 | sys/oracle |
| **sqlserver** | SQL Server 2022 Express | 1433 | sa/SqlServer2022! |
| **dba-tools** | Linux container dengan Oracle Client & SQL tools | - | Interactive |
| **adminer** | Database GUI (MySQL/Oracle/Postgres) | 8080 | Web |
| **portainer** | Container Management Dashboard | 9000 | Web |

## 🚀 Quick Start

### 1. Start All Services

```bash
cd ntt_playground
docker-compose up -d
```

**Note:** First startup membutuhkan waktu 2-3 menit karena Oracle database initialization.

### 2. Check Status

```bash
# Cek container status
docker-compose ps

# Cek logs Oracle (tunggu sampai "DATABASE IS READY")
docker-compose logs -f oracle-primary
```

### 3. Access Services

#### Oracle Database
```bash
# Connect via DBA Tools container
docker-compose exec dba-tools bash
./scripts/connect-oracle.sh

# Atau direct dengan SQL*Plus
docker-compose exec dba-tools sqlplus app_user/app_pass123@ORACLE_PRIMARY
```

#### SQL Server
```bash
# Connect via DBA Tools
docker-compose exec dba-tools bash
./scripts/connect-sqlserver.sh

# Atau direct
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground
```

#### Web Interfaces
- **Adminer (Database GUI):** http://localhost:8080
- **Portainer (Container Management):** http://localhost:9000

## 📁 Directory Structure

```
ntt_playground/
├── docker-compose.yml          # Main orchestration
├── README.md                   # This file
├── oracle/
│   ├── init-scripts/          # SQL scripts dijalankan saat startup
│   │   └── 01_create_tables.sql
│   └── dba-scripts/           # DBA monitoring & maintenance scripts
│       ├── 01_architecture_monitoring.sql
│       ├── 02_sql_examples.sql
│       ├── 03_performance_monitoring.sql
│       └── 04_backup_recovery.sql
├── sqlserver/
│   └── init-scripts/          # SQL Server initialization
│       ├── 01_init.sql
│       └── 02_monitoring.sql
└── dba-tools/
    ├── Dockerfile             # Linux container definition
    ├── tnsnames/
    │   └── tnsnames.ora       # Oracle connection config
    └── scripts/
        ├── connect-oracle.sh
        ├── connect-sqlserver.sh
        ├── dba-daily-tasks.sh
        └── run-sql-examples.sh
```

## 🎯 Presentation Use Cases

### 1. Oracle Architecture Demo

```bash
docker-compose exec dba-tools bash
sqlplus app_user/app_pass123@ORACLE_PRIMARY

-- Run architecture monitoring
@/dba-scripts/01_architecture_monitoring.sql
```

**Cek komponen:**
- ✅ SGA & PGA memory structures
- ✅ Background processes (DBWR, LGWR, etc.)
- ✅ Datafiles, Control files, Redo logs
- ✅ Archive log mode

### 2. SQL Examples (Hands-On)

```bash
docker-compose exec dba-tools bash
./scripts/run-sql-examples.sh
```

**Demonstrates:**
- ✅ CREATE, INSERT, SELECT, UPDATE, DELETE
- ✅ JOIN 3 tables
- ✅ Aggregate functions
- ✅ Subqueries

### 3. Performance Monitoring

```bash
sqlplus app_user/app_pass123@ORACLE_PRIMARY
@/dba-scripts/03_performance_monitoring.sql
```

### 4. Linux DBA Tasks

```bash
docker-compose exec dba-tools bash
./scripts/dba-daily-tasks.sh
```

**Shows:**
- ✅ Disk usage monitoring (df -h)
- ✅ Process monitoring (ps, top)
- ✅ Memory usage
- ✅ Network connections

### 5. Oracle vs SQL Server Comparison

```bash
# Oracle
sqlplus app_user/app_pass123@ORACLE_PRIMARY
SELECT * FROM employees;

# SQL Server (di terminal lain)
docker-compose exec dba-tools /opt/mssql-tools/bin/sqlcmd \
  -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground \
  -Q "SELECT * FROM employees"
```

## 🔧 Useful Commands

### Docker Compose

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Stop dan hapus volumes (reset data)
docker-compose down -v

# Restart service tertentu
docker-compose restart oracle-primary

# View logs
docker-compose logs -f oracle-primary
docker-compose logs -f sqlserver
```

### Oracle Specific

```bash
# Connect as SYSDBA
docker-compose exec dba-tools sqlplus sys/oracle@ORACLE_PRIMARY as sysdba

# Check database status
docker-compose exec oracle-primary healthcheck.sh

# View alert log
docker-compose exec oracle-primary tail -f /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
```

### SQL Server Specific

```bash
# Execute SQL file
docker-compose exec -T dba-tools /opt/mssql-tools/bin/sqlcmd \
  -S sqlserver -U sa -P SqlServer2022! \
  -i /init-scripts/02_monitoring.sql
```

## 🗄️ Database Schemas

### Oracle (XEPDB1)

**Tables:**
- `employees` (emp_id, emp_name, salary, dept_id, hire_date)
- `departments` (dept_id, dept_name, location_id)
- `locations` (location_id, location, city, country)

**Views:**
- `v_employee_details` (JOIN of all 3 tables)

**Users:**
- `sys` / `oracle` (SYSDBA)
- `app_user` / `app_pass123` (Application user)

### SQL Server (NTTPlayground)

Same schema structure as Oracle for easy comparison.

## 🌐 Network Configuration

All services terhubung via Docker network `ntt-network`:

| Container | Hostname | IP | Port |
|-----------|----------|-----|------|
| oracle-primary | oracle-primary | Dynamic | 1521 |
| oracle-standby | oracle-standby | Dynamic | 1521 |
| sqlserver | sqlserver | Dynamic | 1433 |
| dba-tools | dba-tools | Dynamic | - |

## 📊 Resource Requirements

**Minimum:**
- RAM: 4 GB
- Disk: 20 GB free
- CPU: 2 cores

**Recommended:**
- RAM: 8 GB
- Disk: 50 GB free
- CPU: 4 cores

## 🔒 Security Notes

⚠️ **WARNING:** Ini adalah environment untuk development/presentasi saja!

- Password yang digunakan sangat simple (oracle, SqlServer2022!)
- Tidak ada SSL/TLS
- Database ports di-expose ke localhost
- Jangan gunakan untuk production!

## 🆘 Troubleshooting

### Oracle fails to start

```bash
# Check logs
docker-compose logs oracle-primary | tail -50

# Reset data (HATI-HATI: menghapus semua data)
docker-compose down -v
docker-compose up -d
```

### Out of memory

Oracle butuh minimal 2GB RAM. Jika memory error:

```bash
# Increase Docker Desktop memory limit (Mac/Windows)
# Atau untuk Linux, cek swap:
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Connection refused

Tunggu 2-3 menit setelah `docker-compose up` karena Oracle perlu waktu untuk:
1. Create database
2. Run initialization scripts
3. Start listener

Check status:
```bash
docker-compose exec oracle-primary healthcheck.sh
```

## 📝 License

Docker images used:
- Oracle XE: [gvenzl/oracle-xe](https://hub.docker.com/r/gvenzl/oracle-xe) (Oracle License)
- SQL Server: [mcr.microsoft.com/mssql/server](https://hub.docker.com/_/microsoft-mssql-server) (Microsoft License)
- Other: Open Source

---

**Selamat belajar dan presentasi! 🎉**