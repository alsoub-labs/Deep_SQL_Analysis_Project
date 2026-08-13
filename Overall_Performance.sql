
--  ################################
--  1. Executive Business Questions
--  ################################

--  ################################
--       Overall performance
--  ################################


--  What are our total sales?
SELECT 
    sum(Sales) AS  TotalSales 
FROM bara_slaes_project.gold.factable;


-- How many orders do we have?
SELECT 
    count(Order_Number) AS  TotalOrders 
FROM bara_slaes_project.gold.factable;


-- How many unique customers?
SELECT 
    count(distinct Customer_ID) AS  UuniqueCustomers 
FROM bara_slaes_project.gold.dimcustomer_info;

-- How many products are being sold?






-- Which countries generate the most revenue?
SELECT 
    C.Country As Country,
    Sum(F.Sales) As TotalRevenue,
    Rank() OVER (ORDER BY Sum(F.Sales) DESC) AS TotalRevenueRankByCountry
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
GROUP BY C.Country;

-- Which customers generate the most revenue?
SELECT 
    C.Customer_ID As Customer_ID,
    Sum(F.Sales) As TotalRevenue,
    Rank() OVER (ORDER BY Sum(F.Sales) DESC) AS TotalRevenueRankByCustomer_ID
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL
GROUP BY C.Customer_ID;

-- Which product categories generate the most revenue?
SELECT 
    P.Category_Name As Category_Name,
    Sum(F.Sales) As TotalRevenue,
    Rank() OVER (ORDER BY Sum(F.Sales) DESC) AS TotalRevenueRankByCategory
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info  AS P
ON F.Product_srgk=P.Product_srgk
GROUP BY  P.Category_Name ;


-- Which product lines generate the most revenue?
SELECT 
    P.Product_Line As Product_Line,
    Sum(F.Sales) As TotalRevenue,
    Rank() OVER (ORDER BY Sum(F.Sales) DESC) AS TotalRevenueRankByProductLine
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimproduct_info  AS P
ON F.Product_srgk=P.Product_srgk
GROUP BY  P.Product_Line ;

-- What is the average sales per order?
SELECT 
    Order_Number,
    avg(Sales) AS AvgSalesPerOrder 
FROM bara_slaes_project.gold.factable
GROUP BY Order_Number;

-- What is the average sales per customer?
SELECT 
    C.Customer_ID AS Customer_ID,
    avg(F.Sales) AS AvgSalesPerCustomer
FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk=C.Customer_srgk
GROUP BY Customer_ID;



