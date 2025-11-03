## First Normal Form (1NF)

The goal of 1NF is to ensure each table has a primary key and all attributes hold atomic values  with no repeating groups, no lists, and no multi-valued attributes.

 so,

* we made sure every entity had a clear primary key, such as MarketID, VendorID, ProductID, etc  
* we looked for any attributes that could hold multiple values (like phone numbers or emails).We  decided Iwe’d store them in a separate table if needed  for example, a VendorPhone table.

* we verified that no fields contained sets or comma-separated values  

After doing this, each table now represented a single entity with atomic attributes and a unique primary key. That meant all tables were now in 1NF.

## Second Normal Form (2NF)

Next, we focused on removing partial dependencies  meaning, no non-key attribute should depend on just part of a composite key.

To achieve this, I:

* We identified tables that could have composite keys (for example, OrderItem could use (OrderID, ProductID) as a composite key).

  * To simplify, we introduced a surrogate key (OrderItemID) so every record has a single-column primary key.

* We looked at relationship tables like MarketVendor (which links vendors and markets).

  * Attributes such as BoothNumber and AttendanceDate depend on the combination of MarketID and VendorID, not just one.

  * To make this cleaner, we gave the table a surrogate primary key (MarketVendorID) and kept both foreign keys (MarketID, VendorID) to preserve the relationship.

* Ensured that no attribute in any table depended on only part of a key.

Now, every non-key attribute depends on the whole key  not a part of it  meaning the design was in 2NF.

## Third Normal Form (3NF)

The next step was to eliminate transitive dependencies, that is, no non-key attribute should depend on another non-key attribute.

Here’s how we handled that:

* We noticed that City, Country, Latitude, and Longitude were repeated in multiple tables like Market and Customer.  
   So we moved all those attributes into a new table called Location.  
   Now, tables like Market and Customer only store LocationID as a foreign key.

* The Product table had category information that really belonged to its own entity.  
   So we created a Category table and linked it via CategoryID. This way, CategoryName and Description live only once in the database.

* We separated Payment details from the Order table, since payment-related fields (like TransactionID or Amount) depend on the payment itself, not directly on the order.  
   That eliminated the transitive dependency between Order → PaymentMethod → TransactionID.

* In Inventory, we made sure only product and vendor IDswere stored, no redundant product or vendor details that could create dependencies.

