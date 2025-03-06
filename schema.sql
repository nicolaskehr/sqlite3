-- Represent the customers which are defined for the B2B via EDI
CREATE TABLE customers (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "contact" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active',
    PRIMARY KEY("id"),
    CHECK("status" IN ('active', 'inactive'))
);

-- Represents the orders data
CREATE TABLE orders (
    "id" INTEGER,
    "customer_id" INTEGER NOT NULL,
    "order_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "material_code" NUMERIC NOT NULL,
    "unit" TEXT NOT NULL DEFAULT 'pce',
    "amount" INTEGER NOT NULL,
    "status" TEXT NOT NULL,  -- "open", "pending", "shipped", "error"
    PRIMARY KEY("id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id"),
    FOREIGN KEY("material_code") REFERENCES "materials"("material_code"),
    CHECK("status" IN ('open', 'pending', 'shipped', 'error'))
);

-- Represents the material data
CREATE TABLE materials (
    "id" INTEGER,
    "material_code" INTEGER NOT NULL UNIQUE,
    "unit" TEXT NOT NULL DEFAULT 'pce',
    "description" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'listed', -- "listed", "unlisted"
    PRIMARY KEY("id"),
    CHECK("status" IN ('listed', 'unlisted'))
);

-- Represents the warehouse or stock of the materials
CREATE TABLE warehouse (
    "id" INTEGER,
    "material_code" INTEGER NOT NULL,
    "unit" TEXT NOT NULL DEFAULT 'pce',
    "description" TEXT NOT NULL,
    "stock" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("material_code") REFERENCES "materials"("material_code"),
    CHECK("stock" >= 0)
);

-- Represents the data of deliveries
CREATE TABLE deliveries (
    "id" INTEGER,
    "order_id" INTEGER NOT NULL,
    "shipping_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expected_delivery_date" NUMERIC NOT NULL,
    "status" TEXT NOT NULL,  -- "shipped", "in_transit", "delayed", "delivered"
    PRIMARY KEY("id"),
    FOREIGN KEY("order_id") REFERENCES "orders"("id")
);

-- Represents data for invoices
CREATE TABLE invoices (
    "id" INTEGER,
    "order_id" INTEGER NOT NULL,
    "delivery_id" INTEGER NOT NULL,
    "total_amount" INTEGER NOT NULL,
    "type" TEXT NOT NULL,  -- "e-post", "edi", "email"
    "status" TEXT NOT NULL,  -- "submitted", "payed", "overdue"
    PRIMARY KEY("id"),
    FOREIGN KEY("order_id") REFERENCES "orders"("id"),
    FOREIGN KEY("delivery_id") REFERENCES "deliveries"("id")
);


-- Create Trigger to enhance performance and enforce business rules.

-- Trigger for preventing orders for inactive customer
CREATE TRIGGER prevent_order_if_customer_inactive
BEFORE INSERT ON orders
FOR EACH ROW
    BEGIN
        SELECT
            CASE
            -- Check if customer has "status" = 'inactive'
                WHEN (SELECT status FROM customers WHERE id = NEW.customer_id) = 'inactive'
                THEN RAISE(ABORT, 'Cannot create order for inactive customer')
            END;
END;

-- Ensure, that every new material appears in the table "warehouse"
CREATE TRIGGER after_materials_insert
AFTER INSERT ON materials
FOR EACH ROW
    BEGIN
        INSERT INTO warehouse (material_code, unit, description, stock)
        VALUES (NEW.material_code, NEW.unit, NEW.description, 0);
    END;


--Update stock, once an order is placed
CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
    BEGIN
    -- Checking stock, if not enough stock abort.
        SELECT
            CASE
                WHEN (SELECT stock FROM warehouse WHERE material_code = NEW.material_code) < NEW.amount
                THEN RAISE(ABORT, 'Not enough stock to create the order')
            END;
    -- If the order can be created, update the stock on table warehouse.
        UPDATE warehouse
        SET stock = stock - NEW.amount
        WHERE material_code = NEW.material_code;
END;

-- Trigger for preventing a deletion of an invoice
CREATE TRIGGER prevent_delete_invoices
BEFORE DELETE ON invoices
FOR EACH ROW
    BEGIN
        SELECT RAISE(ABORT, 'Delete operation on invoices is not allowed');
    END;


-- CREATE views

-- Every active customer:
CREATE VIEW "active_customers" AS
SELECT
    "customers"."id" AS "customer_id",
    "customers"."name" AS "company",
    "customers"."contact" AS "customer_contact",
    "customers"."email" AS "customer_email",
    "customers"."address" AS "customer_address"
FROM "customers"
WHERE "customers"."status" = 'active';

-- Overview of all orders:
CREATE VIEW order_overview AS
SELECT
    "orders"."id" AS "order_id",
    "orders"."customer_id",
    "customers".name AS "customer_name",
    "orders"."order_date",
    "orders"."material_code",
    "materials"."description",
    "orders"."amount",
    "orders".status AS "order_status"
FROM "orders"
JOIN "customers" ON "orders"."customer_id" = "customers"."id"
JOIN "materials" ON "materials"."material_code" = "orders"."material_code";

-- Overview of the warehouse:
CREATE VIEW warehouse_stock AS
SELECT
    "warehouse"."id" AS "warehouse_id",
    "warehouse"."material_code",
    "materials"."description" AS "material_description",
    "warehouse"."unit",
    "warehouse"."stock"
FROM "warehouse"
JOIN "materials" ON "warehouse"."material_code" = "materials"."material_code";

-- All important details of the invoices:
CREATE VIEW invoice_details AS
SELECT
    "invoices"."id" AS "invoice_id",
    "invoices"."order_id",
    "orders"."customer_id",
    "customers"."name" AS "customer_name",
    "invoices"."delivery_id",
    "invoices"."total_amount",
    "invoices"."type" AS "invoice_type",
    "invoices"."status" AS "invoice_status"
FROM "invoices"
JOIN "orders" ON "invoices"."order_id" = "orders"."id"
JOIN "customers" ON "orders"."customer_id" = "customers"."id";

-- All invoices in status 'overdue':
CREATE VIEW invoices_overdue AS
SELECT
    "invoices"."id" AS "invoice_id",
    "orders"."id" AS "order_id",
    "customers"."name" AS "customer_name",
    "invoices"."total_amount",
    "invoices"."type" AS "invoice_type",
    "invoices"."status" AS "invoice_status"
FROM "invoices"
JOIN "orders" ON "invoices"."order_id" = "orders"."id"
JOIN "customers" ON "orders"."customer_id" = "customers"."id"
WHERE "invoices"."status" = 'overdue';

-- Create indexes to speed common searches
CREATE INDEX "customers_status" ON "customers" ("status");
CREATE INDEX "customers_name" ON "customers" ("name");

CREATE INDEX "customer_orders" ON "orders" ("customer_id");
CREATE INDEX "status_orders" ON "orders" ("status");
CREATE INDEX "orders_date" ON "orders" ("order_date");

CREATE INDEX "deliveries_orders" ON "deliveries" ("order_id");
CREATE INDEX "deliveries_status" ON "deliveries" ("status");
CREATE INDEX "deliveries_shipping_date" ON "deliveries" ("shipping_date");
CREATE INDEX "deliveries_expected_delivery" ON "deliveries" ("expected_delivery_date");

CREATE INDEX "invoices_order" ON "invoices" ("order_id");
CREATE INDEX "invoices_delivery" ON "invoices" ("delivery_id");
CREATE INDEX "invoices_type" ON "invoices" ("type");
CREATE INDEX "invoices_status" ON "invoices" ("status");

CREATE INDEX "warehouse_material_code" ON "warehouse" ("material_code");
CREATE INDEX "materials_status" ON "materials" ("status");

