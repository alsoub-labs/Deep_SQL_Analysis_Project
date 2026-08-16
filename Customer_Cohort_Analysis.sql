


-- #########################
-- Customer Cohort Analysis
-- #########################

-- analyze customers according to their first purchase month/year.
-- This tells us whether newer customers are becoming more or less loyal

WITH CTE_CohortMonth AS (
SELECT 
    C.Customer_ID,
    --MIN(F.Order_Date) AS FirstDate,
    make_date(YEAR(min(F.Order_Date)),MONTH(min(F.Order_Date)),1)   AS CohortMonth
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL 
GROUP BY C.Customer_ID
)
SELECT 
    --FirstDate,
    CohortMonth,
    count(*) AS Cohort
FROM CTE_CohortMonth
GROUP BY CohortMonth;

--  How many customers from each cohort continued purchasing in later months? ??

WITH CTE_CohortMonth AS (
SELECT 
    C.Customer_ID,
    make_date(YEAR(min(F.Order_Date)),MONTH(min(F.Order_Date)),1)   AS CohortMonth
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL 
GROUP BY C.Customer_ID
),CTE_CustomerActivity AS (
SELECT 
    C.Customer_ID,
    make_date(YEAR(F.Order_Date),MONTH(F.Order_Date),1)   AS CustomerActivityMonth
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL 
)

SELECT 
CTE_CO.cohortmonth,
CTE_CU.customeractivitymonth,
count(*) AS Active_Customers 
FROM CTE_CustomerActivity AS CTE_CU
RIGHT JOIN cte_cohortmonth AS CTE_CO
ON CTE_CU.Customer_ID = CTE_CO.Customer_ID
GROUP BY CTE_CO.cohortmonth,CTE_CU.customeractivitymonth
ORDER BY CTE_CO.cohortmonth,CTE_CU.customeractivitymonth;

--############################

WITH CTE_CohortYear AS (
SELECT 
    C.Customer_ID,
    YEAR(min(F.Order_Date))   AS CohortYear
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL 
GROUP BY C.Customer_ID
),CTE_CustomerActivity AS (
SELECT 
    C.Customer_ID,
    --make_date(YEAR(F.Order_Date),MONTH(F.Order_Date),1)   AS CustomerActivityMonth
    YEAR(F.Order_Date)  AS CustomerActivityYear
 FROM bara_slaes_project.gold.factable AS F
LEFT JOIN bara_slaes_project.gold.dimcustomer_info AS C
ON F.Customer_srgk = C.Customer_srgk
WHERE C.Customer_ID IS NOT NULL 
)

SELECT 
CTE_CO.CohortYear,
CTE_CU.CustomerActivityYear,
count(*) AS Active_Customers ,
concat(CAST(Active_Customers *100 /first_value(count(*)) OVER (
    PARTITION BY CTE_CO.CohortYear ORDER BY CTE_CU.CustomerActivityYear) AS DECIMAL (5,1) ),'%') AS RetentionPercentage  
FROM CTE_CustomerActivity AS CTE_CU
LEFT JOIN cte_CohortYear AS CTE_CO
ON CTE_CU.Customer_ID = CTE_CO.Customer_ID
GROUP BY CTE_CO.CohortYear,CTE_CU.CustomerActivityYear
ORDER BY CTE_CO.CohortYear,CTE_CU.CustomerActivityYear;


-- ##################








