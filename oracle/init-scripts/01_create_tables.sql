-- =====================================================
-- NTT PLAYGROUND - Oracle Database Initialization
-- Tables: employees, departments, locations
-- =====================================================

-- Create sample schema for presentation
ALTER SESSION SET CONTAINER = XEPDB1;

-- Create tables
CREATE TABLE departments (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(100) NOT NULL,
    location_id NUMBER
);

CREATE TABLE locations (
    location_id NUMBER PRIMARY KEY,
    location VARCHAR2(100) NOT NULL,
    city VARCHAR2(100),
    country VARCHAR2(50)
);

CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(100) NOT NULL,
    salary NUMBER(12,2),
    dept_id NUMBER,
    hire_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Insert sample data
INSERT INTO locations VALUES (1, 'Jakarta HQ', 'Jakarta', 'Indonesia');
INSERT INTO locations VALUES (2, 'Bandung Office', 'Bandung', 'Indonesia');
INSERT INTO locations VALUES (3, 'Surabaya Office', 'Surabaya', 'Indonesia');

INSERT INTO departments VALUES (10, 'IT Department', 1);
INSERT INTO departments VALUES (20, 'HR Department', 1);
INSERT INTO departments VALUES (30, 'Sales Department', 2);
INSERT INTO departments VALUES (40, 'Finance', 1);

INSERT INTO employees VALUES (1, 'Rafi', 8000000, 10, TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO employees VALUES (2, 'Budi', 7500000, 10, TO_DATE('2023-03-20', 'YYYY-MM-DD'));
INSERT INTO employees VALUES (3, 'Ani', 6500000, 20, TO_DATE('2023-02-10', 'YYYY-MM-DD'));
INSERT INTO employees VALUES (4, 'Citra', 9000000, 30, TO_DATE('2023-04-05', 'YYYY-MM-DD'));
INSERT INTO employees VALUES (5, 'Dedi', 7200000, 40, TO_DATE('2023-05-12', 'YYYY-MM-DD'));

COMMIT;

-- Create indexes
CREATE INDEX idx_emp_dept ON employees(dept_id);
CREATE INDEX idx_emp_name ON employees(emp_name);

-- Grant privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON employees TO APP_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON departments TO APP_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON locations TO APP_USER;

-- Create view for presentation
CREATE OR REPLACE VIEW v_employee_details AS
SELECT 
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name,
    l.location,
    l.city
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN locations l ON d.location_id = l.location_id;

GRANT SELECT ON v_employee_details TO APP_USER;

COMMIT;