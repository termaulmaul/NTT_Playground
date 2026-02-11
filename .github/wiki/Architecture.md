# Oracle Database Architecture

Overview lengkap arsitektur Oracle Database Instance dan Database.

![Oracle Database Architecture](images/OracleDatabaseArchitecture.jpeg)

## 📊 Komponen Utama

Oracle Database terbagi menjadi **dua bagian besar**:
1. **Instance** (Memory + Processes) - Bagian atas diagram
2. **Database** (Physical Files) - Bagian bawah diagram

---

## 🧠 Instance Components

### 1. Memory Structure

#### SGA (System Global Area)
Shared memory yang digunakan oleh semua user session:

| Component | Fungsi |
|-----------|--------|
| **Database Buffer Cache** | Menyimpan data blocks di memory sebelum ditulis ke disk |
| **Shared Pool** | Menyimpan parsed SQL statements dan data dictionary cache |
| **Redo Log Buffer** | Menyimpan redo entries sebelum ditulis oleh LGWR |
| **Large Pool** | Untuk backup/restore operations |
| **Java Pool** | Untuk Java execution |
| **Stream Pool** | Untuk Oracle Streams |

#### PGA (Program Global Area)
Memory private per user session untuk:
- Sorting operations
- Hash joins
- Bitmap merges

### 2. Background Processes

| Process | Kepanjangan | Fungsi |
|---------|-------------|--------|
| **DBWn** | Database Writer | Menulis data dari buffer cache ke datafiles |
| **LGWR** | Log Writer | Menulis redo dari log buffer ke online redo log |
| **CKPT** | Checkpoint | Mengupdate control file dan datafile headers |
| **SMON** | System Monitor | Instance recovery dan cleanup |
| **PMON** | Process Monitor | Cleanup failed user processes |
| **ARCn** | Archiver | Mengarsipkan redo logs ke archived logs |
| **MMON** | Manageability Monitor | AWR snapshots |

---

## 💾 Database (Physical Structure)

### 1. Datafiles
- Menyimpan actual data (tables, indexes, clusters)
- Setiap tablespace terdiri dari satu atau lebih datafiles

### 2. Control Files
- Metadata database (nama, created date, paths)
- Lokasi datafiles dan redo log files
- Recovery information

### 3. Online Redo Log Files
- Mencatat semua perubahan database
- Minimal 2 groups (multiplexing)
- Digunakan untuk recovery

### 4. Archived Redo Logs
- Copy dari online redo logs yang sudah penuh
- Diperlukan untuk point-in-time recovery

### 5. Other Files
- **Parameter File (spfile/pfile)** - Konfigurasi instance
- **Password File** - Autentikasi SYSDBA
- **Flashback Logs** - Untuk flashback database

---

## 🔄 Alur Kerja (Workflow)

```
User Query
    ↓
[Listener] → [Server Process]
                ↓
        [PGA - Private Memory]
                ↓
        Check [Shared Pool] (parsed SQL?)
                ↓
        Read [Data Dictionary Cache]
                ↓
        Access [Database Buffer Cache]
                ↓
        (Jika tidak ada) Read from [Datafiles]
                ↓
        Return Result to User
                ↓
        Log changes to [Redo Log Buffer]
                ↓
        [LGWR] writes to [Online Redo Logs]
                ↓
        [DBWn] writes to [Datafiles] (checkpoint)
```

---

## 🖥️ Demo Commands

### Cek Memory (SGA)
```bash
docker-compose exec oracle-primary bash -c "echo 'SELECT name, value/1024/1024 as size_mb FROM v\$sga;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Cek Background Processes
```bash
docker-compose exec oracle-primary bash -c "echo 'SELECT pname, spid, program FROM v\$process WHERE pname IS NOT NULL ORDER BY pname;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Cek Datafiles
```bash
docker-compose exec oracle-primary bash -c "echo 'SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb FROM dba_data_files;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Cek Control Files
```bash
docker-compose exec oracle-primary bash -c "echo 'SELECT name FROM v\$controlfile;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Cek Redo Logs
```bash
docker-compose exec oracle-primary bash -c "echo 'SELECT group#, sequence#, bytes/1024/1024 as size_mb, status FROM v\$log;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

---

## 🎯 Key Points

✅ **Instance** = Memory + Processes (temporary, bisa di-start/stop)  
✅ **Database** = Physical files (permanent, persistent storage)  
✅ **SGA** = Shared by all sessions  
✅ **PGA** = Private per session  
✅ **Durability** - Changes logged before applied  
✅ **Recovery** - Redo logs enable crash recovery

---

**Next: [Data Guard](Data-Guard)**