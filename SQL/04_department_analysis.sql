Which departments generate the most revenue and profit?
SELECT
    d.department,
    
    SUM(f.revenue) AS total_revenue,
    
    SUM(f.revenue - f.cogs - f.operating_expense) AS total_profit,
    
    ROUND(
        SAFE_DIVIDE(
            SUM(f.revenue - f.cogs - f.operating_expense),
            SUM(f.revenue)
        ) * 100,
        2
    ) AS profit_margin_percent

FROM `financial-data-505202.Financial_data.fact_financials_final` f

JOIN `financial-data-505202.Financial_data.dim_department` d
    ON f.department_key = d.department_key

GROUP BY
    d.department

ORDER BY
    total_revenue DESC;
......................................................
    ### Which departments are performing above or below their revenue budget?
SELECT
    d.department,
    SUM(f.revenue) AS actual_revenue,
    SUM(f.budget_revenue) AS budget_revenue,
    
    SUM(f.revenue) - SUM(f.budget_revenue) AS variance,
    
    ROUND(
        SAFE_DIVIDE(
            SUM(f.revenue) - SUM(f.budget_revenue),
            SUM(f.budget_revenue)
        ) * 100,
        2
    ) AS variance_percent

FROM `financial-data-505202.Financial_data.fact_financials_final` f

JOIN `financial-data-505202.Financial_data.dim_department` d
    ON f.department_key = d.department_key

GROUP BY
    d.department

ORDER BY
    variance_percent DESC;
.........................................................................
