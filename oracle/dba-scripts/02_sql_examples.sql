-- =====================================================
-- Oracle DBA Daily Tasks & SQL Examples
-- For Presentation Hands-On
-- =====================================================

-- =====================================================
-- BASIC CRUD OPERATIONS
-- =====================================================

-- 1. Create Table
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(100) NOT NULL,
    salary NUMBER(12,2),
    dept_id NUMBER,
    hire_date DATE DEFAULT SYSDATE
);

-- 2. Insert Data
INSERT INTO employees VALUES (1, 'Rafi', 8000000, 10, TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO employees VALUES (2, 'Budi', 7500000, 10, SYSDATE);
INSERT INTO employees VALUES (3, 'Ani', 6500000, 20, SYSDATE);
COMMIT;

-- 3. Select All
SELECT * FROM employees;

-- 4. Select with Conditions
SELECT emp_name, salary 
FROM employees 
WHERE salary > 7000000;

-- 5. Update
UPDATE employees 
SET salary = salary + 1000000 
WHERE emp_id = 1;
COMMIT;

-- 6. Delete
DELETE FROM employees WHERE emp_id = 3;
COMMIT;

-- =====================================================
-- JOIN EXAMPLES
-- =====================================================

-- Join 3 Tables
SELECT 
    e.emp_name,
    d.dept_name,
    l.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN locations l ON d.location_id = l.location_id;

-- Left Join
SELECT 
    e.emp_name,
    d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- =====================================================
-- AGGREGATE FUNCTIONS
-- =====================================================

-- Count employees per department
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as employee_count,
    AVG(e.salary) as avg_salary,
    SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- =====================================================
-- SUBQUERIES
-- =====================================================

-- Employees with salary above average
SELECT emp_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- =====================================================
-- INDEX MANAGEMENT
-- =====================================================

-- Create Index
CREATE INDEX idx_emp_salary ON employees(salary);

-- Check Indexes
SELECT index_name, table_name, uniqueness 
FROM user_indexes 
WHERE table_name = 'EMPLOYEES';

-- Drop Index
-- DROP INDEX idx_emp_salary;

COMMIT;