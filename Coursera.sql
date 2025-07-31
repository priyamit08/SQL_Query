CREATE TABLE saless (
    sale_id INT,
    customer_name VARCHAR,
    email VARCHAR,
    city VARCHAR,
    product VARCHAR,
    category VARCHAR,
    quantity INT,
    unit_price DECIMAL,
    discount DECIMAL,
    tax_rate DECIMAL,
    sale_date DATE,
    return_date DATE
);

INSERT INTO saless (sale_id, customer_name, email, city, product, category, quantity, unit_price, discount, tax_rate, sale_date, return_date)
VALUES
-- City A: 2 categories, Laptop sells most
(1, 'Alice', 'alice@example.com', 'City A', 'Laptop', 'Electronics', 5, 1000, 0, 0.1, '2025-07-01', NULL),
(2, 'Bob', 'bob@example.com', 'City A', 'Smartphone', 'Electronics', 3, 500, 0, 0.1, '2025-07-02', NULL),
(3, 'Cathy', 'cathy@example.com', 'City A', 'Desk', 'Furniture', 4, 150, 0, 0.1, '2025-07-03', NULL),

-- City B: 1 category only, should be excluded
(4, 'Dave', 'dave@example.com', 'City B', 'Tablet', 'Electronics', 6, 300, 0, 0.1, '2025-07-01', NULL),
(5, 'Emma', 'emma@example.com', 'City B', 'Laptop', 'Electronics', 2, 1000, 0, 0.1, '2025-07-02', NULL),

-- City C: 2 categories, Book sells most
(6, 'Fred', 'fred@example.com', 'City C', 'Book', 'Books', 10, 20, 0, 0.1, '2025-07-01', NULL),
(7, 'Gina', 'gina@example.com', 'City C', 'Pen', 'Stationery', 6, 2, 0, 0.1, '2025-07-02', NULL),
(8, 'Hank', 'hank@example.com', 'City C', 'Book', 'Books', 5, 20, 0, 0.1, '2025-07-03', NULL),

-- City D: 2 categories, tie between two products
(9, 'Ivy', 'ivy@example.com', 'City D', 'Chair', 'Furniture', 5, 100, 0, 0.1, '2025-07-01', NULL),
(10, 'Jake', 'jake@example.com', 'City D', 'Table', 'Furniture', 5, 150, 0, 0.1, '2025-07-02', NULL),
(11, 'Kim', 'kim@example.com', 'City D', 'Lamp', 'Lighting', 2, 50, 0, 0.1, '2025-07-03', NULL);



WITH cities_with_multiple_categories AS (
    SELECT city
    FROM saless
    GROUP BY city
    HAVING COUNT(DISTINCT category) >= 2
),
product_sales AS (
    SELECT 
        city,
        product,
        SUM(quantity) AS total_quantity
    FROM saless
    WHERE city IN (SELECT city FROM cities_with_multiple_categories)
    GROUP BY city, product
),
ranked_products AS (
    SELECT 
        city,
        product,
        total_quantity,
        RANK() OVER (PARTITION BY city ORDER BY total_quantity DESC) AS rank
    FROM product_sales
)
SELECT 
    city,
    product AS best_selling_product,
    total_quantity
FROM ranked_products
WHERE rank = 1;

/*To find the best-selling product in each city, but only for cities where at least two different product categories were sold, here's the structured thought process I'd follow in PostgreSQL:

1. Understand the goal
We’re trying to:

Identify cities with at least two distinct product categories sold.
Within those cities, determine the product with the highest total quantity sold.
2. Filter cities with ≥ 2 categories
Start by grouping by city, and use COUNT(DISTINCT category) to count unique categories.
Keep only those cities where this count is ≥ 2.
This gives us the qualified cities for further analysis.

3. Aggregate sales data
For only those qualified cities:

Group by city and product.
Use SUM(quantity) to get the total quantity sold for each product in each city.
4. Identify the top-selling product per city
Now for each city, we:

Rank products based on total quantity sold using ROW_NUMBER() or RANK().
Pick the product with rank = 1 in each city — that's the best-selling product.
If using RANK() instead of ROW_NUMBER(), be aware it can return ties if two products have equal quantities.
5. Optional joins
To connect the filtered cities from Step 2 with aggregated data from Step 3, you may need a subquery or CTE (Common Table Expression).

Summary of the approach
Step 1: Filter cities with at least 2 categories.
Step 2: Aggregate product sales in those cities.
Step 3: Rank products by total quantity in each city.
Step 4: Pick the top-ranked (best-selling) product per city.
*/
