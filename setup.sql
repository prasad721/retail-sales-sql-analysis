-- SQL Server. Run once in a fresh practice database before seed.sql.
CREATE TABLE Customers (
    CustomerID int PRIMARY KEY,
    Region varchar(20) NOT NULL,
    Segment varchar(20) NOT NULL
);

CREATE TABLE Products (
    ProductID int PRIMARY KEY,
    ProductName varchar(60) NOT NULL,
    Category varchar(30) NOT NULL,
    UnitCost decimal(10,2) NOT NULL CHECK (UnitCost >= 0)
);

CREATE TABLE Orders (
    OrderID int PRIMARY KEY,
    CustomerID int NOT NULL REFERENCES Customers(CustomerID),
    OrderDate date NOT NULL,
    Channel varchar(20) NOT NULL,
    OrderStatus varchar(12) NOT NULL CHECK (OrderStatus IN ('Completed', 'Cancelled'))
);

CREATE TABLE OrderItems (
    OrderID int NOT NULL REFERENCES Orders(OrderID),
    ProductID int NOT NULL REFERENCES Products(ProductID),
    Quantity int NOT NULL CHECK (Quantity > 0),
    UnitPrice decimal(10,2) NOT NULL CHECK (UnitPrice >= 0),
    DiscountPct int NOT NULL CHECK (DiscountPct BETWEEN 0 AND 100),
    ReturnedQuantity int NOT NULL CHECK (ReturnedQuantity BETWEEN 0 AND Quantity),
    PRIMARY KEY (OrderID, ProductID)
);

CREATE INDEX IX_Orders_Date ON Orders(OrderDate);
CREATE INDEX IX_Orders_Customer ON Orders(CustomerID);
