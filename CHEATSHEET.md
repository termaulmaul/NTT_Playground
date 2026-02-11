# =====================================================
# NTT PLAYGROUND - QUICK REFERENCE CHEAT SHEET
# For Oracle DBA Presentation (Updated for Apple Silicon)
# =====================================================

## 🚀 START / STOP
./start.sh                    # Start all services
./start.sh --reset           # Start fresh (delete data)
./stop.sh                    # Stop services (keep data)
./stop.sh --clean            # Stop and delete data

## 📦 ACCESS CONTAINERS

docker-compose exec dba-tools bash                 # Access DBA tools (Linux utilities)
docker-compose exec oracle-primary bash           # Access Oracle container directly
docker-compose exec sqlserver bash                # Access SQL Server container

## 🔗 CONNECT TO DATABASES (New Workflow)

### Oracle (Direct from oracle-primary container)
docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba
docker-compose exec oracle-primary sqlplus app_user/app_pass123@XEPDB1
./scripts/connect-oracle.sh                       # Helper script (recommended)

### SQL Server (Direct from sqlserver container)
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -d NTTPlayground
./scripts/connect-sqlserver.sh                    # Helper script

## 📜 RUN SCRIPTS

### Oracle (via oracle-primary container)
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/container-entrypoint-initdb.d/01_create_tables.sql
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/dba-scripts/01_architecture_monitoring.sql
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba @/dba-scripts/02_sql_examples.sql
./scripts/run-sql-examples.sh                     # Run all SQL examples

### SQL Server
docker-compose exec -T sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SqlServer2022! -d NTTPlayground -i /init-scripts/02_monitoring.sql

### Helper Scripts (run from dba-tools container)
docker-compose exec dba-tools bash -c "./scripts/dba-daily-tasks.sh"      # Linux monitoring
docker-compose exec dba-tools bash -c "./scripts/run-sql-examples.sh"     # SQL examples

## 🐧 LINUX DBA COMMANDS (inside dba-tools)

# Disk Usage
df -h                           # Check disk space
du -sh /                        # Check directory size

# Process Monitoring
ps -ef | grep -E "(oracle|sql)" # Database processes
top                             # System resources

# Memory
free -h                         # Memory usage

# Network
ss -tulpn                      # Network connections
ping oracle-primary            # Test connectivity
nc -zv oracle-primary 1521     # Test Oracle port

# Logs
docker-compose logs -f oracle-primary      # Follow Oracle logs
docker-compose logs -f sqlserver           # Follow SQL Server logs

## 📝 SQL EXAMPLES (Important: Use SYS schema prefix)

-- SELECT (Note: tables owned by SYS)
SELECT * FROM sys.employees;
SELECT emp_name, salary FROM sys.employees WHERE salary > 7000000;

-- JOIN 3 Tables
SELECT e.emp_name, d.dept_name, l.location
FROM sys.employees e
JOIN sys.departments d ON e.dept_id = d.dept_id
JOIN sys.locations l ON d.location_id = l.location_id;

-- Aggregates
SELECT d.dept_name, COUNT(e.emp_id), AVG(e.salary), SUM(e.salary)
FROM sys.departments d
LEFT JOIN sys.employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- UPDATE
UPDATE sys.employees SET salary = salary + 1000000 WHERE emp_id = 1;
COMMIT;

-- DELETE
DELETE FROM sys.employees WHERE emp_id = 1;
COMMIT;

## 🏗️ ORACLE ARCHITECTURE QUERIES

-- Instance Info
SELECT instance_name, host_name, version, status FROM v\$instance;

-- Memory (SGA)
SELECT name, value/1024/1024 as size_mb FROM v\$sga;

-- Background Processes
SELECT pname, spid, program FROM v\$process WHERE pname IS NOT NULL;

-- Datafiles
SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb 
FROM dba_data_files;

-- Control Files
SELECT name FROM v\$controlfile;

-- Redo Logs
SELECT group#, sequence#, bytes/1024/1024 as size_mb, status 
FROM v\$log;

-- Archive Mode
SELECT log_mode, open_mode FROM v\$database;

## 🌐 WEB INTERFACES

Adminer (Database GUI):     http://localhost:8080
  - System: Oracle
  - Server: oracle-primary:1521/XEPDB1
  - Username: sys (as sysdba)
  - Password: oracle

Portainer (Containers):     http://localhost:9000
  - Create admin account on first run

## 🔧 DOCKER COMPOSE COMMANDS

docker-compose up -d                    # Start services
docker-compose down                     # Stop services
docker-compose down -v                  # Stop and remove volumes
docker-compose ps                       # Check status
docker-compose logs -f [service]        # Follow logs
docker-compose restart [service]        # Restart service
docker-compose exec [service] [cmd]     # Execute command

## 📋 PRESENTATION FLOW (Updated)

1. Start: ./start.sh
2. Wait for "Oracle database is ready!"
3. Test connection: docker-compose exec oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba
4. Demo Architecture: docker-compose exec -T oracle-primary sqlplus ... @01_architecture_monitoring.sql
5. Demo SQL: ./scripts/run-sql-examples.sh
6. Demo Linux: docker-compose exec dba-tools bash -c "./scripts/dba-daily-tasks.sh"
7. Stop: ./stop.sh

## 🎯 KEY DIFFERENCES (Apple Silicon)

- dba-tools: Lightweight Debian Slim (130MB), no Oracle Client
- Oracle connection: Via oracle-primary container directly
- SQL Server tools: In sqlserver container, not dba-tools
- Tables: Owned by SYS, query with sys.table_name
- Architecture: ARM64 native containers

## 🚪 PORTS

1521    Oracle Primary
1522    Oracle Standby
1433    SQL Server
8080    Adminer (DB GUI)
9000    Portainer (Container Management)

## ⚠️ TROUBLESHOOTING

# Check Oracle status
docker-compose exec oracle-primary healthcheck.sh

# Check if tables exist
docker-compose exec oracle-primary sqlplus -S sys/oracle@XEPDB1 as sysdba <<< "SELECT table_name FROM dba_tables WHERE owner='SYS' AND table_name IN ('EMPLOYEES','DEPARTMENTS');"

# Reset everything
docker-compose down -v
./start.sh --reset

# Low memory (need 4GB minimum for Oracle)
docker stats