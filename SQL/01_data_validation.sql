## Check if any transaction_id is duplicated
SELECT
  transaction_id,
  COUNT(*) AS record_count
FROM `financial-data-505202.Financial_data.fact_financials_final`
GROUP BY transaction_id
HAVING COUNT(*) > 1;
.......................................................................
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
.................................................................

## Check Date Range

SELECT
  MIN(date_key) AS earliest_date,
  MAX(date_key) AS latest_date
FROM `financial-data-505202.Financial_data.fact_financials_final`;
....................................................................
  ## Check invalid financial valuesvalue
SELECT *
FROM `financial-data-505202.Financial_data.fact_financials_final`
WHERE revenue < 0
   OR cogs < 0
   OR operating_expense < 0
   OR budget_revenue < 0;
.....................................................................
