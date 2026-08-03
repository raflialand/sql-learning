-- =============================================================================
-- SimpleMart E-Commerce Database — PostgreSQL DDL
-- Source system for Data Warehouse training
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. users — Customer accounts
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    user_id         SERIAL          PRIMARY KEY,
    email           VARCHAR(255)    NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    first_name      VARCHAR(100)    NOT NULL,
    last_name       VARCHAR(100)    NOT NULL,
    phone           VARCHAR(20),
    status          VARCHAR(20)     NOT NULL DEFAULT 'active',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 2. user_addresses — Shipping/billing addresses per user
-- ---------------------------------------------------------------------------
CREATE TABLE user_addresses (
    address_id      SERIAL          PRIMARY KEY,
    user_id         INTEGER         NOT NULL REFERENCES users(user_id),
    label           VARCHAR(50)     NOT NULL,
    recipient_name  VARCHAR(200)    NOT NULL,
    street          TEXT            NOT NULL,
    city            VARCHAR(100)    NOT NULL,
    state           VARCHAR(100),
    postal_code     VARCHAR(20)     NOT NULL,
    country         VARCHAR(100)    NOT NULL DEFAULT 'Indonesia',
    phone           VARCHAR(20),
    is_default      BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 3. categories — Product category hierarchy
-- ---------------------------------------------------------------------------
CREATE TABLE categories (
    category_id     SERIAL          PRIMARY KEY,
    parent_id       INTEGER         REFERENCES categories(category_id),
    name            VARCHAR(100)    NOT NULL,
    slug            VARCHAR(100)    NOT NULL UNIQUE,
    description     TEXT,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 4. products — Sellable items
-- ---------------------------------------------------------------------------
CREATE TABLE products (
    product_id      SERIAL          PRIMARY KEY,
    category_id     INTEGER         NOT NULL REFERENCES categories(category_id),
    name            VARCHAR(200)    NOT NULL,
    slug            VARCHAR(200)    NOT NULL UNIQUE,
    description     TEXT,
    base_price      NUMERIC(12, 2)  NOT NULL,
    sku             VARCHAR(50)     NOT NULL UNIQUE,
    weight_grams    INTEGER,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 5. product_images — Product image gallery
-- ---------------------------------------------------------------------------
CREATE TABLE product_images (
    image_id        SERIAL          PRIMARY KEY,
    product_id      INTEGER         NOT NULL REFERENCES products(product_id),
    url             TEXT            NOT NULL,
    alt_text        VARCHAR(200),
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    is_primary      BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 6. inventory — Warehouse stock per product
-- ---------------------------------------------------------------------------
CREATE TABLE inventory (
    inventory_id    SERIAL          PRIMARY KEY,
    product_id      INTEGER         NOT NULL REFERENCES products(product_id) UNIQUE,
    quantity        INTEGER         NOT NULL DEFAULT 0,
    reserved_qty    INTEGER         NOT NULL DEFAULT 0,
    warehouse_code  VARCHAR(20)     NOT NULL DEFAULT 'WH-001',
    last_restock_at TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 7. carts — Active shopping carts
-- ---------------------------------------------------------------------------
CREATE TABLE carts (
    cart_id         SERIAL          PRIMARY KEY,
    user_id         INTEGER         NOT NULL REFERENCES users(user_id) UNIQUE,
    status          VARCHAR(20)     NOT NULL DEFAULT 'active',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 8. cart_items — Line items within a cart
-- ---------------------------------------------------------------------------
CREATE TABLE cart_items (
    cart_item_id    SERIAL          PRIMARY KEY,
    cart_id         INTEGER         NOT NULL REFERENCES carts(cart_id),
    product_id      INTEGER         NOT NULL REFERENCES products(product_id),
    quantity        INTEGER         NOT NULL DEFAULT 1,
    unit_price      NUMERIC(12, 2)  NOT NULL,
    added_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (cart_id, product_id)
);

-- ---------------------------------------------------------------------------
-- 9. orders — Completed/pending orders
-- ---------------------------------------------------------------------------
CREATE TABLE orders (
    order_id        SERIAL          PRIMARY KEY,
    user_id         INTEGER         NOT NULL REFERENCES users(user_id),
    address_id      INTEGER         NOT NULL REFERENCES user_addresses(address_id),
    order_number    VARCHAR(30)     NOT NULL UNIQUE,
    status          VARCHAR(20)     NOT NULL DEFAULT 'pending',
    subtotal        NUMERIC(12, 2)  NOT NULL,
    shipping_cost   NUMERIC(12, 2)  NOT NULL DEFAULT 0,
    tax_amount      NUMERIC(12, 2)  NOT NULL DEFAULT 0,
    total_amount    NUMERIC(12, 2)  NOT NULL,
    notes           TEXT,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 10. order_items — Line items within an order
-- ---------------------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id   SERIAL          PRIMARY KEY,
    order_id        INTEGER         NOT NULL REFERENCES orders(order_id),
    product_id      INTEGER         NOT NULL REFERENCES products(product_id),
    quantity        INTEGER         NOT NULL,
    unit_price      NUMERIC(12, 2)  NOT NULL,
    subtotal        NUMERIC(12, 2)  NOT NULL,
    UNIQUE (order_id, product_id)
);

-- ---------------------------------------------------------------------------
-- 11. payments — Payment transactions per order
-- ---------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id      SERIAL          PRIMARY KEY,
    order_id        INTEGER         NOT NULL REFERENCES orders(order_id) UNIQUE,
    payment_method  VARCHAR(30)     NOT NULL,
    transaction_ref VARCHAR(100),
    amount          NUMERIC(12, 2)  NOT NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'pending',
    paid_at         TIMESTAMP,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 12. shipments — Delivery tracking per order
-- ---------------------------------------------------------------------------
CREATE TABLE shipments (
    shipment_id     SERIAL          PRIMARY KEY,
    order_id        INTEGER         NOT NULL REFERENCES orders(order_id) UNIQUE,
    carrier         VARCHAR(100)    NOT NULL,
    tracking_number VARCHAR(100),
    status          VARCHAR(20)     NOT NULL DEFAULT 'pending',
    estimated_delivery DATE,
    shipped_at      TIMESTAMP,
    delivered_at    TIMESTAMP,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 13. reviews — Product reviews by customers
-- ---------------------------------------------------------------------------
CREATE TABLE reviews (
    review_id       SERIAL          PRIMARY KEY,
    user_id         INTEGER         NOT NULL REFERENCES users(user_id),
    product_id      INTEGER         NOT NULL REFERENCES products(product_id),
    order_id        INTEGER         NOT NULL REFERENCES orders(order_id),
    rating          SMALLINT        NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment         TEXT,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, product_id, order_id)
);

-- =============================================================================
-- Indexes for common query patterns
-- =============================================================================
CREATE INDEX idx_users_email         ON users(email);
CREATE INDEX idx_users_status        ON users(status);
CREATE INDEX idx_users_created_at    ON users(created_at);

CREATE INDEX idx_addresses_user      ON user_addresses(user_id);

CREATE INDEX idx_categories_parent   ON categories(parent_id);
CREATE INDEX idx_categories_slug     ON categories(slug);

CREATE INDEX idx_products_category   ON products(category_id);
CREATE INDEX idx_products_sku        ON products(sku);
CREATE INDEX idx_products_active     ON products(is_active);

CREATE INDEX idx_images_product      ON product_images(product_id);

CREATE INDEX idx_carts_user          ON carts(user_id);
CREATE INDEX idx_carts_status        ON carts(status);

CREATE INDEX idx_cart_items_cart     ON cart_items(cart_id);
CREATE INDEX idx_cart_items_product  ON cart_items(product_id);

CREATE INDEX idx_orders_user         ON orders(user_id);
CREATE INDEX idx_orders_status       ON orders(status);
CREATE INDEX idx_orders_created_at   ON orders(created_at);
CREATE INDEX idx_orders_number       ON orders(order_number);

CREATE INDEX idx_order_items_order   ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

CREATE INDEX idx_payments_order      ON payments(order_id);
CREATE INDEX idx_payments_status     ON payments(status);

CREATE INDEX idx_shipments_order     ON shipments(order_id);
CREATE INDEX idx_shipments_status    ON shipments(status);

CREATE INDEX idx_reviews_product     ON reviews(product_id);
CREATE INDEX idx_reviews_user        ON reviews(user_id);
CREATE INDEX idx_reviews_order       ON reviews(order_id);
