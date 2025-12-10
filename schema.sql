-- =========================
-- 1) Reference / Lookup
-- =========================
CREATE DATABASE Farmers_Market;
USE Farmers_Market;
CREATE TABLE Location (
  LocationID      INT AUTO_INCREMENT PRIMARY KEY,
  City            VARCHAR(80) NOT NULL,
  Country         VARCHAR(50) NOT NULL,
  Zip             VARCHAR(10),
  Region          VARCHAR(50),
  Latitude        DECIMAL(10,8),
  Longitude       DECIMAL(11,8),
  CreatedOn       DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ProductCategory (
  CategoryID      INT AUTO_INCREMENT PRIMARY KEY,
  Name            VARCHAR(30) NOT NULL,
  Description     VARCHAR(50),
  CreatedOn       DATETIME DEFAULT CURRENT_TIMESTAMP,
  UpdatedOn       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE (Name)
);

-- =========================
-- 2) Core business entities
-- =========================
CREATE TABLE Market (
  MarketID        INT AUTO_INCREMENT PRIMARY KEY,
  Name            VARCHAR(30) NOT NULL,
  Address         VARCHAR(200),
  LocationID      INT,
  OpenTime        TIME,
  CloseTime       TIME,
  StartDate       DATETIME,
  EndDate         DATETIME,
  Phone           VARCHAR(30),
  Email           VARCHAR(120),
  CONSTRAINT fk_market_location
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

CREATE TABLE MarketEvent (
  EventID         INT AUTO_INCREMENT PRIMARY KEY,
  MarketID        INT NOT NULL,
  EventDate       DATETIME NOT NULL,
  StartTime       TIME,
  Address         VARCHAR(120),
  Zip             VARCHAR(10),
  Status          VARCHAR(20),
  LocationID      INT,
  CONSTRAINT fk_event_market
    FOREIGN KEY (MarketID) REFERENCES Market(MarketID),
  CONSTRAINT fk_event_location
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

CREATE TABLE Vendor (
  VendorID        INT AUTO_INCREMENT PRIMARY KEY,
  Name            VARCHAR(80) NOT NULL,
  Description     VARCHAR(255),
  Phone           VARCHAR(30),
  Email           VARCHAR(120),
  Website         VARCHAR(200),
  VendorCategory  VARCHAR(40)
);

CREATE TABLE Product (
  ProductID       INT AUTO_INCREMENT PRIMARY KEY,
  VendorID        INT NOT NULL,
  CategoryID      INT,
  Name            VARCHAR(80) NOT NULL,
  Description     VARCHAR(255),
  CONSTRAINT fk_product_vendor
    FOREIGN KEY (VendorID) REFERENCES Vendor(VendorID),
  CONSTRAINT fk_product_category
    FOREIGN KEY (CategoryID) REFERENCES ProductCategory(CategoryID)
);

-- A vendor’s stock scoped to an event (per ERD: Inventory depends on Vendor, Product, MarketEvent)
CREATE TABLE Inventory (
  InventoryID       INT AUTO_INCREMENT PRIMARY KEY,
  VendorID          INT NOT NULL,
  ProductID         INT NOT NULL,
  EventID           INT NOT NULL,
  AvailableQuantity INT NOT NULL DEFAULT 0,
  ReservedQuantity  INT NOT NULL DEFAULT 0,
  LastUpdated       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  Status            VARCHAR(15),
  CONSTRAINT fk_inv_vendor  FOREIGN KEY (VendorID)  REFERENCES Vendor(VendorID),
  CONSTRAINT fk_inv_product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
  CONSTRAINT fk_inv_event   FOREIGN KEY (EventID)   REFERENCES MarketEvent(EventID),
  CONSTRAINT uq_inv UNIQUE (VendorID, ProductID, EventID)
);

-- Customers
CREATE TABLE Customer (
  UserID          INT AUTO_INCREMENT PRIMARY KEY,
  Name            VARCHAR(80) NOT NULL,
  Phone           VARCHAR(30),
  CustomerType    VARCHAR(20),        -- e.g., "Guest", "Member"
  Email           VARCHAR(120) UNIQUE,
  Username        VARCHAR(60) UNIQUE,
  PasswordHash    VARBINARY(255),     -- replace plain text with hash
  PreferredMarketID INT,
  CCType          VARCHAR(20),
  CCZip           VARCHAR(10),
  CONSTRAINT fk_customer_market
    FOREIGN KEY (PreferredMarketID) REFERENCES Market(MarketID)
);

-- Markets ↔ Vendors (attendance/booths per event)
CREATE TABLE MarketVendor (
  MarketVendorID  INT AUTO_INCREMENT PRIMARY KEY,
  MarketID        INT NOT NULL,
  VendorID        INT NOT NULL,
  EventID         INT,
  BoothNumber     VARCHAR(10),
  AttendanceDate  DATE,
  Status          ENUM('Invited','Confirmed','No-Show','Cancelled') DEFAULT 'Invited',
  Notes           TEXT,
  CONSTRAINT fk_mv_market FOREIGN KEY (MarketID) REFERENCES Market(MarketID),
  CONSTRAINT fk_mv_vendor FOREIGN KEY (VendorID) REFERENCES Vendor(VendorID),
  CONSTRAINT fk_mv_event  FOREIGN KEY (EventID)  REFERENCES MarketEvent(EventID),
  INDEX (MarketID, VendorID, EventID)
);

-- =========================
-- 3) Orders & Payments
-- =========================
CREATE TABLE `Order` (
  OrderID         INT AUTO_INCREMENT PRIMARY KEY,
  UserID          INT NOT NULL,
  EventID         INT,
  OrderDate       DATETIME DEFAULT CURRENT_TIMESTAMP,
  PickupDate      DATETIME,
  TotalAmount     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PaymentStatus   VARCHAR(20) DEFAULT 'Unpaid',
  PickupStatus    VARCHAR(20) DEFAULT 'Pending',
  CONSTRAINT fk_order_user  FOREIGN KEY (UserID) REFERENCES Customer(UserID),
  CONSTRAINT fk_order_event FOREIGN KEY (EventID) REFERENCES MarketEvent(EventID),
  INDEX (UserID, OrderDate)
);

CREATE TABLE OrderItem (
  OrderItemID     INT AUTO_INCREMENT PRIMARY KEY,
  OrderID         INT NOT NULL,
  ProductID       INT NOT NULL,
  Quantity        INT NOT NULL CHECK (Quantity > 0),
  UnitPrice       DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_oi_order   FOREIGN KEY (OrderID)  REFERENCES `Order`(OrderID),
  CONSTRAINT fk_oi_product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
  UNIQUE (OrderID, ProductID)  -- each product once per order
);

CREATE TABLE Payment (
  PaymentID       INT AUTO_INCREMENT PRIMARY KEY,
  OrderID         INT NOT NULL,
  UserID          INT NOT NULL,
  Amount          DECIMAL(10,2) NOT NULL,
  PaymentDate     DATETIME DEFAULT CURRENT_TIMESTAMP,
  Method          VARCHAR(20),                 -- e.g., 'Card','Cash','App'
  TransactionID   VARCHAR(100),
  Status          VARCHAR(20) DEFAULT 'Succeeded',
  CONSTRAINT fk_pay_order FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID),
  CONSTRAINT fk_pay_user  FOREIGN KEY (UserID)  REFERENCES Customer(UserID),
  INDEX (OrderID, Status)
);

