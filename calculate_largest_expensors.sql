-- Use the memory.default schema
USE memory.default;

-- Drop the LARGEST_EXPENSORS table if it already exists 
DROP TABLE IF EXISTS LARGEST_EXPENSORS;

-- Create the LARGEST_EXPENSORS table 
CREATE TABLE LARGEST_EXPENSORS AS
WITH employees AS (
    -- Select all employee details
    SELECT * 
    FROM EMPLOYEE
),
expenses AS (
    -- Select all expense details
    SELECT * 
    FROM EXPENSE
),
employees_name AS (
    -- Concatenate employee first and last names
    SELECT
        employee_id,
        CONCAT(first_name, ' ', last_name) AS employee_name,
        manager_id
    FROM employees
),
employees_with_managers_name AS (
    -- Join employees with their managers' names
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        CONCAT(m.first_name, ' ', m.last_name) AS manager_name
    FROM employees_name e
    LEFT JOIN employees m ON e.manager_id = m.employee_id -- LEFT JOIN to handle cases with no manager
),
employees_expenses AS (
    -- Calculate total expensed amount for each employee
    SELECT
        employee_id,
        SUM(unit_price * quantity) AS total_expense
    FROM expenses
    GROUP BY employee_id
    HAVING SUM(unit_price * quantity) > 1000 -- Filter out employees who expensed more than 1000
)
-- Combine employee and expense data without ordering here
SELECT
    ewmn.employee_id,
    ewmn.employee_name,
    ewmn.manager_id,
    ewmn.manager_name,
    ee.total_expense
FROM employees_with_managers_name ewmn
LEFT JOIN employees_expenses ee ON ewmn.employee_id = ee.employee_id
WHERE ee.employee_id IS NOT NULL;

-- Select and apply ordering when viewing the results
SELECT 
    * 
FROM largest_expensors
ORDER BY total_expense DESC;
