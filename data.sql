-- ==========================================================
-- data.sql  —  Seed data for Farmers Market application
-- Target: MySQL (uses NOW(), STR_TO_DATE, etc.)
-- NOTE: These INSERTs assume empty tables and AUTO_INCREMENT
-- Uses table name: `order`  (backticks required to avoid keyword conflict)
-- ==========================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------
-- 0) Reference: Locations
-- -------------------------
INSERT INTO Location (LocationID, City, Country, Zip, Region, Latitude, Longitude)
VALUES
(1,'Minneapolis','USA','55401','MN',44.986656,-93.258133),
(2,'Saint Paul','USA','55101','MN',44.953703,-93.089958),
(3,'Duluth','USA','55802','MN',46.786672,-92.100485),
(4,'Rochester','USA','55901','MN',44.012122,-92.480199),
(5,'Mankato','USA','56001','MN',44.163578,-93.999399),
(6,'Fargo','USA','58102','ND',46.877186,-96.789803),
(7,'Grand Forks','USA','58201','ND',47.925258,-97.032855),
(8,'Bemidji','USA','56601','MN',47.473611,-94.880278),
(9,'Brainerd','USA','56401','MN',46.352673,-94.202008),
(10,'Winona','USA','55987','MN',44.055390,-91.666352),
(11,'Moorhead','USA','56560','MN',46.8730,-96.7671),
(12,'Crookston','USA','56716','MN',47.774,-96.608);

-- -------------------------
-- 1) Markets (10)
-- -------------------------
INSERT INTO Market (MarketID, Name, Address, LocationID, OpenTime, CloseTime, StartDate, EndDate, Phone, Email)
VALUES
(1,'North Loop Farmers Market','750 2nd St N',1,'08:00','14:00','2025-05-01','2025-10-31','612-555-1001','northloop@fm.com'),
(2,'Lowertown Market','289 5th St E',2,'08:00','13:00','2025-05-01','2025-10-31','651-555-2002','lowertown@fm.com'),
(3,'Canal Park Market','351 S Lake Ave',3,'09:00','14:00','2025-05-15','2025-09-30','218-555-3003','canal@fm.com'),
(4,'Downtown Rochester Market','201 1st Ave SW',4,'08:00','12:00','2025-05-15','2025-10-15','507-555-4004','roch@fm.com'),
(5,'River Hills Market','100 River Hills',5,'08:30','12:30','2025-05-15','2025-09-30','507-555-5005','riverhills@fm.com'),
(6,'Broadway Market','100 Broadway N',6,'09:00','13:00','2025-05-01','2025-10-31','701-555-6006','broadway@fm.com'),
(7,'Town Square Market','3 S 3rd St',7,'09:00','13:00','2025-05-01','2025-10-31','701-555-7007','tsquare@fm.com'),
(8,'Lake Bemidji Market','1 Paul Bunyan Dr',8,'09:00','12:30','2025-06-01','2025-09-30','218-555-8008','bemidji@fm.com'),
(9,'Brainerd Lakes Market','1101 S 6th St',9,'08:30','12:30','2025-05-10','2025-09-30','218-555-9009','brainerd@fm.com'),
(10,'Winona Riverfront Market','2 Johnson St',10,'08:00','12:00','2025-05-10','2025-10-10','507-555-1010','winona@fm.com');

-- -------------------------
-- 2) Events (at least one per market)
-- -------------------------
INSERT INTO MarketEvent (EventID, MarketID, EventDate, StartTime, Address, Status, LocationID)
VALUES
(1,1,'2025-06-07','08:00','750 2nd St N','Scheduled',1),
(2,2,'2025-06-07','08:00','289 5th St E','Scheduled',2),
(3,3,'2025-06-14','09:00','351 S Lake Ave','Scheduled',3),
(4,4,'2025-06-14','08:00','201 1st Ave SW','Scheduled',4),
(5,5,'2025-06-21','08:30','100 River Hills','Scheduled',5),
(6,6,'2025-06-21','09:00','100 Broadway N','Scheduled',6),
(7,7,'2025-06-28','09:00','3 S 3rd St','Scheduled',7),
(8,8,'2025-06-28','09:00','1 Paul Bunyan Dr','Scheduled',8),
(9,9,'2025-07-05','08:30','1101 S 6th St','Scheduled',9),
(10,10,'2025-07-05','08:00','2 Johnson St','Scheduled',10),
(11,1,'2025-07-12','08:00','750 2nd St N','Scheduled',1),
(12,2,'2025-07-12','08:00','289 5th St E','Scheduled',2);

-- -------------------------
-- 3) Product Categories
-- -------------------------
INSERT INTO ProductCategory (CategoryID, Name, Description)
VALUES
(1,'Produce','Fresh vegetables and fruit'),
(2,'Dairy','Milk, cheese, yogurt'),
(3,'Meat','Beef, pork, poultry'),
(4,'Baked Goods','Breads, pastries'),
(5,'Beverages','Juice, kombucha, cold brew'),
(6,'Flowers','Cut flowers, bouquets'),
(7,'Preserves','Jams, pickles'),
(8,'Honey','Honey and bee products'),
(9,'Eggs','Chicken and duck eggs'),
(10,'Herbs','Fresh herbs');

-- -------------------------
-- 4) Vendors (20)  — farmers & makers
-- -------------------------
INSERT INTO Vendor (VendorID, Name, Description, Phone, Email, Website, VendorCategory)
VALUES
(1,'Green Valley Farms','Organic vegetables','612-555-1101','contact@greenvalley.com','https://greenvalley.example','Produce'),
(2,'Sunrise Orchard','Seasonal fruit','612-555-1102','hello@sunriseorchard.com','https://sunrise.example','Produce'),
(3,'North Star Dairy','Artisan cheeses','651-555-1103','info@northstardairy.com','https://nsd.example','Dairy'),
(4,'Prairie Meats','Grass-fed beef & pork','651-555-1104','sales@prairiemeats.com','https://prairiemeats.example','Meat'),
(5,'Riverbread Bakery','Sourdough & pastries','612-555-1105','bakery@riverbread.com','https://riverbread.example','Baked Goods'),
(6,'Twin Cities Kombucha','Small-batch kombucha','612-555-1106','tap@tckombucha.com','https://tck.example','Beverages'),
(7,'Bee Happy Apiary','Local honey','651-555-1107','hive@beehappy.com','https://beehappy.example','Honey'),
(8,'Sunny Eggs','Free-range eggs','651-555-1108','carton@sunnyeggs.com','https://sunnyeggs.example','Eggs'),
(9,'Bloom & Stem','Bouquets and stems','612-555-1109','hi@bloomstem.com','https://bloomstem.example','Flowers'),
(10,'Herb Haven','Culinary herbs','612-555-1110','grow@herbhaven.com','https://herbhaven.example','Herbs'),
(11,'Lakeview Greens','Hydroponic greens','218-555-1111','greens@lakeview.com','https://lakeview.example','Produce'),
(12,'Stone Mill Bakery','Wholegrain breads','218-555-1112','hello@stonemill.com','https://stonemill.example','Baked Goods'),
(13,'North Roast Coffee','Cold brew & beans','701-555-1113','brew@northroast.com','https://northroast.example','Beverages'),
(14,'Frost River Farms','Root vegetables','218-555-1114','market@frostriver.com','https://frostriver.example','Produce'),
(15,'Willow Meats','Pastured poultry','507-555-1115','`order`@willowmeats.com','https://willowmeats.example','Meat'),
(16,'Crescent Creamery','Yogurt & milk','507-555-1116','team@crescentcreamery.com','https://crescent.example','Dairy'),
(17,'Grand Jams','Jams & preserves','701-555-1117','jars@grandjams.com','https://grandjams.example','Preserves'),
(18,'Sprout & Root','Microgreens','612-555-1118','grow@sproutroot.com','https://sproutroot.example','Produce'),
(19,'Harvest Herbs','Potted & cut herbs','701-555-1119','hello@harvestherbs.com','https://harvestherbs.example','Herbs'),
(20,'Prairie Flowers','Seasonal bouquets','507-555-1120','hello@prairieflowers.com','https://prairieflowers.example','Flowers');

-- -------------------------
-- 5) Products (50 unique)
--    Each references Vendor + Category
-- -------------------------
INSERT INTO Product (ProductID, VendorID, CategoryID, Name, Description) VALUES
-- Produce (1,2,11,14,18)
(1,1,1,'Kale Bunch','Curly kale, organic'),
(2,1,1,'Heirloom Tomatoes','Mixed varieties'),
(3,1,1,'Carrots','Sweet Nantes'),
(4,2,1,'Honeycrisp Apples','Fresh picked'),
(5,2,1,'Strawberries Pint','June bearing'),
(6,11,1,'Butter Lettuce','Hydroponic'),
(7,11,1,'Arugula','Peppery greens'),
(8,14,1,'Beets','Red beets with tops'),
(9,18,1,'Sunflower Microgreens','Nutty microgreens'),
(10,18,1,'Radish Microgreens','Spicy microgreens'),
-- Dairy (3,16)
(11,3,2,'Aged Cheddar','12-month cheddar'),
(12,3,2,'Goat Chevre','Fresh chevre'),
(13,16,2,'Greek Yogurt','Plain, whole milk'),
(14,16,2,'Chocolate Milk','Pint'),
-- Meat (4,15)
(15,4,3,'Ground Beef','1 lb, grass-fed'),
(16,4,3,'Pork Chops','Bone-in'),
(17,15,3,'Whole Chicken','Pastured, ~4 lb'),
(18,15,3,'Chicken Thighs','Bone-in'),
-- Baked Goods (5,12)
(19,5,4,'Sourdough Loaf','Country loaf'),
(20,5,4,'Croissant','Butter croissant'),
(21,12,4,'Whole Wheat Loaf','Stone ground'),
(22,12,4,'Cinnamon Roll','Iced'),
-- Beverages (6,13)
(23,6,5,'Ginger Kombucha','16 oz'),
(24,6,5,'Berry Kombucha','16 oz'),
(25,13,5,'Cold Brew Coffee','12 oz'),
(26,13,5,'Coffee Beans','12 oz bag'),
-- Flowers (9,20)
(27,9,6,'Mixed Bouquet','Seasonal mix'),
(28,20,6,'Sunflower Bunch','5 stems'),
-- Preserves (17)
(29,17,7,'Strawberry Jam','8 oz'),
(30,17,7,'Dill Pickles','16 oz'),
-- Honey (7)
(31,7,8,'Raw Honey','1 lb'),
(32,7,8,'Creamed Honey','12 oz'),
-- Eggs (8)
(33,8,9,'Dozen Eggs','Large brown'),
(34,8,9,'Duck Eggs Half-Dozen','Jumbo'),
-- Herbs (10,19)
(35,10,10,'Basil Bunch','Genovese'),
(36,10,10,'Mint Bunch','Spearmint'),
(37,19,10,'Rosemary Bunch','Aromatic'),
(38,19,10,'Thyme Bunch','Lemon thyme'),
-- More Produce to reach 50
(39,2,1,'Blueberries Pint','Fresh'),
(40,1,1,'Cucumbers','Slicing'),
(41,14,1,'Russet Potatoes','5 lb'),
(42,11,1,'Romaine Lettuce','Heads'),
(43,1,1,'Green Onions','Bunch'),
(44,18,1,'Pea Shoots','Microgreen'),
(45,14,1,'Parsnips','Sweet'),
(46,2,1,'Peaches','Ripe'),
(47,11,1,'Spinach','Tender leaves'),
(48,1,1,'Zucchini','Medium'),
(49,18,1,'Broccoli Microgreens','Crunchy'),
(50,14,1,'Turnips','Hakurei');

-- -------------------------
-- 6) Market ↔ Vendor attendance
-- -------------------------
INSERT INTO MarketVendor (MarketVendorID, MarketID, VendorID, EventID, BoothNumber, AttendanceDate, Status, Notes)
VALUES
(1,1,1,1,'A1','2025-06-07','Confirmed',''),
(2,1,3,1,'A2','2025-06-07','Confirmed',''),
(3,1,5,1,'B1','2025-06-07','Confirmed',''),
(4,2,2,2,'C3','2025-06-07','Confirmed',''),
(5,2,7,2,'C4','2025-06-07','Confirmed',''),
(6,3,4,3,'D1','2025-06-14','Confirmed',''),
(7,3,6,3,'D2','2025-06-14','Confirmed',''),
(8,4,8,4,'E1','2025-06-14','Confirmed',''),
(9,5,9,5,'F1','2025-06-21','Confirmed',''),
(10,6,10,6,'G1','2025-06-21','Confirmed',''),
(11,7,11,7,'H1','2025-06-28','Confirmed',''),
(12,8,12,8,'I1','2025-06-28','Confirmed',''),
(13,9,13,9,'J1','2025-07-05','Confirmed',''),
(14,10,14,10,'K1','2025-07-05','Confirmed',''),
(15,1,15,11,'A3','2025-07-12','Confirmed',''),
(16,2,16,12,'C5','2025-07-12','Confirmed',''),
(17,1,17,11,'A4','2025-07-12','Confirmed',''),
(18,2,18,12,'C6','2025-07-12','Confirmed','');

-- -------------------------
-- 7) Inventory for upcoming events
-- -------------------------
INSERT INTO Inventory (InventoryID, VendorID, ProductID, EventID, AvailableQuantity, ReservedQuantity, Status)
VALUES
-- Event 1 (Market 1)
(1,1,1,1,60,5,'In Stock'),
(2,1,2,1,50,10,'In Stock'),
(3,1,3,1,80,0,'In Stock'),
(4,3,11,1,30,2,'In Stock'),
(5,5,19,1,40,5,'In Stock'),
-- Event 2 (Market 2)
(6,2,4,2,90,10,'In Stock'),
(7,2,5,2,70,8,'In Stock'),
(8,7,31,2,40,5,'In Stock'),
(9,7,32,2,35,2,'In Stock'),
-- Event 3 (Market 3)
(10,4,15,3,45,4,'In Stock'),
(11,4,16,3,25,1,'In Stock'),
(12,6,23,3,60,6,'In Stock'),
(13,6,24,3,60,5,'In Stock'),
-- Event 4
(14,8,33,4,80,3,'In Stock'),
(15,15,17,4,30,2,'In Stock'),
-- Event 5
(16,9,27,5,50,6,'In Stock'),
(17,14,41,5,70,4,'In Stock'),
-- Event 6
(18,10,35,6,60,5,'In Stock'),
(19,13,25,6,60,10,'In Stock'),
-- Event 7
(20,11,6,7,80,5,'In Stock'),
(21,11,7,7,70,3,'In Stock'),
-- Event 8
(22,12,21,8,45,2,'In Stock'),
(23,12,22,8,50,5,'In Stock'),
-- Event 9
(24,13,26,9,70,10,'In Stock'),
(25,14,45,9,60,0,'In Stock'),
-- Event 10
(26,20,28,10,40,3,'In Stock'),
(27,14,50,10,55,2,'In Stock'),
-- Event 11 (repeat market 1)
(28,15,18,11,35,1,'In Stock'),
(29,17,29,11,60,4,'In Stock'),
(30,18,9,11,80,5,'In Stock'),
-- Event 12 (repeat market 2)
(31,16,13,12,50,3,'In Stock'),
(32,18,10,12,70,5,'In Stock'),
(33,2,39,12,60,7,'In Stock');

-- -------------------------
-- 8) Customers
-- -------------------------
INSERT INTO Customer (UserID, Name, Phone, CustomerType, Email, Username, PasswordHash, PreferredMarketID, CCType, CCZip)
VALUES
(1,'Alex Kim','612-777-1001','Member','alex@example.com','alexk',UNHEX(SHA1('pw1')),1,'VISA','55401'),
(2,'Priya Patel','651-777-1002','Guest','priya@example.com','priya',UNHEX(SHA1('pw2')),2,'MC','55101'),
(3,'Jordan Lee','218-777-1003','Member','jordan@example.com','jordan',UNHEX(SHA1('pw3')),1,'AMEX','55401'),
(4,'Taylor Smith','507-777-1004','Guest','taylor@example.com','taylor',UNHEX(SHA1('pw4')),4,'VISA','55901'),
(5,'Sam Rivera','701-777-1005','Member','sam@example.com','samr',UNHEX(SHA1('pw5')),6,'VISA','58102');

-- -------------------------
-- 9) `order` / OrderItems / Payments (sample)
-- -------------------------
INSERT INTO `order` (OrderID, UserID, EventID, OrderDate, PickupDate, TotalAmount, PaymentStatus, PickupStatus)
VALUES
(1,1,1,'2025-06-06 10:00','2025-06-07 10:30',0,'Unpaid','Pending'),
(2,2,2,'2025-06-06 11:15','2025-06-07 09:30',0,'Unpaid','Pending'),
(3,3,3,'2025-06-13 12:10','2025-06-14 10:15',0,'Unpaid','Pending'),
(4,1,11,'2025-07-11 13:00','2025-07-12 09:15',0,'Unpaid','Pending');

-- Order 1 items
INSERT INTO OrderItem (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(1,1,1,2,3.50),   -- kale
(2,1,11,1,9.00),  -- cheddar
(3,1,19,1,6.00);  -- sourdough

-- Order 2 items
INSERT INTO OrderItem (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(4,2,4,5,1.50),   -- apples
(5,2,31,1,12.00); -- honey

-- Order 3 items
INSERT INTO OrderItem (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(6,3,15,2,8.50),   -- ground beef
(7,3,23,2,4.50);   -- kombucha

-- Order 4 items
INSERT INTO OrderItem (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(8,4,29,2,7.00),   -- jam
(9,4,18,1,9.50),   -- chicken thighs
(10,4,9,1,4.00);   -- sunflower microgreens

-- Backfill order totals
UPDATE Orders o
JOIN (
  SELECT oi.OrderID, SUM(oi.Quantity * oi.UnitPrice) AS total
  FROM OrderItem oi
  GROUP BY oi.OrderID
) t ON t.OrderID = o.OrderID
SET o.TotalAmount   = t.total,
    o.PaymentStatus = 'Paid'
WHERE o.OrderID >= 1;   -- key column + constant

-- Payments
INSERT INTO Payment (PaymentID, OrderID, UserID, Amount, PaymentDate, Method, TransactionID, Status)
VALUES
(1,1,1,(SELECT TotalAmount FROM `order` WHERE OrderID=1),'2025-06-06 10:05','Card','TXN-1001','Succeeded'),
(2,2,2,(SELECT TotalAmount FROM `order` WHERE OrderID=2),'2025-06-06 11:20','Card','TXN-1002','Succeeded'),
(3,3,3,(SELECT TotalAmount FROM `order` WHERE OrderID=3),'2025-06-13 12:15','Card','TXN-1003','Succeeded'),
(4,4,1,(SELECT TotalAmount FROM `order` WHERE OrderID=4),'2025-07-11 13:05','Card','TXN-1004','Succeeded');

SET FOREIGN_KEY_CHECKS = 1;
