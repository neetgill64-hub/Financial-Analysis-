### Which customers are potentially at risk of churn?
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

### Which customer segments are becoming less active over time?
-- ============================================================

WITH Monthly_Activity AS (
  SELECT
    dc.customer_segment,
    DATE_TRUNC(f.date_key, MONTH) AS activity_month,
    COUNT(DISTINCT f.transaction_id) AS transaction_count

  FROM `financial-data-505202.Financial_data.fact_financials_final` AS f

  LEFT JOIN `financial-data-505202.Financial_data.dim_customer` AS dc
    ON f.customer_key = dc.customer_key

  GROUP BY
    dc.customer_segment,
    activity_month
),

Activity_Change AS (
  SELECT
    customer_segment,
    activity_month,
    transaction_count,

    LAG(transaction_count) OVER (
      PARTITION BY customer_segment
      ORDER BY activity_month
    ) AS previous_month_activity

  FROM Monthly_Activity
),

Activity_Status AS (
  SELECT
    customer_segment,
    activity_month,
    transaction_count,
    previous_month_activity,

    ROUND(
      SAFE_DIVIDE(
        transaction_count - previous_month_activity,
        previous_month_activity
      ) * 100,
      2
    ) AS activity_change_percent

  FROM Activity_Change
)

SELECT
  customer_segment,

  ROUND(
    AVG(activity_change_percent),
    2
  ) AS avg_activity_change_percent,

  CASE
    WHEN AVG(activity_change_percent) >= 10
      THEN 'Increasing Activity'

    WHEN AVG(activity_change_percent) > -10
      THEN 'Stable Activity'

    WHEN AVG(activity_change_percent) > -30
      THEN 'Declining Activity'

    ELSE 'Significant Decline'
  END AS segment_activity_status

FROM Activity_Status

WHERE activity_change_percent IS NOT NULL

GROUP BY
  customer_segment

ORDER BY
  avg_activity_change_percent;

    ELSE 5
  END,

  activity_change_percent ASC;


### which customer generate the highest to Lowest Revenue
  ......................................................

SELECT
    d.customer_segment AS customer,
    SUM(f.revenue) AS total_revenue
FROM `financial-data-505202.Financial_data.fact_financials_final` AS f
LEFT JOIN `financial-data-505202.Financial_data.dim_customer` AS d
    ON f.customer_key = d.customer_key
GROUP BY d.customer_segment
ORDER BY total_revenue DESC;

### Which Customer segment are growing and declining
  ...................................................

  WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC(f.date_key, MONTH) AS month,
    c.customer_segment,
    SUM(f.revenue) AS total_revenue
  FROM `financial-data-505202.Financial_data.fact_financials_final` f
  LEFT JOIN `financial-data-505202.Financial_data.dim_customer` c
    ON f.customer_key = c.customer_key
  GROUP BY
    month,
    c.customer_segment
),

revenue_change AS (
  SELECT
    month,
    customer_segment,
    total_revenue,

    LAG(total_revenue) OVER (
      PARTITION BY customer_segment
      ORDER BY month
    ) AS previous_month_revenue

  FROM monthly_revenue
)

SELECT
  month,
  customer_segment,
  total_revenue,
  previous_month_revenue,

  ROUND(
    SAFE_DIVIDE(
      total_revenue - previous_month_revenue,
      previous_month_revenue
    ) * 100,
    2
  ) AS revenue_change_percent,

  CASE
    WHEN previous_month_revenue IS NULL THEN 'No Previous Data'
    WHEN total_revenue > previous_month_revenue THEN 'Growing'
    WHEN total_revenue < previous_month_revenue THEN 'Declining'
    ELSE 'Stable'
  END AS growth_status

FROM revenue_change
ORDER BY
  month,
  customer_segment;

### Which customer segments have the highest average revenue per transaction, and is this changing over time?"

  WITH monthly_segment_avg AS (
  SELECT
    DATE_TRUNC(f.date_key, MONTH) AS month,
    c.customer_segment,
    AVG(f.revenue) AS avg_monthly_revenue
  FROM `financial-data-505202.Financial_data.fact_financials_final` f
  LEFT JOIN `financial-data-505202.Financial_data.dim_customer` c
    ON f.customer_key = c.customer_key
  GROUP BY
    month,
    c.customer_segment
),

segment_change AS (
  SELECT
    month,
    customer_segment,
    avg_monthly_revenue,

    LAG(avg_monthly_revenue) OVER (
      PARTITION BY customer_segment
      ORDER BY month
    ) AS previous_month_avg

  FROM monthly_segment_avg
)

SELECT
  month,
  customer_segment,
  ROUND(avg_monthly_revenue, 2) AS avg_monthly_revenue,
  ROUND(previous_month_avg, 2) AS previous_month_avg,

  ROUND(
    SAFE_DIVIDE(
      avg_monthly_revenue - previous_month_avg,
      previous_month_avg
    ) * 100,
    2
  ) AS avg_change_percent,

  CASE
    WHEN previous_month_avg IS NULL THEN 'No Previous Data'
    WHEN avg_monthly_revenue > previous_month_avg THEN 'Increasing'
    WHEN avg_monthly_revenue < previous_month_avg THEN 'Declining'
    ELSE 'Stable'
  END AS trend

FROM segment_change
ORDER BY
  month,
  customer_segment;
  
### Which customer segments desrve more sales and marketing investment 
WITH Segment_Performance AS (
  SELECT
    dc.customer_segment AS customer_segment,

    SUM(f.revenue) AS total_revenue,

    SUM(
      f.revenue - f.cogs - f.operating_expense
    ) AS total_profit,

    ROUND(
      SAFE_DIVIDE(
        SUM(f.revenue - f.cogs - f.operating_expense),
        SUM(f.revenue)
      ) * 100,
      2
    ) AS profit_margin_percent

  FROM `financial-data-505202.Financial_data.fact_financials_final` AS f

  LEFT JOIN `financial-data-505202.Financial_data.dim_customer` AS dc
    ON f.customer_key = dc.customer_key

  GROUP BY
    dc.customer_segment
)

SELECT
  customer_segment,
  total_revenue,
  total_profit,
  profit_margin_percent,

  RANK() OVER (
    ORDER BY total_profit DESC
  ) AS profit_rank,

  CASE
    WHEN total_profit >= 5000000
         AND profit_margin_percent >= 45
      THEN 'Core Investment'

    WHEN total_profit < 5000000
         AND profit_margin_percent >= 48
      THEN 'Growth Opportunity'

    WHEN total_profit >= 3000000
         AND profit_margin_percent >= 45
      THEN 'Maintain & Optimise'

    ELSE 'Review'
END AS investment_strategy

FROM Segment_Performance

ORDER BY
  profit_rank;
  
## Which customer segments are underperforming against budget?

SELECT
    customer_segment,
    SUM(revenue) AS actual_revenue,
    SUM(budget_revenue) AS budget_revenue,
    SUM(revenue) - SUM(budget_revenue) AS budget_variance,
    SAFE_DIVIDE(
        SUM(revenue) - SUM(budget_revenue),
        SUM(budget_revenue)
    ) * 100 AS variance_percent
FROM `financial-data-505202.Financial_data.fact_financials_final`
GROUP BY customer_segment
ORDER BY variance_percent ASC;
