-- SQL Server. Run after setup.sql and seed.sql.
-- Build a fulfilled line-level fact table for reusable metric definitions.
DROP TABLE IF EXISTS #Sales;
SELECT o.OrderID, o.CustomerID, o.Channel, o.OrderDate,
       SUBSTRING(CONVERT(varchar(10), o.OrderDate, 23), 1, 7) AS SalesMonth,
       c.Region, c.Segment, p.ProductID, p.ProductName, p.Category,
       i.Quantity, i.ReturnedQuantity,
       i.Quantity - i.ReturnedQuantity AS NetUnits,
       CAST((i.Quantity - i.ReturnedQuantity) * i.UnitPrice
           * (100 - i.DiscountPct) / 100.0 AS decimal(18,2)) AS NetSales,
       CAST((i.Quantity - i.ReturnedQuantity) * p.UnitCost AS decimal(18,2)) AS NetCost
INTO #Sales
FROM Orders AS o
JOIN Customers AS c ON c.CustomerID = o.CustomerID
JOIN OrderItems AS i ON i.OrderID = o.OrderID
JOIN Products AS p ON p.ProductID = i.ProductID
WHERE o.OrderStatus = 'Completed';

-- 1. Executive KPIs
SELECT COUNT(DISTINCT OrderID) AS CompletedOrders, COUNT(DISTINCT CustomerID) AS Buyers,
       SUM(NetUnits) AS NetUnits, SUM(NetSales) AS NetSales,
       SUM(NetSales - NetCost) AS GrossProfit,
       ROUND(100.0 * SUM(NetSales - NetCost) / NULLIF(SUM(NetSales), 0), 2) AS GrossMarginPct,
       ROUND(1.0 * SUM(NetSales) / NULLIF(COUNT(DISTINCT OrderID), 0), 2) AS AverageOrderValue
FROM #Sales;

-- 2. Monthly trend and month-over-month sales growth
WITH Monthly AS (
    SELECT SalesMonth, SUM(NetSales) AS NetSales, COUNT(DISTINCT OrderID) AS Orders
    FROM #Sales GROUP BY SalesMonth
), Comparison AS (
    SELECT *, LAG(NetSales) OVER (ORDER BY SalesMonth) AS PriorMonthSales
    FROM Monthly
)
SELECT SalesMonth, Orders, NetSales,
       ROUND(100.0 * (NetSales - PriorMonthSales) / NULLIF(PriorMonthSales, 0), 2) AS MoMGrowthPct
FROM Comparison ORDER BY SalesMonth;

-- 3. Category contribution, profitability and unit return rate
SELECT Category, SUM(NetSales) AS NetSales, SUM(NetSales - NetCost) AS GrossProfit,
       ROUND(100.0 * SUM(NetSales - NetCost) / NULLIF(SUM(NetSales), 0), 2) AS MarginPct,
       ROUND(100.0 * SUM(ReturnedQuantity) / NULLIF(SUM(Quantity), 0), 2) AS UnitReturnRatePct
FROM #Sales GROUP BY Category ORDER BY NetSales DESC;

-- 4. Top three revenue ranks per category, retaining ties
WITH ProductTotals AS (
    SELECT Category, ProductID, ProductName, SUM(NetSales) AS NetSales
    FROM #Sales GROUP BY Category, ProductID, ProductName
), Ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY Category ORDER BY NetSales DESC) AS RevenueRank
    FROM ProductTotals
)
SELECT Category, ProductName, NetSales, RevenueRank
FROM Ranked WHERE RevenueRank <= 3 ORDER BY Category, RevenueRank, ProductID;

-- 5. Channel performance across regions
SELECT Region, Channel, COUNT(DISTINCT OrderID) AS CompletedOrders,
       SUM(NetSales) AS NetSales, SUM(NetSales - NetCost) AS GrossProfit
FROM #Sales GROUP BY Region, Channel ORDER BY Region, NetSales DESC;

-- 6. Repeat buyer rate by customer segment
WITH BuyerOrders AS (
    SELECT Segment, CustomerID, COUNT(DISTINCT OrderID) AS OrderCount
    FROM #Sales GROUP BY Segment, CustomerID
)
SELECT Segment, COUNT(*) AS Buyers,
       SUM(CASE WHEN OrderCount >= 2 THEN 1 ELSE 0 END) AS RepeatBuyers,
       ROUND(100.0 * SUM(CASE WHEN OrderCount >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS RepeatBuyerPct
FROM BuyerOrders GROUP BY Segment ORDER BY Segment;

-- 7. Compare first and second calendar months by acquisition cohort.
-- December has no observable month one in the 2025 dataset.
WITH Activity AS (
    SELECT DISTINCT CustomerID, SalesMonth FROM #Sales
), Cohorts AS (
    SELECT CustomerID, MIN(SalesMonth) AS CohortMonth FROM Activity GROUP BY CustomerID
)
SELECT c.CohortMonth, COUNT(*) AS NewBuyers,
       CASE WHEN c.CohortMonth < '2025-12' THEN COUNT(a.CustomerID) END AS ActiveNextMonth,
       CASE WHEN c.CohortMonth < '2025-12' THEN ROUND(100.0 * COUNT(a.CustomerID) / COUNT(*), 2) END AS NextMonthPct
FROM Cohorts AS c
LEFT JOIN Activity AS a ON a.CustomerID = c.CustomerID
    AND DATEDIFF(month, CAST(c.CohortMonth + '-01' AS date), CAST(a.SalesMonth + '-01' AS date)) = 1
GROUP BY c.CohortMonth ORDER BY c.CohortMonth;

-- 8. Operational cancellation rates include all placed orders.
SELECT Channel, COUNT(*) AS PlacedOrders,
       SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
       ROUND(100.0 * SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS CancellationPct
FROM Orders GROUP BY Channel ORDER BY CancellationPct DESC, Channel;

DROP TABLE #Sales;
