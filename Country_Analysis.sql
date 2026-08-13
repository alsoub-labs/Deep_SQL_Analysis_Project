

-- #########################
-- Country Analysis
-- #########################

-- Where are our customers and where are we making money?

-- Analyze:
-- Sales by country,Customers by country,Orders by country,Average order value by country

WITH CTE_Country1 AS 
(
SELECT 
C.Country,
C.Customer_ID,
F.Order_Number,
F.Sales AS Total_Sales
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
WHERE C.Country IS NOT NULL
),CTE_Country2 AS 
(
SELECT 
Country,
SUM(Total_Sales) AS TotalSalesByCountry,
COUNT(DISTINCT Customer_ID) AS TotalCustomersByCountry,
COUNT(DISTINCT Order_Number) AS TotalOrdersByCountry
FROM CTE_Country1
GROUP BY Country
)
SELECT 
country,
TotalSalesByCountry,
TotalCustomersByCountry,
TotalOrdersByCountry,
TotalSalesByCountry/TotalOrdersByCountry AS AvgOrderByCountry
--CAST(TotalSalesByCountry AS DECIMAL(18,2)) / NULLIF(TotalOrdersByCountry, 0)
 FROM CTE_Country2;


 -- Country × Product Category

-- What products are popular in each country Generated highest revenue, and highest volume ?

WITH CTE_Country1 AS 
(
SELECT 
    C.Country,
    P.Product_name,
    count(P.Product_name) AS ProductsCountByCountry,
    SUM(F.Sales) AS TotalSalesByCountry
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk = P.Product_srgk
WHERE C.Country IS NOT NULL
GROUP BY P.Product_name,  C.Country
),CTE_Country2 AS 
(
SELECT 
    Country,
    Product_name,
    TotalSalesByCountry,
    ProductsCountByCountry,
    dense_rank() OVER(PARTITION BY Country ORDER BY TotalSalesByCountry DESC) AS ProductSalesRank,
    dense_rank() OVER(PARTITION BY Country ORDER BY ProductsCountByCountry DESC) AS ProductCountRank
FROM CTE_Country1
)
SELECT 
    Country,
    Product_name,
    TotalSalesByCountry,
    ProductsCountByCountry,
    ProductSalesRank,
    ProductCountRank
FROM CTE_Country2
    WHERE ProductSalesRank = 1 OR ProductCountRank = 1
ORDER BY Country;

---Customer Age × Product Category  , Do different age groups buy different products?


WITH CTE_CustomerAge AS
(
SELECT
        P.Product_name AS Product_name,
        F.Sales AS Sales,
        date_diff(YEAR, C.Date_Of_Birth, current_date()) As CustomerAge 
        
FROM  bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk=P.Product_srgk
WHERE C.Customer_ID IS NOT NULL
),
CTE_AgeGroups AS
(
    SELECT
        Product_name,
        Sales,
        CASE 
        WHEN CustomerAge < 18 THEN 'Under 18'
        WHEN CustomerAge BETWEEN 18 AND 24 THEN '18-24'
        WHEN CustomerAge BETWEEN 25 AND 34 THEN '25-34'
        WHEN CustomerAge BETWEEN 35 AND 44 THEN '35-44'
        WHEN CustomerAge BETWEEN 45 AND 54 THEN '45-54'
        WHEN CustomerAge BETWEEN 55 AND 64 THEN '55-64'
        WHEN CustomerAge BETWEEN 65 AND 74 THEN '65-74'
        WHEN CustomerAge BETWEEN 75 AND 84 THEN '75-84'
        WHEN CustomerAge >= 85 THEN '85+' 
    End   AS CustomerAgeGroup
    FROM CTE_CustomerAge
),CTE_AgeGroups2 AS
(
SELECT 
customeragegroup,
Product_name,
SUM(Sales) AS TotalSales,
avg(Sales) AS AvgSales
 FROM CTE_AgeGroups
 GROUP BY customeragegroup,Product_name
 ORDER BY TotalSales DESC
)
SELECT
 *
 FROM CTE_AgeGroups2;


-- 14. Customer Age × Country  , Which age groups dominate each market?

WITH CTE_CustomerAge AS
(
SELECT
        C.Country AS Country,
        F.Sales AS Sales,
        date_diff(YEAR, C.Date_Of_Birth, current_date()) As CustomerAge 
        
FROM  bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
LEFT JOIN bara_slaes_project.gold.dimproduct_info AS P
ON F.Product_srgk=P.Product_srgk
WHERE C.Customer_ID IS NOT NULL
),
CTE_AgeGroups AS
(
    SELECT
        Country,
        Sales,
        CASE 
        WHEN CustomerAge < 18 THEN 'Under 18'
        WHEN CustomerAge BETWEEN 18 AND 24 THEN '18-24'
        WHEN CustomerAge BETWEEN 25 AND 34 THEN '25-34'
        WHEN CustomerAge BETWEEN 35 AND 44 THEN '35-44'
        WHEN CustomerAge BETWEEN 45 AND 54 THEN '45-54'
        WHEN CustomerAge BETWEEN 55 AND 64 THEN '55-64'
        WHEN CustomerAge BETWEEN 65 AND 74 THEN '65-74'
        WHEN CustomerAge BETWEEN 75 AND 84 THEN '75-84'
        WHEN CustomerAge >= 85 THEN '85+' 
    End   AS CustomerAgeGroup
    FROM CTE_CustomerAge
),CTE_AgeGroups2 AS
(
SELECT 
    Country,
    customeragegroup,
    SUM(Sales) AS TotalSales
 FROM CTE_AgeGroups
 GROUP BY customeragegroup,Country
),CTE_AgeGroups3 AS
(
SELECT
 Country,
 customeragegroup,
 TotalSales,
 dense_rank(TotalSales) OVER(PARTITION BY Country order by TotalSales DESC) AS TotalSalesRankByCountry
 FROM CTE_AgeGroups2
 )
 SELECT * FROM CTE_AgeGroups3
 WHERE TotalSalesRankByCountry =1;


----Average Order Value

SELECT 
    Order_Number,
    AVG(Sales) 
FROM bara_slaes_project.gold.factable
 GROUP BY Order_Number

-- How much does the average customer spend per order?


-- by Country,Product category,Product line Customer age group,Year,Month