 Farmers Market Management System

Project Overview
The Farmers Market Management System is a database driven application designed to efficiently manage the operations of local markets, vendors, products, and customer orders.  
This project models the interactions between markets, vendors, products, customers, and events, providing a centralized system for organizing and tracking market activities.

The goal is to streamline communication, improve inventory tracking, and simplify order and payment processing for vendors and customers participating in various market events.

Objectives
 To design a normalised relational that supports the management of markets, vendors, products, orders, and payments.
 To ensure data consistency and referential integrity through the use of appropriate primary and foreign key relationships.
 To facilitate reporting and analytics through structured relationships among entities.



 Features
 Market Management
 Create and manage market profiles with location, opening hours, and contact information.
 Support multiple market events occurring on different dates and locations.
 Track vendor participation in each market or event.

 Vendor & Product Management
 Maintain vendor profiles with contact information, descriptions, and website links.
 Categorize vendors by business type or category.
 Manage an inventory of products offered by vendors, including stock availability and categories.

Inventory Management
 Track available and reserved product quantities.
 Associate inventory records with both vendors and market events.
 Record last update timestamps and inventory status.

 Order & Payment Processing
 Allow customers to place orders for products from multiple vendors.
 Record order details, including quantity, price, and order date.
 Integrate payment information, including transaction details, amount, and payment status.

 Customer Management
 Store customer profiles with names, contact info, and account credentials.
 Track customer order histories and market attendance.



 Database Design

 Entity Relationship Diagram (ERD)
The database design is represented in the following ERD:
 


The ERD shows the relationships between all key entities:
 Market, MarketEvent, and MarketVendor manage the scheduling and participation of vendors.
 Vendor, Product, Category, and Inventory manage product listings and stock control.
 Customer, Order, OrderItem, and Payment handle purchasing and transactions.
 Country_City stores geographical information used across entities.

 Farmers Market Management System

A compact relationaldatabase design for managing markets, vendors, products, inventory, and orders.
 What this repo contains
 ERD and schema design for Markets, Vendors, Products, Inventory, Orders, and Payments.

 Author
Ranjan Khadka 
Tristan Brown
Aaron Kraska



Course: SE3050  
Date: October 2025

