-- Q11: Revenue breakdown by order status using conditional aggregation.
SELECT
    SUM(CASE WHEN status = 'Completed' THEN total_amount ELSE 0 END) AS completed_rev,
    SUM(CASE WHEN status = 'Shipped' THEN total_amount ELSE 0 END) AS shipped_rev,
    SUM(CASE WHEN status = 'Pending' THEN total_amount ELSE 0 END) AS pending_rev,
    SUM(CASE WHEN status = 'Cancelled' THEN total_amount ELSE 0 END) AS cancelled_rev
FROM orders;
