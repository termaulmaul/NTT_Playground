# =====================================================
# NTT PLAYGROUND - QUICK REFERENCE CHEAT SHEET
# For Oracle DBA Presentation
# =====================================================

## START / STOP
./start.sh                    # Start all services
./start.sh --reset           # Start fresh (delete data)
./stop.sh                    # Stop services (keep data)
./stop.sh --clean            # Stop and delete data

## ACCESS CONTAINERS
docker-compose exec dba-tools bash                 # Access DBA tools container
docker-compose exec oracle-primary bash           # Access Oracle container
docker-compose exec sqlserver bash                # Access SQL Server container

## CONNECT TO DATABASES

# Oracle (via DBA Tools)
sqlplus app_user/app_pass123@ORACLE_PRIMARY      # As app user
sqlplus sys/oracle@ORACLE_PRIMARY as sysdba      # As SYSDBA
./scripts/connect-oracle.sh                       # Using helper script

# SQL Server (via DBA Tools)
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P SqlServer2022! -d NTTPlayground
./scripts/connect-sqlserver.sh                    # Using helper script

## RUN SCRIPTS

# Oracle
sqlplus app_user/app_pass123@ORACLE_PRIMARY @/dba-scripts/01_architecture_monitoring.sql
sqlplus app_user/app_pass123@ORACLE_PRIMARY @/dba-scripts/02_sql_examples.sql
sqlplus app_user/app_pass123@ORACLE_PRIMARY @/dba-scripts/03_performance_monitoring.sql
sqlplus app_user/app_pass123@ORACLE_PRIMARY @/dba-scripts/04_backup_recovery.sql

# SQL Server
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P SqlServer2022! -i /init-scripts/02_monitoring.sql

# Helper Scripts (from dba-tools container)
./scripts/dba-daily-tasks.sh      # Linux monitoring commands
./scripts/run-sql-examples.sh     # Run all SQL examples

## LINUX DBA COMMANDS (inside dba-tools)

# Disk Usage
df -h                           # Check disk space
du -sh /oracle-data            # Check directory size

# Process Monitoring
ps -ef | grep ora_             # Oracle processes
top                             # System resources
htop                            # Interactive process viewer (if available)

# Memory
free -h                         # Memory usage
cat /proc/meminfo              # Detailed memory info

# Network
netstat -tulpn                 # Network connections (if available)
ss -tulpn                      # Alternative to netstat
ping oracle-primary            # Test connectivity
telnet oracle-primary 1521     # Test Oracle port

# Logs
docker-compose logs -f oracle-primary      # Follow Oracle logs
docker-compose logs -f sqlserver           # Follow SQL Server logs

## SQL EXAMPLES (from presentation)

-- SELECT
SELECT * FROM employees;
SELECT emp_name, salary FROM employees WHERE salary > 7000000;

-- JOIN 3 Tables
SELECT e.emp_name, d.dept_name, l.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN locations l ON d.location_id = l.location_id;

-- Aggregates
SELECT d.dept_name, COUNT(e.emp_id), AVG(e.salary), SUM(e.salary)
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- UPDATE
UPDATE employees SET salary = salary + 1000000 WHERE emp_id = 1;
COMMIT;

-- DELETE
DELETE FROM employees WHERE emp_id = 1;
COMMIT;

## ORACLE ARCHITECTURE QUERIES

-- Instance Info
SELECT instance_name, host_name, version, status FROM v$instance;

-- Memory (SGA)
SELECT name, value/1024/1024 as size_mb FROM v$sga;

-- Background Processes
SELECT pname, spid, program FROM v$process WHERE pname IS NOT NULL;

-- Datafiles
SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb 
FROM dba_data_files;

-- Control Files
SELECT name FROM v$controlfile;

-- Redo Logs
SELECT group#, sequence#, bytes/1024/1024 as size_mb, status 
FROM v$log;

-- Archive Mode
SELECT log_mode, open_mode FROM v$database;

## WEB INTERFACES

Adminer (Database GUI):     http://localhost:8080
  - System: Oracle
  - Server: oracle-primary:1521/XEPDB1
  - Username: app_user
  - Password: app_pass123

Portainer (Containers):     http://localhost:9000
  - Create admin account on first run

## DOCKER COMPOSE COMMANDS

docker-compose up -d                    # Start services
docker-compose down                     # Stop services
docker-compose down -v                  # Stop and remove volumes
docker-compose ps                       # Check status
docker-compose logs -f [service]        # Follow logs
docker-compose restart [service]        # Restart service
docker-compose exec [service] [cmd]     # Execute command

## PRESENTATION FLOW

1. Start: ./start.sh
2. Wait for "Oracle database is ready!"
3. Open dba-tools: docker-compose exec dba-tools bash
4. Demo Architecture: sqlplus ... @01_architecture_monitoring.sql
5. Demo SQL: ./scripts/run-sql-examples.sh
6. Demo Linux: ./scripts/dba-daily-tasks.sh
7. Compare Oracle vs SQL Server
8. Stop: ./stop.sh

## TROUBLESHOOTING

# Oracle won't start
docker-compose logs oracle-primary | tail -50

# Reset everything
docker-compose down -v
./start.sh --reset

# Check container health
docker-compose exec oracle-primary healthcheck.sh

# Low memory
# Increase Docker memory limit to 4GB minimum

## PORTS

1521    Oracle Primary
1522    Oracle Standby
1433    SQL Server
8080    Adminer (DB GUI)
9000    Portainer (Container Management)