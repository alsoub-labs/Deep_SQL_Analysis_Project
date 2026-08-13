

-- #######################
-- Product Analysis
-- #######################

-- What are we actually selling successfully?

-- Top 10 products
SELECT 
    P.Product_name,
    SUM(F.Sales) AS TotalSales,
    COUNT(P.Product_name) AS TotalProductsCount
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY P.Product_name
ORDER BY TotalSales DESC
LIMIT 10;

-- Bottom 10 products
SELECT 
    P.Product_name,
    SUM(F.Sales) AS TotalSales,
    COUNT(P.Product_name) AS TotalProductsCount
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY P.Product_name
ORDER BY TotalSales ASC
LIMIT 10;

-- Products with increasing/declining YearlySales
WITH CTE_YearlySales AS(
SELECT 
    year(F.Order_Date) AS YearDate, 
    --month(F.Order_Date) AS MonthDate,
    P.Product_name,
    SUM(F.Sales) AS TotalSales,
    COUNT(P.Product_name) AS TotalProductsCount
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY YearDate,P.Product_name
)
SELECT 
    Product_name,
    YearDate,
    --MonthDate,
    TotalSales,
    LAG(TotalSales) OVER(PARTITION BY Product_name ORDER BY YearDate) AS PreviousYearSales,
    CASE 
        WHEN TotalSales > PreviousYearSales  THEN 'Increasing'
        WHEN TotalSales < PreviousYearSales THEN 'Decreasing'
        ELSE 'Stable'
    END AS YearlySalesTrend
FROM CTE_YearlySales;


-- Products with increasing/declining MonthlySales
WITH CTE_MonthlySales AS(
SELECT 
    --year(F.Order_Date) AS YearDate, 
    month(F.Order_Date) AS MonthDate,
    P.Product_name AS Product_name,
    SUM(F.Sales) AS TotalSales,
    COUNT(P.Product_name) AS TotalProductsCount
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY MonthDate,P.Product_name
)
SELECT 
    Product_name,
    --YearDate,
    MonthDate,
    TotalSales,
    LAG(TotalSales) OVER(PARTITION BY Product_name ORDER BY MonthDate) AS PreviousMonthSales,
    CASE 
        WHEN TotalSales > PreviousMonthSales  THEN 'Increasing'
        WHEN TotalSales < PreviousMonthSales THEN 'Decreasing'
        WHEN TotalSales = PreviousMonthSales THEN 'Stable'
        ELSE 'others'
    END AS MonthlySalesTrend
FROM CTE_MonthlySales;

-- Products with increasing/declining YearlyMonthlySales
WITH CTE_YearlyMonthlySales AS(
SELECT 
    year(F.Order_Date) AS YearDate, 
    month(F.Order_Date) AS MonthDate,
    P.Product_name AS Product_name,
    SUM(F.Sales) AS TotalSales,
    COUNT(P.Product_name) AS TotalProductsCount
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY YearDate,MonthDate,P.Product_name
)
SELECT 
    Product_name,
    YearDate,
    MonthDate,
    TotalSales,
    LAG(TotalSales) OVER(PARTITION BY Product_name ORDER BY YearDate,MonthDate) AS PreviousSales,
    CASE 
        WHEN TotalSales > PreviousSales  THEN 'Increasing'
        WHEN TotalSales < PreviousSales THEN 'Decreasing'
        WHEN TotalSales = PreviousSales THEN 'Stable'
        ELSE 'others'
    END AS YearlyMonthlySalesTrend
FROM CTE_YearlyMonthlySales;


