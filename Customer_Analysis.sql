

-- #######################
--  Who are our customers?
-- #######################

-- We Will Calculate customer age and classify what customer Age belong to which age group

-- Which age group generates the most sales?

WITH CTE_CustomerAge AS
(
SELECT
        C.Customer_ID AS Customer_ID,
        F.Order_Number AS Order_Number,
        F.Sales AS Sales,
        date_diff(YEAR, C.Date_Of_Birth, current_date()) As CustomerAge 

        
FROM  bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL
),
CTE_AgeGroups AS
(
    SELECT
        Customer_ID,
        Order_Number,
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
)
SELECT
    CustomerAgeGroup,
    COUNT(DISTINCT Customer_ID) AS CustomersCounts,
    COUNT(DISTINCT Order_Number) AS OrderscCOUNTS,
    SUM(Sales) AS TotaSlales
FROM CTE_AgeGroups
WHERE CustomerAgeGroup IS NOT NULL
GROUP BY CustomerAgeGroup
ORDER BY
    CASE CustomerAgeGroup
        WHEN '18-24' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        WHEN '55-64' THEN 5
        WHEN '65-74' THEN 6
        WHEN '75-84' THEN 7
        WHEN '85+' THEN 8
    END;


-- #######################
--  Customer Value
-- #######################

--Which customers are most valuable to us?
--Calculate:Total sales per customer,Number of orders per customer,Average order value per customer
--First order date,Last order date

WITH CTE_CustomerValue AS
(
SELECT 
    C.Customer_ID AS Customer_ID,
    F.Order_Number AS Order_Number,
    F.Sales AS Sales,
    min(F.Order_Date) over () AS FirstOrderDate,
    max(F.Order_Date) over () AS LastOrderDate
 FROM bara_slaes_project.gold.factable AS F
    LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
    ON F.Customer_srgk=C.Customer_srgk
 WHERE C.Customer_ID IS NOT NULL
)
SELECT 
    customer_id ,
    count(order_number) AS NumberOfOrdersPerCustomer,
    sum(sales) AS TotalSalesPerCustomer,
    avg(sales) AS AverageOrderValuePerCustomer,
    FirstOrderDate,
    LastOrderDate
 FROM CTE_CustomerValue
 GROUP BY 
    customer_id ,
    FirstOrderDate,
    LastOrderDate
  ORDER BY TotalSalesPerCustomer DESC  ;


-- #######################
--  Customer Segmentation
-- #######################

-- classify customers based on their purchasing behavior
--         VIP       ,      High-value     ,    Medium-value  ,  Low-value 
-- (Sales > $10,000  ,  $5,000 – $10,000  ,  $1,000 – $5,000  ,  < $1,000)

WITH CTE_CustomerSegmentation AS 
(
SELECT 
    C.Customer_ID AS Customer_ID,
    SUM(F.Sales) AS TotalSalesPerCustomer
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL
GROUP BY 
    C.Customer_ID
)
SELECT 
    Customer_ID,
    TotalSalesPerCustomer,
    CASE 
        WHEN TotalSalesPerCustomer > 10000 THEN 'VIP'
        WHEN TotalSalesPerCustomer <= 10000 AND TotalSalesPerCustomer > 5000 THEN 'High-value' 
        WHEN TotalSalesPerCustomer <= 4999 AND TotalSalesPerCustomer >= 1000 THEN 'Medium-value' 
        WHEN TotalSalesPerCustomer < 1000 THEN 'Low-value' 
    END AS CustomerSegment  
FROM CTE_CustomerSegmentation;


---
-- Are customers coming back?
---

--Calculate:Customers with 1 order,Customers with 2 orders ,Customers with 3+ orders

WITH CTE_CustomerOrders AS
(
SELECT 
    C.Customer_ID AS Customer_ID,
    COUNT(F.Order_Number) AS NumberOfOrdersPerCustomer
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL
GROUP BY Customer_ID
) 
SELECT Customer_ID,
    NumberOfOrdersPerCustomer,
    CASE 
        WHEN NumberOfOrdersPerCustomer = 1 THEN 'One Time'
        WHEN NumberOfOrdersPerCustomer = 2 THEN 'Repeat'
        WHEN NumberOfOrdersPerCustomer >= 3 THEN 'Loyal'
    END AS CustomerType  
FROM CTE_CustomerOrders;
        
    
----  Calculate:  Total Customers Loyality Group, and Percent of Customers Loyality Group

WITH CTE_CustomerType AS
(
SELECT 
    C.Customer_ID AS Customer_ID,
    COUNT(F.Order_Number) AS NumberOfOrdersPerCustomer
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL
GROUP BY Customer_ID
) , CTE_CustomerType2 AS
(
SELECT 
    NumberOfOrdersPerCustomer,
    CASE 
        WHEN NumberOfOrdersPerCustomer = 1 THEN 'One Time'
        WHEN NumberOfOrdersPerCustomer = 2 THEN 'Repeat'
        WHEN NumberOfOrdersPerCustomer >= 3 THEN 'Loyal'
    END AS CustomerType  
FROM CTE_CustomerType
), CTE_CustomerType3 AS
(
SELECT 
    CustomerType,
    sum(NumberOfOrdersPerCustomer) AS TotalCustomersPerSegment
FROM CTE_CustomerType2
GROUP BY CustomerType
) 
SELECT CustomerType,
    TotalCustomersPerSegment,
    round(TotalCustomersPerSegment/sum(TotalCustomersPerSegment) over () * 100,2) AS PercentageOfCustomersPerSegment
FROM CTE_CustomerType3
ORDER BY TotalCustomersPerSegment DESC


