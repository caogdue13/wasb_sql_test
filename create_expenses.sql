-- Use the memory.default schema
USE memory.default;

-- Drop the EXPENSE table if it already exists 
DROP TABLE IF EXISTS EXPENSE; 

-- Create the EXPENSE table 
CREATE TABLE IF NOT EXISTS EXPENSE (
        employee_id TINYINT,
        unit_price DECIMAL(8, 2),
        quantity TINYINT
);

-- Insert data into EXPENSE table
INSERT INTO EXPENSE (employee_id, unit_price, quantity)

-- Define temporary data for employee expenses
WITH temp_expenses AS (
    SELECT
        employee_name,
        unit_price,
        quantity
    FROM (
        VALUES 
            ('Alex Jacobson', 'Drinks, lots of drinks', 6.50, 14),
            ('Alex Jacobson', 'More Drinks', 11.00, 20),
            ('Alex Jacobson', 'So Many Drinks!', 22.00, 18),
            ('Alex Jacobson', 'I bought everyone in the bar a drink!', 13.00, 75),
            ('Andrea Ghibaudi', 'Flights from Mexico back to New York', 300, 1),
            ('Darren Poynton', 'Ubers to get us all home', 40.00, 9), 
            ('Umberto Torrielli', 'I had too much fun and needed something to eat', 17.50, 4)
    ) AS receipts(employee_name, description, unit_price, quantity)
),

-- Map employees to their IDs by concatenatiing the first and last names to create a full name
map_employees AS (
    SELECT
        employee_id,
        CONCAT(first_name, ' ', last_name) AS full_name -- Create full name by concatenating first and last name
    FROM EMPLOYEE
),

-- Join the employee names in the temporary expense data with the employee table to assign employee IDs
expenses_final AS (
    SELECT
        emp.employee_id,
        te.unit_price,
        te.quantity
    FROM temp_expenses te
    JOIN map_employees emp
        ON te.employee_name = emp.full_name
)

-- Select the final data (employee_id, unit_price, quantity) to be inserted into the EXPENSE table
SELECT
    employee_id,
    unit_price,
    quantity
FROM expenses_final;
    
-- View the EXPENSE table with the data inserted
SELECT * FROM EXPENSE;