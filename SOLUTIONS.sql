-- 1.1 
-- This query joins customers with tariffs by using the tariff id.
-- The WHERE condition filters only the Kobiye Destek tariff.
-- The result shows the customers who use this tariff.

SELECT c.CUSTOMER_ID,
       c.NAME,
       c.CITY,
       c.SIGNUP_DATE,
       t.NAME AS TARIFF_NAME
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t
ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';


-- 1.2
-- This query joins customers with tariffs.
-- The customers are ordered by signup date from newest to oldest.
-- FETCH FIRST 1 ROW ONLY returns only the newest customer.

SELECT c.CUSTOMER_ID,
       c.NAME,
       c.CITY,
       c.SIGNUP_DATE,
       t.NAME AS TARIFF_NAME
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t
ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROW ONLY;


-- 2.1
-- This query joins customers and tariffs.
-- GROUP BY groups the customers according to tariff name.
-- COUNT shows how many customers are using each tariff.

SELECT t.NAME AS TARIFF_NAME,
       COUNT(*) AS CUSTOMER_COUNT
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t
ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME
ORDER BY CUSTOMER_COUNT DESC;


-- 3.1
-- This query finds the minimum signup date from the customers table.
-- It does not assume that the lowest customer id is the earliest customer.
-- The result shows all customers who signed up on the earliest date.

SELECT CUSTOMER_ID,
       NAME,
       CITY,
       SIGNUP_DATE
FROM SYSTEM.CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM SYSTEM.CUSTOMERS
);

-- 3.2
-- This query first finds the earliest signup date.
-- Then it filters customers who signed up on that date.
-- GROUP BY is used to count these customers by city.

SELECT CITY,
       COUNT(*) AS CUSTOMER_COUNT
FROM SYSTEM.CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM SYSTEM.CUSTOMERS
)
GROUP BY CITY
ORDER BY CUSTOMER_COUNT DESC;


-- 4.1
-- This query compares customers with monthly statistics records.
-- NOT IN is used to find customers who do not exist in MONTHLY_STATS.
-- The result shows customer ids with missing monthly records.

SELECT CUSTOMER_ID
FROM SYSTEM.CUSTOMERS
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM SYSTEM.MONTHLY_STATS
);


-- 4.2
-- This query finds customers who do not have monthly statistics.
-- These missing customers are grouped by city.
-- COUNT shows how many missing records exist for each city.

SELECT CITY,
       COUNT(*) AS CUSTOMER_COUNT
FROM SYSTEM.CUSTOMERS
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM SYSTEM.MONTHLY_STATS
)
GROUP BY CITY
ORDER BY CUSTOMER_COUNT DESC;


-- 5.1
-- This query joins customers, tariffs, and monthly usage records.
-- It compares data usage with 75% of the tariff data limit.
-- Tariffs with zero data limit are excluded to avoid incorrect results.

SELECT c.CUSTOMER_ID,
       c.NAME,
       c.CITY,
       t.NAME AS TARIFF_NAME,
       m.DATA_USAGE,
       t.DATA_LIMIT
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t
ON c.TARIFF_ID = t.TARIFF_ID
JOIN SYSTEM.MONTHLY_STATS m
ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE t.DATA_LIMIT > 0
AND m.DATA_USAGE >= t.DATA_LIMIT * 0.75;


-- 5.2
-- This query compares data, minute, and SMS usage with tariff limits.
-- A customer is selected only if all three usage values reached the package limits.
-- The result returns no rows because no customer reached the SMS limit in the dataset.

SELECT c.CUSTOMER_ID,
       c.NAME,
       c.CITY,
       t.NAME AS TARIFF_NAME,
       m.DATA_USAGE,
       m.MINUTE_USAGE,
       m.SMS_USAGE
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t
ON c.TARIFF_ID = t.TARIFF_ID
JOIN SYSTEM.MONTHLY_STATS m
ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.DATA_USAGE >= t.DATA_LIMIT
AND m.MINUTE_USAGE >= t.MINUTE_LIMIT
AND m.SMS_USAGE >= t.SMS_LIMIT;


-- 6.1
-- This query lists customers with unpaid payment status.
-- The REPLACE function removes hidden carriage return characters from the imported CSV data.
-- The result shows customer ids whose payment status is marked as UNPAID.

SELECT CUSTOMER_ID,
       PAYMENT_STATUS
FROM SYSTEM.MONTHLY_STATS
WHERE REPLACE(PAYMENT_STATUS, CHR(13), '') = 'UNPAID';


-- 6.2
-- This query joins customers, tariffs, and monthly statistics.
-- GROUP BY is used to count cleaned payment statuses for each tariff.
-- The REPLACE function removes hidden carriage return characters from payment status values.

SELECT t.NAME AS TARIFF_NAME,
       REPLACE(m.PAYMENT_STATUS, CHR(13), '') AS PAYMENT_STATUS,
       COUNT(*) AS CUSTOMER_COUNT
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t
ON c.TARIFF_ID = t.TARIFF_ID
JOIN SYSTEM.MONTHLY_STATS m
ON c.CUSTOMER_ID = m.CUSTOMER_ID
GROUP BY t.NAME, REPLACE(m.PAYMENT_STATUS, CHR(13), '')
ORDER BY t.NAME, PAYMENT_STATUS;