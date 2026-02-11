# Oracle Data Guard

High Availability dan Disaster Recovery Solution untuk Oracle Database.

![Oracle Data Guard Architecture](images/OracleDataGuard.jpeg)

## 🎯 Tujuan Data Guard

- **High Availability (HA)** - Minimize downtime
- **Disaster Recovery (DR)** - Protection dari site failures
- **Data Protection** - Zero data loss option
- **Workload Distribution** - Offload backup/reporting ke standby

---

## 🏗️ Arsitektur Komponen

### Primary Database (Kiri)
Database produksi yang menerima transaksi dari aplikasi.

### Standby Database (Kanan)
Copy dari primary database yang selalu synchronized.

---

## 🔄 Alur Redo Transport (1-6)

| Step | Proses | Keterangan |
|------|--------|------------|
| **1** | User Transaction | User melakukan DML/DDL di Primary |
| **2** | Redo Buffer | Changes dicatat di memory (Redo Log Buffer) |
| **3** | LGWR | Log Writer menulis ke Online Redo Logs |
| **4** | LNSn | Log Network Server mengirim redo ke standby |
| **5** | Network | Transport via Oracle Net |
| **6** | RFS | Remote File Server menerima di Standby |

---

## 📦 Standby Components

### 1. Standby Redo Logs
- Menerima redo dari primary secara real-time
- Mirip dengan Online Redo Logs di primary

### 2. RFS (Remote File Server)
- Process yang menerima redo dari primary
- Menulis ke Standby Redo Logs

### 3. MRP (Managed Recovery Process)
- Apply redo ke standby database
- Dapat berjalan **real-time** atau **delayed**

### 4. ARC0 (Archiver)
- Mengarsipkan Standby Redo Logs ke Archived Logs
- Menangani **Gap Resolution**

---

## 🛡️ Gap Resolution (Step 5)

### Masalah
Ketika network interruption terjadi, redo logs mungkin tidak terkirim.

### Solusi
**ARC0** di primary mendeteksi gap dan mengirim archived logs yang tertinggal ke standby.

```
Primary                             Standby
-------                             -------
Archived Log 101 ────────────────→  (Missing 101)
Archived Log 102 ────────────────→  (Missing 102)
     ↑                                    ↑
   ARC0 detects gap                 Apply queued logs
   Sends archived logs              MRP applies changes
```

---

## ⚡ Real-Time Apply (Step 3)

### Tanpa Real-Time Apply
```
Primary:     Log Switch → Archive → Send → Apply
Standby:     Wait for complete archive file
```

### Dengan Real-Time Apply
```
Primary:     Write to Redo → Stream immediately
Standby:     Apply saat redo diterima (streaming)
Latency:     Hanya network latency (detik)
```

**Keuntungan:** Recovery Point Objective (RPO) mendekati nol.

---

## 🎭 Mode Data Guard

| Mode | Protection | Availability | Use Case |
|------|------------|--------------|----------|
| **Maximum Protection** | Zero data loss | High overhead | Critical systems |
| **Maximum Availability** | Zero data loss (async) | Good balance | Most applications |
| **Maximum Performance** | Minimal performance impact | Best performance | Non-critical, geographic DR |
| **Active Data Guard** | Read-only standby | Real-time reporting | Reporting offload |

---

## 🔄 Switchover vs Failover

### Switchover (Planned)
```
Primary ←→ Standby
   ↓
Graceful role reversal
   ↓
Standby → Primary
Primary → Standby
```
- **Zero data loss**
- **Reversible**
- Untuk: Maintenance, testing, migrations

### Failover (Unplanned)
```
Primary (Down)
     ↓
Standby promoted
     ↓
New Primary
```
- **Possible data loss** (if async)
- **Not reversible** (tanpa Flashback)
- Untuk: Primary failure, disasters

---

## 🖥️ Demo Commands

### Check Primary Database
```bash
docker-compose exec oracle-primary bash -c "echo 'SELECT database_role, open_mode FROM v\$database;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

**Expected Output:**
```
DATABASE_ROLE    OPEN_MODE
---------------- --------------------
PRIMARY          READ WRITE
```

### Check Standby Database
```bash
docker-compose exec oracle-standby bash -c "echo 'SELECT database_role, open_mode FROM v\$database;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

**Expected Output:**
```
DATABASE_ROLE        OPEN_MODE
-------------------- --------------------
PHYSICAL STANDBY     MOUNTED
```

### Check Log Transport Status
```bash
# Di Primary
docker-compose exec oracle-primary bash -c "echo 'SELECT dest_name, status, error FROM v\$archive_dest WHERE dest_id <= 2;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Check Apply Status (di Standby)
```bash
docker-compose exec oracle-standby bash -c "echo 'SELECT process, status, sequence# FROM v\$managed_standby;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

---

## 🎯 Key Points

✅ **Synchronous** - Tunggu acknowledgment dari standby  
✅ **Asynchronous** - Kirim tanpa tunggu acknowledgment (lebih cepat, risk data loss)  
✅ **AFFIRM** - Standby confirm write ke disk  
✅ **NOAFFIRM** - Standby tidak confirm (async mode)  
✅ **Lag** - Perbedaan time antara primary dan standby  
✅ **LNS** - Kirim redo secara real-time  
✅ **ARCH** - Kirim archived logs (fallback)

---

## 📊 Comparison: With vs Without Data Guard

| Scenario | Without Data Guard | With Data Guard |
|----------|-------------------|-----------------|
| Primary crash | Restore from backup (hours) | Failover (minutes) |
| Data loss | Last backup to crash time | Near zero (sync) / Minutes (async) |
| Maintenance | Downtime required | Switchover (zero downtime) |
| Reporting | Impact primary performance | Offload ke standby |

---

## 🔗 Related Topics

- [Architecture](Architecture) - Oracle Database Architecture
- [Commands](Commands) - Semua commands
- [Quick Start](Quick-Start) - Setup environment

---

**Selanjutnya: [Commands](Commands)**