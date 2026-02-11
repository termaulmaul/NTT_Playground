-- =====================================================
-- NTT PLAYGROUND - SQL Server Initialization
-- Tables: employees, departments, locations
-- =====================================================

-- Create database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'NTTPlayground')
BEGIN
    CREATE DATABASE NTTPlayground;
END
GO

USE NTTPlayground;
GO

-- Create tables
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'locations')
BEGIN
    CREATE TABLE locations (
        location_id INT PRIMARY KEY,
        location NVARCHAR(100) NOT NULL,
        city NVARCHAR(100),
        country NVARCHAR(50)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'departments')
BEGIN
    CREATE TABLE departments (
        dept_id INT PRIMARY KEY,
        dept_name NVARCHAR(100) NOT NULL,
        location_id INT
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'employees')
BEGIN
    CREATE TABLE employees (
        emp_id INT PRIMARY KEY,
        emp_name NVARCHAR(100) NOT NULL,
        salary DECIMAL(12,2),
        dept_id INT,
        hire_date DATETIME DEFAULT GETDATE()
    );
END
GO

-- Insert sample data
IF NOT EXISTS (SELECT 1 FROM locations)
BEGIN
    INSERT INTO locations VALUES 
        (1, 'Jakarta HQ', 'Jakarta', 'Indonesia'),
        (2, 'Bandung Office', 'Bandung', 'Indonesia'),
        (3, 'Surabaya Office', 'Surabaya', 'Indonesia');
END
GO

IF NOT EXISTS (SELECT 1 FROM departments)
BEGIN
    INSERT INTO departments VALUES 
        (10, 'IT Department', 1),
        (20, 'HR Department', 1),
        (30, 'Sales Department', 2),
        (40, 'Finance', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM employees)
BEGIN
    INSERT INTO employees VALUES 
        (1, 'Rafi', 8000000, 10, '2023-01-15'),
        (2, 'Budi', 7500000, 10, '2023-03-20'),
        (3, 'Ani', 6500000, 20, '2023-02-10'),
        (4, 'Citra', 9000000, 30, '2023-04-05'),
        (5, 'Dedi', 7200000, 40, '2023-05-12');
END
GO

-- Create indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_emp_dept')
BEGIN
    CREATE INDEX idx_emp_dept ON employees(dept_id);
END
GO

-- Create view
IF EXISTS (SELECT * FROM sys.views WHERE name = 'v_employee_details')
    DROP VIEW v_employee_details;
GO

CREATE VIEW v_employee_details AS
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
GO

PRINT 'NTT Playground database initialized successfully!';
GO