-- Use the memory.default schema
USE memory.default;

-- Drop the SUPPLIER table if it already exists 
DROP TABLE IF EXISTS SUPPLIER;

-- Create the SUPPLIER table 
CREATE TABLE IF NOT EXISTS SUPPLIER (
    supplier_id TINYINT,
    name VARCHAR
);

-- Drop the INVOICE table if it already exists
DROP TABLE IF EXISTS INVOICE;

-- Create the INVOICE table
CREATE TABLE IF NOT EXISTS INVOICE (
    supplier_id TINYINT,
    invoice_amount DECIMAL(8, 2),
    due_date DATE
);

-- Insert distinct suppliers into SUPPLIER table
INSERT INTO SUPPLIER (supplier_id, name)

WITH supplier_data AS (
    -- Define the supplier names only once
    SELECT DISTINCT supplier_name
    FROM (
        VALUES 
            ('Party Animals'),
            ('Catering Plus'),
            ('Dave''s Discos'),
            ('Entertainment Tonight'),
            ('Ice Ice Baby')
        ) AS tmp (supplier_name)
),
distinct_suppliers AS (
    -- Assign supplier_id using DENSE_RANK based on distinct supplier names
    SELECT 
        DENSE_RANK() OVER (ORDER BY supplier_name) AS supplier_id,
        supplier_name
    FROM supplier_data
)
SELECT supplier_id, supplier_name
FROM distinct_suppliers;

-- Insert invoice data into INVOICE table, using SUPPLIER table for supplier_id
INSERT INTO INVOICE (supplier_id, invoice_amount, due_date)

WITH invoice_data AS (
    -- Define the invoice details
    SELECT 
        supplier_name, 
        invoice_amount, 
        due_months
    FROM (
        VALUES 
            ('Party Animals', 6000, 3),
            ('Catering Plus', 2000, 2),
            ('Catering Plus', 1500, 3),
            ('Dave''s Discos', 500, 1),
            ('Entertainment Tonight', 6000, 3),
            ('Ice Ice Baby', 4000, 6)
    ) AS tmp (supplier_name, invoice_amount, due_months)
)
SELECT 
    s.supplier_id, 
    id.invoice_amount, 
    -- Calculate the last day of the month using DATE_TRUNC and DATE_ADD
    DATE_ADD('day', -1, DATE_ADD('month', 1, DATE_TRUNC('month', DATE_ADD('month', id.due_months, CURRENT_DATE)))) AS due_date
FROM invoice_data id
JOIN SUPPLIER s
ON id.supplier_name = s.name;

-- View the INVOICE table with the data inserted
SELECT * FROM INVOICE;

-- View the SUPPLIER table with the data inserted
SELECT * FROM SUPPLIER;