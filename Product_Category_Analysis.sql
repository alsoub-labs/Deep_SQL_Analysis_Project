

-- ##########################
-- Product Category Analysis
-- #########################

-- Which categories are driving the business?

WITH CTE_CategoriesSales AS 
(

SELECT 
    P.Category_Name AS CategoryName,
    SUM(F.Sales) AS TotalSales
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY P.Category_Name
),CTE_CategoriesSales2 AS
(
SELECT 
    CategoryName,
    TotalSales,
    SUM(TotalSales) OVER() AS Total_Sales_By_Category
FROM CTE_CategoriesSales
)
SELECT 
    CategoryName,
    TotalSales,
    round(TotalSales/Total_Sales_By_Category,2) AS ProdcutTotalSalesPercentage
 FROM CTE_CategoriesSales2;


-- Which product lines are performing well within each category?

-- Best product line overall

SELECT
    P.Product_Line AS ProductLine,
    SUM(F.Sales) AS TotalSales
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY ProductLine
ORDER BY TotalSales DESC;

-- Best product line within each category
SELECT
    P.Category_Name AS CategoryName,
    P.Product_Line AS ProductLine,
    SUM(F.Sales) AS TotalSales
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY CategoryName,ProductLine
ORDER BY TotalSales DESC;


-- Worst product line within each category 
SELECT
    P.Category_Name AS CategoryName,
    P.Product_Line AS ProductLine,
    SUM(F.Sales) AS TotalSales
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY CategoryName,ProductLine
ORDER BY TotalSales ASC;

-- Sales contribution of each product line
WITH CTE_ProductLineSalescontribution AS
(
SELECT
    P.Category_Name AS CategoryName,
    P.Product_Line AS ProductLine,
    SUM(F.Sales) AS TotalSales
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
GROUP BY CategoryName,ProductLine
ORDER BY TotalSales DESC
)
SELECT
    CategoryName,
    ProductLine,
    TotalSales,
    TotalSales/sum(TotalSales) OVER() AS TotalSalesPercentage
FROM CTE_ProductLineSalescontribution;

