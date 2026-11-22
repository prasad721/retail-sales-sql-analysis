-- 1. Total revenue, units and transactions
SELECT SUM(Quantity * UnitPrice) AS TotalRevenue,
       SUM(Quantity) AS UnitsSold,
       COUNT(*) AS Transactions
FROM Sales;

-- 2. Monthly revenue trend
SELECT YEAR(OrderDate) AS SalesYear,
       MONTH(OrderDate) AS SalesMonth,
       SUM(Quantity * UnitPrice) AS Revenue
FROM Sales
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;

-- 3. Revenue and units by category, including categories with no sales
SELECT p.Category,
       COALESCE(SUM(s.Quantity), 0) AS UnitsSold,
       COALESCE(SUM(s.Quantity * s.UnitPrice), 0) AS Revenue
FROM Products AS p
LEFT JOIN Sales AS s ON p.ProductID = s.ProductID
GROUP BY p.Category
ORDER BY Revenue DESC, p.Category;

-- 4. Products with at least $100 in revenue
SELECT p.ProductName, SUM(s.Quantity * s.UnitPrice) AS Revenue
FROM Products AS p
INNER JOIN Sales AS s ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.ProductName
HAVING SUM(s.Quantity * s.UnitPrice) >= 100
ORDER BY Revenue DESC, p.ProductName;
