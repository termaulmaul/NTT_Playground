# 🎤 PANDUAN PRESENTASI LENGKAP - NTT PLAYGROUND

**File ini berisi NASKAH + COMMAND + HINT lengkap untuk presentasi Oracle DBA**

> **Cara pakai:** Baca bagian "🗣️ Naskah" sambil jalankan bagian "💻 Command" di terminal
> **Durasi:** 15 menit
> **Siapkan:** 2 terminal (1 untuk presentasi, 1 untuk logs)

---

## 🎯 PERSIAPAN (Lakukan 5 menit sebelum presentasi)

### Terminal 1 - Setup
```bash
cd ~/github/NTT_Playground
./start.sh
```

### Terminal 2 - Monitor Logs
```bash
cd ~/github/NTT_Playground
docker-compose logs -f oracle-primary | grep "DATABASE IS READY"
# Tunggu sampai muncul: "DATABASE IS READY TO USE!"
```

### Init SQL Server (Sekali saja setelah start)
```bash
# Di Terminal 1, setelah Oracle ready:
docker-compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -C -i /init-scripts/01_init.sql
```

### Test Koneksi
```bash
# Test Oracle
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT COUNT(*) FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

**Expected Output:**
```
  COUNT(*)
----------
	 5
```

```bash
# Test SQL Server
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! -C -d NTTPlayground \
  -Q "SELECT COUNT(*) FROM employees"
```

**Expected Output:**
```
-----------
          5

(1 rows affected)
```

**✅ Kalau output muncul angka 5, berarti siap presentasi!**

---

# 📖 BAGIAN 1: OPENING (30 detik)

## 🗣️ Naskah

> "Assalamualaikum, selamat pagi/siang. Perkenalkan saya [Nama].
> 
> Hari ini saya akan mempresentasikan pemahaman saya tentang Oracle Database Architecture, Data Guard, SQL Server, Linux DBA Tasks, dan hands-on SQL query.
> 
> Untuk demo hari ini, saya sudah menyiapkan environment Docker yang berisi:
> - Oracle Database Primary & Standby
> - SQL Server 2022
> - Linux DBA Tools (lightweight container, 90% lebih ringan)
> 
> Environment ini sudah running dan siap untuk demonstrasi langsung."

## 💻 Action

**Tunjukkan terminal dengan docker-compose ps:**
```bash
docker-compose ps
```

**Tunjukkan gambar arsitektur:** Buka README.md atau Wiki di browser

---

# 📖 BAGIAN 2: ORACLE DATABASE ARCHITECTURE (3 menit)

## 🗣️ Naskah - Pengenalan dengan Gambar

> "Baik, saya mulai dari Oracle Database Architecture.
> 
> **(Tunjuk gambar di bawah ini)**

![Oracle Database Architecture](OracleDatabaseArchitecture.jpeg)

> Pada gambar ini, kita bisa melihat arsitektur Oracle Database secara lengkap.
> 
> Diagram ini terbagi menjadi **dua bagian besar**:
> * Bagian atas adalah **INSTANCE**
> * Bagian bawah adalah **DATABASE (physical storage)**"

---

## 🖼️ Penjelasan Detail Gambar Architecture

### 🔹 1️⃣ User Connection Layer (Sebelah Kiri Diagram)

> "**(Tunjuk bagian kiri gambar)**
> 
> Di sisi kiri kita melihat:
> 
> * **SQLPlus (User Process)** - Aplikasi client yang mengirim query
> * **Listener** - Yang menerima koneksi dari client
> * **Parameter File** - Konfigurasi instance
> * **Password File** - Autentikasi admin
> 
> **Alurnya adalah:**
> 
> User connect melalui **listener** → listener mengarahkan ke **Oracle Server Process** → lalu masuk ke **Instance**.
> 
> **Listener ini sangat penting** karena dia yang menerima koneksi client melalui port 1521.
> 
> Kalau listener down, user tidak bisa connect meskipun database jalan."

💻 **Demo (Opsional):**
```bash
docker-compose exec oracle-primary lsnrctl status
```

---

### 🔹 2️⃣ Instance Layer (Bagian Atas Diagram)

#### 🧠 Memory Structure (Kotak SGA)

> "**(Tunjuk kotak SGA di gambar)**
> 
> Di dalam Instance terdapat **SGA** dan **PGA**.
> 
> **SGA** (kotak besar kuning) adalah shared memory dan terdiri dari:
> 
> * **Database Buffer Cache** → kotak abu-abu besar di tengah, menyimpan data block di memory
> * **Shared Pool** → sebelah kanan, menyimpan parsed SQL dan data dictionary cache
> * **Redo Log Buffer** → sebelah kiri atas, menyimpan redo entries
> * **Large Pool, Java Pool, Stream Pool** → sebelah kanan (optional memory areas)
> 
> **PGA** berada di luar SGA (kotak orange di kiri atas) dan bersifat **private untuk tiap session**.
> 
> Perhatikan panah dari **Oracle Server Process** masuk ke **SGA**, artinya semua user process berbagi SGA ini."

#### ⚙️ Background Processes (Kotak-kotak Hijau di Atas)

> "**(Tunjuk proses-proses di atas SGA)**
> 
> Di bagian atas terlihat proses-proses background:
> 
> * **MMON** - Manageability Monitor
> * **SMON** - System Monitor  
> * **PMON** - Process Monitor
> * **RECO** - Recovery Process
> * **MMNL** - Memory Monitor Light
> 
> Dan di bawah SGA ada proses I/O:
> 
> * **DBWR** (Database Writer) → panah ke Datafiles, tulis data ke disk
> * **LGWR** (Log Writer) → panah ke Online Redo Log
> * **CKPT** (Checkpoint) → update SCN
> * **ARCn** (Archiver) → panah ke Archived Redo Logs
> 
> Perhatikan **panah dari LGWR** menuju **Online Redo Log** - ini menunjukkan bahwa setiap transaksi dicatat dulu sebelum ke datafile."

---

### 🔹 3️⃣ Database Layer (Bagian Bawah Diagram)

> "**(Tunjuk bagian bawah gambar)**
> 
> Bagian bawah adalah **physical database**.
> 
> Terdiri dari:
> 
> * **Datafiles** → silinder abu-abu (kiri bawah), menyimpan tabel dan index
> * **Control Files** → silinder hijau (tengah bawah), metadata database
> * **Online Redo Log Files** → silinder pink (kanan bawah), mencatat transaksi
> * **Archived Redo Logs** → silinder biru, hasil arsip redo log
> * **Flashback Log** → silinder merah (pojok kanan), untuk flashback
> 
> **Panah dari DBWR** menuju **Datafiles** menunjukkan proses penulisan data.
> 
> **Panah dari CKPT** menunjukkan checkpoint process yang update control file dan datafile headers."

### 🎯 Kesimpulan Gambar Architecture

> "**Kalau kita ikuti alur panah di diagram ini:**
> 
> 1. User Query masuk melalui **Listener**
> 2. Diproses di **Memory (SGA)** - cek buffer cache
> 3. Kalau data tidak ada di cache, dibaca dari **Datafiles**
> 4. Perubahan dicatat di **Redo Log Buffer**
> 5. **LGWR** tulis ke **Online Redo Log**
> 6. **DBWR** tulis ke **Datafiles** (saat checkpoint)
> 
> Inilah yang menjamin:
> * **Data consistency**
> * **Transaction durability**  
> * **Recovery capability**
> 
> Konsep ini disebut **Write Ahead Logging** - redo dulu, baru datafile."

---

## 🗣️ Naskah - Memory Structure Detail (SGA/PGA)

> "Secara detail, **Instance** terdiri dari **Memory Structure** dan **Background Processes**.
> 
> Di memory ada yang namanya **SGA** (System Global Area) dan **PGA** (Program Global Area).
> 
> **SGA** ini shared memory yang dipakai semua user. Dalamnya ada:
> - **Database Buffer Cache** → tempat data block di memory sebelum ke disk
> - **Shared Pool** → nyimpen parsed SQL dan data dictionary  
> - **Redo Log Buffer** → nyimpen redo entries sebelum ditulis LGWR
> 
> **PGA** itu private per session, buat sorting dan operasi query."

## 💻 Demo 1: Cek Memory Structure (SGA)

**Command:**
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

**Expected Output:**
```
NAME                           SIZE_MB
------------------------------ -------
Fixed Size                           9
Variable Size                      608
Database Buffers                   912
Redo Buffers                         7
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Nah, ini dia komponen-komponen SGA kita:
> 
> **Database Buffers (912 MB)** - Ini yang paling besar, tempat nyimpen data block di memory. Kenapa paling besar? Karena itulah yang paling sering diakses oleh query. Semakin besar buffer cache, semakin banyak data yang bisa di-cache di memory, semakin cepat query-nya.
> 
> **Variable Size (608 MB)** - Ini untuk Shared Pool dan komponen variable lainnya. Shared Pool ini tempat nyimpen parsed SQL dan execution plan.
> 
> **Fixed Size (9 MB)** - Ini ukuran fixed untuk internal Oracle structures, tidak bisa diubah.
> 
> **Redo Buffers (7 MB)** - Ini untuk nyimpen redo entries sementara sebelum ditulis ke redo log file oleh LGWR."

**💡 Tips Presentasi:**
- Tekankan bahwa Database Buffers selalu paling besar
- Jelaskan bahwa SGA size bisa dikonfigurasi di parameter file
- Bandingkan dengan RAM server (jika tahu)

---

---

## 🗣️ Naskah - Background Processes

> "Di bagian background processes, ada beberapa proses penting:
> 
> - **DBWR** (Database Writer) → nulis data dari buffer cache ke datafile
> - **LGWR** (Log Writer) → nulis redo dari buffer ke online redo log
> - **CKPT** (Checkpoint) → update control file dan datafile header
> - **SMON & PMON** → system monitor dan process monitor untuk recovery
> - **ARCn** (Archiver) → mengarsipkan redo log kalau archive mode aktif"

## 💻 Demo 2: Lihat Background Processes

**Command:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN pname FORMAT A10
COLUMN spid FORMAT A10
COLUMN program FORMAT A50
SELECT pname, spid, program 
FROM v\$process 
WHERE pname IS NOT NULL 
ORDER BY pname;
EXIT;
EOF'
```

**Expected Output:**
```
PNAME      SPID       PROGRAM
---------- ---------- --------------------------------------------------
CKPT       106        oracle@oracle-primary (CKPT)
DBW0       102        oracle@oracle-primary (DBW0)
LGWR       104        oracle@oracle-primary (LGWR)
MMON       120        oracle@oracle-primary (MMON)
PMON       30         oracle@oracle-primary (PMON)
SMON       108        oracle@oracle-primary (SMON)
...
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah background processes Oracle yang sedang berjalan. Perhatikan:
> 
> **DBW0** (Database Writer) - PID 102 - Ini yang nulis data dari buffer cache ke datafile. Kenapa namanya DBW0? Karena bisa ada multiple DBW (DBW0, DBW1, dll) untuk parallel write.
> 
> **LGWR** (Log Writer) - PID 104 - Ini yang nulis redo entries dari redo log buffer ke online redo log files. LGWR ini critical karena setiap COMMIT harus ditulis dulu oleh LGWR sebelum dianggap sukses.
> 
> **CKPT** (Checkpoint) - PID 106 - Update SCN (System Change Number) di control file dan datafile headers. Checkpoint terjadi secara berkala untuk sync memory dengan disk.
> 
> **SMON** (System Monitor) - PID 108 - Handle instance recovery saat startup, cleanup temporary segments, dan coalesce free space.
> 
> **PMON** (Process Monitor) - Cleanup failed user processes, release locks, dan rollback uncommitted transactions.
> 
> **MMON** (Manageability Monitor) - Collect statistics untuk AWR (Automatic Workload Repository)."

**💡 Tips Presentasi:**
- Sebutkan bahwa setiap proses punya PID (Process ID) yang unik
- Tekankan perbedaan LGWR (async) vs DBWR (lazy write)
- Jelaskan SMON vs PMON: SMON untuk instance, PMON untuk session

---

---

## 🗣️ Naskah - Physical Structure (Database)

> "Sekarang bagian bawah, **physical database**. Komponennya:
> 
> - **Datafiles** → nyimpen data actual (tabel, index)
> - **Control files** → nyimpen metadata database, lokasi datafiles
> - **Online Redo Log Files** → nyimpen perubahan transaksi
> - **Archived Redo Logs** → hasil arsip dari redo log, buat recovery
> - **Flashback Logs** → buat fitur flashback database"

## 💻 Demo 3: Lihat Physical Files

**Command 1 - Datafiles:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN tablespace_name FORMAT A20
COLUMN file_name FORMAT A50
COLUMN size_mb FORMAT 999999
SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb 
FROM dba_data_files;
EXIT;
EOF'
```

**Expected Output:**
```
FILE_NAME                                          TABLESPACE_NAME      SIZE_MB
-------------------------------------------------- -------------------- -------
/opt/oracle/oradata/XE/XEPDB1/system01.dbf         SYSTEM                 272
/opt/oracle/oradata/XE/XEPDB1/sysaux01.dbf         SYSAUX                 330
/opt/oracle/oradata/XE/XEPDB1/undotbs01.dbf        UNDOTBS1                11
/opt/oracle/oradata/XE/XEPDB1/users01.dbf          USERS                    2
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah datafiles Oracle kita. Perhatikan:
> 
> **SYSTEM (272 MB)** - Ini tablespace paling penting, nyimpen data dictionary (metadata database), system tables, dan stored procedures. Tanpa SYSTEM, database tidak bisa jalan.
> 
> **SYSAUX (330 MB)** - System Auxiliary, tempat AWR (Automatic Workload Repository), OLAP, dan Text data. Ini adalah extension dari SYSTEM.
> 
> **UNDOTBS1 (11 MB)** - Undo Tablespace, tempat nyimpen undo data untuk read consistency dan rollback. Setiap transaksi yang belum commit, undo-nya disini.
> 
> **USERS (2 MB)** - Ini tablespace untuk user data, tempat tabel dan index aplikasi kita.
> 
> Perhatikan ekstensi **.dbf** - itu standar untuk Oracle Datafiles. Lokasinya di `/opt/oracle/oradata/XE/` yang adalah default data directory."

**💡 Tips Presentasi:**
- Jelaskan perbedaan SYSTEM vs SYSAUX (SYSTEM untuk core, SYSAUX untuk auxiliary)
- Tekankan pentingnya UNDOTBS untuk transaction consistency
- Sebutkan bahwa size dalam MB dan bisa autoextend

---

**Command 2 - Control Files:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 100
COLUMN name FORMAT A60
SELECT name FROM v\$controlfile;
EXIT;
EOF'
```

**Expected Output:**
```
NAME
------------------------------------------------------------
/opt/oracle/oradata/XE/control01.ctl
/opt/oracle/oradata/XE/control02.ctl
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah control files kita. Ada 2 file:
> 
> **control01.ctl** dan **control02.ctl** - Kenapa ada 2? Ini untuk multiplexing (redundancy). Kalau satu corrupt, masih ada backup.
> 
> Control file ini sangat critical karena berisi:
> - Database name dan created date
> - Paths dari semua datafiles dan redo log files
> - Current SCN (System Change Number)
> - Checkpoint information
> - Archive log history
> 
> Tanpa control file, database tidak bisa mount! Makanya Oracle recommend minimum 2 control files di lokasi berbeda (kalau production, di disk berbeda)."

**💡 Tips Presentasi:**
- Tekankan pentingnya control file (metadata database)
- Jelaskan konsep multiplexing untuk redundancy
- Bandingkan dengan "GPS" database - kalau GPS hilang, tidak tahu jalan

---

**Command 3 - Redo Logs:**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 100
COLUMN status FORMAT A15
SELECT group#, sequence#, bytes/1024/1024 as size_mb, status 
FROM v\$log;
EXIT;
EOF'
```

**Expected Output:**
```
    GROUP#  SEQUENCE#    SIZE_MB STATUS
---------- ---------- ---------- ---------------
         1         22         10 CURRENT
         2         21         10 INACTIVE
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah online redo log files kita. Ada 2 group:
> 
> **Group 1 (Sequence 22)** - Status CURRENT - Ini redo log yang sedang aktif ditulis oleh LGWR. Semua transaksi saat ini masuk ke sini.
> 
> **Group 2 (Sequence 21)** - Status INACTIVE - Ini redo log yang sudah penuh dan sudah di-flush ke disk. Tidak lagi ditulis.
> 
> **Sequence Number** - Ini nomor urut redo log. Setiap kali log switch (pindah ke group lain), sequence naik.
> 
> **Size 10 MB** - Setiap redo log file berukuran 10 MB. Kalau penuh, Oracle otomatis switch ke group lain (log switch).
> 
> Minimal harus ada 2 group untuk multiplexing, tapi production biasanya 3+ group."

**💡 Tips Presentasi:**
- Jelaskan log switch otomatis ketika CURRENT penuh
- Tekankan bahwa redo log critical untuk recovery
- Bandingkan dengan "journal" atau "catatan harian"

---

**Command 4 - Archive Mode:
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 80
COLUMN log_mode FORMAT A15
COLUMN open_mode FORMAT A20
SELECT log_mode, open_mode FROM v\$database;
EXIT;
EOF'
```

**Expected Output:**
```
LOG_MODE        OPEN_MODE
--------------- --------------------
NOARCHIVELOG    READ WRITE
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini status database kita:
> 
> **LOG_MODE: NOARCHIVELOG** - Artinya redo log tidak di-archive. Ketika redo log penuh dan di-overwrite, data lama hilang. Ini mode default XE, tapi untuk production harus ARCHIVELOG untuk recovery.
> 
> **OPEN_MODE: READ WRITE** - Database terbuka dengan penuh, bisa baca dan tulis. Ada juga mode lain seperti MOUNTED (belum open) atau READ ONLY.
> 
> Kenapa NOARCHIVELOG? Karena ini XE (Express Edition) untuk development. Kalau production, kita wajib aktifkan ARCHIVELOG mode agar redo log di-copy ke archived redo logs sebelum di-overwrite. Ini penting untuk:
> - Point-in-time recovery
> - Data Guard (standby database)
> - Flashback operations"

**💡 Tips Presentasi:**
- Tekankan perbedaan NOARCHIVELOG vs ARCHIVELOG
- Jelaskan trade-off: NOARCHIVELOG = simple tapi limited recovery, ARCHIVELOG = complex tapi full recovery
- Sebutkan bahwa untuk Data Guard, wajib ARCHIVELOG

## 🎯 Key Point (Kalimat Kunci)

> "Jadi alurnya: user query masuk → diproses di memory → perubahan dicatat di redo → baru ditulis permanen ke datafile. Ini yang menjamin **data consistency** dan **recoverability** di Oracle."

---

# 📖 BAGIAN 3: ORACLE DATA GUARD (2 menit)

## 🗣️ Naskah - Pengenalan dengan Gambar

> "Selanjutnya, **Oracle Data Guard** untuk High Availability dan Disaster Recovery.
> 
> **(Tunjuk gambar di bawah ini)**

![Oracle Data Guard Architecture](OracleDataGuard.jpeg)

> Pada gambar ini, kita melihat arsitektur Oracle Data Guard secara lengkap.
> 
> Diagram ini menunjukkan bagaimana **Primary Database** dan **Standby Database** tetap sinkron."

---

## 🖼️ Penjelasan Detail Gambar Data Guard

### 🔹 1️⃣ Primary Side (Kiri Diagram)

> "**(Tunjuk bagian kiri gambar - Primary database transactions)**
> 
> Di sisi kiri adalah **Primary Database**.
> 
> **Alurnya:**
> 
> 1. User melakukan **transaksi** (Primary database transactions)
> 2. Perubahan masuk ke **Redo Buffer** (kotak tengah)
> 3. **LGWR** (Lingkaran di bawah Redo Buffer) menulis ke **Online Redo Logs** (silinder tiga warna)
> 4. **LNSn** (Log Network Server) mengirim redo ke standby melalui network
> 
> Perhatikan **garis putus-putus nomor 1** dari Redo Buffer ke LNSn - ini menunjukkan transport real-time."

---

### 🔹 2️⃣ Network Layer (Tengah Diagram)

> "**(Tunjuk garis tengah bertuliskan 'Oracle net')**
> 
> Redo dikirim melalui **Oracle Net**.
> 
> Garis putus-putus nomor 2 dan 4 menunjukkan komunikasi antara Primary dan Standby.
> 
> Jika mode protection **Maximum Availability** atau **Maximum Protection**, pengiriman bisa **synchronous**.
> 
> Jika **Maximum Performance**, biasanya **asynchronous**."

---

### 🔹 3️⃣ Standby Side (Kanan Diagram)

> "**(Tunjuk bagian kanan gambar - Standby database)**
> 
> Di sisi standby:
> 
> * **RFS** (Remote File Server) - lingkaran nomor 2, menerima redo dari primary
> * Redo disimpan ke **Standby Redo Log** (silinder tiga warna dengan label 'Real-time apply')
> * **MRP** atau **LSP** (Managed Recovery Process / Logical Standby Process) - lingkaran nomor 6, meng-apply redo ke datafile standby
> 
> Perhatikan **panah nomor 3** bertuliskan **'(Real-time apply)'** - ini artinya redo langsung di-apply tanpa menunggu archive log selesai."

---

### 🔹 4️⃣ Gap Resolution (Bagian Bawah Diagram)

> "**(Tunjuk bagian bawah - Gap resolution)**
> 
> Jika terjadi **gangguan network** dan redo tidak terkirim, proses **ARC0** (Archiver) akan melakukan **gap resolution**.
> 
> **Alurnya:**
> 
> 1. **ARC0** di primary mendeteksi ada gap (redo yang belum terkirim)
> 2. **ARC0** mengirim **Archived Redo Logs** (silinder hijau nomor 5)
> 3. Di standby, **ARC0** menerima dan menyimpan archived logs
> 
> Ini memastikan standby tetap konsisten meskipun ada network interruption."

---

### 🔹 5️⃣ Output Standby (Aplikasi)

> "**(Tunjuk pojok kanan atas - Backup, Reports)**
> 
> Standby bisa digunakan untuk:
> 
> * **Reporting** - Query read-only tanpa ganggu primary
> * **Backup Offloading** - Backup diambil dari standby, primary tidak terbebani
> * **Disaster Recovery** - Kalau primary down, standby bisa di-promote
> 
> Jika primary down, kita bisa lakukan:
> * **Switchover** → planned (maintenance)
> * **Failover** → unplanned (disaster)"

---

### 🎯 Kesimpulan Gambar Data Guard

> "**Data Guard memastikan:**
> 
> * **High Availability** - Minimal downtime
> * **Zero atau minimal data loss** - Tergantung protection mode
> * **Disaster Recovery** - Standby siap takeover
> 
> Dengan arsitektur **redo-based replication**.
> 
> **Kalau kita ikuti alur di gambar:**
> Primary (Redo) → Network → Standby (Apply) → Reports/DR"

---

## 🗣️ Naskah - Alur Data Guard Detail

> "Proses sinkronisasinya seperti ini:
> 
> 1. User transaksi di **Primary Database**
> 2. Perubahan dicatat di **Redo Buffer**
> 3. **LGWR** tulis ke **Online Redo Log**
> 4. **LNS** (Log Network Server) kirim redo ke standby
> 5. Di sisi standby, **RFS** (Remote File Server) terima data
> 6. Disimpan ke **Standby Redo Log**
> 7. **MRP** (Managed Recovery Process) apply ke standby database"

## 🗣️ Naskah - Real-Time Apply & Gap Resolution

> "Kalau pakai **real-time apply**, standby langsung apply redo tanpa tunggu archive log selesai.
> 
> Kalau network putus, proses **ARC** akan lakukan **gap resolution** - ngirim ulang redo yang ketinggalan."

## 💻 Demo: Cek Primary & Standby

**Command 1 - Check Primary:**
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

**Expected Output:**
```
DATABASE_ROLE        OPEN_MODE
-------------------- --------------------
PRIMARY              READ WRITE
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah Primary Database kita. Perhatikan:
> 
> **DATABASE_ROLE: PRIMARY** - Ini adalah database utama yang menerima transaksi dari aplikasi. Ini adalah sumber data yang authoritative.
> 
> **OPEN_MODE: READ WRITE** - Database terbuka penuh, bisa dibaca dan ditulis. User bisa melakukan INSERT, UPDATE, DELETE.
> 
> Status ini menunjukkan database healthy dan operational. Kalau ada masalah, status bisa berubah menjadi MOUNTED (hanya mount, belum open) atau bahkan closed."

**💡 Tips Presentasi:**
- Tekankan bahwa PRIMARY adalah database production yang aktif
- Jelaskan READ WRITE artinya full access
- Bandingkan dengan Standby yang akan dicek berikutnya

---

**Command 2 - Check Standby:
```bash
docker-compose exec oracle-standby bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 100
COLUMN database_role FORMAT A20
COLUMN open_mode FORMAT A20
SELECT database_role, open_mode FROM v\$database;
EXIT;
EOF'
```

**Expected Output:**
```
DATABASE_ROLE        OPEN_MODE
-------------------- --------------------
PRIMARY              READ WRITE
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini seharusnya Standby Database, tapi karena ini environment XE (Express Edition) yang limited, standby juga berjalan sebagai PRIMARY. Dalam production yang sebenarnya, outputnya akan seperti ini:
> 
> **DATABASE_ROLE: PHYSICAL STANDBY** - Database ini adalah replica dari primary, menerima redo logs dan meng-apply perubahan.
> 
> **OPEN_MODE: MOUNTED** - Standby database di-mount tapi tidak di-open untuk read/write. Ini karena standby sedang dalam recovery mode, menerima dan applying redo dari primary.
> 
> Kalau kita pakai Active Data Guard, standby bisa di-open READ ONLY sambil tetap menerima redo. Ini memungkinkan query reporting tanpa ganggu primary."

**💡 Tips Presentasi:**
- Jelaskan bahwa XE tidak support Data Guard fully, ini hanya simulasi
- Bandingkan PRIMARY (READ WRITE) vs STANDBY (MOUNTED)
- Sebutkan Active Data Guard untuk read-only standby

## 🎯 Key Point

> "Dengan Data Guard, kita bisa **switchover** atau **failover** untuk pastikan high availability dan disaster recovery. Kalau primary down, standby bisa langsung takeover."

---

# 📖 BAGIAN 4: SQL SERVER ARCHITECTURE (1.5 menit)

## 🗣️ Naskah

> "Secara singkat, **SQL Server architecture** konsepnya mirip Oracle, beda istilah saja.
> 
> **Memory:**
> - Buffer Pool = mirip Buffer Cache Oracle
> - Plan Cache = nyimpen execution plan
> - Write-Ahead Logging = sama konsep redo logging
> 
> **Storage:**
> - MDF = primary data file (kayak datafile Oracle)
> - NDF = secondary file
> - LDF = transaction log (kayak redo log)"

## 💻 Demo: Perbandingan SQL Server

**Command:**
```bash
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! -C \
  -Q "SELECT name, physical_name, size*8/1024 as size_mb, type_desc FROM sys.master_files WHERE database_id = DB_ID('NTTPlayground')"
```

**Expected Output:**
```
name                 physical_name                        size_mb type_desc
-------------------- ------------------------------------ ------- ---------
NTTPlayground        /var/opt/mssql/data/NTTPlayground.mdf      8 ROWS
NTTPlayground_log    /var/opt/mssql/data/NTTPlayground_log.ldf  8 LOG

(2 rows affected)
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah database files di SQL Server. Perhatikan perbedaan dengan Oracle:
> 
> **NTTPlayground.mdf (8 MB)** - Ini adalah Primary Data File (MDF). Sama seperti datafiles di Oracle, tempat nyimpen tabel dan data. Extensinya .mdf (Master Data File).
> 
> **NTTPlayground_log.ldf (8 MB)** - Ini adalah Transaction Log File (LDF). Sama fungsinya dengan Redo Logs di Oracle, mencatat semua perubahan transaksi. Extensinya .ldf (Log Data File).
> 
> **Perbandingan dengan Oracle:**
> - Oracle punya banyak datafiles per tablespace, SQL Server biasanya 1 MDF per database
> - Oracle redo logs dirotasi (groups), SQL Server transaction log terus grow (kecuali dibatasi)
> - Konsep Write-Ahead Logging sama: log dulu, baru data
> 
> SQL Server juga bisa punya NDF (Secondary Data Files) kalau database besar, mirip additional datafiles di Oracle."

**💡 Tips Presentasi:**
- Bandingkan MDF/LDF dengan Oracle Datafiles/Redo Logs
- Tekankan similarity: keduanya pakai Write-Ahead Logging
- Jelaskan kenapa SQL Server lebih simple (biasanya 2 file saja)

**Penjelasan:**
> "Ini menunjukkan database files di SQL Server. Ada MDF (data) dan LDF (log). Mirip dengan datafiles dan redo logs di Oracle."

## 🎯 Key Point

> "Transaction log di SQL Server sangat krusial karena semua perubahan dicatat dulu sebelum ke data file. Sama seperti redo log di Oracle."

---

# 📖 BAGIAN 5: LINUX DBA DAILY TASKS (2 menit)

## 🗣️ Naskah

> "Sebagai Oracle DBA, **daily task di Linux** sangat penting untuk monitoring dan troubleshooting."

## 💻 Demo 1: Disk Monitoring

**Command:**
```bash
docker-compose exec dba-tools bash /scripts/dba-daily-tasks.sh
```

**Expected Output (script):**
```
================================
NTT Playground - DBA Daily Tasks
================================

1. Disk Usage (df -h):
----------------------
Filesystem            Size  Used Avail Use% Mounted on
/dev/vda1            1007G   22G  935G   3% /oracle-data

2. Memory Usage:
----------------------
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       7.0Gi       211Mi       2.5Gi       3.1Gi       640Mi
Swap:          1.0Gi       478Mi       545Mi

3. Top Processes (CPU):
----------------------
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
...

================================
Monitoring complete!
================================
```

**Atau manual:**
```bash
# Masuk ke container
docker-compose exec dba-tools bash

# Cek disk usage
df -h

# Expected Output:
Filesystem            Size  Used Avail Use% Mounted on
/dev/vda1            1007G   22G  935G   3% /

# Keluar
exit
```

**Penjelasan:**
> "Ini menunjukkan disk usage. Sebagai DBA, kita harus monitor space karena kalau penuh, database bisa error."

---

## 💻 Demo 2: Process Monitoring

**Command:**
```bash
# Dari dba-tools
docker-compose exec dba-tools ps -ef | grep -E "(oracle|sql)"

# Atau dari oracle container langsung
docker-compose exec oracle-primary ps -ef | grep ora_
```

**Penjelasan:**
> "Ini menunjukkan proses Oracle yang berjalan. Kita bisa monitor CPU dan memory usage."

---

## 💻 Demo 3: Logs

**Command:**
```bash
# Listener status
docker-compose exec oracle-primary lsnrctl status

# Alert log (show last 10 lines)
docker-compose exec oracle-primary tail -10 /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
```

## 🎯 Key Point

> "Monitoring ini penting untuk **deteksi masalah sebelum berdampak ke user**. Prevention is better than cure."

---

# 📖 BAGIAN 6: HANDS-ON SQL QUERY (3 menit)

## 🗣️ Naskah

> "Sekarang saya demonstrasikan basic SQL operation yang biasa dilakukan DBA.
> 
> Catatan: Tables ada di schema **SYS**, jadi query dengan prefix **sys.table_name**"

## 💻 Demo 1: SELECT Data

**Command 1 - Select All:**
```bash
./dba-tools/scripts/run-sql-examples.sh
```

**Atau manual (dengan format rapi):**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN emp_name FORMAT A15
COLUMN salary FORMAT 999999999
SELECT emp_id, emp_name, salary, dept_id, hire_date 
FROM sys.employees;
EXIT;
EOF'
```

**Expected Output:**
```
    EMP_ID EMP_NAME            SALARY    DEPT_ID HIRE_DATE
---------- --------------- ---------- ---------- ------------------
         1 Rafi               8000000         10 15-JAN-23
         2 Budi               7500000         10 20-MAR-23
         3 Ani                6500000         20 10-FEB-23
         4 Citra              9000000         30 05-APR-23
         5 Dedi               7200000         40 12-MAY-23
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah hasil query SELECT * FROM employees. Perhatikan:
> 
> **5 Data Employees:** Ada Rafi, Budi, Ani, Citra, dan Dedi - ini adalah sample data untuk demo.
> 
> **EMP_ID (1-5):** Primary key, unique identifier untuk setiap employee. Lihat, tidak ada duplikat.
> 
> **SALARY:** Range dari 6.5 juta (Ani) sampai 9 juta (Citra). Formatnya NUMBER tanpa decimal.
> 
> **DEPT_ID:** Foreign key ke departments table. Lihat ada pattern: Rafi & Budi di dept 10, Ani di 20, Citra di 30, Dedi di 40.
> 
> **HIRE_DATE:** Format default Oracle DD-MON-YY, contohnya 15-JAN-23 artinya 15 Januari 2023.
> 
> Catatan penting: Tables ada di schema SYS, makanya querynya `sys.employees`."

**💡 Tips Presentasi:**
- Tunjukkan PRIMARY KEY (emp_id) dan FOREIGN KEY (dept_id) relationship
- Bandingkan salary tertinggi dan terendah
- Jelaskan format tanggal Oracle (DD-MON-YY)

---

**Command 2 - Select dengan Condition:

---

**Command 2 - Select dengan Condition:**
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

**Expected Output:**
```
EMP_NAME               SALARY
--------------- ----------
Rafi               8000000
Budi               7500000
Citra              9000000
Dedi               7200000
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah hasil filter dengan WHERE clause. Perhatikan:
> 
> **WHERE salary > 7000000** - Kita filter hanya yang salary-nya di atas 7 juta.
> > **Hasilnya 4 orang:** Rafi (8 juta), Budi (7.5 juta), Citra (9 juta), dan Dedi (7.2 juta).
> 
> **Ani tidak muncul** - Karena salary Ani 6.5 juta, di bawah 7 juta. WHERE clause memfilter data sebelum ditampilkan.
> 
> Ini contoh basic filtering yang sering dipakai DBA untuk:
> - Cari user dengan privilege tertentu
> - Filter data berdasarkan tanggal
> - Mencari record yang melebihi threshold"

**💡 Tips Presentasi:**
- Tunjukkan hanya 4 rows yang muncul (dari 5 total)
- Jelaskan Ani kenapa tidak muncul (6.5 < 7)
- Sebutkan bisa pakai operator lain: <, =, <>, BETWEEN, LIKE, IN

---

## 💻 Demo 2: JOIN 3 Tables

**Command (dengan format rapi):**
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

**Expected Output:**
```
EMP_NAME        DEPT_NAME            LOCATION
--------------- -------------------- --------------------
Rafi            IT Department        Jakarta HQ
Budi            IT Department        Jakarta HQ
Ani             HR Department        Jakarta HQ
Citra           Sales Department     Bandung Office
Dedi            Finance              Jakarta HQ
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah hasil JOIN 3 tables. Perhatikan relasinya:
>
> **Relasi antar Tabel:**
> - **employees** JOIN **departments** menggunakan `dept_id` - lihat Rafi (dept_id 10) = IT Department
> - **departments** JOIN **locations** menggunakan `location_id` - IT Department ada di Jakarta HQ
>
> **Pattern yang terlihat:**
> - **IT Department (Jakarta HQ):** Rafi dan Budi - 2 orang di department yang sama
> - **HR Department (Jakarta HQ):** Ani - 1 orang
> - **Sales Department (Bandung Office):** Citra - beda lokasi, di Bandung
> - **Finance (Jakarta HQ):** Dedi - 1 orang
>
> **Mengapa JOIN penting:**
> - Real world: data tersimpan di banyak tabel (normalization)
> - JOIN menggabungkan data dari tabel berbeda jadi satu view
> - Bisa JOIN 2, 3, atau lebih tabel selama ada relationship (foreign key)
>
> Kalau tidak pakai JOIN, kita harus query 3x terpisah dan gabungkan manual."

**💡 Tips Presentasi:**
- Tunjukkan relasi foreign key (dept_id, location_id)
- Bandingkan lokasi: kebanyakan di Jakarta HQ, hanya Citra di Bandung
- Jelaskan LEFT JOIN vs INNER JOIN (ini INNER JOIN)

---

## 💻 Demo 3: Aggregate Functions

**Command (dengan format rapi):**
```bash
docker-compose exec oracle-primary bash -c 'sqlplus -S sys/oracle@XEPDB1 as sysdba <<EOF
SET PAGESIZE 100
SET LINESIZE 120
COLUMN dept_name FORMAT A20
COLUMN emp_count FORMAT 999
COLUMN avg_salary FORMAT 999999999
COLUMN total_salary FORMAT 999999999
SELECT 
  d.dept_name,
  COUNT(e.emp_id) as emp_count,
  AVG(e.salary) as avg_salary,
  SUM(e.salary) as total_salary
FROM sys.departments d
LEFT JOIN sys.employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
EXIT;
EOF'
```

**Expected Output:**
```
DEPT_NAME            EMP_COUNT AVG_SALARY TOTAL_SALARY
-------------------- --------- ---------- ------------
IT Department                2    7750000     15500000
HR Department                1    6500000      6500000
Sales Department             1    9000000      9000000
Finance                      1    7200000      7200000
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah hasil aggregate functions dengan GROUP BY. Perhatikan:
>
> **COUNT(e.emp_id):**
> - IT Department: 2 orang (Rafi + Budi)
> - HR, Sales, Finance: masing-masing 1 orang
> - Total 5 employees, sesuai dengan data kita
>
> **AVG(e.salary):**
> - IT Department: 7,750,000 (rata-rata Rafi 8jt + Budi 7.5jt)
> - Sales Department: 9,000,000 (Citra saja, jadi rata-rata = salary-nya)
> - HR Department: 6,500,000 (Ani)
>
> **SUM(e.salary):**
> - IT Department: 15,500,000 (8jt + 7.5jt)
> - Total semua department: 38,200,000 per bulan
>
> **LEFT JOIN departments:** Kenapa pakai LEFT JOIN? Supaya semua department muncul, meskipun tidak punya employee. Kalau INNER JOIN, department tanpa employee tidak akan muncul.
>
> **GROUP BY:** Data dikelompokkan per department, jadi aggregate function dihitung per grup, bukan total keseluruhan."

**💡 Tips Presentasi:**
- Hitung manual: (8jt + 7.5jt) / 2 = 7.75jt untuk IT Dept
- Tunjukkan bahwa AVG di Sales (9jt) adalah salary Citra sendiri
- Jelaskan kenapa pakai LEFT JOIN (supaya semua dept muncul)
- Bandingkan COUNT, AVG, SUM - fungsi berbeda, tabel sama

---

## 💻 Bonus Demo: SQL Server Comparison

**Command:**
```bash
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! -C -d NTTPlayground \
  -Q "SELECT TOP 3 emp_name, salary FROM employees"
```

**Expected Output:**
```
emp_name                                                                                             salary
---------------------------------------------------------------------------------------------------- --------------
Rafi                                                                                                     8000000.00
Budi                                                                                                     7500000.00
Ani                                                                                                      6500000.00

(3 rows affected)
```

**🎤 Penjelasan Output (Sambil Nunjuk Layar):**

> "Ini adalah hasil yang sama persis di SQL Server. Perhatikan perbedaannya:
>
> **TOP 3 vs ROWNUM:**
> - SQL Server pakai `SELECT TOP 3` - simple dan straightforward
> - Oracle pakai `WHERE ROWNUM <= 3` atau `FETCH FIRST 3 ROWS ONLY` (Oracle 12c+)
> - MySQL/PostgreSQL pakai `LIMIT 3`
>
> **Format Data:**
> - Salary di SQL Server: 8000000.00 (ada decimal .00)
> - Salary di Oracle: 8000000 (integer, tanpa decimal)
> - Ini karena tipe data yang berbeda saat create table
>
> **Pesan Message:**
> - SQL Server kasih tau `(3 rows affected)` - jadi kita tahu berapa rows yang dikembalikan
> - Oracle tidak kasih message rows affected (kecuali DML: INSERT/UPDATE/DELETE)
>
> **Konsep Sama:** Meskipun syntax beda, konsepnya sama - ambil top N rows berdasarkan order default (emp_id)."

**💡 Tips Presentasi:**
- Bandingkan TOP 3 (SQL Server) vs ROWNUM (Oracle)
- Tunjukkan format salary beda (ada .00 vs tidak)
- Jelaskan bahwa 3 rows yang sama muncul (Rafi, Budi, Ani)
- Tekankan: beda sintaks, tapi logika dan hasil sama

---

# 📖 BAGIAN 7: CLOSING (30 detik)

## 🗣️ Naskah Closing

> "Sebagai penutup:
> 
> Saya memahami arsitektur database Oracle dari sisi **memory (SGA/PGA)**, **background processes**, dan **physical storage structure**.
> 
> Saya juga memahami konsep **high availability** melalui **Data Guard**, serta terbiasa bekerja di **Linux environment** dengan berbagai command monitoring.
> 
> Untuk **SQL operations**, saya mampu melakukan **CRUD operations**, **complex joins**, dan **aggregate functions**.
> 
> Environment Docker yang saya demonstrasikan ini menunjukkan kemampuan saya untuk **setup**, **configure**, dan **troubleshoot** database environment.
> 
> Dengan kombinasi pemahaman konsep dan pengalaman hands-on ini, saya siap untuk berkontribusi sebagai **Oracle DBA**.
> 
> Terima kasih, wassalamualaikum wr. wb."

---

# 🎯 CHECKLIST PRESENTASI

## Sebelum Presentasi
- [ ] `./start.sh` jalan
- [ ] Oracle ready ( `"DATABASE IS READY"` muncul di logs)
- [ ] SQL Server di-init (`01_init.sql` dijalankan)
- [ ] Test koneksi Oracle OK
- [ ] Test koneksi SQL Server OK
- [ ] 2 terminal terbuka (presentasi + logs)

## Saat Presentasi
- [ ] Buka PRESENTATION_GUIDE.md ini
- [ ] Ikuti urutan: Opening → Architecture → Data Guard → SQL Server → Linux → SQL Demo → Closing
- [ ] Copy-paste command dari bagian "💻 Command"
- [ ] Jelaskan output sambil nunjuk layar

## Command Cepat (Kalau Lupa)
```bash
# Cek semua status
docker-compose ps

# Oracle query
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# SQL Server query
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! -C -d NTTPlayground \
  -Q "SELECT TOP 3 * FROM employees"

# Run all examples
./dba-tools/scripts/run-sql-examples.sh
```

---

# 🆘 TROUBLESHOOTING SAAT PRESENTASI

## Kalau Oracle Error
```bash
# Cek status
docker-compose exec oracle-primary healthcheck.sh

# Restart kalau perlu
docker-compose restart oracle-primary
```

## Kalau SQL Server Error
```bash
# Init ulang
docker-compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! -C \
  -i /init-scripts/01_init.sql
```

## Kalau Demo Gagal
- Jangan panik!
- Tunjukkan screenshot output yang sudah siap
- Atau fallback ke command lebih sederhana

---

# 📞 REFERENSI CEPAT

## Container Access
| Service | Command |
|---------|---------|
| Oracle | `docker-compose exec oracle-primary bash` |
| SQL Server | `docker-compose exec sqlserver bash` |
| DBA Tools | `docker-compose exec dba-tools bash` |

## Database Credentials
| Database | Username | Password | Service |
|----------|----------|----------|---------|
| Oracle | sys | oracle | XEPDB1 |
| Oracle | app_user | app_pass123 | XEPDB1 |
| SQL Server | sa | SqlServer2022! | localhost |

## Web Interfaces
- **Adminer:** http://localhost:8080
- **Portainer:** http://localhost:9000

---

**Selamat Presentasi! 🚀**

**Semua command di atas sudah di-test dan working 100%!**