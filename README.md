# 🎓 NTT Playground - Oracle DBA Docker Environment

**Docker Compose Stack untuk Presentasi & Belajar Oracle Database, SQL Server, dan Linux DBA Tasks**

> 📺 **Untuk Presentasi:** Lihat [NASKAH.md](ntt_playground/NASKAH.md) - Script presentasi 15 menit lengkap dengan demo commands  
> 📋 **Quick Reference:** Lihat [CHEATSHEET.md](CHEATSHEET.md) - Semua command dalam 1 halaman

---

## 📑 Table of Contents

- [Overview](#overview)
- [Persiapan Presentasi](#-persiapan-presentasi)
- [Workflow Presentasi](#-workflow-presentasi-15-menit)
- [Services Overview](#-services-overview)
- [Quick Start](#-quick-start)
- [Struktur Folder](#-struktur-folder)
- [Demo Scenarios](#-demo-scenarios)
- [Troubleshooting](#-troubleshooting)

---

## 📺 Persiapan Presentasi

### Prerequisites

Pastikan Docker & Docker Compose sudah terinstall:
```bash
docker --version
docker-compose --version  # atau: docker compose version
```

### 5 Menit Sebelum Presentasi

```bash
# 1. Start semua services
./start.sh

# 2. Tunggu sampai Oracle ready (2-3 menit)
docker-compose logs -f oracle-primary | grep "DATABASE IS READY"

# 3. Test koneksi
docker-compose exec dba-tools sqlplus app_user/app_pass123@ORACLE_PRIMARY -v
```

### Setup Terminal (Rekomendasi)

Buka **3 terminal window** untuk presentasi yang smooth:

```
Terminal 1: Presentasi (baca NASKAH.md + eksekusi command)
Terminal 2: Oracle Logs (docker-compose logs -f oracle-primary)
Terminal 3: Backup/Testing (untuk test command sebelum demo)
```

---

## 🎬 Workflow Presentasi (15 Menit)

Ikuti alur ini untuk presentasi yang terstruktur:

### ⏱️ Timeline Presentasi

| Fase | Durasi | Aktivitas | File Referensi |
|------|--------|-----------|----------------|
| **Opening** | 30s | Perkenalan & setup environment | NASKAH.md - Section 1 |
| **Oracle Architecture** | 3m | Jelaskan Instance & Database + Demo memory/process | NASKAH.md - Section 2 |
| **Data Guard** | 2m | Konsep HA & DR + Demo primary/standby | NASKAH.md - Section 3 |
| **SQL Server** | 1.5m | Perbandingan architecture | NASKAH.md - Section 4 |
| **Linux Tasks** | 2m | Demo monitoring commands | NASKAH.md - Section 5 |
| **Hands-On SQL** | 3m | CRUD + Join demo | NASKAH.md - Section 6 |
| **Closing** | 30s | Summary & Q&A | NASKAH.md - Section 7 |

### 📖 Script Presentasi Lengkap

**📝 Buka file:** [ntt_playground/NASKAH.md](ntt_playground/NASKAH.md)

File ini berisi:
- ✅ Script dialog lengkap (apa yang harus diucapkan)
- ✅ 🖥️ Hint eksekusi command real-time
- ✅ 🎯 Kalimat kunci untuk penekanan
- ✅ ⏱️ Timing per section
- ✅ 💡 Tips & trik presentasi

---

## 📦 Services Overview

| Service | Deskripsi | Port | Credentials | Status |
|---------|-----------|------|-------------|---------|
| **oracle-primary** | Oracle Database XE 21c (Primary) | 1521 | sys/oracle | 🟢 Core |
| **oracle-standby** | Oracle Database XE 21c (Standby/DR) | 1522 | sys/oracle | 🟢 Demo HA |
| **sqlserver** | SQL Server 2022 Express | 1433 | sa/SqlServer2022! | 🟢 Comparison |
| **dba-tools** | Linux + Oracle Client + mssql-tools | - | - | 🟢 Interactive |
| **adminer** | Database GUI (Web-based) | 8080 | - | 🟢 Utility |
| **portainer** | Container Management Dashboard | 9000 | Setup on first run | 🟢 Utility |

### 🌐 Akses Web Interface

- **Adminer (Database GUI):** http://localhost:8080
  - Oracle: `oracle-primary:1521/XEPDB1` (app_user/app_pass123)
  - SQL Server: `sqlserver:1433` (sa/SqlServer2022!)
  
- **Portainer:** http://localhost:9000
  - Buat admin account saat pertama kali akses

---

## 🚀 Quick Start

### Option 1: Start Script (Recommended)

```bash
# Clone atau navigate ke folder
# cd /path/to/NTT_Playground

# Jalankan start script
./start.sh
```

Script ini akan:
1. Build dba-tools image
2. Start semua services
3. Tunggu Oracle ready
4. Tampilkan summary akses

### Option 2: Manual Docker Compose

```bash
# Build dan start
docker-compose up -d

# Check status
docker-compose ps

# View logs Oracle
docker-compose logs -f oracle-primary
```

### Stop Environment

```bash
# Stop tapi simpan data
./stop.sh

# Atau
# Stop dan hapus semua data (reset)
./stop.sh --clean
```

---

## 📁 Struktur Folder

```
NTT_Playground/
│
├── 🎬 NASKAH.md                    ⭐ Script presentasi lengkap (476 baris)
├── 📋 CHEATSHEET.md                ⭐ Quick reference commands
├── 📖 README.md                    ⭐ Dokumentasi ini
│
├── 🚀 start.sh                     Start script dengan auto-wait
├── 🛑 stop.sh                      Stop script
│
├── 🐳 docker-compose.yml           Docker orchestration
│
├── 🛢️ oracle/                      Oracle Database Resources
│   ├── init-scripts/              # Auto-run saat startup
│   │   └── 01_create_tables.sql   # Create employees, departments, locations
│   │
│   └── dba-scripts/               # DBA monitoring scripts
│       ├── 01_architecture_monitoring.sql   # ⭐ SGA, PGA, Processes
│       ├── 02_sql_examples.sql              # ⭐ CRUD, Join, Aggregate
│       ├── 03_performance_monitoring.sql    # Tablespace, waits, locks
│       └── 04_backup_recovery.sql           # RMAN, Data Pump
│
├── 🗄️ sqlserver/                   SQL Server Resources
│   └── init-scripts/
│       ├── 01_init.sql            # Create same schema as Oracle
│       └── 02_monitoring.sql      # SQL Server monitoring queries
│
└── 🐧 dba-tools/                   Linux DBA Container
    ├── Dockerfile                 # Ubuntu + Oracle Instant Client
    │
    ├── tnsnames/
    │   └── tnsnames.ora           # Oracle connection aliases
    │
    └── scripts/                   # Helper scripts
        ├── connect-oracle.sh      # Quick connect to Oracle
        ├── connect-sqlserver.sh   # Quick connect to SQL Server
        ├── dba-daily-tasks.sh     # ⭐ Linux monitoring demo
        └── run-sql-examples.sh    # ⭐ Run all SQL examples
```

---

## 🎯 Demo Scenarios

### Scenario 1: Oracle Architecture Deep Dive

**Tujuan:** Demonstrasikan komponen Instance dan Database

```bash
# Step 1: Masuk ke DBA Tools
docker-compose exec dba-tools bash

# Step 2: Connect ke Oracle
sqlplus app_user/app_pass123@ORACLE_PRIMARY

# Step 3: Jalankan architecture monitoring
@/dba-scripts/01_architecture_monitoring.sql
```

**Penjelasan Output:**
- `v$sga` - Tunjukkan SGA components
- `v$process` - Tunjukkan background processes (DBWR, LGWR, etc.)
- `dba_data_files` - Tunjukkan physical datafiles
- `v$log` - Tunjukkan redo log files

### Scenario 2: Data Guard High Availability

**Tujuan:** Demonstrasikan konsep Primary & Standby

```bash
# Terminal 1 - Check Primary
docker-compose exec dba-tools bash
sqlplus sys/oracle@ORACLE_PRIMARY as sysdba
SELECT database_role, open_mode FROM v$database;
-- Output: PRIMARY - READ WRITE

# Terminal 2 - Check Standby
docker-compose exec dba-tools bash
sqlplus sys/oracle@ORACLE_STANDBY as sysdba
SELECT database_role, open_mode FROM v$database;
-- Output: PHYSICAL STANDBY - MOUNTED
```

### Scenario 3: Hands-On SQL Examples

**Tujuan:** Demonstrasikan CRUD operations dan Joins

```bash
# Jalankan semua SQL examples sekaligus
docker-compose exec dba-tools bash
./scripts/run-sql-examples.sh
```

**Atau step-by-step:**
```sql
-- Connect
sqlplus app_user/app_pass123@ORACLE_PRIMARY

-- 1. SELECT
SELECT * FROM employees;

-- 2. JOIN 3 Tables
SELECT e.emp_name, d.dept_name, l.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN locations l ON d.location_id = l.location_id;

-- 3. Aggregates
SELECT d.dept_name, COUNT(e.emp_id), AVG(e.salary)
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

### Scenario 4: Linux DBA Daily Tasks

**Tujuan:** Demonstrasikan monitoring commands

```bash
docker-compose exec dba-tools bash

# Jalankan monitoring lengkap
./scripts/dba-daily-tasks.sh

# Atau manual:
df -h                    # Disk usage
ps -ef | grep ora_       # Oracle processes
free -h                  # Memory
```

### Scenario 5: Oracle vs SQL Server Comparison

**Tujuan:** Tunjukkan perbedaan dan persamaan

```bash
# Oracle
docker-compose exec dba-tools sqlplus app_user/app_pass123@ORACLE_PRIMARY -S \
  <<EOF
SET PAGESIZE 0
SELECT emp_name, salary FROM employees WHERE ROWNUM <= 3;
EXIT;
EOF

# SQL Server
docker-compose exec dba-tools /opt/mssql-tools/bin/sqlcmd \
  -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground \
  -Q "SELECT TOP 3 emp_name, salary FROM employees"
```

---

## 🗄️ Database Schema Reference

### Oracle (XEPDB1)

**Tables:**
```sql
-- employees
emp_id      NUMBER (PK)
emp_name    VARCHAR2(100)
salary      NUMBER(12,2)
dept_id     NUMBER (FK)
hire_date   DATE

-- departments
dept_id     NUMBER (PK)
dept_name   VARCHAR2(100)
location_id NUMBER (FK)

-- locations
location_id NUMBER (PK)
location    VARCHAR2(100)
city        VARCHAR2(100)
country     VARCHAR2(50)
```

**Views:**
- `v_employee_details` - JOIN employees + departments + locations

**Users:**
- `sys` / `oracle` - SYSDBA (full access)
- `app_user` / `app_pass123` - Application user (CRUD access)

### SQL Server (NTTPlayground)

Schema identik dengan Oracle untuk easy comparison.

---

## 🔧 Command Reference

### Docker Compose Commands

```bash
# Lifecycle
docker-compose up -d                    # Start all
docker-compose down                     # Stop (keep data)
docker-compose down -v                  # Stop + delete data
docker-compose restart oracle-primary   # Restart specific service

# Monitoring
docker-compose ps                       # List containers
docker-compose logs -f oracle-primary   # Follow Oracle logs
docker-compose top                      # Process stats

# Access
docker-compose exec dba-tools bash      # Interactive shell
docker-compose exec oracle-primary bash # Direct to Oracle container
```

### Oracle Connection Commands

```bash
# Via DBA Tools container
docker-compose exec dba-tools bash

# Connect as APP_USER
sqlplus app_user/app_pass123@ORACLE_PRIMARY

# Connect as SYSDBA
sqlplus sys/oracle@ORACLE_PRIMARY as sysdba

# Quick test
sqlplus app_user/app_pass123@ORACLE_PRIMARY -S <<EOF
SELECT 'Connected!' FROM dual;
EXIT;
EOF
```

### SQL Server Connection Commands

```bash
# Via DBA Tools
docker-compose exec dba-tools bash

# Interactive
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground

# Single query
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P SqlServer2022! \
  -d NTTPlayground -Q "SELECT COUNT(*) FROM employees"
```

---

## 🆘 Troubleshooting

### Oracle Database

#### "ORA-12541: TNS:no listener"
```bash
# Listener belum ready, tunggu 1-2 menit lagi
docker-compose logs oracle-primary | grep "DATABASE IS READY"

# Atau restart listener
docker-compose exec oracle-primary lsnrctl stop
docker-compose exec oracle-primary lsnrctl start
```

#### "ORA-01017: invalid username/password"
```bash
# Database belum selesai init, tunggu atau check logs
docker-compose logs oracle-primary | tail -20

# Test dengan sys
docker-compose exec dba-tools sqlplus sys/oracle@ORACLE_PRIMARY as sysdba
```

#### Database startup lama (>5 menit)
```bash
# Cek resource Docker (butuh min 4GB RAM)
docker stats

# Atau restart
docker-compose restart oracle-primary
```

### SQL Server

#### "Login failed for user 'sa'"
```bash
# SQL Server masih initializing, tunggu 30-60 detik
docker-compose logs sqlserver | grep "Recovery is complete"
```

### Presentasi-Specific Issues

#### Demo gagal di tengah presentasi
```bash
# Siapkan plan B - restart service tertentu
docker-compose restart dba-tools

# Atau fallback ke script yang sudah di-test
./scripts/run-sql-examples.sh
```

#### Terminal freeze
```bash
# Buka terminal baru, environment masih jalan
docker-compose ps  # Check status
docker-compose exec dba-tools bash  # New session
```

---

## 📊 Resource Requirements

### Minimum (Bisa jalan tapi lambat)
- **RAM:** 4 GB
- **Disk:** 20 GB free
- **CPU:** 2 cores
- **Swap:** 2 GB (penting untuk Oracle)

### Recommended (Untuk presentasi smooth)
- **RAM:** 8 GB
- **Disk:** 50 GB free (SSD preferred)
- **CPU:** 4 cores
- **Swap:** 4 GB

### Check Resource
```bash
# Mac/Linux
docker stats

# Atau
free -h
df -h
```

---

## 🔒 Security Warning

⚠️ **WARNING: Environment untuk Development/Presentasi Saja!**

- Password sederhana: `oracle`, `app_pass123`, `SqlServer2022!`
- Tanpa SSL/TLS encryption
- Database ports exposed ke localhost
- **JANGAN** gunakan untuk production atau data sensitif!

---

## 📚 Additional Resources

### Documentation
- [NASKAH.md](ntt_playground/NASKAH.md) - Script presentasi lengkap
- [CHEATSHEET.md](CHEATSHEET.md) - Semua command 1 halaman

### External Links
- [Oracle XE Docker Image](https://hub.docker.com/r/gvenzl/oracle-xe)
- [SQL Server Docker](https://hub.docker.com/_/microsoft-mssql-server)
- [Oracle Instant Client](https://www.oracle.com/database/technologies/instant-client.html)

---

## 🤝 Contributing

Kalau ada improvement atau tambahan script, silakan:
1. Fork repository
2. Buat branch baru
3. Submit PR

---

## 📝 License

Docker images menggunakan license masing-masing vendor:
- Oracle XE: [Oracle License](https://www.oracle.com/downloads/licenses/oracle-db-license.html)
- SQL Server: [Microsoft License](https://www.microsoft.com/sql-server/sql-server-2022)
- Ubuntu & Tools: Open Source

---

## 💡 Quick Tips untuk Presenter

1. **Test dulu** - Jalankan `./start.sh` 10 menit sebelum presentasi
2. **Siapkan backup** - Screenshot output penting kalau demo gagal
3. **Split terminal** - 1 untuk script, 1 untuk demo
4. **Clipboard ready** - Copy command ke clipboard sebelum demo
5. **Relax** - Kalau ada error, tunjukkan troubleshooting skill! 😊

---

**🎉 Selamat Presentasi! Semoga sukses! 🚀**