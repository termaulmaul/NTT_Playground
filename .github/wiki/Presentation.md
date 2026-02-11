![[PRESENTATION_GUIDE]]# Presentation Script

Naskah presentasi lengkap 15 menit untuk Oracle DBA Interview.

---

## 🎯 Overview

**Durasi:** 15 Menit  
**Audience:** Technical Interviewers  
**Goal:** Demonstrasikan pemahaman Oracle Architecture, Data Guard, dan hands-on skills

---

## 1️⃣ OPENING (30 detik)

**Script:**
> "Assalamualaikum, selamat pagi/siang. Perkenalkan saya [Nama].
> 
> Hari ini saya akan mempresentasikan pemahaman saya tentang Oracle Database Architecture, Data Guard, SQL Server, Linux DBA Tasks, dan hands-on SQL query.
> 
> Untuk demo hari ini, saya sudah menyiapkan environment Docker yang berisi Oracle Database Primary & Standby, SQL Server 2022, dan Linux DBA Tools.
> 
> Environment ini optimized untuk Apple Silicon dengan image yang 90% lebih ringan."

**Action:**
```bash
# Terminal 1
./start.sh

# Terminal 2 (logs)
docker-compose logs -f oracle-primary
```

---

## 2️⃣ ORACLE DATABASE ARCHITECTURE (3 menit)

### Visual Reference
Lihat gambar: [Oracle Database Architecture](images/OracleDatabaseArchitecture.jpeg)

### Script

**Introduction:**
> "Baik, saya mulai dari Oracle Database Architecture.
> 
> Kalau kita lihat konsepnya, Oracle dibagi menjadi dua bagian besar: Instance dan Database.
> 
> Instance itu ada di memory (atas), Database itu ada di disk (bawah)."

### Memory Structure (SGA/PGA)

**Script:**
> "Instance terdiri dari Memory Structure dan Background Processes.
> 
> Di memory ada yang namanya SGA (System Global Area) dan PGA (Program Global Area).
> 
> SGA ini shared memory yang dipakai semua user. Dalamnya ada:
> - Database Buffer Cache → tempat data block di memory sebelum ke disk
> - Shared Pool → nyimpen parsed SQL dan data dictionary  
> - Redo Log Buffer → nyimpen redo entries sebelum ditulis LGWR
> 
> PGA itu private per session, buat sorting dan operasi query."

**Demo:**
```bash
# Cek SGA
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT name, value/1024/1024 as size_mb FROM v\$sga;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Background Processes

**Script:**
> "Di bagian background processes, ada beberapa proses penting:
> 
> - DBWn (Database Writer) → nulis data dari buffer cache ke datafile
> - LGWR (Log Writer) → nulis redo dari buffer ke online redo log
> - CKPT (Checkpoint) → update control file dan datafile header
> - SMON & PMON → system monitor dan process monitor untuk recovery
> - ARCn (Archiver) → mengarsipkan redo log kalau archive mode aktif"

**Demo:**
```bash
# Lihat background processes
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT pname, spid, program FROM v\$process WHERE pname IS NOT NULL ORDER BY pname;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Physical Structure

**Script:**
> "Sekarang bagian bawah, physical database. Komponennya:
> 
> - Datafiles → nyimpen data actual
> - Control files → nyimpen metadata database
> - Online Redo Log Files → mencatat perubahan transaksi
> - Archived Redo Logs → untuk recovery
> - Flashback Logs → untuk flashback database"

**Demo:**
```bash
# Datafiles, Control files, Redo logs
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT file_name, tablespace_name FROM dba_data_files;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

**Key Point:**
> "Jadi alurnya: user query masuk → diproses di memory → perubahan dicatat di redo → baru ditulis permanen ke datafile. Ini yang menjamin data consistency dan recoverability."

---

## 3️⃣ ORACLE DATA GUARD (2 menit)

### Visual Reference
Lihat gambar: [Oracle Data Guard](images/OracleDataGuard.jpeg)

### Script

**Introduction:**
> "Selanjutnya, Oracle Data Guard untuk High Availability.
> 
> Konsepnya ada Primary Database (kiri) dan Standby Database (kanan)."

### Alur Data Guard

**Script:**
> "Proses sinkronisasinya seperti ini:
> 
> 1. User transaksi di Primary Database
> 2. Perubahan dicatat di Redo Buffer
> 3. LGWR tulis ke Online Redo Log
> 4. LNS (Log Network Server) kirim redo ke standby
> 5. Di sisi standby, RFS (Remote File Server) terima data
> 6. Disimpan ke Standby Redo Log
> 7. MRP (Managed Recovery Process) apply ke standby database"

### Real-Time Apply & Gap Resolution

**Script:**
> "Kalau pakai real-time apply, standby langsung apply redo tanpa tunggu archive log selesai.
> 
> Kalau network putus, proses ARC akan lakukan gap resolution - ngirim ulang redo yang ketinggalan."

**Demo:**
```bash
# Check Primary
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT database_role, open_mode FROM v\$database;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Check Standby
docker-compose exec oracle-standby bash -c \
  "echo 'SELECT database_role, open_mode FROM v\$database;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

**Key Point:**
> "Dengan Data Guard, kita bisa switchover atau failover untuk pastikan high availability dan disaster recovery. Primary down, standby bisa langsung takeover."

---

## 4️⃣ SQL SERVER ARCHITECTURE (1.5 menit)

**Script:**
> "Secara singkat, SQL Server architecture konsepnya mirip Oracle, beda istilah saja.
> 
> Memory:
> - Buffer Pool = mirip Buffer Cache Oracle
> - Plan Cache = nyimpen execution plan
> - Write-Ahead Logging = sama konsep redo logging
> 
> Storage:
> - MDF = primary data file
> - NDF = secondary file
> - LDF = transaction log"

**Demo:**
```bash
# Compare dengan SQL Server
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -Q "SELECT name, physical_name, type_desc FROM sys.master_files WHERE database_id = DB_ID('NTTPlayground')"
```

**Key Point:**
> "Transaction log di SQL Server sangat krusial karena semua perubahan dicatat dulu sebelum ke data file. Sama seperti redo log di Oracle."

---

## 5️⃣ LINUX DBA DAILY TASKS (2 menit)

**Script:**
> "Sebagai Oracle DBA, daily task di Linux sangat penting untuk monitoring dan troubleshooting."

### Disk Monitoring

**Demo:**
```bash
# Masuk ke DBA Tools
docker-compose exec dba-tools bash

# Cek disk
df -h
du -sh /
```

### Process Monitoring

**Demo:**
```bash
# Oracle processes
ps -ef | grep -E "(oracle|sql)"

# Resource usage
top
```

### Logs

**Demo:**
```bash
# Listener status
docker-compose exec oracle-primary lsnrctl status

# Alert log
docker-compose exec oracle-primary tail -f /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
```

**Key Point:**
> "Monitoring ini penting untuk deteksi masalah sebelum berdampak ke user. Prevention is better than cure."

---

## 6️⃣ HANDS-ON SQL QUERY (3 menit)

**Script:**
> "Sekarang saya demonstrasikan basic SQL operation.
> 
> Catatan: Tables ada di schema SYS, jadi query dengan prefix sys.table_name"

### SELECT

**Demo:**
```bash
# Select all
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# With condition
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT emp_name, salary FROM sys.employees WHERE salary > 7000000;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### JOIN

**Demo:**
```bash
# Join 3 tables
docker-compose exec oracle-primary sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SELECT e.emp_name, d.dept_name, l.location
FROM sys.employees e
JOIN sys.departments d ON e.dept_id = d.dept_id
JOIN sys.locations l ON d.location_id = l.location_id;
EXIT;
EOF
```

### Aggregates

**Demo:**
```bash
./scripts/run-sql-examples.sh
```

**Key Point:**
> "Ini menunjukkan kemampuan saya dalam SQL operations, complex joins, dan aggregate functions."

---

## 7️⃣ CLOSING (30 detik)

**Script:**
> "Sebagai penutup:
> 
> Saya memahami arsitektur database Oracle dari sisi memory (SGA/PGA), background processes, dan physical storage structure.
> 
> Saya juga memahami konsep high availability melalui Data Guard, serta terbiasa bekerja di Linux environment dengan berbagai command monitoring.
> 
> Environment Docker yang saya demonstrasikan ini menunjukkan kemampuan saya untuk setup, configure, dan troubleshoot database environment.
> 
> Dengan kombinasi pemahaman konsep dan pengalaman hands-on ini, saya siap untuk berkontribusi sebagai Oracle DBA.
> 
> Terima kasih, wassalamualaikum wr. wb."

---

## 📊 Timing Breakdown

| Section | Duration | Key Demo |
|---------|----------|----------|
| Opening | 30s | ./start.sh |
| Oracle Architecture | 3m | SGA + Background processes |
| Data Guard | 2m | Check primary/standby role |
| SQL Server | 1.5m | Files comparison |
| Linux Tasks | 2m | df -h, ps, logs |
| SQL Demo | 3m | Join + Aggregates |
| Closing | 30s | Summary |
| **Total** | **12-13 min** | **Buffer: 2-3 min** |

---

## 💡 Tips Presentasi

1. **Practice dulu** - Test semua command sebelum presentasi
2. **Terminal split** - Buka 2 terminal (main + logs)
3. **Siapkan clipboard** - Copy-paste command lebih cepat
4. **Backup plan** - Screenshot output kalau demo gagal
5. **Interact** - Ajak interviewer bertanya

---

## 🔗 Referensi

- [Architecture](Architecture) - Detail arsitektur Oracle
- [Data Guard](Data-Guard) - Detail konsep HA/DR
- [Commands](Commands) - Semua commands

---

**Good luck! 🚀**