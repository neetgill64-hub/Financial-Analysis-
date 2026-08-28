## Which regions have the strongest revenue growth, and where should the company focus its sales efforts?
WITH Regional_Revenue AS (
  SELECT
    dr.region AS region,
    d.year AS year,
    SUM(f.revenue) AS total_revenue

  FROM `financial-data-505202.Financial_data.fact_financials_final` AS f

  LEFT JOIN `financial-data-505202.Financial_data.dim_region` AS dr
    ON f.region_key = dr.region_key

  LEFT JOIN `financial-data-505202.Financial_data.dim_date` AS d
    ON f.date_key = d.date_key

  GROUP BY
    dr.region,
    d.year
),

Regional_Growth AS (
  SELECT
    region,
    year,
    total_revenue,

    LAG(total_revenue) OVER (
      PARTITION BY region
      ORDER BY year
    ) AS previous_year_revenue

  FROM Regional_Revenue
)

SELECT
  region,
  year,
  total_revenue,
  previous_year_revenue,

  ROUND(
    SAFE_DIVIDE(
      total_revenue - previous_year_revenue,
      previous_year_revenue
    ) * 100,
    2
  ) AS revenue_growth_percent,

  RANK() OVER (
    PARTITION BY year
    ORDER BY
      SAFE_DIVIDE(
        total_revenue - previous_year_revenue,
        previous_year_revenue
      ) DESC
  ) AS growth_rank

FROM Regional_Growth

WHERE previous_year_revenue IS NOT NULL

ORDER BY
  year,
  growth_rank;

......................................................................
