-- ============================================================
-- ORDER FULFILLMENT & INVENTORY PERFORMANCE ANALYSIS - SQL QUERIES
-- ============================================================

-- 1. Order fulfillment rate
-- Insight: measures the percentage of orders Shipped vs Canceled vs Pending
SELECT OrderStatus, COUNT(*) AS order_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM OrderDetails), 1) AS percentage
FROM OrderDetails
GROUP BY OrderStatus
ORDER BY order_count DESC;


-- 2. Product categories with the highest total order value
-- Insight: identifies which categories should be the priority for inventory management
SELECT product.CategoryName,
  SUM(orderdetails.OrderItemQuantity * orderdetails.PerUnitPrice) AS total_order_value
FROM product
JOIN orderdetails ON product.ProductID = orderdetails.ProductID
GROUP BY product.CategoryName
ORDER BY total_order_value DESC;


-- 3. Warehouse and staff distribution by region (with data cleaning)
-- Note: the region name "North America" appeared inconsistently (double space),
-- REPLACE() is used to merge it before grouping
SELECT REPLACE(region.RegionName, '  ', ' ') AS region_clean,
  COUNT(DISTINCT warehouse.WarehouseID) AS warehouse_count,
  COUNT(employee.EmployeeID) AS employee_count
FROM region
LEFT JOIN warehouse ON region.RegionID = warehouse.RegionID
LEFT JOIN employee ON warehouse.WarehouseID = employee.WarehouseID
GROUP BY REPLACE(region.RegionName, '  ', ' ')
ORDER BY warehouse_count DESC;


-- 4. Top 10 products by profit margin
-- Insight: compares per-unit profitability, not just sales volume
SELECT ProductName, CategoryName,
  ROUND(Profit / ProductListPrice * 100, 1) AS profit_margin
FROM Product
ORDER BY profit_margin DESC
LIMIT 10;


-- 5. Products with the most Pending/Canceled orders
-- Insight: identifies products that most often fail to ship,
-- top candidates for a stock availability audit
SELECT product.ProductName, COUNT(orderdetails.OrderStatus) AS order_count
FROM product
JOIN orderdetails ON product.ProductID = orderdetails.ProductID
WHERE orderdetails.OrderStatus IN ('Pending', 'Canceled')
GROUP BY product.ProductName
ORDER BY order_count DESC
LIMIT 10;
