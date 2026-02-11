# Troubleshooting

Solusi untuk masalah umum yang mungkin terjadi saat menggunakan NTT Playground.

---

## 📋 Daftar Isi

- [Startup Issues](#startup-issues)
- [Oracle Database](#oracle-database-issues)
- [SQL Server](#sql-server-issues)
- [Connection Problems](#connection-problems)
- [Performance Issues](#performance-issues)
- [Data Issues](#data-issues)
- [Reset Everything](#nuclear-option-reset-everything)

---

## 🚀 Startup Issues

### `./start.sh` hangs atau lama

**Symptom:** Script tidak selesai atau stuck di "Waiting for Oracle"

**Solution:**
```bash
# Cek apa yang terjadi di background
docker-compose logs -f oracle-primary

# Tunggu sampai muncul pesan:
# "DATABASE IS READY TO USE!"
```

**Expected time:** 2-3 menit untuk first startup

### Port already in use

**Symptom:**
```
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:1521 -> 0.0.0.0:0: listen tcp 0.0.0.0:1521: bind: address already in use
```

**Solution:**
```bash
# Cek apa yang pakai port 1521
lsof -i :1521
# atau
netstat -tulpn | grep 1521

# Stop service yang conflict
# atau ganti port di docker-compose.yml
```

### Container name already exists

**Symptom:**
```
Conflict. The container name "/portainer" is already in use
```

**Solution:**
```bash
# Remove existing container
docker stop portainer
docker rm portainer

# Atau hapus semua container
docker-compose down
./start.sh
```

---

## 🛢️ Oracle Database Issues

### ORA-12514: TNS:listener does not know of service

**Symptom:**
```
ORA-12514: TNS:listener does not currently know of service requested in connect descriptor
```

**Cause:** Database belum fully started atau service name salah

**Solution:**
```bash
# Tunggu sampai Oracle ready
docker-compose logs oracle-primary | grep "DATABASE IS READY"

# Check available services
docker-compose exec oracle-primary bash -c \
  "lsnrctl status | grep Service"

# Use correct service name: XEPDB1 (bukan XE)
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba
```

### ORA-01017: invalid username/password

**Symptom:**
```
ORA-01017: invalid username/password; logon denied
```

**Cause:** 
- app_user belum dibuat
- Password salah
- Database baru start, init scripts belum jalan

**Solution:**
```bash
# Connect sebagai SYSDBA dulu
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Buat user manual
CREATE USER app_user IDENTIFIED BY app_pass123;
GRANT CREATE SESSION TO app_user;
GRANT SELECT ANY TABLE TO app_user;
GRANT INSERT ANY TABLE TO app_user;
GRANT UPDATE ANY TABLE TO app_user;
GRANT DELETE ANY TABLE TO app_user;
EXIT;
```

### ORA-01950: no privileges on tablespace

**Symptom:**
```
ORA-01950: no privileges on tablespace 'USERS'
```

**Solution:**
```bash
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba <<EOF
GRANT UNLIMITED TABLESPACE TO app_user;
EXIT;
EOF
```

### Tables tidak ditemukan

**Symptom:**
```
ORA-00942: table or view does not exist
```

**Cause:** Tables di schema SYS, perlu prefix atau init scripts belum jalan

**Solution:**
```bash
# Check tables exist
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT owner, table_name FROM dba_tables WHERE table_name=\"EMPLOYEES\";' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"

# Jika tidak ada, run init script
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/container-entrypoint-initdb.d/01_create_tables.sql

# Query dengan schema prefix
docker-compose exec oracle-primary bash -c \
  "echo 'SELECT * FROM sys.employees;' | \
   sqlplus -S sys/oracle@XEPDB1 as sysdba"
```

### Oracle crash atau tidak respond

**Symptom:** Command hang atau error connection

**Solution:**
```bash
# Restart Oracle container
docker-compose restart oracle-primary

# Atau hard restart
docker-compose stop oracle-primary
docker-compose start oracle-primary

# Check logs
docker-compose logs oracle-primary | tail -50
```

---

## 🗄️ SQL Server Issues

### Login failed for user 'sa'

**Symptom:**
```
Login failed for user 'sa'
```

**Cause:** SQL Server masih initializing

**Solution:**
```bash
# Tunggu 30-60 detik
docker-compose logs sqlserver | grep "Recovery is complete"

# Test connection
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -Q "SELECT @@VERSION"
```

### Database 'NTTPlayground' does not exist

**Symptom:**
```
Cannot open database "NTTPlayground" requested by the login
```

**Solution:**
```bash
# Run init script
docker-compose exec -T sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P SqlServer2022! \
  -i /init-scripts/01_init.sql
```

---

## 🔌 Connection Problems

### Cannot connect from host machine

**Symptom:** SQL*Plus atau sqlcmd dari host tidak bisa connect

**Solution:**
```bash
# Gunakan docker-compose exec (recommended)
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# Atau check port mapping
docker-compose ps

# Test dengan telnet
telnet localhost 1521
telnet localhost 1433
```

### dba-tools container - command not found

**Symptom:** sqlplus tidak ditemukan di dba-tools

**Cause:** dba-tools sekarang lightweight (tanpa Oracle Client)

**Solution:**
```bash
# Connect via oracle-primary container
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba

# dba-tools untuk Linux utilities saja
docker-compose exec dba-tools bash
df -h
ps -ef
```

---

## ⚡ Performance Issues

### Out of memory

**Symptom:** Containers exit dengan error OOM

**Solution:**
```bash
# Check memory usage
docker stats

# Increase Docker Desktop memory limit
# Mac: Docker Desktop > Settings > Resources > Memory (set to 8GB)

# Atau untuk Linux, tambah swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Slow performance

**Symptom:** Query lambat atau timeout

**Solution:**
```bash
# Check resource usage
docker stats --no-stream

# Restart services
docker-compose restart

# Check logs untuk error
docker-compose logs --tail=100
```

### Build process terlalu lama

**Symptom:** `docker-compose build` berlangsung sangat lama

**Solution:**
```bash
# Gunakan cache
./start.sh  # (sudah include build)

# Atau parallel build
export DOCKER_BUILDKIT=1
docker-compose build --parallel
```

---

## 📊 Data Issues

### Data hilang setelah restart

**Symptom:** Tables atau data tidak ada setelah `docker-compose down`

**Cause:** Menggunakan `docker-compose down -v` (volumes dihapus)

**Solution:**
```bash
# Jangan pakai -v flag
docker-compose down  # (tanpa -v)

# Kalau sudah hilang, init ulang
docker-compose up -d
./scripts/run-sql-examples.sh
```

### Data tidak consistent

**Symptom:** Hasil query aneh atau tidak sesuai

**Solution:**
```bash
# Check data corruption
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba <<EOF
ANALYZE TABLE sys.employees VALIDATE STRUCTURE;
ANALYZE TABLE sys.departments VALIDATE STRUCTURE;
EXIT;
EOF

# Kalau corrupt, reset database
./stop.sh --clean
./start.sh
```

---

## ☢️ Nuclear Option: Reset Everything

**Gunakan jika semua solusi di atas tidak berhasil:**

```bash
# 1. Stop semua
docker-compose down -v

# 2. Hapus semua images (opsional)
docker rmi ntt_playground-dba-tools

# 3. Hapus cache
docker system prune -f

# 4. Start fresh
./start.sh

# 5. Tunggu sampai ready
docker-compose logs -f oracle-primary | grep "DATABASE IS READY"

# 6. Run init scripts manual jika perlu
docker-compose exec -T oracle-primary \
  sqlplus sys/oracle@XEPDB1 as sysdba \
  @/container-entrypoint-initdb.d/01_create_tables.sql
```

---

## 🐛 Debug Commands

### Check container health
```bash
# Status semua containers
docker-compose ps

# Detail status
docker-compose exec oracle-primary healthcheck.sh

# Resource usage
docker stats

# Logs
docker-compose logs oracle-primary | tail -100
docker-compose logs sqlserver | tail -50
```

### Check network
```bash
# Docker network
docker network inspect ntt-network

# Container IPs
docker-compose exec dba-tools ping oracle-primary -c 3
docker-compose exec dba-tools ping sqlserver -c 3

# Ports
docker-compose exec dba-tools nc -zv oracle-primary 1521
docker-compose exec dba-tools nc -zv sqlserver 1433
```

### Check volumes
```bash
# List volumes
docker volume ls

# Inspect
docker volume inspect oracle-primary-data

# Size
docker system df -v
```

---

## 🆘 Masih Bermasalah?

Jika tidak ada yang berhasil:

1. **Collect info:**
```bash
# Save diagnostic info
docker-compose ps > diagnostic.txt
docker-compose logs >> diagnostic.txt 2>&1
docker stats --no-stream >> diagnostic.txt
cat diagnostic.txt | pbcopy  # Copy ke clipboard
```

2. **Create issue di GitHub dengan info diagnostic**

3. **Fallback:** Gunakan Adminer (http://localhost:8080) untuk query

---

**Semoga sukses! 🍀**