DROP TABLE IF EXISTS fraud_transactions;

CREATE TABLE fraud_transactions ( 
trans_date_trans_time TEXT, ---DATESTAMP 
merchant TEXT, 
category TEXT, 
amt NUMERIC(12,2), 
city VARCHAR(100), 
state VARCHAR(2), 
lat NUMERIC(9,6), 
long NUMERIC(9,6), 
city_pop INTEGER, 
job VARCHAR(150), 
dob TEXT, ----DATE 
trans_num VARCHAR(100), 
merch_lat NUMERIC(9,6), 
merch_long NUMERIC(9,6), 
is_fraud TEXT ----INTEGER 
);

update fraud_transactions 
set is_fraud = case 
when is_fraud::text ='1' then 1 
else 0 end 

ALTER TABLE fraud_transactions 
ALTER COLUMN is_fraud TYPE INTEGER USING 
CAST(is_fraud AS INTEGER);


/* CREDIT CARD FRAUD RISK & TRANSACTION ANALYSIS
   PostgreSQL */


/* 1. CLEAN EXISTING DATA TYPES */

-- Convert transaction date/time from TEXT to TIMESTAMP
ALTER TABLE fraud_transactions
ALTER COLUMN trans_date_trans_time
TYPE TIMESTAMP
USING TO_TIMESTAMP(
    trans_date_trans_time::TEXT, 
    'DD-MM-YYYY HH24:MI'
);

-- Convert date of birth from TEXT to DATE
ALTER TABLE fraud_transactions
ALTER COLUMN dob
TYPE DATE
USING TO_DATE(
    dob::TEXT, 
    'DD-MM-YYYY'
);
-- Convert fraud indicator from TEXT to INTEGER
ALTER TABLE fraud_transactions
ALTER COLUMN is_fraud
TYPE INTEGER
USING CASE 
    WHEN TRIM(is_fraud::TEXT) = '1' THEN 1
    WHEN TRIM(is_fraud::TEXT) = '0' THEN 0
    ELSE NULL
END;

-- Add a constraint so only 0 and 1 are allowed
-- Drop the constraint if it already exists, then add it fresh
ALTER TABLE fraud_transactions 
DROP CONSTRAINT IF EXISTS chk_is_fraud;

ALTER TABLE fraud_transactions
ADD CONSTRAINT chk_is_fraud
CHECK (is_fraud IN (0, 1));

/* 2. ADD PRIMARY KEY */

ALTER TABLE fraud_transactions
ADD COLUMN transaction_id BIGSERIAL;

ALTER TABLE fraud_transactions
ADD CONSTRAINT pk_fraud_transactions
PRIMARY KEY (transaction_id);


/* 3. CHECK THE DATA */

SELECT *
FROM fraud_transactions
LIMIT 10;

SELECT DISTINCT is_fraud
FROM fraud_transactions;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE trans_date_trans_time IS NULL)
        AS missing_transaction_date,
    COUNT(*) FILTER (WHERE merchant IS NULL)
        AS missing_merchant,
    COUNT(*) FILTER (WHERE category IS NULL)
        AS missing_category,
    COUNT(*) FILTER (WHERE amt IS NULL)
        AS missing_amount,
    COUNT(*) FILTER (WHERE dob IS NULL)
        AS missing_dob
FROM fraud_transactions;


/* PROJECT 1 — CREDIT CARD FRAUD RISK & TRANSACTION ANALYSIS */


/* ============================================================
   1. TOTAL TRANSACTIONS, TOTAL AMOUNT AND AVERAGE AMOUNT
   ============================================================ */

SELECT
    COUNT(*) AS total_transactions,
    SUM(amt) AS total_transaction_amount,
    ROUND(AVG(amt), 2) AS average_transaction_amount
FROM fraud_transactions;


/* ============================================================
   2. WHAT PERCENTAGE OF ALL TRANSACTIONS ARE FRAUDULENT?
   ============================================================ */

SELECT
    ROUND(
        COUNT(*) FILTER (WHERE is_fraud = 1) * 100.0
        / COUNT(*),
        2
    ) AS fraud_rate_pct
FROM fraud_transactions;


/* ============================================================
   3. WHAT PERCENTAGE OF TOTAL TRANSACTION VALUE IS FRAUDULENT?
   ============================================================ */

SELECT
    ROUND(
        SUM(amt) FILTER (WHERE is_fraud = 1) * 100.0
        / SUM(amt),
        2
    ) AS fraudulent_value_pct
FROM fraud_transactions;


/* Total fraudulent transaction amount */

SELECT
    SUM(amt) AS total_fraud_amount
FROM fraud_transactions
WHERE is_fraud = 1;


/* ============================================================
   4. MONTHLY TRANSACTION VOLUME AND FRAUD RATE
   ============================================================ */

SELECT
    DATE_TRUNC('month', trans_date_trans_time) AS month,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY 1
ORDER BY 1;


/* ============================================================
   5. WHICH CATEGORIES HAVE THE HIGHEST NUMBER OF TRANSACTIONS?
   ============================================================ */

SELECT
    category,
    COUNT(*) AS total_transactions
FROM fraud_transactions
GROUP BY category
ORDER BY total_transactions DESC;


/* ============================================================
   6. WHICH CATEGORIES HAVE THE HIGHEST FRAUD RATE?
   ============================================================ */

SELECT
    category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY category
ORDER BY fraud_rate_pct DESC;


/* ============================================================
   7. WHICH CATEGORIES HAVE THE HIGHEST TOTAL TRANSACTION VALUE?
   ============================================================ */

SELECT
    category,
    SUM(amt) AS total_transaction_amount
FROM fraud_transactions
GROUP BY category
ORDER BY total_transaction_amount DESC;


/* ============================================================
   8. WHICH MERCHANTS HAVE THE MOST FRAUDULENT TRANSACTIONS?
   ============================================================ */

SELECT
    merchant,
    SUM(is_fraud) AS fraud_transactions
FROM fraud_transactions
GROUP BY merchant
ORDER BY fraud_transactions DESC;


/* ============================================================
   9. WHICH MERCHANTS HAVE THE HIGHEST FRAUD RATE?
      ONLY MERCHANTS WITH AT LEAST 50 TRANSACTIONS
   ============================================================ */

SELECT
    merchant,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY merchant
HAVING COUNT(*) >= 50
ORDER BY fraud_rate_pct DESC;


/* ============================================================
   10. AVERAGE TRANSACTION AMOUNT:
       FRAUDULENT VS NON-FRAUDULENT
   ============================================================ */

SELECT
    CASE
        WHEN is_fraud = 1 THEN 'Fraudulent'
        ELSE 'Non-fraudulent'
    END AS transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(AVG(amt), 2) AS average_transaction_amount
FROM fraud_transactions
GROUP BY is_fraud
ORDER BY is_fraud;


/* ============================================================
   11. FRAUD RATE BY TRANSACTION AMOUNT RANGE
   ============================================================ */

SELECT
    CASE
        WHEN amt < 50 THEN '< $50'
        WHEN amt < 100 THEN '$50-$100'
        WHEN amt < 500 THEN '$100-$500'
        WHEN amt < 1000 THEN '$500-$1000'
        ELSE '$1000+'
    END AS amount_range,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY 1
ORDER BY MIN(amt);


/* ============================================================
   12. WHICH STATES HAVE THE MOST FRAUDULENT TRANSACTIONS?
   ============================================================ */

SELECT
    state,
    SUM(is_fraud) AS fraud_transactions
FROM fraud_transactions
GROUP BY state
ORDER BY fraud_transactions DESC;


/* ============================================================
   13. WHICH STATES HAVE THE HIGHEST FRAUD RATE?
   ============================================================ */

SELECT
    state,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY state
ORDER BY fraud_rate_pct DESC;


/* ============================================================
   14. TRANSACTION AMOUNT VS FRAUD
   ============================================================ */

SELECT
    CASE
        WHEN is_fraud = 1 THEN 'Fraudulent'
        ELSE 'Non-fraudulent'
    END AS transaction_type,

    COUNT(*) AS total_transactions,
    MIN(amt) AS minimum_amount,
    ROUND(AVG(amt), 2) AS average_amount,
    MAX(amt) AS maximum_amount
FROM fraud_transactions
GROUP BY is_fraud
ORDER BY is_fraud;


/* ============================================================
   15. CITY POPULATION VS FRAUD RATE
   ============================================================ */

SELECT
    city,
    city_pop,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY
    city,
    city_pop
ORDER BY fraud_rate_pct DESC;


/* ============================================================
   16. FRAUD RATE BY CUSTOMER AGE GROUP
   ============================================================ */

WITH customer_ages AS (
    SELECT
        is_fraud,
        EXTRACT(
            YEAR FROM AGE(dob)
        ) AS customer_age
   FROM fraud_transactions
),
age_groups AS (
    SELECT
        is_fraud,
        CASE
            WHEN customer_age < 25 THEN 'Under 25'
            WHEN customer_age BETWEEN 25 AND 39 THEN '25-39'
            WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
            ELSE '60+'
        END AS age_group
    FROM customer_ages
)
SELECT
    age_group,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM age_groups
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN 'Under 25' THEN 1
        WHEN '25-39' THEN 2
        WHEN '40-59' THEN 3
        WHEN '60+' THEN 4
    END;


/* ============================================================
   17. WHICH JOB CATEGORIES HAVE THE HIGHEST FRAUD RATE?
      ONLY JOBS WITH AT LEAST 30 TRANSACTIONS
   ============================================================ */

SELECT
    job,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY job
HAVING COUNT(*) >= 30
ORDER BY fraud_rate_pct DESC;


/* ============================================================
   18. FRAUD BY HOUR OF THE DAY
   ============================================================ */

SELECT
    EXTRACT(
        HOUR FROM trans_date_trans_time
    ) AS transaction_hour,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY transaction_hour
ORDER BY transaction_hour;


/* ============================================================
   18. FRAUD BY DAY OF THE WEEK
   ============================================================ */

SELECT
    EXTRACT(
        DOW FROM trans_date_trans_time
    ) AS day_number,
    TO_CHAR(
        trans_date_trans_time,
        'Day'
    ) AS day_of_week,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY
    EXTRACT(DOW FROM trans_date_trans_time),
    TO_CHAR(trans_date_trans_time, 'Day')
ORDER BY day_number


/* ============================================================
   19. DISTANCE BETWEEN CUSTOMER AND MERCHANT
   ============================================================ */

WITH transaction_distances AS (
    SELECT
        is_fraud,
        6371 * 2 * ASIN(
            SQRT(
                POWER(
                    SIN(
                        RADIANS(merch_lat - lat) / 2
                    ),
                    2
                )
                +
                COS(RADIANS(lat))
                * COS(RADIANS(merch_lat))
                * POWER(
                    SIN(
                        RADIANS(merch_long - long) / 2
                    ),
                    2
                )
            )
        ) AS distance_km

    FROM fraud_transactions
)

SELECT

    CASE
        WHEN distance_km < 5 THEN '< 5 km'
        WHEN distance_km < 20 THEN '5-20 km'
        WHEN distance_km < 50 THEN '20-50 km'
        WHEN distance_km < 100 THEN '50-100 km'
        ELSE '100+ km'
    END AS distance_range,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM transaction_distances
GROUP BY 1
ORDER BY
    MIN(distance_km);


/* ============================================================
   20. CATEGORY + STATE + AMOUNT RANGE
       HIGHEST FRAUD RISK
   ============================================================ */

SELECT
    category,
    state,
    CASE
        WHEN amt < 50 THEN '< $50'
        WHEN amt < 100 THEN '$50-$100'
        WHEN amt < 500 THEN '$100-$500'
        WHEN amt < 1000 THEN '$500-$1000'
        ELSE '$1000+'
    END AS amount_range,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(
        SUM(is_fraud)::NUMERIC / COUNT(*) * 100,
        2
    ) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY
    category,
    state,
    amount_range
HAVING COUNT(*) >= 30
ORDER BY fraud_rate_pct DESC;

