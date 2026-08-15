-- #############################
--   Customer Purchase Recency
-- #############################


-- When did our customers last purchase?
--For each customer:Customer ID,First Order,Last Order,Number of Orders,Total Sales

--For each customer classify:
--0–30 days     → Active
--31–90 days    → Potentially inactive
--91–180 days   → At risk
--180+ days     → Inactive


WITH CTE_CustomerPurchase AS
(
SELECT 
    C.Customer_ID AS CustomerID ,
    MIN(F.Order_Date) AS FirstOrder,
    MAX(F.Order_Date) AS LastOrder,
    count(DISTINCT F.Order_Number) AS TotalOrders,
    SUM(F.Sales) AS TotalSales,
    date_diff(DAY, FirstOrder , LastOrder) As DayDiffFirstLastOrder 

 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL 
GROUP BY CustomerID
)
SELECT 
*,
CASE
  WHEN DayDiffFirstLastOrder <= 30 THEN 'Active'
  WHEN DayDiffFirstLastOrder > 30 AND DayDiffFirstLastOrder <= 90 THEN 'Potentially inactive'
  WHEN DayDiffFirstLastOrder > 90 AND DayDiffFirstLastOrder <= 180 THEN 'At risk'
  WHEN DayDiffFirstLastOrder > 180 THEN 'Inactive'
 END AS CustomerSegment 
 FROM CTE_CustomerPurchase;
