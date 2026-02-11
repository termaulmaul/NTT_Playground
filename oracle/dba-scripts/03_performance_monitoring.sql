-- =====================================================
-- Oracle Performance Monitoring & Tuning
-- =====================================================

-- 1. Check Tablespace Usage
SELECT 
    df.tablespace_name,
    ROUND(df.bytes/1024/1024, 2) as total_mb,
    ROUND((df.bytes - NVL(fs.bytes, 0))/1024/1024, 2) as used_mb,
    ROUND(NVL(fs.bytes, 0)/1024/1024, 2) as free_mb,
    ROUND(100 * (df.bytes - NVL(fs.bytes, 0)) / df.bytes, 2) as pct_used
FROM (
    SELECT tablespace_name, SUM(bytes) bytes 
    FROM dba_data_files 
    GROUP BY tablespace_name
) df
LEFT JOIN (
    SELECT tablespace_name, SUM(bytes) bytes 
    FROM dba_free_space 
    GROUP BY tablespace_name
) fs ON df.tablespace_name = fs.tablespace_name
ORDER BY pct_used DESC;

-- 2. Check Top SQL by Elapsed Time
SELECT * FROM (
    SELECT 
        sql_id,
        sql_text,
        elapsed_time/1000000 as elapsed_seconds,
        executions,
        ROUND(elapsed_time/1000000/NULLIF(executions,0), 4) as avg_seconds_per_exec
    FROM v$sql
    WHERE executions > 0
    ORDER BY elapsed_time DESC
)
WHERE ROWNUM <= 10;

-- 3. Check Long Running Queries
SELECT 
    s.sid,
    s.serial#,
    s.username,
    s.program,
    t.sql_id,
    t.sql_exec_start,
    ROUND((SYSDATE - t.sql_exec_start) * 24 * 60, 2) as minutes_running
FROM v$session s
JOIN v$sql_monitor t ON s.sql_id = t.sql_id
WHERE s.status = 'ACTIVE'
AND s.username IS NOT NULL
AND (SYSDATE - t.sql_exec_start) * 24 * 60 > 1;

-- 4. Check Locked Objects
SELECT 
    l.session_id,
    l.lock_type,
    l.mode_held,
    l.mode_requested,
    o.object_name,
    o.object_type
FROM dba_ddl_locks l
JOIN dba_objects o ON l.name = o.object_name
WHERE l.session_id IN (
    SELECT sid FROM v$session WHERE status = 'ACTIVE'
);

-- 5. Check Wait Events
SELECT 
    event,
    total_waits,
    total_timeouts,
    time_waited/100 as time_waited_seconds
FROM v$system_event
WHERE wait_class != 'Idle'
ORDER BY time_waited DESC
FETCH FIRST 10 ROWS ONLY;

-- 6. Check PGA Usage
SELECT 
    name,
    value/1024/1024 as size_mb
FROM v$pgastat
WHERE name IN ('maximum PGA allocated', 'total PGA allocated', 'total PGA inuse');

COMMIT;