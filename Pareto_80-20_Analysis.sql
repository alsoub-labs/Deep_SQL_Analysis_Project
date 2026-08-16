-- Do a small number of customers generate most of our revenue?
-- This can tell us whether the company is heavily dependent on a small group of customers.
WITH CTE_customers_revenue AS (
  SELECT
    C.Customer_ID AS CustomerID,
    F.Sales AS Revenue,
    percent_rank() OVER (ORDER BY F.Sales ASC) AS PercentileRank
  FROM
    bara_slaes_project.gold.factable AS F
      LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
        ON F.Customer_srgk = C.Customer_srgk
  WHERE
    c.Customer_ID IS NOT NULL
),
CTE_CustomerPercentileRankSegment AS (
  SELECT
    CustomerID,
    CASE
      WHEN PercentileRank >= 0.9 THEN 'Top 10 % Customers'
      WHEN PercentileRank >= 0.8 THEN 'Top 20 % Customers'
      WHEN PercentileRank >= 0.5 THEN 'Top 50 % Customers'
      ELSE 'Bottom 50 % Customers'
    End AS CustomerPercentileRankSegment
  FROM
    CTE_customers_revenue
),
CTE_TotalCustomersPercent AS (
  SELECT
    CTER.CustomerPercentileRankSegment,
    Count(*) AS TotalCustomers,
    round(totalcustomers / SUM(Count(*)) OVER (), 2) AS TotalCustomersPercent
  FROM
    CTE_CustomerPercentileRankSegment AS CTER
      LEFT JOIN cte_customers_revenue AS CTECR
        ON CTER.CustomerID = CTECR.CustomerID
  GROUP BY
    CTER.CustomerPercentileRankSegment
),
CTE_TotalRevenuePercent AS (
  SELECT
    CTER.CustomerPercentileRankSegment,
    Sum(CTECR.Revenue) AS TotalRevenue,
    round(TotalRevenue / Sum(Sum(CTECR.Revenue)) OVER (), 2) AS TotalRevenuePercent
  FROM
    CTE_customers_revenue AS CTECR
      LEFT JOIN CTE_CustomerPercentileRankSegment AS CTER
        ON CTECR.customerid = CTER.customerid
  GROUP BY
    CTER.CustomerPercentileRankSegment
)
SELECT
  CTECP.customerpercentileranksegment AS CustomerPercentileRankSegment,
  CTECP.totalcustomers AS TotalCustomers,
  CTECP.totalcustomerspercent AS TotalCustomersPercent,
  CTECRP.totalrevenue AS TotalRevenue,
  CTECRP.totalrevenuepercent AS TotalRevenuePercent
FROM
  CTE_TotalCustomersPercent AS CTECP
    LEFT JOIN CTE_TotalRevenuePercent AS CTECRP
      ON CTECP.CustomerPercentileRankSegment = CTECRP.CustomerPercentileRankSegment
WHERE
  CTECP.CustomerPercentileRankSegment <> 'Bottom 50 % Customers'
ORDER BY
  CTECP.CustomerPercentileRankSegment;


  -- Do a small number of customers generate most of our revenue?
WITH CTE_Customer_Total_Revenue AS (
  SELECT
    C.Customer_ID AS CustomerID,
    SUM(F.Sales) AS TotalCustomerRevenue,
    -- Rank customers based on their TOTAL lifetime value, not single sales
    PERCENT_RANK() OVER (ORDER BY SUM(F.Sales) ASC) AS PercentileRank
  FROM bara_slaes_project.gold.factable AS F
  LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
    ON F.Customer_srgk = C.Customer_srgk
  WHERE C.Customer_ID IS NOT NULL
  GROUP BY C.Customer_ID
),
CTE_Segmented_Customers AS (
  SELECT
    CustomerID,
    TotalCustomerRevenue,
    -- Creates mutually exclusive tiers for clean reporting
    CASE
      WHEN PercentileRank >= 0.90 THEN 'Top 10% Customers'
      WHEN PercentileRank >= 0.80 THEN 'Top 10.01% - 20% Customers'
      WHEN PercentileRank >= 0.50 THEN 'Top 20.01% - 50% Customers'
      ELSE 'Bottom 50% Customers'
    END AS CustomerSegment
  FROM CTE_Customer_Total_Revenue
)
SELECT
  CustomerSegment,
  COUNT(*) AS TotalCustomers,
  ROUND(COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (), 4) AS TotalCustomersPercent,
  SUM(TotalCustomerRevenue) AS TotalRevenue,
  ROUND(SUM(TotalCustomerRevenue) * 1.0 / SUM(SUM(TotalCustomerRevenue)) OVER (), 4) AS TotalRevenuePercent
FROM CTE_Segmented_Customers
-- Optional: Remove if you want to see the full 100% picture for comparison
WHERE CustomerSegment <> 'Bottom 50% Customers' 
GROUP BY CustomerSegment
ORDER BY CustomerSegment ASC;



