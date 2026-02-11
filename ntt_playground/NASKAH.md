# 🎤 NASKAH PRESENTASI ORACLE DBA - NTT PLAYGROUND

> **Versi:** 15 Menit + Demo Hands-On  
> **Environment:** NTT Playground Docker Stack  
> **Format:** Script presentasi dengan panduan eksekusi real-time

---

## 📝 PERSIAPAN SEBELUM PRESENTASI

### Start Environment (5 menit sebelum presentasi):
```bash
cd ntt_playground
./start.sh
```

### Pastikan services ready:
```bash
docker-compose ps
```

---

# 1️⃣ OPENING (30 detik)

**🗣️ "Assalamualaikum, selamat pagi/siang. Perkenalkan saya [Nama].**  
**Hari ini saya akan mempresentasikan pemahaman saya tentang Oracle Database Architecture, Data Guard, SQL Server, Linux DBA Tasks, dan hands-on SQL query.**

**Untuk demo hari ini, saya sudah menyiapkan environment Docker yang berisi:**
- Oracle Database Primary & Standby
- SQL Server 2022
- Linux DBA Tools dengan Oracle Client

**Ini akan memungkinkan saya untuk demonstrasi langsung sambil menjelaskan konsep.**"

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
# Masuk ke DBA Tools container
docker-compose exec dba-tools bash

# Connect ke Oracle
sqlplus app_user/app_pass123@ORACLE_PRIMARY

# Jalankan query monitoring
@/dba-scripts/01_architecture_monitoring.sql
```

**🎯 Penjelasan sambil nunjuk output:**  
**🗣️ "Ini kita bisa lihat SGA components dan ukurannya. Buffer Cache paling besar karena itu yang sering diakses."**

---

## 🔹 B. INSTANCE - Background Processes

**🗣️ "Di bagian background processes, ada beberapa proses penting:**

- **DBWR** (Database Writer) → nulis data dari buffer cache ke datafile
- **LGWR** (Log Writer) → nulis redo dari buffer ke online redo log
- **CKPT** (Checkpoint) → update control file dan datafile header
- **SMON & PMON** → system monitor dan process monitor untuk recovery
- **ARCn** (Archiver) → mengarsipkan redo log kalau archive mode aktif"

### 🖥️ DEMO: Lihat Background Processes
```sql
-- Di SQL*Plus, jalankan:
SELECT pname, spid, program 
FROM v$process 
WHERE pname IS NOT NULL 
ORDER BY pname;
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
```sql
-- Datafiles
SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb 
FROM dba_data_files;

-- Control files
SELECT name FROM v$controlfile;

-- Redo logs
SELECT group#, sequence#, bytes/1024/1024 as size_mb, status 
FROM v$log;

-- Archive mode
SELECT log_mode, open_mode FROM v$database;
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
5. Di standby, **RFS** (Remote File Server) terima data
6. Disimpan di **Standby Redo Log**
7. **MRP** (Managed Recovery Process) apply ke standby database"

---

## 🔹 Real-Time Apply & Gap Resolution

**🗣️ "Kalau pakai real-time apply, standby langsung apply redo tanpa tunggu archive log selesai.**

**Kalau network putus, proses **ARC** akan lakukan **gap resolution** - ngirim ulang redo yang ketinggalan.**"

### 🖥️ DEMO: Cek Primary & Standby
```bash
# Cek Primary
docker-compose exec dba-tools sqlplus sys/oracle@ORACLE_PRIMARY as sysdba
SELECT database_role, open_mode FROM v$database;

# Cek Standby (di terminal lain)
docker-compose exec dba-tools sqlplus sys/oracle@ORACLE_STANDBY as sysdba
SELECT database_role, open_mode FROM v$database;
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
# Connect ke SQL Server
docker-compose exec dba-tools /opt/mssql-tools/bin/sqlcmd \
  -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground

# Cek database files
SELECT 
  name, physical_name, 
  size * 8 / 1024 as size_mb,
  type_desc
FROM sys.master_files
WHERE database_id = DB_ID('NTTPlayground');
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
# Masuk ke DBA Tools
docker-compose exec dba-tools bash

# Cek disk usage
df -h

# Cek ukuran direktori
du -sh /oracle-data

# Atau jalankan script monitoring lengkap
./scripts/dba-daily-tasks.sh
```

---

## 🔹 Monitoring Process

**🗣️ "Cek proses Oracle yang berjalan:**"

### 🖥️ DEMO: Process Monitoring
```bash
# Oracle processes
ps -ef | grep ora_

# Atau pakai top/htop
top
```

---

## 🔹 Monitoring Listener & Logs

**🗣️ "Listener harus selalu jalan, dan alert log harus dimonitor:**"

### 🖥️ DEMO: Listener & Logs
```bash
# Cek listener (di container oracle)
docker-compose exec oracle-primary lsnrctl status

# Monitor alert log
docker-compose exec oracle-primary tail -f /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
```

**🎯 Kalimat Kunci:**  
**🗣️ "Monitoring ini penting untuk deteksi masalah sebelum berdampak ke user. Prevention is better than cure."**

---

# 6️⃣ HANDS-ON SQL QUERY (3 menit)

**🗣️ "Sekarang saya demonstrasikan basic SQL operation yang biasa dilakukan DBA."**

---

## 🔹 Create Table

**🗣️ "Pertama, create table untuk data karyawan:**"

### 🖥️ DEMO: Create Table
```sql
-- Connect sebagai app_user
sqlplus app_user/app_pass123@ORACLE_PRIMARY

-- Create table
CREATE TABLE employees_demo (
  emp_id NUMBER PRIMARY KEY,
  emp_name VARCHAR2(100),
  salary NUMBER,
  dept_id NUMBER
);
```

---

## 🔹 Insert Data

**🗣️ "Insert data sample:**"

### 🖥️ DEMO: Insert
```sql
INSERT INTO employees_demo VALUES (1, 'Rafi', 8000000, 10);
INSERT INTO employees_demo VALUES (2, 'Budi', 7500000, 10);
INSERT INTO employees_demo VALUES (3, 'Ani', 6500000, 20);
COMMIT;
```

---

## 🔹 Select & Update

**🗣️ "Query data dan update:**"

### 🖥️ DEMO: Select & Update
```sql
-- Select all
SELECT * FROM employees_demo;

-- Select dengan condition
SELECT emp_name, salary 
FROM employees_demo 
WHERE salary > 7000000;

-- Update salary
UPDATE employees_demo 
SET salary = salary + 1000000 
WHERE emp_id = 1;
COMMIT;
```

---

## 🔹 Join 3 Tables

**🗣️ "Contoh join 3 tables - employees, departments, locations:**"

### 🖥️ DEMO: Join (Pakai Data yang Sudah Ada)
```sql
-- Join 3 tables
SELECT 
  e.emp_name, 
  d.dept_name, 
  l.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN locations l ON d.location_id = l.location_id;
```

**🎯 Penjelasan sambil nunjuk output:**  
**🗣️ "Ini menunjukkan hubungan antar tabel dan bagaimana kita menggabungkan data dari multiple sources."**

---

## 🔹 Aggregate Functions

**🗣️ "Contoh aggregate function:**"

### 🖥️ DEMO: Aggregates
```sql
-- Count, AVG, SUM per department
SELECT 
  d.dept_name,
  COUNT(e.emp_id) as emp_count,
  AVG(e.salary) as avg_salary,
  SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
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
# DBA Tools (Linux + Oracle Client)
docker-compose exec dba-tools bash

# Oracle Primary langsung
docker-compose exec oracle-primary bash

# SQL Server langsung
docker-compose exec sqlserver bash
```

## Connect Database
```bash
# Oracle sebagai app_user
sqlplus app_user/app_pass123@ORACLE_PRIMARY

# Oracle sebagai SYSDBA
sqlplus sys/oracle@ORACLE_PRIMARY as sysdba

# SQL Server
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground
```

## Script Demo Siap Pakai
```bash
# 1. Monitoring Arsitektur
sqlplus app_user/app_pass123@ORACLE_PRIMARY @/dba-scripts/01_architecture_monitoring.sql

# 2. SQL Examples
./scripts/run-sql-examples.sh

# 3. Performance Monitoring
sqlplus app_user/app_pass123@ORACLE_PRIMARY @/dba-scripts/03_performance_monitoring.sql

# 4. Linux DBA Tasks
./scripts/dba-daily-tasks.sh
```

## Web Interfaces
- **Adminer (DB GUI):** http://localhost:8080
- **Portainer:** http://localhost:9000

---

# 💡 TIPS PRESENTASI

1. **Buka terminal split** - Satu untuk presentasi, satu untuk demo
2. **Siapkan command di clipboard** - Copy-paste lebih cepat
3. **Test dulu sebelum presentasi** - Jalankan `./start.sh` 5 menit sebelum mulai
4. **Siapkan failover** - Kalau demo gagal, tunjukkan output yang sudah di-screenshot
5. **Interaksi** - Ajak audiens untuk bertanya di tengah-tengah

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

**Good luck with your presentation! 🚀**