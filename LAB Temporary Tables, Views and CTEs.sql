-- 1
CREATE VIEW Customer_rental1 AS
SELECT a.customer_id, a.first_name, a.last_name, a.email, rental_count
FROM customer a
JOIN (
    SELECT customer_id, COUNT(rental_id) AS rental_count
    FROM rental
    GROUP BY customer_id
) b ON a.customer_id = b.customer_id;

select * 
from Customer_rental1;

-- 2
CREATE TEMPORARY TABLE Customer_spending AS
SELECT a.*, SUM(b.amount) AS total_amount
FROM Customer_rental1 a
JOIN payment b 
ON a.customer_id = b.customer_id
GROUP BY a.customer_id, a.first_name, a.last_name, a.rental_count
order by total_amount desc;

select * 
from Customer_spending;
-- 3
WITH CustomerSummary AS (
    SELECT 
        cr.customer_id,
        CONCAT(cr.first_name, ' ', cr.last_name) AS customer_name, 
        cr.email,
        cr.rental_count,
        cps.total_amount AS total_paid,
        (cps.total_amount / NULLIF(cps.rental_count, 0)) AS average_payment_per_rental -- Handle division by zero
    FROM Customer_rental1 cr
    JOIN Customer_spending cps 
    ON cr.customer_id = cps.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    round(average_payment_per_rental, 2) as average_payment_per_rental
FROM CustomerSummary
ORDER BY total_paid DESC;

