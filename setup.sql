-- Run in a new practice database in SQL Server Management Studio.
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    Category VARCHAR(30) NOT NULL
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    ProductID INT NOT NULL REFERENCES Products(ProductID),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0)
);

INSERT INTO Products (ProductID, ProductName, Category) VALUES
(1, 'Keyboard', 'Electronics'),
(2, 'Mouse', 'Electronics'),
(3, 'Notebook', 'Stationery'),
(4, 'Pen Set', 'Stationery'),
(5, 'Desk Lamp', 'Home Office');

INSERT INTO Sales (SaleID, OrderDate, ProductID, Quantity, UnitPrice) VALUES
(1, '20260103', 1, 2, 30.00),
(2, '20260112', 2, 3, 15.00),
(3, '20260120', 3, 5, 4.00),
(4, '20260205', 1, 3, 30.00),
(5, '20260211', 4, 4, 6.00),
(6, '20260218', 3, 6, 4.00),
(7, '20260302', 2, 4, 15.00),
(8, '20260308', 1, 4, 28.00),
(9, '20260316', 4, 5, 6.00),
(10, '20260323', 3, 5, 4.00);
