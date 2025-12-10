-- ==========================================================
-- queries_mysql.sql — Farmers Market app queries
-- Runs directly in MySQL / MySQL Workbench (no ? placeholders)
-- Change the SET @... values to test different cases.
-- ==========================================================

-- -----------------------------------------
-- Default parameter values  (edit as needed)
-- -----------------------------------------
SET @eventId              = 1;                -- used for event-based queries
SET @categoryId           = NULL;             -- NULL = no category filter
SET @search               = NULL;             -- e.g. 'kale' (NULL = no search)

SET @daysLookback         = 30;               -- for latest price query

SET @userId               = 1;                -- for customer history

SET @startDate            = '2025-06-01';     -- for date-range queries
SET @endDate              = '2025-06-30';

SET @vendorId             = 1;                -- for vendor revenue
SET @lowStockThreshold    = 10;               -- for low stock alerts

SET @cartEventId          = 1;                -- for cart availability check

SET @alsoBoughtProductId  = 1;                -- product to base "also bought" on

-- ==========================================================
-- 1) Markets list with city and next scheduled event date
-- ==========================================================
SELECT
  m.MarketID,
  m.Name AS MarketName,
  l.City,
  l.Region,
  l.Zip,
  MIN(CASE WHEN me.EventDate >= CURDATE() THEN me.EventDate END) AS NextEventDate,
  m.OpenTime,
  m.CloseTime
FROM Market m
LEFT JOIN Location l   ON l.LocationID = m.LocationID
LEFT JOIN MarketEvent me ON me.MarketID  = m.MarketID
GROUP BY
  m.MarketID,
  m.Name,
  l.City,
  l.Region,
  l.Zip,
  m.OpenTime,
  m.CloseTime
ORDER BY l.City, m.Name;

-- ==========================================================
-- 2) Event roster: vendors attending @eventId (with booth)
-- ==========================================================
SELECT
  me.EventID,
  me.EventDate,
  m.Name AS MarketName,
  v.VendorID,
  v.Name AS VendorName,
  mv.BoothNumber,
  mv.Status
FROM MarketEvent me
JOIN Market       m  ON m.MarketID   = me.MarketID
JOIN MarketVendor mv ON mv.EventID   = me.EventID
JOIN Vendor       v  ON v.VendorID   = mv.VendorID
WHERE me.EventID = @eventId
ORDER BY v.Name;

-- ==========================================================
-- 3) Product catalog for @eventId with stock and filters
--    - @categoryId: filter by category (NULL = no filter)
--    - @search: search by product name (NULL = no search)
-- ==========================================================
SELECT
  p.ProductID,
  p.Name AS ProductName,
  pc.Name AS Category,
  v.VendorID,
  v.Name AS Vendor,
  i.AvailableQuantity - i.ReservedQuantity AS QtyAvailable
FROM Inventory i
JOIN Product p         ON p.ProductID   = i.ProductID
JOIN Vendor v          ON v.VendorID    = i.VendorID
LEFT JOIN ProductCategory pc ON pc.CategoryID = p.CategoryID
WHERE i.EventID = @eventId
  AND (@categoryId IS NULL OR p.CategoryID = @categoryId)
  AND (@search    IS NULL OR p.Name LIKE CONCAT('%', @search, '%'))
  AND (i.AvailableQuantity - i.ReservedQuantity) > 0
ORDER BY pc.Name, p.Name;

-- ==========================================================
-- 4) Latest price observed for each product in last @daysLookback days
-- ==========================================================
SELECT
  p.ProductID,
  p.Name,
  (
    SELECT oi.UnitPrice
    FROM OrderItem oi
    JOIN `order` o ON o.OrderID = oi.OrderID
    WHERE oi.ProductID = p.ProductID
      AND o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL @daysLookback DAY)
    ORDER BY o.OrderDate DESC
    LIMIT 1
  ) AS LatestPrice
FROM Product p;

-- ==========================================================
-- 5) Customer order history for @userId
-- ==========================================================
SELECT
  o.OrderID,
  o.OrderDate,
  o.PickupDate,
  o.TotalAmount,
  COUNT(oi.OrderItemID) AS LineItems,
  o.PaymentStatus,
  o.PickupStatus,
  me.EventDate,
  m.Name AS MarketName
FROM `order` o
LEFT JOIN OrderItem   oi ON oi.OrderID  = o.OrderID
LEFT JOIN MarketEvent me ON me.EventID  = o.EventID
LEFT JOIN Market      m  ON m.MarketID  = me.MarketID
WHERE o.UserID = @userId
GROUP BY
  o.OrderID,
  o.OrderDate,
  o.PickupDate,
  o.TotalAmount,
  o.PaymentStatus,
  o.PickupStatus,
  me.EventDate,
  m.Name
ORDER BY o.OrderDate DESC;

-- ==========================================================
-- 6) Top-selling products by quantity in [@startDate, @endDate]
-- ==========================================================
SELECT
  p.ProductID,
  p.Name,
  SUM(oi.Quantity) AS UnitsSold
FROM OrderItem oi
JOIN `order`  o ON o.OrderID  = oi.OrderID
JOIN Product p ON p.ProductID = oi.ProductID
WHERE o.OrderDate >= @startDate
  AND o.OrderDate < DATE_ADD(@endDate, INTERVAL 1 DAY)
GROUP BY p.ProductID, p.Name
ORDER BY UnitsSold DESC
LIMIT 10;

-- ==========================================================
-- 7) Vendor revenue per event for @vendorId in [@startDate, @endDate]
-- ==========================================================
SELECT
  v.VendorID,
  v.Name AS Vendor,
  me.EventID,
  me.EventDate,
  m.Name AS Market,
  SUM(oi.Quantity * oi.UnitPrice) AS GrossRevenue
FROM OrderItem oi
JOIN Product     p  ON p.ProductID = oi.ProductID
JOIN Vendor      v  ON v.VendorID  = p.VendorID
JOIN `order`      o  ON o.OrderID   = oi.OrderID
LEFT JOIN MarketEvent me ON me.EventID = o.EventID
LEFT JOIN Market      m  ON m.MarketID = me.MarketID
WHERE v.VendorID = @vendorId
  AND o.OrderDate >= @startDate
  AND o.OrderDate < DATE_ADD(@endDate, INTERVAL 1 DAY)
GROUP BY
  v.VendorID,
  v.Name,
  me.EventID,
  me.EventDate,
  m.Name
ORDER BY me.EventDate;

-- ==========================================================
-- 8) Low-stock alert for @eventId (threshold = @lowStockThreshold)
-- ==========================================================
SELECT
  p.ProductID,
  p.Name,
  v.Name AS Vendor,
  (i.AvailableQuantity - i.ReservedQuantity) AS QtyAvailable
FROM Inventory i
JOIN Product p ON p.ProductID = i.ProductID
JOIN Vendor  v ON v.VendorID  = i.VendorID
WHERE i.EventID = @eventId
  AND (i.AvailableQuantity - i.ReservedQuantity) <= @lowStockThreshold
ORDER BY QtyAvailable ASC, p.Name;

-- ==========================================================
-- 9) Cart availability check for @cartEventId
--    Requires a temporary table Cart(ProductID INT, Qty INT)
--    Example:
--      CREATE TEMPORARY TABLE Cart (ProductID INT, Qty INT);
--      INSERT INTO Cart VALUES (1, 2), (11, 1);
-- ==========================================================

CREATE TEMPORARY TABLE Cart (
  ProductID INT NOT NULL,
  Qty       INT NOT NULL
);

-- Add some test items to this "cart"
INSERT INTO Cart (ProductID, Qty) VALUES
  (1, 2),     -- 2 of product 1
  (11, 1),    -- 1 of product 11
  (19, 3);    -- 3 of product 19

SELECT
  c.ProductID,
  p.Name,
  c.Qty AS Requested,
  GREATEST(
    0,
    c.Qty - GREATEST(0, (i.AvailableQuantity - i.ReservedQuantity))
  ) AS Shortfall
FROM Cart c
JOIN Product p ON p.ProductID = c.ProductID
LEFT JOIN Inventory i
  ON i.ProductID = c.ProductID
 AND i.EventID   = @cartEventId
ORDER BY p.Name;

-- ==========================================================
-- 10) “Customers also bought” suggestions
--     For base product @alsoBoughtProductId, return @alsoBoughtLimit suggestions
-- ==========================================================
SELECT
  p2.ProductID,
  p2.Name,
  pc.Name AS Category,
  COUNT(*) AS TogetherCount
FROM OrderItem oi1
JOIN OrderItem oi2
  ON oi2.OrderID  = oi1.OrderID
 AND oi2.ProductID <> oi1.ProductID
JOIN Product p1 ON p1.ProductID = oi1.ProductID
JOIN Product p2 ON p2.ProductID = oi2.ProductID
LEFT JOIN ProductCategory pc ON pc.CategoryID = p2.CategoryID
WHERE oi1.ProductID = @alsoBoughtProductId
GROUP BY
  p2.ProductID,
  p2.Name,
  pc.Name
ORDER BY TogetherCount DESC
LIMIT 5;
