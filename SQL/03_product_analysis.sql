## which products have the highest profit margin and revenue ?
SELECT
    p.Product_Category,
    SUM(f.revenue) AS total_revenue,
    SUM(f.revenue - f.cogs - f.operating_expense) AS total_profit,

    ROUND(
      SAFE_DIVIDE(
        SUM(f.revenue - f.cogs - f.operating_expense),
        SUM(f.revenue)
      ) * 100,
      2
    ) AS profit_margin_percent

    RANK() OVER (
      ORDER BY profit_margin_percent DESC
    ) AS profit_rank 

FROM `financial-data-505202.Financial_data.fact_financials_final` f
JOIN `financial-data-505202.Financial_data.dim_product` p
    ON f.product_key = p.product_key
GROUP BY
    p.Product_Category
ORDER BY
    total_revenue DESC;
