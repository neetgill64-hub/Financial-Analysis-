Which customers are potentially at risk of churn?
-- ============================================================

WITH Customer_Monthly_Activity AS (
  SELECT
    f.customer_key,
    dc.customer_segment,
    DATE_TRUNC(f.date_key, MONTH) AS activity_month,

    COUNT(DISTINCT f.transaction_id) AS transaction_count,

    SUM(f.revenue) AS total_revenue,

    SUM(
      f.revenue - f.cogs - f.operating_expense
    ) AS total_profit

  FROM `financial-data-505202.Financial_data.fact_financials_final` AS f

  LEFT JOIN `financial-data-505202.Financial_data.dim_customer` AS dc
    ON f.customer_key = dc.customer_key

  GROUP BY
    f.customer_key,
    dc.customer_segment,
    activity_month
),

Latest_Month AS (
  SELECT
    MAX(activity_month) AS latest_month
  FROM Customer_Monthly_Activity
),

Customer_Activity_Comparison AS (
  SELECT
    curr.customer_key,
    curr.customer_segment,

    curr.transaction_count AS current_month_activity,

    COALESCE(
      prev.transaction_count,
      0
    ) AS previous_month_activity,

    curr.total_revenue,
    curr.total_profit,

    ROUND(
      SAFE_DIVIDE(
        curr.transaction_count
          - COALESCE(prev.transaction_count, 0),
        NULLIF(prev.transaction_count, 0)
      ) * 100,
      2
    ) AS activity_change_percent

  FROM Customer_Monthly_Activity AS curr

  LEFT JOIN Customer_Monthly_Activity AS prev
    ON curr.customer_key = prev.customer_key

    AND prev.activity_month = DATE_SUB(
      curr.activity_month,
      INTERVAL 1 MONTH
    )

  CROSS JOIN Latest_Month AS lm

  WHERE curr.activity_month = lm.latest_month
)

SELECT
  customer_key,
  customer_segment,
  current_month_activity,
  previous_month_activity,
  activity_change_percent,
  total_revenue,
  total_profit,

  CASE
    WHEN previous_month_activity = 0
         AND current_month_activity > 0
      THEN 'New/Reactived Customer'

    WHEN activity_change_percent >= 0
      THEN 'Low Risk'

    WHEN activity_change_percent >= -20
      THEN 'Medium Risk'

    WHEN activity_change_percent >= -40
      THEN 'High Risk'

    ELSE 'Critical Risk'
  END AS churn_risk

FROM Customer_Activity_Comparison

ORDER BY
  CASE
    WHEN previous_month_activity = 0
         AND current_month_activity > 0
      THEN 1

    WHEN activity_change_percent >= 0
      THEN 2

    WHEN activity_change_percent >= -20
      THEN 3

    WHEN activity_change_percent >= -40
      THEN 4

    ELSE 5
  END,

  activity_change_percent ASC;
