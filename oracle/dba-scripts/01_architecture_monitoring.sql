-- =====================================================
-- Oracle Architecture Monitoring Scripts
-- For Presentation & Learning
-- =====================================================

-- 1. Check Database Instance Information
SELECT 
    instance_name,
    host_name,
    version,
    status,
    database_status,
    startup_time
FROM v$instance;

-- 2. Check Memory Structures (SGA & PGA)
SELECT 
    name,
    value/1024/1024 as size_mb
FROM v$sga;

-- 3. Check SGA Components Detail
SELECT 
    pool,
    name,
    bytes/1024/1024 as size_mb
FROM v$sgastat
WHERE pool IS NOT NULL
ORDER BY pool, name;

-- 4. Check Buffer Cache Usage
SELECT 
    block_size,
    current_size,
    prev_size,
    db_block_gets,
    consistent_gets,
    physical_reads
FROM v$buffer_pool_statistics;

-- 5. Check Background Processes
SELECT 
    pname,
    pid,
    spid,
    username,
    program
FROM v$process
WHERE pname IS NOT NULL
ORDER BY pname;

-- 6. Check Database Files
SELECT 
    file_name,
    tablespace_name,
    bytes/1024/1024 as size_mb,
    status
FROM dba_data_files
ORDER BY tablespace_name;

-- 7. Check Control Files
SELECT name FROM v$controlfile;

-- 8. Check Online Redo Log Files
SELECT 
    group#,
    thread#,
    sequence#,
    bytes/1024/1024 as size_mb,
    archived,
    status
FROM v$log;

-- 9. Check Archive Log Mode
SELECT 
    log_mode,
    open_mode
FROM v$database;

-- 10. Check Current Sessions
SELECT 
    sid,
    serial#,
    username,
    machine,
    program,
    status
FROM v$session
WHERE username IS NOT NULL;

COMMIT;