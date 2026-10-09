# Credit Card Fraud Risk & Transaction Analysis

<img width="1417" height="820" alt="cc_fraud_analysis" src="https://github.com/user-attachments/assets/5422e252-58ad-4566-9cbd-f0f748e81c28" />


**Tools:** PostgreSQL · SQL · Tableau
**Focus:** Financial Analytics · Fraud Detection · Transaction Analysis · Risk Assessment · Data Quality

## Project Overview

Financial transactions generate valuable insights into customer behaviour, spending patterns, and potential financial risks. Understanding these patterns can help businesses identify unusual activity, monitor fraud exposure, and make more informed decisions.

This project explores credit card transaction data to analyse transaction patterns and investigate factors associated with fraudulent activity. Using PostgreSQL, I cleaned and prepared the data, performed exploratory data analysis, and developed SQL queries to examine fraud rates across different transaction characteristics, customer demographics, locations, and time periods.

I then used Tableau to transform the analytical results into an interactive dashboard, making key metrics and patterns easier to explore and interpret.

This is the **first project in my three-part Financial Analytics Portfolio**, where I will explore different analytical perspectives using the same underlying dataset.

## Project Objectives

The main objectives of this project are to:

* Understand overall transaction activity and transaction values.
* Measure fraud rates and assess fraudulent transaction exposure.
* Identify transaction categories and merchants associated with higher fraud rates.
* Explore the relationship between transaction amounts and fraudulent activity.
* Analyse fraud patterns across customer age groups, locations, and job categories.
* Investigate how fraud rates vary by transaction hour and day of the week.
* Examine the relationship between geographical distance and fraudulent transactions.
* Identify combinations of transaction categories, states, and amount ranges associated with elevated fraud rates.

## Dataset

The dataset contains credit card transaction records, including transaction timestamps, merchant information, transaction categories, amounts, customer locations, demographic information, and fraud indicators.

The dataset includes the following key fields:

| Field                     | Description                                             |
| ------------------------- | ------------------------------------------------------- |
| `trans_date_trans_time`   | Transaction date and time                               |
| `merchant`                | Merchant associated with the transaction                |
| `category`                | Transaction category                                    |
| `amt`                     | Transaction amount                                      |
| `city`, `state`           | Customer location                                       |
| `lat`, `long`             | Customer geographical coordinates                       |
| `city_pop`                | Population of the customer's city                       |
| `job`                     | Customer occupation                                     |
| `dob`                     | Customer date of birth                                  |
| `trans_num`               | Transaction reference                                   |
| `merch_lat`, `merch_long` | Merchant geographical coordinates                       |
| `is_fraud`                | Fraud indicator: 1 for fraudulent, 0 for non-fraudulent |

The dataset was initially imported into PostgreSQL, where I reviewed its structure and prepared the fields for analysis.

**Data source:** Credit Card Fraud Detection Analysis dataset on Kaggle.

## Tools & Technologies

* **PostgreSQL:** Data preparation, data quality checks, exploratory data analysis, and analytical SQL queries.
* **SQL:** Aggregations, conditional logic, CTEs, date/time functions, filtering, and calculated metrics.
* **Tableau:** Interactive dashboard development and visual exploration of fraud patterns.
* **GitHub:** Project documentation, SQL code, and portfolio presentation.

## Data Preparation & Quality Checks

Before conducting the analysis, I prepared the dataset for consistent and reliable querying.

The main preparation steps included:

1. **Data type conversion:** Converted transaction timestamps to `TIMESTAMP`, dates of birth to `DATE`, and fraud indicators to `INTEGER`.
2. **Fraud indicator standardisation:** Standardised the fraud flag to use `1` for fraudulent transactions and `0` for non-fraudulent transactions.
3. **Data integrity:** Added a primary key to uniquely identify each row in the analysis table and a check constraint to restrict the fraud indicator to valid binary values.
4. **Missing-value checks:** Reviewed key fields, including transaction timestamps, merchant names, categories, amounts, and dates of birth.
5. **Data validation:** Inspected sample records and distinct fraud indicator values before proceeding with the analysis.

These steps established a structured foundation for the subsequent SQL analysis.

## Key Areas of Analysis

### 1. Overall Transaction Performance

* Total number of transactions.
* Total transaction value.
* Average transaction amount.
* Total fraudulent transaction amount.
* Fraud rate by transaction count.
* Fraudulent transaction value as a percentage of total transaction value.

### 2. Transaction Trends Over Time

* Monthly transaction volume and fraud rates.
* Fraud rates by hour of the day.
* Fraud rates by day of the week.

This analysis explores whether fraudulent activity varies across different periods and helps highlight potential temporal patterns.

### 3. Category & Merchant Risk

* Transaction volume by category.
* Fraud rates by transaction category.
* Total transaction value by category.
* Number of fraudulent transactions by merchant.
* Merchant fraud rates, considering only merchants with at least 50 transactions.

The minimum transaction threshold helps avoid ranking merchants based on very small transaction samples.

### 4. Transaction Amount Analysis

* Average transaction amount for fraudulent and non-fraudulent transactions.
* Minimum, average, and maximum amounts by transaction type.
* Fraud rates across transaction amount ranges: below $50, $50–$100, $100–$500, $500–$1,000, and $1,000 or more.

The objective is to investigate how transaction size relates to observed fraud patterns.

### 5. Customer Demographics & Occupation

* Fraud rates across customer age groups.
* Fraud rates by occupation, considering only occupations with at least 30 transactions.

This analysis explores differences in observed transaction patterns across customer groups without assuming that demographic characteristics cause fraudulent activity.

### 6. Geographical Analysis

* Number of fraudulent transactions by state.
* Fraud rates by state.
* Fraud rates by city population.
* Distance between customer and merchant locations.

The geographical distance was calculated in kilometres using the Haversine formula, based on customer and merchant latitude and longitude coordinates.

Distance was then grouped into ranges to compare transaction volumes and fraud rates across geographical segments.


## Key Performance Indicators (KPIs)

The Tableau dashboard presents the main indicators of transaction activity and fraud exposure:

* **Total Transactions:** Number of transaction records analysed.
* **Total Transaction Value:** Combined value of all transactions.
* **Fraud Rate:** Percentage of transactions flagged as fraudulent.
* **Total Fraudulent Transaction Value:** Combined value of transactions flagged as fraudulent.
* **Fraudulent Value %:** Fraudulent transaction value as a percentage of total transaction value.

These indicators provide an overview of transaction activity and fraud exposure before exploring individual analytical views.

## Tableau Dashboard

The completed Tableau dashboard brings together the main KPIs and analytical views developed for this project.

It allows users to explore fraud patterns across transaction amounts, customer demographics, transaction timing, and geographical distance.

<img width="1417" height="820" alt="cc_fraud_analysis" src="https://github.com/user-attachments/assets/5422e252-58ad-4566-9cbd-f0f748e81c28" />


## SQL Skills Demonstrated

Through this project, I applied the following SQL techniques:

* `SELECT`, `WHERE`, `GROUP BY`, and `ORDER BY`
* Aggregate functions, including `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`
* Conditional logic using `CASE WHEN`
* Conditional aggregation using `FILTER`
* Common Table Expressions (CTEs)
* Date and time analysis using `DATE_TRUNC`, `EXTRACT`, and `TO_CHAR`
* Data type conversion and table constraints
* Data quality and missing-value checks
* Fraud rate calculations using conditional aggregation
* Geographical distance calculations using trigonometric functions
* Filtering aggregated results using `HAVING`

## Limitations & Considerations

This project is an exploratory analysis of historical transaction data. The results describe patterns within the dataset and should not be interpreted as proof of causation or as a production-ready fraud detection system.

Fraud rates for merchants, occupations, states, and other segments can be influenced by transaction volumes and the distribution of the underlying data. Minimum transaction thresholds help reduce the influence of very small samples but do not eliminate statistical uncertainty.

The analysis identifies associations and segments for further investigation; it does not train or validate a predictive machine learning model.

## What I Learned

Working on this project helped me strengthen my practical SQL skills and apply them to a financial analytics use case.

I gained experience in preparing raw data for analysis, calculating financial and risk-related metrics, exploring transaction patterns, and translating SQL results into an interactive Tableau dashboard.

Most importantly, I practised approaching a dataset from a business perspective: not only calculating metrics, but also asking what they reveal, where further investigation may be useful, and how analytical findings can be communicated clearly.

## Portfolio Roadmap

This project is the first of three planned financial analytics projects using the same underlying dataset.

* **Project 1 — Credit Card Fraud Risk & Transaction Analysis:** Exploratory analysis of transaction activity, fraud rates, and risk patterns using PostgreSQL and Tableau.

Each project will focus on a distinct analytical objective while building on the same data foundation.

## Author

Dilara Sarsembayeva

Junior Data Analyst | Aspiring Financial & Data Analyst

Interested in financial analytics, SQL, PostgreSQL, data visualisation, and turning raw data into actionable business insights.

**Tools:** PostgreSQL · SQL · Tableau · Excel
