-- ==========================================================
-- queries.sql — Application queries (MySQL)
-- ==========================================================

-- 1) Markets list with city and next scheduled event date
SELECT
  m.MarketID, m.Name AS MarketName,
  l.City, l.Region, l.Zip,
  MIN(CASE WHEN me.EventDate >= CURDATE() THEN me.EventDate END) AS NextEventDate,
  m.OpenTime, m.CloseTime
FROM Market m
LEFT JOIN Location l ON l.LocationID = m.LocationID
LEFT JOIN MarketEvent me ON me.MarketID = m.MarketID
GROUP BY m.MarketID, m.Name, l.City, l.Region, l.Zip, m.OpenTime, m.CloseTime
ORDER BY l.City, m.Name;

-- 2) Event roster: vendors attending a given event (with booth)
-- :eventId
SELECT
  me.EventID, me.EventDate, m.Name AS MarketName,
  v.VendorID, v.Name AS VendorName, mv.BoothNumber, mv.Status
FROM MarketEvent me
JOIN Market m ON m.MarketID = me.MarketID
JOIN MarketVendor mv ON mv.EventID = me.EventID
JOIN Vendor v ON v.VendorID = mv.VendorID
WHERE me.EventID = ?                -- bind parameter
ORDER BY v.Name;

-- 3) Product catalog available at an event with current stock
-- :eventId, optional :categoryId, :q (search)
SELECT
  p.ProductID, p.Name AS ProductName, pc.Name AS Category,
  v.VendorID, v.Name AS Vendor,
  i.AvailableQuantity - i.ReservedQuantity AS QtyAvailable
FROM Inventory i
JOIN Product p     ON p.ProductID = i.ProductID
JOIN Vendor v      ON v.VendorID  = i.VendorID
LEFT JOIN ProductCategory pc ON pc.CategoryID = p.CategoryID
WHERE i.EventID = ?
  AND ( ? IS NULL OR p.CategoryID = ? )
  AND ( ? IS NULL OR p.Name LIKE CONCAT('%', ?, '%') )
  AND (i.AvailableQuantity - i.ReservedQuantity) > 0
ORDER BY pc.Name, p.Name;

-- 4) Latest observed price for each product (from recent `order`)
-- Useful when Product has no base price column.
-- :daysLookback
SELECT
  p.ProductID, p.Name,
  (SELECT oi.UnitPrice
   FROM OrderItem oi
   JOIN `order` o ON o.OrderID = oi.OrderID
   WHERE oi.ProductID = p.ProductID
     AND o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
   ORDER BY o.OrderDate DESC
   LIMIT 1) AS LatestPrice
FROM Product p;

-- 5) Customer order history with totals and item count
-- :userId
SELECT
  o.OrderID, o.OrderDate, o.PickupDate, o.TotalAmount,
  COUNT(oi.OrderItemID) AS LineItems,
  o.PaymentStatus, o.PickupStatus,
  me.EventDate, m.Name AS MarketName
FROM `order` o
LEFT JOIN OrderItem oi ON oi.OrderID = o.OrderID
LEFT JOIN MarketEvent me ON me.EventID = o.EventID
LEFT JOIN Market m ON m.MarketID = me.MarketID
WHERE o.UserID = ?
GROUP BY o.OrderID, o.OrderDate, o.PickupDate, o.TotalAmount, o.PaymentStatus, o.PickupStatus, me.EventDate, m.Name
ORDER BY o.OrderDate DESC;

-- 6) Top-selling products by quantity in a date range
-- :startDate, :endDate, optional :limit
SELECT
  p.ProductID, p.Name,
  SUM(oi.Quantity) AS UnitsSold
FROM OrderItem oi
JOIN `order` o ON o.OrderID = oi.OrderID
JOIN Product p ON p.ProductID = oi.ProductID
WHERE o.OrderDate >= ? AND o.OrderDate < DATE_ADD(?, INTERVAL 1 DAY)
GROUP BY p.ProductID, p.Name
ORDER BY UnitsSold DESC
LIMIT ?;

-- 7) Vendor revenue per event (what a farmer sold)
-- :vendorId, :startDate, :endDate
SELECT
  v.VendorID, v.Name AS Vendor,
  me.EventID, me.EventDate, m.Name AS Market,
  SUM(oi.Quantity * oi.UnitPrice) AS GrossRevenue
FROM OrderItem oi
JOIN Product p   ON p.ProductID = oi.ProductID
JOIN Vendor v    ON v.VendorID  = p.VendorID
JOIN `order` o    ON o.OrderID   = oi.OrderID
LEFT JOIN MarketEvent me ON me.EventID = o.EventID
LEFT JOIN Market m ON m.MarketID = me.MarketID
WHERE v.VendorID = ?
  AND o.OrderDate >= ?
  AND o.OrderDate < DATE_ADD(?, INTERVAL 1 DAY)
GROUP BY v.VendorID, v.Name, me.EventID, me.EventDate, m.Name
ORDER BY me.EventDate;

-- 8) Low-stock alert for an event (after reservations)
-- :eventId, :threshold
SELECT
  p.ProductID, p.Name, v.Name AS Vendor,
  (i.AvailableQuantity - i.ReservedQuantity) AS QtyAvailable
FROM Inventory i
JOIN Product p ON p.ProductID = i.ProductID
JOIN Vendor v  ON v.VendorID  = i.VendorID
WHERE i.EventID = ?
  AND (i.AvailableQuantity - i.ReservedQuantity) <= ?
ORDER BY QtyAvailable ASC, p.Name;

-- 9) Availability check for a "cart" (list of productId, qty) at event
-- Example uses a temp table or in-DB list named Cart(ProductID, Qty)
-- :eventId
-- CREATE TEMPORARY TABLE Cart (ProductID INT, Qty INT);  -- fill client-side
SELECT
  c.ProductID, p.Name,
  c.Qty AS Requested,
  GREATEST(0, c.Qty - GREATEST(0, (i.AvailableQuantity - i.ReservedQuantity))) AS Shortfall
FROM Cart c
JOIN Product p ON p.ProductID = c.ProductID
LEFT JOIN Inventory i
  ON i.ProductID = c.ProductID
 AND i.EventID   = ?
ORDER BY p.Name;

-- 10) “Customers also bought” within a category (simple co-occurrence)
-- :productId, :limit
SELECT
  p2.ProductID, p2.Name, pc.Name AS Category,
  COUNT(*) AS TogetherCount
FROM OrderItem oi1
JOIN OrderItem oi2 ON oi2.OrderID = oi1.OrderID AND oi2.ProductID <> oi1.ProductID
JOIN Product p1 ON p1.ProductID = oi1.ProductID
JOIN Product p2 ON p2.ProductID = oi2.ProductID
LEFT JOIN ProductCategory pc ON pc.CategoryID = p2.CategoryID
WHERE oi1.ProductID = ?
GROUP BY p2.ProductID, p2.Name, pc.Name
ORDER BY TogetherCount DESC
LIMIT ?;
