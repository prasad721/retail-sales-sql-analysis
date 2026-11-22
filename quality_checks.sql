-- SQL Server. Run after loading the seed data. Every FailureCount should be 0.
SELECT 'Orders without line items' AS QualityCheck, COUNT(*) AS FailureCount
FROM Orders AS o LEFT JOIN OrderItems AS i ON i.OrderID = o.OrderID
WHERE i.OrderID IS NULL
UNION ALL
SELECT 'Cancelled orders with recorded returns', COUNT(*)
FROM Orders AS o JOIN OrderItems AS i ON i.OrderID = o.OrderID
WHERE o.OrderStatus = 'Cancelled' AND i.ReturnedQuantity > 0
UNION ALL
SELECT 'Orders outside dataset year', COUNT(*)
FROM Orders WHERE OrderDate < '2025-01-01' OR OrderDate >= '2026-01-01'
UNION ALL
SELECT 'Unexpected table counts',
    CASE WHEN (SELECT COUNT(*) FROM Customers) = 1800
          AND (SELECT COUNT(*) FROM Products) = 40
          AND (SELECT COUNT(*) FROM Orders) = 6400 THEN 0 ELSE 1 END;
