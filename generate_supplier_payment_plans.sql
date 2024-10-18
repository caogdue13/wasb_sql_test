-- Use the memory.default schema
USE memory.default;

-- Get the list of suppliers and their invoices
WITH supplier_invoices AS (
    SELECT 
        s.supplier_id,               
        s.name AS supplier_name,     
        i.invoice_amount,            
        i.due_date                   
    FROM SUPPLIER s
    JOIN INVOICE i ON s.supplier_id = i.supplier_id -- Join SUPPLIER and INVOICE tables on supplier_id
),

-- Calculate the total balance outstanding for each supplier
supplier_balance AS (
    SELECT 
        supplier_id,                              
        SUM(invoice_amount) AS total_balance_outstanding -- Total balance outstanding per supplier
    FROM supplier_invoices
    GROUP BY supplier_id -- Group by supplier ID to calculate the sum for each supplier
),

-- Determine the maximum due date for each supplier
max_due_dates AS (
    SELECT 
        supplier_id,
        MAX(due_date) AS max_due_date -- Maximum due date for invoices
    FROM supplier_invoices
    GROUP BY supplier_id -- Group by supplier ID to find the due date for each
),

-- Generate monthly payment dates and calculate payments
monthly_payments AS (
    SELECT
        si.supplier_id, 
        si.supplier_name,
        ROUND(SUM(si.invoice_amount) / (DATE_DIFF('month', CURRENT_DATE, md.max_due_date) + 1), 2) AS payment_amount, 
        -- Calculate monthly payment amount based on total invoices and months until the max due date
        DATE_ADD('day', -1, DATE_ADD('month', 1, DATE_TRUNC('month', DATE_ADD('month', seq, CURRENT_DATE)))) AS payment_date 
        -- Calculate the last day of the month for each payment date
    FROM supplier_invoices si
    JOIN max_due_dates md ON si.supplier_id = md.supplier_id -- Join with max_due_dates to get the max due date
    CROSS JOIN UNNEST(SEQUENCE(0, DATE_DIFF('month', CURRENT_DATE, md.max_due_date))) AS t(seq) 
    -- Generate a sequence of months between the current date and the maximum due date
    GROUP BY si.supplier_id, si.supplier_name, md.max_due_date, seq -- Group by supplier details and sequence
),

-- Calculate the outstanding balance after each payment
final_payment_plan AS (
    SELECT 
        mp.supplier_id,                     
        mp.supplier_name,                   
        mp.payment_amount,                  
        mp.payment_date,                    
        sb.total_balance_outstanding - SUM(mp.payment_amount) OVER (PARTITION BY mp.supplier_id ORDER BY mp.payment_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance_outstanding
        -- Calculate balance outstanding after each payment, subtracting cumulative payments from the total outstanding balance
    FROM monthly_payments mp
    JOIN supplier_balance sb ON mp.supplier_id = sb.supplier_id -- Join to get total balance outstanding
)

-- Output the final payment plan with the balance outstanding and payment details
SELECT 
    pp.supplier_id, 
    pp.supplier_name,
    pp.payment_amount,
    pp.balance_outstanding,
    pp.payment_date
FROM final_payment_plan pp
ORDER BY pp.supplier_id, pp.payment_date; -- Order results by supplier ID and payment date
