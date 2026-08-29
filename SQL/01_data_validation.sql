## Check if any transaction_id is duplicated
SELECT
  transaction_id,
  COUNT(*) AS record_count
FROM `financial-data-505202.Financial_data.fact_financials_final`
GROUP BY transaction_id
HAVING COUNT(*) > 1;
.........................................................................
  ## Check NULL/missing-value validation query
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(transaction_id IS NULL) AS missing_transaction_id,
  COUNTIF(date_key IS NULL) AS missing_date,
  COUNTIF(department_key IS NULL) AS missing_department_key,
  COUNTIF(region_key IS NULL) AS missing_region_key,
  COUNTIF(product_key IS NULL) AS missing_product_key,
  COUNTIF(customer_key IS NULL) AS missing_customer_key,
  COUNTIF(revenue IS NULL) AS missing_revenue,
  COUNTIF(cogs IS NULL) AS missing_cogs,
  COUNTIF(operating_expense IS NULL) AS missing_operating_expense,
  COUNTIF(budget_revenue IS NULL) AS missing_budget_revenue,
  COUNTIF(budget_cogs IS NULL) AS missing_budget_cogs,
  COUNTIF(budget_expense IS NULL) AS missing_budget_expense
FROM `financial-data-505202.Financial_data.fact_financials_final`;

...............................................................................
  ## Check your Calculation Accuracy
SELECT
  transaction_id,
  revenue,
  cogs,
  operating_expense,
  revenue - cogs - operating_expense AS calculated_profit
FROM `financial-data-505202.Financial_data.fact_financials_final`;
.......................................................................................

## Check Date Range

SELECT
  MIN(date_key) AS earliest_date,
  MAX(date_key) AS latest_date
FROM `financial-data-505202.Financial_data.fact_financials_final`;
...................................................................................
  ## Check invalid financial valuesvalue
SELECT *
FROM `financial-data-505202.Financial_data.fact_financials_final`
WHERE revenue < 0
   OR cogs < 0
   OR operating_expense < 0
   OR budget_revenue < 0;
..............................................................................................

## Referential Integrity Check:
  SELECT
  COUNT(*) AS total_fact_records,

  COUNTIF(d.department_key IS NULL) AS missing_department_keys,

  COUNTIF(l.region_key IS NULL) AS missing_region_keys,

  COUNTIF(p.product_key IS NULL) AS missing_product_keys,

  COUNTIF(c.customer_key IS NULL) AS missing_customer_keys,

  COUNTIF(dt.date_key IS NULL) AS missing_date_keys

FROM `financial-data-505202.Financial_data.fact_financials_final` f

LEFT JOIN `financial-data-505202.Financial_data.dim_department` d
  ON f.department_key = d.department_key

LEFT JOIN `financial-data-505202.Financial_data.dim_region` l
  ON f.region_key = l.region_key

LEFT JOIN `financial-data-505202.Financial_data.dim_product` p
  ON f.product_key = p.product_key

LEFT JOIN `financial-data-505202.Financial_data.dim_customer` c
  ON f.customer_key = c.customer_key

LEFT JOIN `financial-data-505202.Financial_data.dim_date` dt
  ON f.date_key = dt.date_key;
...........................................................................................................
  ## Check Data Types 
SELECT
  column_name,
  data_type,
  is_nullable
FROM `financial-data-505202.Financial_data.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'fact_financials_final'
ORDER BY ordinal_position;

..............................................
