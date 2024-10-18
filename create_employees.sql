-- Use the memory.default schema
USE memory.default;

-- Drop the EMPLOYEE table if it already exists 
DROP TABLE IF EXISTS EMPLOYEE; 

-- Create the EMPLOYEE table 
CREATE TABLE EMPLOYEE (
	employee_id TINYINT, 
	first_name VARCHAR(255), 
	last_name VARCHAR(255), 
	job_title VARCHAR(255), 
	manager_id TINYINT 
);

-- Insert the data (from hr?employee_index.csv) to EMPLOYEE table
INSERT INTO EMPLOYEE (employee_id, first_name, last_name, job_title, manager_id) 
VALUES 
(1, 'Ian', 'James', 'CEO', 4), 
(2, 'Umberto', 'Torrielli', 'CSO', 1), 
(3, 'Alex', 'Jacobson', 'MD EMEA', 2), 
(4, 'Darren', 'Poynton', 'CFO', 2), 
(5, 'Tim', 'Beard', 'MD APAC', 2), 
(6, 'Gemma', 'Dodd', 'COS', 1), 
(7, 'Lisa', 'Platten', 'CHR', 6), 
(8, 'Stefano', 'Camisaca', 'GM Activation', 2), 
(9, 'Andrea', 'Ghibaudi', 'MD NAM', 2);

-- View the EMPLOYEE table with the data inserted
SELECT * FROM EMPLOYEE;