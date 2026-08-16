
-- Product Pareto Analysis
-- Do 20% of our products generate 80% of sales?
-- Which products are essential?,Which products contribute very little?,Should we reconsider low-performing products?


-- Sales Per Product
SELECT
    P.Product_name AS ProductName,
        SUM(F.Sales) AS ProductSales
    FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
    GROUP BY ProductName;



-- Cumulative Sales Per Product
WITH CTE_ProductSales AS
(
SELECT
        P.Product_name AS ProductName,
        SUM(F.Sales) AS ProductSales
    FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
    GROUP BY ProductName
),CTE_ProductAnalysis AS
(
SELECT
    ProductName,
    ProductSales,
    ROW_NUMBER() OVER ( ORDER BY ProductSales DESC) AS ProductRank,
    SUM(ProductSales) OVER (
      ORDER BY ProductSales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeSales,
    SUM(ProductSales) OVER () AS TotalSales
    FROM CTE_ProductSales
)
SELECT
    ProductRank,
    ProductName,
    ProductSales,
    CumulativeSales,
    CAST( CumulativeSales * 100.0 / TotalSales AS DECIMAL(10,2) ) AS CumulativeSalesPercentage

FROM CTE_ProductAnalysis
ORDER BY ProductRank;



WITH CTE_ProductSales AS
(
  SELECT
        P.Product_name AS ProductName,
        SUM(F.Sales) AS ProductSales
    FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
    GROUP BY ProductName
),ProductAnalysis AS
(
SELECT
      ProductName,
      ProductSales,
      ROW_NUMBER() OVER (ORDER BY ProductSales DESC) AS ProductRank,
      COUNT(*) OVER () AS TotalProducts,
      SUM(ProductSales) OVER () AS TotalSales,
      SUM(ProductSales) OVER (
            ORDER BY ProductSales DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Cumulative_Sales
    FROM CTE_ProductSales
)

SELECT
    ProductRank,
    ProductName,
    ProductSales,
    CAST(
        ProductRank * 100.0 / TotalProducts
        AS DECIMAL(10,2)
    ) AS PercentageOfProducts,

    CAST(
        Cumulative_Sales * 100.0 / TotalSales
        AS DECIMAL(10,2)
    ) AS CumulativeSalesPercentage

FROM ProductAnalysis
ORDER BY ProductRank;


WITH CTE_ProductSales AS
(
    SELECT
        P.Product_name AS ProductName,
        SUM(F.Sales) AS ProductSales
    FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
    GROUP BY ProductName
),CTE_ProductAnalysis AS
(
    SELECT
      ProductName,
      ProductSales,
      ROW_NUMBER() OVER (ORDER BY ProductSales DESC) AS ProductRank,
      COUNT(*) OVER () AS TotalProducts,
      SUM(ProductSales) OVER () AS TotalSales,
      SUM(ProductSales) OVER (
            ORDER BY ProductSales DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeSales
    FROM CTE_ProductSales
)
SELECT
    COUNT(*) AS ProductsRequiredFor_80_PercentSales,

    MAX(TotalProducts) AS Total_Products,

    CAST(
        COUNT(*) * 100.0 / MAX(TotalProducts)
        AS DECIMAL(10,2)
    ) AS Percentage_Of_Products,

    CAST(
        MAX(CumulativeSales) * 100.0 / MAX(TotalSales)
        AS DECIMAL(10,2)
    ) AS PercentageOfSales

FROM CTE_ProductAnalysis
WHERE CumulativeSales <= TotalSales * 0.80;


WITH CTE_ProductSales AS
(
    SELECT
        P.Product_name AS ProductName,
        SUM(F.Sales) AS ProductSales
    FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
    GROUP BY ProductName
),CTE_ProductAnalysis AS
(
    SELECT
        ProductName,
        ProductSales,

        ROW_NUMBER() OVER (
            ORDER BY ProductSales DESC
        ) AS ProductRank,

        SUM(ProductSales) OVER () AS TotalSales,

        SUM(ProductSales) OVER (
            ORDER BY ProductSales DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeSales

    FROM CTE_ProductSales
)

SELECT
    ProductRank,
    ProductName,
    ProductSales,

    CAST(
        CumulativeSales * 100.0 / TotalSales
        AS DECIMAL(10,2)
    ) AS CumulativeSalesPercentage,

    CASE
        WHEN CumulativeSales <= TotalSales * 0.80
            THEN 'Essential'
        ELSE 'Low Contribution'
    END AS Product_Classification

FROM CTE_ProductAnalysis
ORDER BY ProductRank;



