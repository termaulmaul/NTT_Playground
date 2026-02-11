#!/bin/bash
# =====================================================
# Run SQL Examples from Presentation
# Demonstrates CRUD operations and Joins
# Note: Tables are owned by SYS, using sys. prefix
# =====================================================

echo "================================"
echo "Running SQL Examples"
echo "================================"

# Connect as sys and run examples via oracle-primary container
docker-compose exec -T oracle-primary sqlplus sys/oracle@XEPDB1 as sysdba <<'EOF'

PROMPT =================================
PROMPT 1. SELECT All Employees
PROMPT =================================
SELECT * FROM sys.employees;

PROMPT
PROMPT =================================
PROMPT 2. SELECT with Condition
PROMPT =================================
SELECT emp_name, salary FROM sys.employees WHERE salary > 7000000;

PROMPT
PROMPT =================================
PROMPT 3. JOIN 3 Tables
PROMPT =================================
SELECT 
    e.emp_name,
    d.dept_name,
    l.location
FROM sys.employees e
JOIN sys.departments d ON e.dept_id = d.dept_id
JOIN sys.locations l ON d.location_id = l.location_id;

PROMPT
PROMPT =================================
PROMPT 4. Aggregate Functions
PROMPT =================================
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as emp_count,
    AVG(e.salary) as avg_salary,
    SUM(e.salary) as total_salary
FROM sys.departments d
LEFT JOIN sys.employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

PROMPT
PROMPT =================================
PROMPT SQL Examples Complete!
PROMPT =================================

EXIT;
EOF