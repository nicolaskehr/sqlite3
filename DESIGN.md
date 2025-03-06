# Design Document

By Nicolas Kehr

Video overview: <https://youtu.be/kCvgdfLJ9g4>

## Scope

This database is designed to manage the core business operations of a B2B system, with an emphasis on electronic data interchange (EDI). It supports essential workflows such as customer management, order processing, material tracking, stock control, shipping, and invoicing. It ensures data integrity through constraints, triggers, and predefined rules.

* Customers, including basic identifying information.
* Orders, orders placed by customers. It stores information like the order date, order status, and links to the customer placing the order.
* Transactions, represents transactions in the order process, including the type of transaction (order, invoice, or delivery) and its status.
* Deliveries, shows information related to shipments, including shipping date, expected delivery date, and delivery status.
* Invoices, includes all information generated for a created delivery, including the invoice type (e.g., EDI or paper) and its payment status.
* Errors, tracks errors related to orders, including error types (e.g., customer data, material issues, shipping data) and error status.

Overall a user should be able to perform searches and create reports with several values. Search orders, transactions, deliveries, invoices, and errors using filters. Create reports based on
different criteria, like pending orders, failed transactions, or overdue invoices.



## Functional Requirements

In this section you should answer the following questions:
The database serves multiple purposes:

Maintain a list of customers and their statuses.
Manage and track orders, ensuring stock availability and customer eligibility.
Store information about materials, their availability, and their stock in a warehouse.
Monitor deliveries, linking them to orders and keeping shipping data organized.
Record invoices, ensuring no deletions occur and tracking payment statuses.



* What should a user be able to do with your database?
A user is able to maintain a list of customers and their statuses.
A user can manage and track orders, ensuring stock availability and customer eligibility.
The database stores information about materials, their availability, and their stock in a warehouse.
Users can monitor deliveries, linking them to orders and keeping shipping data organized as well as record invoices,
ensuring no deletions occur and tracking payment statuses.

* What's beyond the scope of what a user should be able to do with your database?
A user should not be able to change tables or the database itself. Users are not allowed to change or modify the tables structure. Users are not allowed to delete invoices or create orders with materials that have no stock in the warehouse.


## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

The database includes the following entities:

#### Customer

The 'customers' table includes:

* `id`, which specifies the unique ID for a customer as an `INTEGER`. This column has the `PRIMARY KEY` constraint applied.
* `name`, which specifies the customers (company) name as `TEXT`, given `TEXT` is appropriate for name fields.
* `contact`, which specifies the contact name of the customer as `TEXT`, given `TEXT` is appropriate for name fields.
* `email`, which specifies the email address of the customers contact as `TEXT`, given `TEXT` is appropriate for email fields.
* `address`, which specifies the address of the customer as `TEXT`, given `TEXT` is appropriate for address fields.
* `status`, which specifies the status of the customer as `TEXT`.

#### ORDERS

* `id`, which specifies the unique ID for an order as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `customer_id`, which specifies the customer ID for the order as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `customers` table to ensure data integrity.
* `order_date`, which specifies when the order was created. Timestamps in SQLite can be conveniently stored as `NUMERIC`, per SQLite documentation at <https://www.sqlite.org/datatype3.html>. The default value for the `order_date` attribute is the current timestamp, as denoted by `DEFAULT CURRENT_TIMESTAMP`.
* `material_code`, specifies the identifier of the material as `NUMERIC`.
* `unit`, which specifies the UOM (unit of measure) in which the material can be ordered. The format is `TEXT` and the default value is `pce` for piece.
* `amount`, which represents the amount of the ordered unit per order as `NUMERIC`.
* `status`, which specifies the status (open, pending, shipped or error) of the order as `TEXT`.

### Materials
* `id`, which specifies the unique ID for a material as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `material_code`, which specifies the unique ID for a material as an `INTEGER`.
* `unit`, which specifies the UOM (unit of measure) in which the material can be ordered. The format is `TEXT` and the default value is `pce`for piece.
* `description`, which represents the description of the given material as a `TEXT`
* `status`, represents the status of a material (listed, unlisted) as a `TEXT`.

### Warehouse
* `id`, which specifies the unique ID for a material in the warehouse as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `material_code`, which specifies the unique ID for a material as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `material_code` column in the `materials` table to ensure data integrity.
* `unit`, which specifies the UOM (unit of measure) in which the material can be ordered. The format is `TEXT` and the default value is `pce`for piece.
* `description`, which represents the description of the given material as a `TEXT`
* `stock`, represents the stock of the given material in the warehouse as an `INTEGER`. It cant be less than 0.

#### Deliveries

* `id`, which specifies the unique ID for a delivery as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `order_id`, which specifies the related order ID for the delivery as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `orders` table to ensure data integrity.
* `shipping_date`, which specifies when the delivery was created. Timestamps in SQLite can be conveniently stored as `NUMERIC`, per SQLite documentation at <https://www.sqlite.org/datatype3.html>. The default value for the `shipping_date` attribute is the current timestamp, as denoted by `DEFAULT CURRENT_TIMESTAMP`.
* `expected_delivery_date`, which specifies when the delivery will arrive on it´s destination. The `expected_delivery_date`is stored in `NUMERIC`.
* `status`, which specifies the status (shipped, in_transit, delayed or delivered) of the delivery as `TEXT`.

#### Invoices

* `id`, which specifies the unique ID for an invoice as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `order_id`, which specifies the related order ID for the invoice as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `orders` table to ensure data integrity.
* `delivery_id`, which specifies the related delivery ID for the invoice as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `deliveries` table to ensure data integrity.
* `total_amount`, which represents the invoiced amount of the material as an `INTEGER`.
* `type`, which specifies the type of the invoice (e-post, edi or email) as `TEXT`.
* `status`, which specifies the status (submitted, payed or overdue) of the invoice as `TEXT`.

All columns are required and hence have the `NOT NULL` constraint applied where a `PRIMARY KEY` or `FOREIGN KEY` constraint is not.


### Relationships

![Customer_EDI_SQLITE_schema](.png)

As detailed by the diagram:

* customers -> orders: A customer can have 0 to many orders but a specific order is always connected to just one customer. Relationship: one to many
* materials -> orders: A material can be found in many orders but one order only contains one material. Relationship: one to many
* materials -> warehouse: Every material has one place in the warehouse. Relationship: one to one.
* orders -> deliveries: An order can have one or more deliveries (partial deliveries) but deliveries are always related to one order. Relationship: one to many
* orders -> invoices: An order can be related to one or more invoices (partial deliveries) but an invoice is always related to just one order. Relationship: one to many
* deliveries -> invoices: A delivery is always related to one invoice and an invoice is always connected to just one delivery. Relationship: one to one

## Optimizations

Triggers ensure data consistency and enforce business rules automatically without relying on external application logic.

* Trigger `prevent_order_if_customer_inactive` was created to prevent that orders from being created where the customer is set as `inactive`. This makes sure, that possible business rules are met
and ensures data integrity.
* Trigger `after_materials_insert` was created to add automatically new materials to the warehouse table to make stock tracking possible.
* Trigger `after_order_insert` was created to validate stock before an order is placed, aborting the transaction if stock is insufficient.
Updates the stock of the material after a valid order is placed. This ensures stock levels are always correct.
* Trigger `prevent_delete_invoices` stops a user to delete an invoice. This is important to met business rules like archiving invoice data.

Views were created for simplifying complex queries, enhancing data readability, and supporting common reporting needs.

* View `active_customers` provides a list of active customers. This is often used for reporting.
* View `order_overview` combines data from orders, customers, and materials for a comprehensive view of all orders. This is useful for dashboards and order management.
* View `invoice_details` create a combination of invoices with orders and customers for detailed financial reporting. It is useful for invoice reports.
* View `invoices_overdue` provides a list of overdue invoices, supporting financial teams in managing payments and collections efficiently.

Indexes were created to improve the speed and performance of common queries. The choice of columns for indexing is based on their frequent usage in filtering, sorting, and joining operations.

* Index `customers_status` speeds up queries filtering by customer status (active/inactive) as it is commonly used in business logic (e.g., validating orders).
* Index `customers_name` optimizes searches or sorts based on customer names.
* Index`customer_orders` improves performance for queries joining customers with their orders (foreign key customer_id).
* Index `status_orders` speeds up filtering by order status (open, pending, etc.), normally needed in operations workflows.
* Index `orders_date` optimizes sorting and range queries by order_date, often used for date-based analytics or reports.
* Index `deliveries_orders` speeds up queries joining orders with deliveries.
* Index `deliveries_status` improves filtering by delivery status (shipped, delivered, etc.).
* Index `deliveries_shipping_date` and `deliveries_expected_delivery` optimizes date-related filtering and sorting, which is crucial for logistics.
* Index `invoices_order` and `invoices_delivery` optimizes performance for joins between invoices, orders, and deliveries.
* Index `invoices_type` improves filtering by invoice type (EDI, email, etc.).
* Index `invoices_status` speeds up queries filtering by invoice status (submitted, overdue, etc.).
* Index `warehouse_material_code` makes joins between warehouse and materials faster.
* Index `materials_status` enhances performance for filtering materials by their status (listed, unlisted).


## Limitations

There is only one warehouse supported. Once the business needs more than one warehouse that could cause problems.
The database has no archiving which can be a problem due to several business rules.

Obviously the database is created for a rudimental bussiness case without complex bussiness scenarios. There is only one warehouse and the orders table supports only one line item.
In the real world we would have a lot more tables for different warehouses and a greater orders function like more line items and maybe additional table for several partner like buyer,
supplier, delivery address and also invoice.
