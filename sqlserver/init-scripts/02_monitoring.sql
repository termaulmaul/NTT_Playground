-- =====================================================
-- SQL Server Architecture & Monitoring Scripts
-- For Oracle vs SQL Server Comparison
-- =====================================================

USE NTTPlayground;
GO

-- 1. Check Database Information
SELECT 
    name,
    database_id,
    create_date,
    compatibility_level,
    recovery_model_desc,
    state_desc
FROM sys.databases
WHERE name = 'NTTPlayground';

-- 2. Check Buffer Pool (Memory) Usage
SELECT 
    (COUNT(*) * 8) / 1024 AS BufferPool_MB
FROM sys.dm_os_buffer_descriptors;

-- 3. Check Memory Usage Details
SELECT 
    type,
    name,
    pages_kb/1024 AS size_mb
FROM sys.dm_os_memory_clerks
WHERE type LIKE '%BUFFER%'
ORDER BY pages_kb DESC;

-- 4. Check Database Files (similar to Oracle Datafiles)
SELECT 
    db.name AS database_name,
    mf.name AS logical_name,
    mf.physical_name,
    mf.type_desc,
    CAST(mf.size * 8 / 1024 AS DECIMAL(10,2)) AS size_mb
FROM sys.master_files mf
JOIN sys.databases db ON mf.database_id = db.database_id
WHERE db.name = 'NTTPlayground';

-- 5. Check Transaction Log (similar to Redo Log)
SELECT 
    db.name,
    mf.name,
    mf.physical_name,
    CAST(mf.size * 8 / 1024 AS DECIMAL(10,2)) AS size_mb,
    ls.log_reuse_wait_desc
FROM sys.master_files mf
JOIN sys.databases db ON mf.database_id = db.database_id
JOIN sys.databases ls ON db.database_id = ls.database_id
WHERE mf.type_desc = 'LOG'
AND db.name = 'NTTPlayground';

-- 6. Check Active Connections
SELECT 
    DB_NAME(dbid) AS database_name,
    COUNT(dbid) AS connections,
    loginame AS login_name
FROM sys.sysprocesses
WHERE DB_NAME(dbid) = 'NTTPlayground'
GROUP BY dbid, loginame;

-- 7. Check Wait Statistics
SELECT TOP 10
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE '%SLEEP%'
AND wait_type NOT LIKE '%IDLE%'
ORDER BY wait_time_ms DESC;

-- 8. Check Running Queries
SELECT 
    r.session_id,
    r.status,
    r.start_time,
    r.command,
    t.text AS query_text,
    r.cpu_time,
    r.total_elapsed_time,
    r.reads,
    r.writes,
    r.logical_reads
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50
ORDER BY r.cpu_time DESC;

-- 9. Check Index Usage
SELECT 
    OBJECT_NAME(s.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates,
    s.last_user_seek,
    s.last_user_scan
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE s.database_id = DB_ID('NTTPlayground')
ORDER BY s.user_seeks + s.user_scans DESC;

-- 10. Check Table Sizes
SELECT 
    t.name AS table_name,
    p.rows AS row_count,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS total_mb,
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS used_mb
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
GROUP BY t.name, p.rows
ORDER BY total_mb DESC;

GO