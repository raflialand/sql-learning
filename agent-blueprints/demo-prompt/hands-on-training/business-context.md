# Business Context — Simple E-Commerce Platform

## Overview

**SimpleMart** is a small-to-medium e-commerce platform that sells consumer goods online. The platform supports the end-to-end purchase lifecycle: customer registration, product browsing, cart management, checkout, payment processing, order fulfillment, and product reviews.

This database serves as the **operational (OLTP) source system** for a data warehouse training exercise. Participants will model this OLTP schema into a star/snowflake dimensional model, build ETL pipelines, and create analytical reports.

---

## Business Entities

### Customers (Users)

A customer registers with an email and password. They can maintain multiple shipping addresses. Customers browse products and place orders.

### Product Catalog

Products are organized into a hierarchy of categories (e.g., Electronics → Smartphones). Each product has a name, description, base price, and one or more images. Products belong to exactly one category.

### Inventory

Each product has a stock quantity tracked in a warehouse. Inventory is decremented when an order is placed and can be manually adjusted.

### Shopping Cart

Registered users can add products to their cart. A cart is session-scoped — one active cart per user at a time. Carts expire after 7 days of inactivity.

### Orders

When a customer checks out, the cart is converted into an order. An order captures the shipping address, order status, and total amount. Each order contains one or more line items (order items).

### Payments

Each order has exactly one payment record. Payments track the payment method, transaction status, and timestamps. Supported payment methods: credit_card, debit_card, bank_transfer, ewallet.

### Shipments

Each order has one shipment record. Shipments track the carrier, tracking number, shipping status, and delivery estimate.

### Reviews

After receiving an order, customers can leave a product review with a rating (1–5) and optional comment.

---

## Key Business Processes

| Process | Description |
|---|---|
| **Customer Registration** | User creates an account with email, name, password |
| **Product Browsing** | Users browse categories and view product details |
| **Add to Cart** | User adds products to their shopping cart |
| **Checkout** | Cart is converted to an order with a shipping address |
| **Payment** | Payment is processed for the order |
| **Fulfillment** | Order is picked, packed, and shipped |
| **Delivery** | Order is delivered to the customer |
| **Review** | Customer rates and reviews purchased products |

---

## Order Status Lifecycle

```
pending → confirmed → paid → shipped → delivered
                           ↘ cancelled (only before shipped)
```

---

## Analytical Use Cases (DW Training Goals)

Participants will answer these analytical questions using the data warehouse built from this source:

1. Daily/weekly/monthly revenue trends
2. Top-selling products and categories
3. Customer lifetime value (LTV) segmentation
4. Cart abandonment rate analysis
5. Average order value (AOV) by customer segment
6. Inventory turnover and stock-out risk
7. Payment method preference by region
8. Shipping performance (on-time delivery rate)
9. Product review sentiment and rating distribution
10. Customer cohort retention analysis
