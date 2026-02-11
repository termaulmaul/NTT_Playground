# 🎤 NASKAH PRESENTASI ORACLE DBA - NTT PLAYGROUND

> **Versi:** 15 Menit + Demo Hands-On  
> **Environment:** NTT Playground Docker Stack (Apple Silicon Compatible)  
> **Format:** Script presentasi dengan panduan eksekusi real-time

---

## 📝 PERSIAPAN SEBELUM PRESENTASI

### Start Environment (5 menit sebelum presentasi):
```bash
cd ~/github/NTT_Playground
./start.sh
```

### Pastikan services ready:
```bash
docker-compose ps
```

### Setup Terminal
- **Terminal 1**: Presentasi (jalankan command)
- **Terminal 2**: Oracle logs (`docker-compose logs -f oracle-primary`)
- **Terminal 3**: Testing (opsional)

---

# 1️⃣ OPENING (30 detik)

**🗣️ "Assalamualaikum, selamat pagi/siang. Perkenalkan saya [Nama].**

**Hari ini saya akan mempresentasikan pemahaman saya tentang Oracle Database Architecture, Data Guard, SQL Server, Linux DBA Tasks, dan hands-on SQL query.**

**Untuk demo hari ini, saya sudah menyiapkan environment Docker yang berisi:**
- Oracle Database Primary & Standby
- SQL Server 2022  
- Linux DBA Tools (lightweight container)

**Environment ini optimized untuk Apple Silicon dengan image yang 90% lebih ringan.**"

---

# 2️⃣ ORACLE DATABASE ARCHITECTURE (3 menit)

**🗣️ "Baik, saya mulai dari Oracle Database Architecture.**

**Kalau kita lihat konsepnya, Oracle dibagi menjadi dua bagian besar: Instance dan Database.**

**Instance itu ada di memory (atas), Database itu ada di disk (bawah).**"

---

## 🔹 A. INSTANCE - Memory Structure

**🗣️ "Instance terdiri dari Memory Structure dan Background Processes.**

**Di memory ada yang namanya SGA (System Global Area) dan PGA (Program Global Area).**

**SGA ini shared memory yang dipakai semua user. Dalamnya ada:**
- **Database Buffer Cache** → tempat data block di memory sebelum ke disk
- **Shared Pool** → nyimpen parsed SQL dan data dictionary  
- **Redo Log Buffer** → nyimpen redo entries sebelum ditulis LGWR

**PGA itu private per session, buat sorting dan operasi query.**"

### 🖥️ DEMO: Cek Memory Structure
```bash
# Connect langsung ke oracle-primary container
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Di SQL*Plus, jalankan:
SELECT name, value/1024/1024 as size_mb FROM v$sga;
SELECT pool, name, bytes/1024/1024 as size_mb FROM v$sgastat WHERE pool IS NOT NULL;
```

**🎯 Penjelasan sambil nunjuk output:**  
**🗣️ "Ini kita bisa lihat SGA components dan ukurannya. Buffer Cache paling besar karena itu yang sering diakses."**

Ketik `EXIT` untuk keluar.

---

## 🔹 B. INSTANCE - Background Processes

**🗣️ "Di bagian background processes, ada beberapa proses penting:**

- **DBWn** (Database Writer) → nulis data dari buffer cache ke datafile
- **LGWR** (Log Writer) → nulis redo dari buffer ke online redo log
- **CKPT** (Checkpoint) → update control file dan datafile header
- **SMON & PMON** → system monitor dan process monitor untuk recovery
- **ARCn** (Archiver) → mengarsipkan redo log kalau archive mode aktif"

### 🖥️ DEMO: Lihat Background Processes
```bash
# Connect dan query
docker-compose exec oracle-primary bash -c "echo 'SELECT pname, spid, program FROM v\$process WHERE pname IS NOT NULL ORDER BY pname;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

**🎯 Penjelasan:**  
**🗣️ "Ini kita bisa lihat proses-proses Oracle yang berjalan. Setiap proses punya PID dan nama spesifik."**

---

## 🔹 C. DATABASE - Physical Structure

**🗣️ "Sekarang bagian bawah, physical database. Komponennya:**

- **Datafiles** → nyimpen data actual (tabel, index)
- **Control files** → nyimpen metadata database, lokasi datafiles
- **Online Redo Log Files** → nyimpen perubahan transaksi
- **Archived Redo Logs** → hasil arsip dari redo log, buat recovery
- **Flashback Logs** → buat fitur flashback database"

### 🖥️ DEMO: Lihat Physical Files
```bash
# Datafiles
docker-compose exec oracle-primary bash -c "echo 'SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb FROM dba_data_files;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Control files
docker-compose exec oracle-primary bash -c "echo 'SELECT name FROM v\$controlfile;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Redo logs
docker-compose exec oracle-primary bash -c "echo 'SELECT group#, sequence#, bytes/1024/1024 as size_mb, status FROM v\$log;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Archive mode
docker-compose exec oracle-primary bash -c "echo 'SELECT log_mode, open_mode FROM v\$database;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

**🎯 Kalimat Kunci:**  
**🗣️ "Jadi alurnya: user query masuk → diproses di memory → perubahan dicatat di redo → baru ditulis permanen ke datafile. Ini yang menjamin data consistency dan recoverability."**

---

# 3️⃣ ORACLE DATA GUARD ARCHITECTURE (2 menit)

**🗣️ "Selanjutnya, Oracle Data Guard untuk High Availability.**

**Konsepnya ada Primary Database (kiri) dan Standby Database (kanan).**"

---

## 🔹 Alur Data Guard

**🗣️ "Proses sinkronisasinya seperti ini:**

1. User transaksi di **Primary Database**
2. Perubahan dicatat di **Redo Buffer**
3. **LGWR** tulis ke **Online Redo Log**
4. Proses **LNS** (Log Network Server) kirim redo ke standby
5. Di sisi standby, **RFS** (Remote File Server) terima data
6. Disimpan di **Standby Redo Log**
7. **MRP** (Managed Recovery Process) apply ke standby database"

---

## 🔹 Real-Time Apply & Gap Resolution

**🗣️ "Kalau pakai real-time apply, standby langsung apply redo tanpa tunggu archive log selesai.**

**Kalau network putus, proses **ARC** akan lakukan **gap resolution** - ngirim ulang redo yang ketinggalan.**"

### 🖥️ DEMO: Cek Primary & Standby
```bash
# Check Primary
docker-compose exec oracle-primary bash -c "echo 'SELECT database_role, open_mode FROM v\$database;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
# Output: PRIMARY - READ WRITE

# Check Standby (di terminal lain)
docker-compose exec oracle-standby bash -c "echo 'SELECT database_role, open_mode FROM v\$database;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
# Output: PHYSICAL STANDBY - MOUNTED
```

**🎯 Kalimat Kunci:**  
**🗣️ "Dengan Data Guard, kita bisa switchover atau failover untuk pastikan high availability dan disaster recovery. Primary down, standby bisa langsung takeover."**

---

# 4️⃣ SQL SERVER ARCHITECTURE (1.5 menit)

**🗣️ "Secara singkat, SQL Server architecture konsepnya mirip Oracle, beda istilah saja.**

**Memory:**
- **Buffer Pool** = mirip Buffer Cache Oracle
- **Plan Cache** = nyimpen execution plan
- **Write-Ahead Logging** = sama konsep redo logging

**Storage:**
- **MDF** = primary data file (kayak datafile Oracle)
- **NDF** = secondary file
- **LDF** = transaction log (kayak redo log)"

### 🖥️ DEMO: Perbandingan SQL Server
```bash
# Cek database files di SQL Server
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -Q "SELECT name, physical_name, size*8/1024 as size_mb, type_desc FROM sys.master_files WHERE database_id = DB_ID('NTTPlayground')"
```

**🎯 Penjelasan:**  
**🗣️ "Transaction log di SQL Server sangat krusial karena semua perubahan dicatat dulu sebelum ke data file. Sama seperti redo log di Oracle."**

---

# 5️⃣ LINUX DBA DAILY TASKS (2 menit)

**🗣️ "Sebagai Oracle DBA, daily task di Linux sangat penting untuk monitoring dan troubleshooting."**

---

## 🔹 Monitoring Disk Space

**🗣️ "Saya selalu cek disk space, karena Oracle error kalau tablespace penuh.**

Command yang sering dipakai:"

### 🖥️ DEMO: Disk Monitoring
```bash
# Masuk ke DBA Tools (lightweight container)
docker-compose exec dba-tools bash

# Cek disk usage
df -h

# Cek ukuran direktori
du -sh /

# Atau jalankan script monitoring lengkap
./scripts/dba-daily-tasks.sh
```

---

## 🔹 Monitoring Process

**🗣️ "Cek proses Oracle yang berjalan:**"

### 🖥️ DEMO: Process Monitoring
```bash
# Oracle processes (dari dba-tools container)
ps -ef | grep -E "(oracle|sql)"

# Atau dari host
docker-compose exec oracle-primary ps -ef | grep ora_
```

---

## 🔹 Monitoring Listener & Logs

**🗣️ "Listener harus selalu jalan, dan alert log harus dimonitor:**"

### 🖥️ DEMO: Listener & Logs
```bash
# Cek listener (dari oracle container)
docker-compose exec oracle-primary lsnrctl status

# Monitor alert log
docker-compose exec oracle-primary tail -f /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
```

**🎯 Kalimat Kunci:**  
**🗣️ "Monitoring ini penting untuk deteksi masalah sebelum berdampak ke user. Prevention is better than cure."**

---

# 6️⃣ HANDS-ON SQL QUERY (3 menit)

**🗣️ "Sekarang saya demonstrasikan basic SQL operation yang biasa dilakukan DBA.**

**Catatan: Tables ada di schema SYS, jadi query dengan prefix sys.table_name**"

---

## 🔹 SELECT Data

**🗣️ "Query data dari table employees:**"

### 🖥️ DEMO: Select
```bash
# Select all (gunakan sys prefix)
docker-compose exec oracle-primary bash -c "echo 'SELECT * FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Select dengan condition
docker-compose exec oracle-primary bash -c "echo 'SELECT emp_name, salary FROM sys.employees WHERE salary > 7000000;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

---

## 🔹 JOIN 3 Tables

**🗣️ "Contoh join 3 tables - employees, departments, locations:**"

### 🖥️ DEMO: Join
```bash
docker-compose exec oracle-primary sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SELECT e.emp_name, d.dept_name, l.location
FROM sys.employees e
JOIN sys.departments d ON e.dept_id = d.dept_id
JOIN sys.locations l ON d.location_id = l.location_id;
EXIT;
EOF
```

**🎯 Penjelasan sambil nunjuk output:**  
**🗣️ "Ini menunjukkan hubungan antar tabel dan bagaimana kita menggabungkan data dari multiple sources."**

---

## 🔹 Aggregate Functions

**🗣️ "Contoh aggregate function:**"

### 🖥️ DEMO: Aggregates
```bash
docker-compose exec oracle-primary sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SELECT 
  d.dept_name,
  COUNT(e.emp_id) as emp_count,
  AVG(e.salary) as avg_salary,
  SUM(e.salary) as total_salary
FROM sys.departments d
LEFT JOIN sys.employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
EXIT;
EOF
```

**🎯 Atau jalankan semua sekaligus:**
```bash
./scripts/run-sql-examples.sh
```

---

# 7️⃣ CLOSING (30 detik)

**🗣️ "Sebagai penutup:**

**Saya memahami arsitektur database Oracle dari sisi memory (SGA/PGA), background processes, dan physical storage structure.**

**Saya juga memahami konsep high availability melalui Data Guard, serta terbiasa bekerja di Linux environment dengan berbagai command monitoring.**

**Untuk SQL operations, saya mampu melakukan CRUD operations, complex joins, dan aggregate functions.**

**Environment Docker yang saya demonstrasikan ini menunjukkan kemampuan saya untuk setup, configure, dan troubleshoot database environment.**

**Dengan kombinasi pemahaman konsep dan pengalaman hands-on ini, saya siap untuk berkontribusi sebagai Oracle DBA.**

**Terima kasih, wassalamualaikum wr. wb."**

---

# 🎯 REFERENSI CEPAT PERINTAH

## Start/Stop Environment
```bash
./start.sh                 # Start semua service
./stop.sh                  # Stop service (simpan data)
./stop.sh --clean          # Stop & hapus data
```

## Akses Container
```bash
# DBA Tools (Linux utilities only)
docker-compose exec dba-tools bash

# Oracle Primary langsung
docker-compose exec oracle-primary bash

# SQL Server langsung
docker-compose exec sqlserver bash
```

## Connect Database (New Workflow)
```bash
# Oracle sebagai SYSDBA
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Oracle sebagai app_user
docker-compose exec oracle-primary sqlplus app_user/app_pass123@XEPDB1

# SQL Server
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -d NTTPlayground
```

## Script Demo Siap Pakai
```bash
# 1. Monitoring Arsitektur
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/dba-scripts/01_architecture_monitoring.sql

# 2. SQL Examples
./scripts/run-sql-examples.sh

# 3. Performance Monitoring
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/dba-scripts/03_performance_monitoring.sql

# 4. Linux DBA Tasks
docker-compose exec dba-tools bash -c "./scripts/dba-daily-tasks.sh"
```

## Web Interfaces
- **Adminer (DB GUI):** http://localhost:8080
- **Portainer:** http://localhost:9000

---

# 💡 TIPS PRESENTASI

1. **Buka terminal split** - Satu untuk presentasi, satu untuk logs
2. **Siapkan command di clipboard** - Copy-paste lebih cepat
3. **Test dulu sebelum presentasi** - Jalankan `./start.sh` 5 menit sebelum mulai
4. **Siapkan failover** - Kalau demo gagal, tunjukkan output yang sudah di-screenshot
5. **Catatan penting** - Tables di schema SYS, pakai prefix `sys.table_name`

---

# 📊 TIMING BREAKDOWN

| Section | Durasi | Demo |
|---------|--------|------|
| Opening | 30s | - |
| Oracle Architecture | 3m | ✅ Query memory & processes |
| Data Guard | 2m | ✅ Check primary/standby |
| SQL Server | 1.5m | ✅ Quick comparison |
| Linux Tasks | 2m | ✅ Monitoring commands |
| Hands-On SQL | 3m | ✅ CRUD + Join demo |
| Closing | 30s | - |
| **Total** | **~12-13 menit** | **Buffer 2-3 menit** |

---

# 🍎 APPLE SILICON NOTES

## What's Different?
- **dba-tools**: Lightweight Debian (130MB), no Oracle Client
- **Oracle connection**: Via `docker-compose exec oracle-primary`
- **Architecture**: ARM64 native (no Rosetta)

## Key Commands
```bash
# Connect to Oracle (new way)
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Query with SYS prefix
docker-compose exec oracle-primary bash -c "echo 'SELECT * FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Run scripts
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/dba-scripts/01_architecture_monitoring.sql
```

---

**Good luck with your presentation! 🚀**