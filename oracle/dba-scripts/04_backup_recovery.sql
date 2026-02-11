-- =====================================================
-- Oracle Backup & Recovery Scripts
-- For Presentation Demo
-- =====================================================

-- 1. Check Archive Log Mode (Important for Backup Strategy)
SELECT 
    name,
    log_mode,
    open_mode,
    database_role,
    platform_name
FROM v$database;

-- 2. Check Archive Log Destination
SELECT 
    destination,
    status,
    binding,
    target
FROM v$archive_dest
WHERE status != 'INACTIVE';

-- 3. Check Recent Archive Logs
SELECT 
    sequence#,
    first_time,
    next_time,
    archived,
    status
FROM v$archived_log
WHERE first_time > SYSDATE - 1
ORDER BY sequence# DESC
FETCH FIRST 10 ROWS ONLY;

-- 4. RMAN Backup Commands (Run in RMAN, not SQL*Plus)
-- These are reference commands for presentation

/*
-- Full Database Backup
RMAN> BACKUP DATABASE;

-- Backup with Format
RMAN> BACKUP DATABASE FORMAT '/backup/%d_%T_%s_%p.bkp';

-- Backup Tablespace
RMAN> BACKUP TABLESPACE users;

-- Backup Controlfile
RMAN> BACKUP CURRENT CONTROLFILE;

-- Backup SPFILE
RMAN> BACKUP SPFILE;

-- Backup Archive Logs
RMAN> BACKUP ARCHIVELOG ALL;

-- Incremental Backup (Level 0)
RMAN> BACKUP INCREMENTAL LEVEL 0 DATABASE;

-- Backup with Compression
RMAN> BACKUP AS COMPRESSED BACKUPSET DATABASE;

-- Full Backup with Archive Logs
RMAN> RUN {
    BACKUP DATABASE;
    BACKUP ARCHIVELOG ALL;
    BACKUP CURRENT CONTROLFILE;
    BACKUP SPFILE;
}
*/

-- 5. Data Pump Export Commands (Reference)
/*
-- Full Schema Export
expdp app_user/app_pass123 DIRECTORY=DATA_PUMP_DIR DUMPFILE=app_user_full.dmp SCHEMAS=app_user LOGFILE=exp_app_user.log

-- Table Export
expdp app_user/app_pass123 DIRECTORY=DATA_PUMP_DIR DUMPFILE=employees.dmp TABLES=employees LOGFILE=exp_employees.log

-- Import
impdp app_user/app_pass123 DIRECTORY=DATA_PUMP_DIR DUMPFILE=app_user_full.dmp SCHEMAS=app_user LOGFILE=imp_app_user.log
*/

-- 6. Flashback Query Example
SELECT * FROM employees AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '10' MINUTE);

-- 7. Create Restore Point
CREATE RESTORE POINT before_presentation;

-- 8. Check Restore Points
SELECT 
    name,
    time,
    guarantee_flashback_database
FROM v$restore_point;

COMMIT;