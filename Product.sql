✅ Rolling Average using Window Functions
✅ Top 5 Products by Revenue in the last quarter
✅ Identifying Inactive Customers
✅ YoY Growth Analysis
✅ Average Delivery Time Calculation


✅ Rolling Average using Window Functions
SELECT 
  order_date,
  sale_amount,
  AVG(sale_amount) OVER (ORDER BY order_date ROW BETWEEN 29 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM sales

✅ Top 5 Products by Revenue in the last quarter

SELECT
  product_id,
  SUM(revenue) AS total_revenue
FROM product
WHERE order_date BETWEEN DATEADD(QUARTER , -1 , GETDATE()) AND GETDATE()
GROUP BY product_id
ORDER BY total_revenue

✅ Identifying Inactive Customers:Find the customer who had not placed any order in last 6 month

SELECT 
  c.customer_id, c.customer_name
FROM customer c
JOIN sales s
ON c.customer_id = o.customer_id
AND s.orderdate > DATEADD(MONTH ,  -6, GETDATE())
WHERE o.customer_id IS NULL


✅ Calculate YoY Growth percenatge in sales for each product Analysis(Compare sales performnce from prevous year)
WITH sales_per_year AS (
    SELECT
        product_id,
        YEAR(order_date) AS year,
        SUM(sales_amount) AS total_sales
    FROM sales
    GROUP BY product_id, YEAR(order_date)
)
SELECT
    s1.product_id,
    s1.year AS current_year,
    s1.total_sales AS current_year_sales,
    s2.year AS previous_year,
    s2.total_sales AS previous_year_sales,
    ((s1.total_sales - s2.total_sales) / s2.total_sales) * 100 AS yoy_growth
FROM sales_per_year s1
LEFT JOIN sales_per_year s2
    ON s1.product_id = s2.product_id AND s1.year = s2.year + 1
WHERE s1.year = YEAR(GETDATE());



✅ Average time taken for an order to be Delivered after its place
SELECT
 AVG(DATEDIFF(day,order_date,delivery_date) AS avg_delivery_time
FROM orders
WHERE delivery_date IS NOT NULL

