# 🎓 NTT Playground - Oracle DBA Docker Environment

**Docker Compose Stack untuk Presentasi & Belajar Oracle Database, SQL Server, dan Linux DBA Tasks**

> 🍎 **Apple Silicon Ready!** Native ARM64 support  
> 📚 **Dokumentasi Lengkap:** [Wiki](https://github.com/termaulmaul/NTT_Playground/wiki)  
> 📺 **Untuk Presentasi:** Lihat [NASKAH.md](ntt_playground/NASKAH.md) - Script presentasi 15 menit

---

## 📸 Oracle Architecture

![Oracle Database Architecture](OracleDatabaseArchitecture.jpeg)

*Oracle Database Architecture - Instance dan Database Structure*

## 📸 Oracle Data Guard

![Oracle Data Guard](OracleDataGuard.jpeg)

*Oracle Data Guard Architecture - High Availability & Disaster Recovery*

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/termaulmaul/NTT_Playground.git
cd NTT_Playground

# Start environment (130MB lightweight image)
./start.sh

# Tunggu 2-3 menit sampai Oracle ready
# Buka http://localhost:8080 untuk Adminer
```

**Full documentation:** [GitHub Wiki](https://github.com/termaulmaul/NTT_Playground/wiki)

---

## 📚 Dokumentasi Wiki

| Dokumen | Deskripsi |
|---------|-----------|
| [Home](https://github.com/termaulmaul/NTT_Playground/wiki) | Overview dan navigasi |
| [Quick Start](https://github.com/termaulmaul/NTT_Playground/wiki/Quick-Start) | Panduan 5 menit |
| [Architecture](https://github.com/termaulmaul/NTT_Playground/wiki/Architecture) | Oracle Architecture dengan diagram |
| [Data Guard](https://github.com/termaulmaul/NTT_Playground/wiki/Data-Guard) | HA/DR dengan visualisasi |
| [Commands](https://github.com/termaulmaul/NTT_Playground/wiki/Commands) | Reference command lengkap |
| [Presentation](https://github.com/termaulmaul/NTT_Playground/wiki/Presentation) | Naskah presentasi 15 menit |
| [Troubleshooting](https://github.com/termaulmaul/NTT_Playground/wiki/Troubleshooting) | Solusi masalah umum |

---

## 🎯 Fitur Utama

- ✅ **Apple Silicon Ready** - Native ARM64 support
- ✅ **Lightweight** - 90% lebih ringan (130MB vs 1.5GB)
- ✅ **Complete Stack** - Oracle, SQL Server, Linux tools
- ✅ **Documentation** - Wiki lengkap dengan diagram
- ✅ **Presentation Ready** - Script presentasi 15 menit

---

## 🗄️ Services

| Service | Description | Port |
|---------|-------------|------|
| **oracle-primary** | Oracle Database XE 21c | 1521 |
| **oracle-standby** | Oracle Standby/DR | 1522 |
| **sqlserver** | SQL Server 2022 Express | 1433 |
| **dba-tools** | Linux utilities (130MB) | - |
| **adminer** | Database GUI | 8080 |
| **portainer** | Container management | 9000 |

---

## 🖥️ Demo Commands

```bash
# Connect to Oracle
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Query data
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM sys.employees;' | sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Check architecture
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/dba-scripts/01_architecture_monitoring.sql
```

---

## 📖 Local Files

- [README.md](README.md) - Dokumentasi utama
- [NASKAH.md](ntt_playground/NASKAH.md) - Script presentasi
- [CHEATSHEET.md](CHEATSHEET.md) - Quick reference
- [Wiki](.github/wiki/) - Full documentation

---

**Selamat belajar! 🚀**