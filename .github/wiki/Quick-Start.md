# Quick Start Guide

Panduan cepat untuk mulai menggunakan NTT Playground dalam 5 menit.

## 🚀 Langkah 1: Prerequisites

Pastikan Docker dan Docker Compose sudah terinstall:

```bash
docker --version
docker-compose --version
```

**Minimum Requirements:**
- CPU: Apple Silicon (M1/M2/M3) atau Intel x86_64
- RAM: 4 GB (8 GB recommended)
- Disk: 20 GB free

## 📦 Langkah 2: Clone dan Setup

```bash
# Clone repository
git clone https://github.com/termaulmaul/NTT_Playground.git
cd NTT_Playground

# Start environment
./start.sh
```

**Proses ini akan:**
1. Build dba-tools image (130MB)
2. Pull Oracle dan SQL Server images
3. Start semua containers
4. Tunggu Oracle siap (2-3 menit)

## ✅ Langkah 3: Verifikasi

### Cek Status Container
```bash
docker-compose ps
```

**Expected output:**
```
NAME             STATUS
oracle-primary   Up (healthy)
sqlserver        Up (healthy)
dba-tools        Up
adminer          Up
portainer        Up
```

### Test Oracle Connection
```bash
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Di SQL*Plus:
SQL> SELECT 'Connected!' FROM dual;
SQL> EXIT;
```

### Test SQL Server Connection
```bash
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -Q "SELECT @@VERSION"
```

## 🌐 Langkah 4: Akses Web Interface

Buka browser dan akses:

| Service | URL | Kegunaan |
|---------|-----|----------|
| **Adminer** | http://localhost:8080 | Database GUI |
| **Portainer** | http://localhost:9000 | Container management |

### Adminer Setup
1. Buka http://localhost:8080
2. Pilih **System**: Oracle
3. **Server**: oracle-primary:1521/XEPDB1
4. **Username**: sys
5. **Password**: oracle
6. **Database**: XEPDB1

### Portainer Setup
1. Buka http://localhost:9000
2. Buat admin account
3. Pilih "Get Started"
4. Lihat semua containers

## 🎬 Langkah 5: Demo Pertama

### 1. Lihat Tables
```bash
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT table_name FROM dba_tables WHERE owner=\"SYS\";' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### 2. Query Data
```bash
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM sys.employees;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### 3. Monitoring Architecture
```bash
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/dba-scripts/01_architecture_monitoring.sql
```

## 🛑 Langkah 6: Stop Environment

```bash
# Stop tapi simpan data
./stop.sh

# Atau stop dan hapus semua data
./stop.sh --clean
```

---

## 📋 Command Cheat Sheet

### Lifecycle
```bash
./start.sh              # Start all
./stop.sh               # Stop (keep data)
./stop.sh --clean       # Stop + delete data
docker-compose ps       # Check status
docker-compose logs -f  # View logs
```

### Connect to Databases
```bash
# Oracle
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# SQL Server
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022!
```

### Helper Scripts
```bash
./scripts/connect-oracle.sh         # Connect Oracle
./scripts/run-sql-examples.sh       # Run SQL examples
./scripts/dba-daily-tasks.sh        # Linux monitoring
```

---

## 🎯 Next Steps

- [Architecture](Architecture) - Pelajari Oracle Architecture
- [Data Guard](Data-Guard) - Pahami konsep HA/DR
- [Commands](Commands) - Lihat semua commands
- [Presentation](Presentation) - Siapkan presentasi

---

## ⚠️ Troubleshooting

### Oracle belum ready
```bash
# Tunggu sampai muncul:
docker-compose logs -f oracle-primary | grep "DATABASE IS READY"
```

### Tables tidak ditemukan
```bash
# Run init script manual:
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/container-entrypoint-initdb.d/01_create_tables.sql
```

### Permission denied
```bash
# Grant permissions:
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba <<EOF
GRANT SELECT ANY TABLE TO app_user;
GRANT INSERT ANY TABLE TO app_user;
GRANT UPDATE ANY TABLE TO app_user;
GRANT DELETE ANY TABLE TO app_user;
EXIT;
EOF
```

---

**Lanjut ke: [Commands](Commands)**