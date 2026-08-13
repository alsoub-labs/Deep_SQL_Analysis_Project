select 

--  ################################
--       Sales Trend Analysis
--  ################################


-- Are sales growing or declining?

v
-- Monthly sales
SELECT 
    date_format(Order_Date, 'yyyy-MM') AS SalesMonth ,
    SUM(Sales) AS TotalSales
FROM bara_slaes_project.gold.factable
GROUP BY SalesMonth;


-- Total sales by year
SELECT 
    year(Order_Date) AS SalesYear,
    SUM(Sales) AS TotalSales
FROM bara_slaes_project.gold.factable
GROUP BY SalesYear;


-- Total sales by month,-- Number of orders by month,-- Average order value by month
SELECT 
    month(Order_Date) AS Month,
    SUM(Sales) AS TotalSales,
    count(Order_Number) AS TotalOrders,
    avg(Sales) AS AvgOrderValue
FROM bara_slaes_project.gold.factable
GROUP BY Month;



-- Are sales increasing? -- Which month had the highest sales?-- Which month had the lowest?
WITH MonthlySales AS (
    SELECT 
        YEAR(Order_Date) AS SalesYear,
        MONTH(Order_Date) AS SalesMonth,
        SUM(Sales) AS TotalSales
    FROM bara_slaes_project.gold.factable
    GROUP BY YEAR(order_date), MONTH(order_date)
),
SalesComparison AS (
    SELECT 
        SalesYear,
        SalesMonth,
        TotalSales,
        LAG(TotalSales, 1) OVER (ORDER BY SalesYear, SalesMonth) AS PreviousSales
    FROM MonthlySales
)
SELECT 
    SalesYear,
    SalesMonth,
    TotalSales,
    PreviousSales,
    (TotalSales - PreviousSales) AS SalesDifference,
    CASE 
        WHEN TotalSales > PreviousSales THEN 'Increasing'
        WHEN TotalSales < PreviousSales THEN 'Decreasing'
        ELSE 'No Change'
    END AS Trend
FROM SalesComparison;



-- Are there seasonal patterns?
WITH MonthlySales AS (
    SELECT 
        YEAR(order_date) AS SalesYear,
        MONTH(order_date) AS SalesMonth,
        SUM(Sales) AS MonthlyTotal
    FROM bara_slaes_project.gold.factable
    GROUP BY YEAR(order_date), MONTH(order_date)
),
OverallAverage AS (
    SELECT AVG(MonthlyTotal) AS GlobalAvg FROM MonthlySales
)
SELECT 
    m.SalesMonth,
    AVG(m.MonthlyTotal) AS AvgSalesForMonth,
    (AVG(m.MonthlyTotal) / o.GlobalAvg) AS SeasonalityIndex
FROM MonthlySales m
CROSS JOIN OverallAverage o
GROUP BY m.SalesMonth, o.GlobalAvg
ORDER BY m.SalesMonth;


-- Year-over-Year Growth
--How much did our business grow compared with the previous year?
SELECT YEAR(Order_Date) AS Year,
       SUM(Sales) AS TotalSales,
       LAG(SUM(Sales), 1) OVER (ORDER BY YEAR(Order_Date)) AS PreviousYearSales,
       TotalSales-PreviousYearSales AS YoY_Growth,
       ((TotalSales-PreviousYearSales)/previousyearsales) * 100
        / LAG(SUM(Sales), 1) OVER (ORDER BY YEAR(Order_Date)) * 100 AS YoY_Growth_Percentage
FROM bara_slaes_project.gold.factable   
GROUP BY YEAR(Order_Date);


