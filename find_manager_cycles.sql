-- Set session property to handle multiple distinct stages
SET SESSION distinct_aggregations_strategy = 'single_step';

-- Create a recursive CTE to trace employee-manager paths and detect cycles
WITH RECURSIVE employee_manager_cycles (employee_id, manager_id, cycle_path, origin_employee) AS (
    -- Base case: Start with direct employee-manager relationships
    SELECT
        employee_id,
        manager_id,
        CAST(employee_id AS VARCHAR) AS cycle_path, -- Initialize the cycle path with the employee's ID
        employee_id AS origin_employee -- Track the starting employee
    FROM EMPLOYEE

    UNION ALL

    -- Recursive case: Adding managers to the path and trace the relationships
    SELECT
        e.employee_id,
        e.manager_id,
        CONCAT(emc.cycle_path, ',', CAST(e.employee_id AS VARCHAR)) AS cycle_path, -- Append the employee's ID to the path
        emc.origin_employee
    FROM employee_manager_cycles emc
    JOIN EMPLOYEE e ON emc.manager_id = e.employee_id
    WHERE
        NOT (POSITION(CAST(e.employee_id AS VARCHAR) IN emc.cycle_path) > 0) -- Prevent revisiting an employee already in the path
)

-- Detect cycles
SELECT DISTINCT
    origin_employee AS employee_id,
    cycle_path -- Show the complete cycle path of employees involved
FROM employee_manager_cycles
WHERE 
    POSITION(CAST(origin_employee AS VARCHAR) IN cycle_path) > 0 -- Ensure the cycle closes back on the origin employee
    AND cycle_path != CAST(origin_employee AS VARCHAR) -- Ensure that it is not just the employee's own ID
ORDER BY employee_id;
