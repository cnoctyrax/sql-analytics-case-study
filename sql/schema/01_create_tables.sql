PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
  customer_id  TEXT PRIMARY KEY,
  full_name    TEXT NOT NULL,
  city         TEXT NOT NULL,
  country      TEXT NOT NULL,
  signup_date  TEXT NOT NULL
);

CREATE TABLE products (
  product_id    TEXT PRIMARY KEY,
  product_name  TEXT NOT NULL,
  category      TEXT NOT NULL,
  unit_price    REAL NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE orders (
  order_id     TEXT PRIMARY KEY,
  order_date   TEXT NOT NULL,
  customer_id  TEXT NOT NULL,
  product_id   TEXT NOT NULL,
  quantity     INTEGER NOT NULL CHECK (quantity > 0),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_product ON orders(product_id);
