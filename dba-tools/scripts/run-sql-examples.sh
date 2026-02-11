#!/bin/bash
# =====================================================
# Run SQL Examples from Presentation
# Demonstrates CRUD operations and Joins
# =====================================================

echo "================================"
echo "Running SQL Examples"
echo "================================"

# Connect as app_user and run examples via oracle-primary container
docker-compose exec -T oracle-primary sqlplus app_user/app_pass123@XEPDB1 <<'EOF'

PROMPT =================================
PROMPT 1. SELECT All Employees
PROMPT =================================
SELECT * FROM employees;

PROMPT
PROMPT =================================
PROMPT 2. SELECT with Condition
PROMPT =================================
SELECT emp_name, salary FROM employees WHERE salary > 7000000;

PROMPT
PROMPT =================================
PROMPT 3. JOIN 3 Tables
PROMPT =================================
SELECT 
    e.emp_name,
    d.dept_name,
    l.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN locations l ON d.location_id = l.location_id;

PROMPT
PROMPT =================================
PROMPT 4. Aggregate Functions
PROMPT =================================
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as emp_count,
    AVG(e.salary) as avg_salary,
    SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

PROMPT
PROMPT =================================
PROMPT SQL Examples Complete!
PROMPT =================================

EXIT;
EOF