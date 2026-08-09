-- Q18: Which shipments were delivered late (delivery after order + 7 days) or not yet delivered?
SELECT s.shipment_id, s.order_id, s.carrier, s.ship_date, s.delivery_date,
       o.order_date,
       CASE
           WHEN s.delivery_date IS NULL THEN 'In transit'
           WHEN julianday(s.delivery_date) - julianday(o.order_date) > 7 THEN 'Late'
           ELSE 'On time'
       END AS delivery_status
FROM shipments s
JOIN orders o ON s.order_id = o.order_id
WHERE s.delivery_date IS NULL
   OR julianday(s.delivery_date) - julianday(o.order_date) > 7
ORDER BY s.delivery_date IS NULL DESC, s.shipment_id;
