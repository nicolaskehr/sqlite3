-- Find the data for a specified invoice
SELECT *
FROM "invoices"
WHERE "id" = 1
;

-- Find a customer by it's name
SELECT *
FROM "customers"
WHERE "name" LIKE '%Toma%'
;

-- Find all active customer
SELECT *
FROM "customers"
WHERE "status" = 'active';

-- Find all orders for a specific customer
SELECT *
FROM "orders"
WHERE "customer_id" = 1;

-- Find all open orders
SELECT *
FROM "orders"
WHERE "status" = 'open';

-- Checking stock for a specific material
SELECT "stock"
FROM "warehouse"
WHERE "material_code" = 2000001;

-- Find a delivery by shipping date
SELECT *
FROM "deliveries"
WHERE "shipping_date" = '2024-11-01 15:00:00'
;

-- Find delivery for a specific order
SELECT *
FROM "deliveries"
WHERE "order_id" = 2;

-- Find invoices for a specific type
SELECT *
FROM "invoices"
WHERE "type" = 'edi';

-- Find invoices which are overdue
SELECT *
FROM "invoices"
WHERE "status" = 'overdue';

-- Add new customer
INSERT INTO "customers" ("name", "contact", "email", "address", "status")
VALUES
('Office Supplies Toma', 'Mr. Toma', 'j.toma@os.com', 'garden street 100, 02163 Boston', 'active'),
('Dunder Mifflin', 'Mr. Scott', 'm.scott@dundermifflin.com', '13927 Saticoy St, 91402 Panorama City', 'active')
;

-- Add new material
INSERT INTO "materials" ("material_code", "unit", "description")
VALUES
('2000001', 'pce', 'Dunder Mifflin office paper'),
('2000002', 'pce', 'Scranton business paper'),
('2000003', 'pce', 'Michael Scott dad cap')
;

-- Update stock in warehouse
UPDATE "warehouse"
SET "stock" = '1000'
WHERE "material_code" = 2000003
;

-- Add new order
INSERT INTO "orders" ("customer_id", "order_date", "material_code", "unit", "amount", "status")
VALUES
    (1, '2024-11-01 10:00:00','2000003', 'pce', 3000, 'open'),
    (2, '2024-11-01 11:00:00','2000001', 'pce', 1000, 'shipped');

-- Add new delivery
INSERT INTO "deliveries" ("order_id", "shipping_date", "expected_delivery_date", "status")
VALUES (2, '2024-11-01 15:00:00', '2024-11-02', 'shipped');

-- Add new invoice
INSERT INTO "invoices" ("order_id", "delivery_id", "total_amount", "type", "status")
VALUES (2, 1, 120.50, 'edi', 'submitted');


-- Update the status of an invoice
UPDATE "invoices"
SET "status" = 'overdue'
WHERE "id" = 1
;


-- Update the status of a customer to 'inactive'
UPDATE "customers"
SET "status" = 'inactive'
WHERE "id" = 2
;





