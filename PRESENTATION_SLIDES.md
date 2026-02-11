# 🎤 PANDUAN PRESENTASI SLIDE-BY-SLIDE - NTT PLAYGROUND

**Format Presentasi:**
- 🟦 **Isi Slide** (bullet point yang bisa dimasukkan ke PPT)
- 🎤 **Script Natural** (yang Anda ucapkan, bukan baca mentah)

**Durasi:** ±20-25 menit  
**Total Slide:** 25 slides  
**Environment:** NTT Playground Docker (sudah running)

---

# 🟦 SLIDE 1 — Cover

### Isi Slide

**Oracle DBA Architecture & Hands-On Demonstration**

Maulana Rafi  
Oracle DBA Presentation

### 🎤 Script

"Assalamualaikum warahmatullahi wabarakatuh.  
Selamat pagi/siang.

Perkenalkan, nama saya Maulana Rafi.

Pada kesempatan ini saya akan mempresentasikan pemahaman saya terkait Oracle Database Architecture, Oracle Data Guard, SQL Server Architecture, Linux daily task untuk DBA, serta hands-on SQL menggunakan environment yang sudah saya siapkan."

---

# 🟦 SLIDE 2 — Background

### Isi Slide

* Database = Core System
* Downtime = Financial & Operational Impact
* Data Loss = Critical Risk
* Need: HA, Monitoring, Recovery

### 🎤 Script

"Database adalah core system dalam hampir semua enterprise application.  
Kalau database down, maka aplikasi juga ikut down.

Downtime bisa berdampak pada kerugian finansial dan gangguan operasional.  
Dan yang lebih fatal adalah kehilangan data.

Karena itu, seorang DBA harus memahami arsitektur, recovery mechanism, dan high availability."

---

# 🟦 SLIDE 3 — Objective

### Isi Slide

* Memahami Oracle Architecture
* Memahami Redo & Recovery
* Memahami Data Guard
* Demonstrasi Hands-On
* Monitoring Linux

### 🎤 Script

"Tujuan dari presentasi ini adalah menunjukkan bahwa saya memahami:

* Bagaimana Oracle bekerja dari sisi memory dan storage
* Bagaimana redo dan recovery berjalan
* Bagaimana konsep standby database di Data Guard
* Serta kemampuan hands-on dalam monitoring dan SQL"

---

# 🟦 SLIDE 4 — Environment Topology

### Isi Slide

**Docker-based Lab:**

* Oracle Primary (Port 1521)
* Oracle Standby (Port 1522)
* SQL Server 2022 (Port 1433)
* Linux DBA Tools (Lightweight)
* Adminer GUI (Port 8080)

### 🎤 Script

"Untuk demo ini saya menggunakan environment berbasis Docker.

Di dalamnya ada Oracle Primary, Oracle Standby, SQL Server 2022, dan container khusus untuk Linux DBA tools.

Semua environment sudah running dan siap untuk demonstrasi.  
Saya bisa tunjukkan dengan docker-compose ps..."

**💻 Action:**
```bash
docker-compose ps
```

---

# 🟦 SLIDE 5 — Oracle Architecture Overview

### Isi Slide

Oracle =
1️⃣ Instance (Memory + Processes)
2️⃣ Database (Physical Files)

![Oracle Architecture](OracleDatabaseArchitecture.jpeg)

### 🎤 Script

"Oracle Database secara konsep terbagi menjadi dua bagian besar:  
Instance dan Database.

Instance ada di memory.  
Database ada di disk.

Kalau kita lihat gambar ini, bagian atas adalah Instance dengan SGA dan Background Processes.  
Bagian bawah adalah Database dengan datafiles, control files, dan redo logs.

Ini penting, karena pemisahan ini memungkinkan Oracle melakukan recovery dan high availability."

---

# 🟦 SLIDE 6 — User Connection Layer

### Isi Slide

**Kiri Diagram:**

* SQLPlus / Client Application
* Listener (Port 1521)
* Parameter File
* Password File

### 🎤 Script

"Di sisi kiri diagram kita melihat layer koneksi.

User connect melalui listener di port 1521.  
Listener kemudian meneruskan koneksi ke Oracle Server Process.

Kalau listener down, user tidak bisa connect walaupun database berjalan.  
Makanya monitoring listener sangat penting."

**💻 Demo (Opsional):**
```bash
docker-compose exec oracle-primary lsnrctl status | head -10
```

---

# 🟦 SLIDE 7 — SGA (Memory Structure)

### Isi Slide

**SGA Components:**

* Database Buffer Cache (912 MB)
* Shared Pool
* Redo Log Buffer
* Large Pool / Java Pool

### 🎤 Script

"SGA adalah shared memory yang digunakan semua session.

Database Buffer Cache menyimpan data block - di environment kita ini 912 MB.  
Ini yang paling besar karena itulah yang paling sering diakses oleh query.

Shared Pool menyimpan parsed SQL dan data dictionary.  
Redo Log Buffer menyimpan redo entries sebelum ditulis ke disk.

Semakin optimal SGA, semakin baik performance database."

**💻 Demo:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 80
COLUMN name FORMAT A30
COLUMN size_mb FORMAT 999999
SELECT name, value/1024/1024 as size_mb FROM v\$sga;
EXIT;
EOF'
```

---

# 🟦 SLIDE 8 — PGA

### Isi Slide

**PGA (Program Global Area):**

* Private per session
* Sorting operations
* Hash Join
* Query Execution Work Area

### 🎤 Script

"Berbeda dengan SGA, PGA bersifat private per session.

Digunakan untuk operasi seperti sorting, hash join, dan eksekusi query.  
Jadi setiap user punya PGA masing-masing.

Kalau query-nya butuh sorting besar, PGA akan digunakan.  
Kalau tidak cukup, akan pakai temporary tablespace di disk."

---

# 🟦 SLIDE 9 — Background Processes

### Isi Slide

**Background Processes:**

* DBWR - Database Writer
* LGWR - Log Writer
* CKPT - Checkpoint
* SMON - System Monitor
* PMON - Process Monitor
* ARCn - Archiver

### 🎤 Script

"Background process inilah yang membuat Oracle powerful.

LGWR menulis redo.  
DBWR menulis data ke datafile.  
SMON melakukan recovery saat startup.  
PMON membersihkan session yang crash.

Semua proses ini berjalan otomatis di background.  
Kalau salah satu proses kritis mati, database akan bermasalah."

**💻 Demo:**
```bash
docker top oracle-primary | grep -E "(oracle|tnslsnr)" | head -8
```

---

# 🟦 SLIDE 10 — Write Ahead Logging Concept

### Isi Slide

**Alur Transaksi:**

User Query → Memory (SGA) → Redo Log Buffer → LGWR → Online Redo Log → DBWR → Datafile

### 🎤 Script

"Konsep penting di Oracle adalah Write Ahead Logging.

Artinya, setiap perubahan dicatat dulu di redo log sebelum ditulis ke datafile.

Jadi alurnya:  
User query masuk → diproses di memory → perubahan dicatat di redo buffer → LGWR tulis ke redo log → baru DBWR tulis ke datafile.

Inilah yang menjamin durability dan recovery capability.  
Kalau database crash sebelum datafile terupdate, kita bisa recover dari redo log."

---

# 🟦 SLIDE 11 — Physical Database Structure

### Isi Slide

**Physical Files:**

* Datafiles (.dbf) - Data actual
* Control Files (.ctl) - Metadata
* Online Redo Logs - Transaksi
* Archived Logs - Backup recovery
* Flashback Logs - Flashback DB

### 🎤 Script

"Bagian bawah diagram menunjukkan physical database.

Datafiles menyimpan data actual - tabel, index, dan object database.  
Control file menyimpan metadata database.  
Redo log menyimpan transaksi.  
Archive log untuk recovery.  
Flashback log untuk flashback database.

Saya bisa tunjukkan datafiles kita..."

**💻 Demo:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN tablespace_name FORMAT A20
COLUMN file_name FORMAT A50
SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb FROM dba_data_files;
EXIT;
EOF'
```

---

# 🟦 SLIDE 12 — Control File Importance

### Isi Slide

**Control File contains:**

* Database Name & Created Date
* SCN (System Change Number)
* Datafile location & names
* Redo log location
* Checkpoint information
* Archive log history

### 🎤 Script

"Control file sangat critical.

Di dalamnya ada SCN, lokasi datafile, dan history archive log.  
Ini seperti GPS database - kalau hilang, database tidak tahu di mana datafiles-nya.

Kalau control file corrupt dan tidak ada backup, database tidak bisa mount.

Makanya Oracle merekomendasikan multiplexing - minimal 2 control files di lokasi berbeda."

**💻 Demo:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 100
COLUMN name FORMAT A60
SELECT name FROM v\$controlfile;
EXIT;
EOF'
```

---

# 🟦 SLIDE 13 — Oracle Data Guard Overview

### Isi Slide

**High Availability & Disaster Recovery**

Primary Database ↔ Standby Database  
Redo-based replication

![Oracle Data Guard](OracleDataGuard.jpeg)

### 🎤 Script

"Oracle Data Guard digunakan untuk high availability dan disaster recovery.

Konsepnya sederhana:  
Primary database mengirim redo ke standby database.

Kalau kita lihat gambar ini, sebelah kiri adalah Primary, sebelah kanan adalah Standby.  
Redo dari primary dikirim melalui network ke standby.

Standby bisa digunakan untuk reporting, backup offloading, atau disaster recovery."

---

# 🟦 SLIDE 14 — Data Guard Flow

### Isi Slide

**Alur Sinkronisasi:**

1. Primary Transaction
2. Redo Buffer
3. LGWR → Online Redo Log
4. LNS (Log Network Server)
5. Oracle Net
6. RFS (Remote File Server)
7. Standby Redo Log
8. MRP (Managed Recovery Process)

### 🎤 Script

"Alurnya seperti ini:

User melakukan transaksi di primary → perubahan masuk ke Redo Buffer → LGWR tulis ke Online Redo Log → LNS (Log Network Server) kirim redo ke standby melalui network → di standby, RFS (Remote File Server) terima data → disimpan di Standby Redo Log → lalu di-apply oleh MRP.

Kalau pakai real-time apply, standby langsung apply redo tanpa menunggu archive log selesai."

---

# 🟦 SLIDE 15 — Protection Modes

### Isi Slide

**Data Guard Protection Modes:**

* **Maximum Protection** - Zero data loss, synchronous (strict)
* **Maximum Availability** - Balance, async/sync hybrid
* **Maximum Performance** - Asynchronous, minimal overhead

### 🎤 Script

"Data Guard memiliki tiga mode proteksi.

Maximum Protection = zero data loss tapi strict.  
Setiap transaksi harus ditulis ke primary DAN standby sebelum commit dianggap sukses.

Maximum Availability = balance antara protection dan performance.  
Biasanya synchronous tapi bisa fallback ke async kalau standby lambat.

Maximum Performance = asynchronous dan lebih ringan.  
Primary tidak menunggu standby, cocok untuk long distance."

---

# 🟦 SLIDE 16 — Switchover vs Failover

### Isi Slide

**Role Transition:**

* **Switchover** = Planned (maintenance, testing)
  * Primary → Standby
  * Standby → Primary
  * Reversible

* **Failover** = Unplanned (primary crash)
  * Standby promoted jadi Primary
  * Data loss possible
  * Original primary must be rebuilt

### 🎤 Script

"Switchover adalah pergantian role yang direncanakan, misalnya saat maintenance.  
Primary di-switch jadi standby, standby di-switch jadi primary.  
Ini reversible.

Failover adalah saat primary down dan standby harus takeover secara paksa.  
Bisa ada data loss kalau mode-nya async.  
Original primary harus di-rebuild setelah failover.

Saya bisa cek role database kita..."

**💻 Demo:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 100
COLUMN database_role FORMAT A20
COLUMN open_mode FORMAT A20
SELECT database_role, open_mode FROM v\$database;
EXIT;
EOF'
```

---

# 🟦 SLIDE 17 — SQL Server Architecture

### Isi Slide

**SQL Server Components:**

* MDF - Primary Data File (data)
* LDF - Transaction Log File (log)
* NDF - Secondary Data File
* Buffer Pool
* Write-Ahead Logging

### 🎤 Script

"SQL Server secara konsep mirip Oracle.

MDF adalah Master Data File - sama seperti datafiles di Oracle.  
LDF adalah Log Data File - sama seperti redo logs di Oracle.  
NDF adalah Secondary Data File untuk database besar.

Dan juga menggunakan write-ahead logging - log dulu, baru data."

**💻 Demo:**
```bash
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -C -Q "SELECT name, physical_name, size*8/1024 as size_mb, type_desc FROM sys.master_files WHERE database_id = DB_ID('NTTPlayground')"
```

---

# 🟦 SLIDE 18 — Oracle vs SQL Server Comparison

### Isi Slide

| Oracle | SQL Server |
|--------|------------|
| Datafile (.dbf) | MDF |
| Redo Log | LDF |
| SGA | Buffer Pool |
| Data Guard | Always On |
| Background Processes | SQL Server Services |
| PL/SQL | T-SQL |

### 🎤 Script

"Secara konsep hampir sama, hanya istilahnya berbeda.

Oracle punya Data Guard, SQL Server punya Always On.  
Oracle pakai PL/SQL, SQL Server pakai T-SQL.

Tapi keduanya mengutamakan durability dan transaction logging.  
Keduanya menggunakan konsep write-ahead logging.  
Dan keduanya memerlukan DBA untuk monitoring dan maintenance."

---

# 🟦 SLIDE 19 — Linux DBA Daily Tasks

### Isi Slide

**Daily Monitoring Commands:**

* `df -h` - Disk space usage
* `free -h` - Memory usage
* `docker top` - Process monitoring
* `lsnrctl status` - Listener status
* `tail alert log` - Database events

### 🎤 Script

"Sebagai DBA, monitoring Linux sangat penting.

Cek disk space dengan df -h - kalau penuh database error.  
Cek memory dengan free -h - kalau habis pakai swap jadi lambat.  
Cek proses dengan docker top atau ps.  
Cek listener dengan lsnrctl status.  
Dan cek alert log untuk errors atau warnings.

Karena prevention lebih baik daripada troubleshooting saat sudah down."

**💻 Demo:**
```bash
docker-compose exec dba-tools bash /scripts/dba-daily-tasks.sh
```

---

# 🟦 SLIDE 20 — SQL CRUD Operations

### Isi Slide

**SQL Basics:**

* CREATE - Membuat tabel/object
* INSERT - Menambah data
* SELECT - Membaca data
* UPDATE - Mengubah data
* DELETE - Menghapus data
* DROP - Menghapus object

### 🎤 Script

"Untuk SQL, saya terbiasa melakukan operasi CRUD.

Membuat tabel dengan CREATE.  
Insert data dengan INSERT.  
Baca data dengan SELECT.  
Update data dengan UPDATE.  
Delete data dengan DELETE.  
Dan DROP untuk menghapus tabel atau object.

Saya bisa demonstrasikan SELECT dan JOIN..."

---

# 🟦 SLIDE 21 — SELECT & Filtering

### Isi Slide

**Query Examples:**

```sql
SELECT * FROM employees;
SELECT emp_name, salary FROM employees WHERE salary > 7000000;
```

**Clauses:**

* WHERE - Filtering
* ORDER BY - Sorting
* GROUP BY - Aggregation

### 🎤 Script

"SELECT digunakan untuk mengambil data.

WHERE untuk filtering - misalnya hanya yang salary-nya di atas 7 juta.  
ORDER BY untuk sorting.  
GROUP BY untuk grouping sebelum aggregate.

Saya bisa tunjukkan..."

**💻 Demo:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN emp_name FORMAT A15
COLUMN salary FORMAT 999999999
SELECT emp_name, salary FROM sys.employees WHERE salary > 7000000;
EXIT;
EOF'
```

---

# 🟦 SLIDE 22 — JOIN Multiple Tables

### Isi Slide

**JOIN Operations:**

* INNER JOIN - Data yang match di kedua tabel
* LEFT JOIN - Semua data kiri + match kanan
* RIGHT JOIN - Semua data kanan + match kiri

**Example:**
Employees → Departments → Locations

### 🎤 Script

"JOIN digunakan untuk menggabungkan beberapa tabel.

Relasi antar tabel menggunakan foreign key.  
Ini adalah konsep relational database.

Contoh: Tabel employees join dengan departments pakai dept_id.  
Kemudian departments join dengan locations pakai location_id.

Hasilnya kita bisa lihat employee di department mana dan lokasi mana."

**💻 Demo:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN emp_name FORMAT A15
COLUMN dept_name FORMAT A20
COLUMN location FORMAT A20
SELECT e.emp_name, d.dept_name, l.location
FROM sys.employees e
JOIN sys.departments d ON e.dept_id = d.dept_id
JOIN sys.locations l ON d.location_id = l.location_id;
EXIT;
EOF'
```

---

# 🟦 SLIDE 23 — Aggregate Functions

### Isi Slide

**Aggregate Functions:**

* COUNT(*) - Menghitung jumlah rows
* AVG(column) - Rata-rata
* SUM(column) - Total
* MAX/MIN - Nilai tertinggi/terendah

**With GROUP BY:**

```sql
SELECT dept_name, COUNT(emp_id), AVG(salary), SUM(salary)
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

### 🎤 Script

"Aggregate function digunakan untuk summary data.

Misalnya menghitung jumlah employee per department.  
Atau rata-rata salary per department.  
Atau total salary per department.

Dengan GROUP BY, kita bisa mengelompokkan data sebelum dihitung.  
Jadi aggregate function dihitung per grup, bukan total keseluruhan."

**💻 Demo:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN dept_name FORMAT A20
COLUMN emp_count FORMAT 999
COLUMN avg_salary FORMAT 999999999
COLUMN total_salary FORMAT 999999999
SELECT d.dept_name, COUNT(e.emp_id) as emp_count, AVG(e.salary) as avg_salary, SUM(e.salary) as total_salary
FROM sys.departments d
LEFT JOIN sys.employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
EXIT;
EOF'
```

---

# 🟦 SLIDE 24 — Hands-On Demo Result

### Isi Slide

**✅ Demo Results:**

* Oracle Architecture verified
* Background processes running
* SGA Memory configured
* Datafiles & Control files exist
* SQL CRUD successful
* JOIN 3 tables working
* Aggregate functions working
* Linux monitoring functional

### 🎤 Script

"Dari demo tadi, kita sudah melihat bahwa:

Oracle berjalan normal dengan background process aktif.  
SGA Memory terkonfigurasi dengan Database Buffer Cache 912 MB.  
Datafiles dan control files ada di lokasi yang benar.  
SQL berjalan baik - SELECT, JOIN, dan aggregate functions.  
Linux monitoring juga berjalan baik.

Ini menunjukkan environment siap untuk production simulation."

---

# 🟦 SLIDE 25 — Closing

### Isi Slide

**Summary:**

✅ Oracle Architecture (Instance + Database)  
✅ Memory Structure (SGA + PGA)  
✅ Background Processes  
✅ Physical Storage (Datafiles, Control, Redo)  
✅ Data Guard (HA & DR)  
✅ SQL Server Comparison  
✅ Linux Monitoring  
✅ Hands-On SQL

**Maulana Rafi**  
Ready to contribute as Oracle DBA

### 🎤 Script (Final Natural Closing)

"Sebagai penutup, saya memahami Oracle dari sisi:

* Arsitektur memory dan storage
* Background processes dan recovery mechanism
* High availability menggunakan Data Guard
* Serta terbiasa bekerja di Linux environment untuk monitoring

Selain itu saya mampu melakukan SQL CRUD, join multiple tables, dan aggregate function secara hands-on.

Dengan kombinasi pemahaman konsep dan praktik langsung, saya siap untuk berkontribusi sebagai Oracle DBA.

Terima kasih atas waktunya.  
Wassalamualaikum warahmatullahi wabarakatuh."

---

# 🎯 TIPS PRESENTASI

## Timing per Slide

| Slide | Durasi | Content |
|-------|--------|---------|
| 1-4 | 2 menit | Opening & Setup |
| 5-12 | 8 menit | Architecture |
| 13-16 | 4 menit | Data Guard |
| 17-18 | 2 menit | SQL Server |
| 19 | 2 menit | Linux Tasks |
| 20-23 | 5 menit | SQL Demo |
| 24-25 | 2 menit | Closing |

## Command Cepat (Copy-Paste)

```bash
# Check all services
docker-compose ps

# Quick Oracle check
docker-compose exec oracle-primary bash -c "echo 'SELECT COUNT(*) FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Quick SQL Server check
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -C -Q "SELECT COUNT(*) FROM employees"

# Run all SQL examples
./dba-tools/scripts/run-sql-examples.sh
```

## Kalimat Transisi

* "Kalau kita lihat gambar ini..."
* "Ini menunjukkan bahwa..."
* "Secara sederhana, prosesnya seperti ini..."
* "Yang menarik adalah..."
* "Nah, sekarang kita coba..."

## Emergency Fallback

Kalau demo gagal:
1. Tunjukkan screenshot yang sudah disiapkan
2. Jelaskan "seharusnya outputnya seperti ini..."
3. Lanjut ke slide berikutnya tanpa panik

---

**Good luck with your presentation! 🚀**