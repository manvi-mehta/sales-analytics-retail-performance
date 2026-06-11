-- =====================================================
-- Project : Superstore Retail Performance and Profitability Analysis 
-- Author: Manvi Mehta
-- Tools: MySQL, Power BI, Python
-- Description:
-- Designed a star-schema data warehouse and executed
-- business analysis queries to evaluate sales performance,
-- profitability, customer behavior, shipping efficiency,
-- and discount impact.
-- =====================================================

-- 1. Database Setup
Create database sales_dw;
use sales_dw;


-- 2. Dimension Table
-- Customer
Create Table dim_customer(
customer_id varchar(50) NOT NULL PRIMARY KEY,
customer_name varchar(100),
segment varchar(30)
);

-- Product
Create Table dim_product(
product_id varchar(50) NOT NULL PRIMARY KEY,
product_name varchar(255),
category varchar(50),
sub_category varchar(50)
);


-- Location
Create Table dim_geography(
location_id INT PRIMARY KEY,
country varchar(50),
city varchar(50),
state varchar(50),
postal_code varchar(50),
region varchar(50)
);


-- Date
Create Table dim_date(
date_key INT PRIMARY KEY,
full_date DATE,
year_num int,
month_num int,
day_num int, 
month_name varchar(30),
quarter_num int
);

-- Shipping
Create Table dim_shipping(
shipping_id INT PRIMARY KEY,
ship_mode varchar(50)
);

-- 3. Fact Table
Create Table fact_sales(
sale_id INT AUTO_INCREMENT PRIMARY KEY,
order_id varchar(50),
customer_id varchar(50),
product_id varchar(50),
location_id INT,
shipping_id INT,
order_date_key int,
ship_date_key int,

sales decimal(10,2),
profit decimal(10,2),
quantity int,
discount decimal(4,2),

FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id), 
FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
FOREIGN KEY (location_id) REFERENCES dim_geography(location_id),
FOREIGN KEY (shipping_id) REFERENCES dim_shipping(shipping_id),
FOREIGN KEY (order_date_key) REFERENCES dim_date(date_key),
FOREIGN KEY (ship_date_key) REFERENCES dim_date(date_key)
);

--4. DATA VALIDATION
SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_geography;
SELECT COUNT(*) FROM dim_date;
SELECT COUNT(*) FROM dim_shipping;
SELECT COUNT(*) FROM fact_sales;


-- ==========================================
-- SALES PERFORMANCE ANALYSIS
-- ==========================================

--REVENUE TREND  

SELECT 
    d.year_num,
    d.month_num,
    d.month_name,
    SUM(f.sales) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.order_date_key = d.date_key
GROUP BY d.year_num, d.month_num, d.month_name
ORDER BY d.year_num, d.month_num;

--Contribution % by Category

SELECT 
    p.category,
    SUM(f.sales) AS total_sales,
    ROUND(
        SUM(f.sales) * 100 / (SELECT SUM(sales) FROM fact_sales), 2
    ) AS contribution_pct
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category;


--Top Performing Region per Category

SELECT 
    p.category,
    g.region,
    SUM(f.sales) AS total_sales
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_geography g ON f.location_id = g.location_id
GROUP BY p.category, g.region
ORDER BY p.category, total_sales DESC;


-- =====================================================
-- PRODUCT PERFORMANCE ANALYSIS
-- =====================================================

--Profitability by Category

SELECT 
    p.category,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    ROUND(SUM(f.profit)/SUM(f.sales)*100,2) AS profit_margin
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

--Loss-Making Sub-Categories

SELECT 
    p.sub_category,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.sub_category
HAVING total_profit < 0
ORDER BY total_profit;

--Top Profitable Products

SELECT 
    p.product_name,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 10;

--Top products by Profit
SELECT 
    p.product_name,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 5;


--Regional Performance

SELECT 
    g.region,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_geography g ON f.location_id = g.location_id
GROUP BY g.region
ORDER BY total_sales DESC;


-- =====================================================
-- CUSTOMER ANALYSIS
-- =====================================================

--Top Customers
SELECT 
    c.customer_name,
    SUM(f.sales) AS total_spent
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 10;

--Customer Segmentation (High / Medium / Low value)
SELECT 
    c.customer_name,
    SUM(f.sales) AS total_spent,
    CASE 
        WHEN SUM(f.sales) > 5000 THEN 'High Value'
        WHEN SUM(f.sales) BETWEEN 2000 AND 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_name;


--Average Order Value (AOV)
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales) AS total_revenue,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM fact_sales;

-- Repeat vs One-Time Customers
SELECT
CASE
WHEN order_count = 1 THEN 'One-time'
ELSE 'Repeat'
END AS customer_type,
COUNT(*) AS num_customers
FROM (
SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
FROM fact_sales
GROUP BY customer_id
) t
GROUP BY customer_type;



-- =====================================================
-- SHIPPING & DISCOUNT ANALYSIS
-- =====================================================

--Delivery Time Analysis

SELECT 
    AVG(DATEDIFF(d2.full_date, d1.full_date)) AS avg_delivery_days
FROM fact_sales f
JOIN dim_date d1 ON f.order_date_key = d1.date_key
JOIN dim_date d2 ON f.ship_date_key = d2.date_key;


--Shipping Performance

SELECT 
    s.ship_mode,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_shipping s ON f.shipping_id = s.shipping_id
GROUP BY s.ship_mode
ORDER BY total_sales DESC;

--Discount Impact

SELECT 
    ROUND(f.discount,1) AS discount_level,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM fact_sales f
GROUP BY discount_level
ORDER BY discount_level;

--Profit vs Discount Correlation 

SELECT 
    ROUND(f.discount,1) AS discount_level,
    AVG(f.profit) AS avg_profit
FROM fact_sales f
GROUP BY discount_level
ORDER BY discount_level;
