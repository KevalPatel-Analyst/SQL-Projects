use store_db;

/*Who are the top customers by total spending, and what patterns can be observed in their purchasing behavior?*/
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_price), 2) AS total_spending,
    ROUND(SUM(o.total_price) / COUNT(o.order_id),
            2) AS average_order_value
FROM
    customer c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id , customer_name
ORDER BY total_spending DESC
LIMIT 10;

/*Retention Analysis for Top Customers*/
WITH Top_Customers AS (
    SELECT 
        o.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        count(o.order_id) AS total_orders,
        ROUND(SUM(o.total_price), 2) AS total_spending,
        ROUND(AVG(o.total_price), 2) AS average_order_value
    FROM orders o
    JOIN customer c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, customer_name
    ORDER BY total_spending DESC
    LIMIT 10
)
SELECT 
    tc.customer_id,
    tc.customer_name,
    COUNT(DISTINCT DATE_FORMAT(o.order_date, '%Y-%m')) AS active_months,
    MIN(o.order_date) AS first_purchase_date,
    MAX(o.order_date) AS last_purchase_date,
    tc.total_orders,
    tc.total_spending,
    tc.average_order_value
FROM Top_Customers tc
JOIN orders o ON tc.customer_id = o.customer_id
GROUP BY tc.customer_id, tc.customer_name, tc.total_orders, tc.total_spending, tc.average_order_value
ORDER BY active_months DESC, total_spending DESC;

/*Top Customers’ Purchase Frequency by Month */
WITH Top_cust AS (
    SELECT 
        o.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(o.total_price) AS total_spending
    FROM 
        orders o
    JOIN 
        customer c ON o.customer_id = c.customer_id
    GROUP BY 
        o.customer_id, customer_name
    ORDER BY 
        total_spending DESC
    LIMIT 10  -- Get the top 10 customers by spending
)
SELECT 
    tc.customer_id,
    tc.customer_name,
    monthname(o.order_date) AS order_month,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_price) AS total_spending
FROM 
    orders o
JOIN 
    Top_Cust tc ON o.customer_id = tc.customer_id
GROUP BY 
    tc.customer_id, tc.customer_name, order_month
ORDER BY 
    tc.customer_id, total_orders DESC;


/*Top 5 state and city revenue generating */
select  substring_index(c.address,",",-1) as 
state,SUBSTRING_INDEX(SUBSTRING_INDEX(c.address, ',', -2), ',', 1) as City,round(sum(o.total_price)) as total_amt_generated
from store_db.customer as c join store_db.orders as o
on c.customer_id=o.customer_id
where c.address is not null
group by substring_index(c.address,",",-1),SUBSTRING_INDEX(SUBSTRING_INDEX(c.address, ',', -2), ',', 1) 
order by total_amt_generated desc
limit 5;



/*What are the top 10 best-selling products, and how do their sales vary by category?*/
select p.category , p.product_name,sum(oi.quantity) as total_units_sold, sum(oi.quantity * oi.price_at_purchase) as total_revenue
from store_db.product as p join store_db.order_items as oi
on p.product_id = oi.product_id
where p.category is not null
group by p.category , p.product_name
order by total_units_sold desc, total_revenue desc
limit 10;

-- Revenue contribution by product category with percentage
SELECT 
    p.category,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue,
    ROUND(SUM(oi.quantity * oi.price_at_purchase) / (SELECT SUM(oi2.quantity * oi2.price_at_purchase)
                                                     FROM order_items oi2
                                                     JOIN product p2 ON oi2.product_id = p2.product_id) * 100, 2) AS revenue_percentage,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units_sold
FROM 
    store_db.product p
JOIN 
    order_items oi ON p.product_id = oi.product_id
JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    p.category
ORDER BY 
    total_revenue DESC;
    
    
select * from store_db.orders;

/*Monthly total orders and total revenue trends*/
select date_format(order_date,'%Y-%m') as month, 
count(o.order_id) as total_orders, sum(oi.quantity * oi.price_at_purchase) as total_revenue
from store_db.orders as o join store_db.order_items as oi
on o.order_id = oi.order_id 
where o.order_id is not null
group by date_format(order_date,'%Y-%m') 
order by month asc;

/*Quaterly total orders and total revenue Trends*/
select CONCAT(YEAR(o.order_date), '-Q', 
QUARTER(o.order_date)) as quater , count(o.order_id) as total_orders, sum(oi.quantity * oi.price_at_purchase) as total_revenue
from store_db.orders as o join store_db.order_items as oi
on o.order_id = oi.order_id 
where o.order_id is not null
group by CONCAT(YEAR(o.order_date), '-Q', QUARTER(o.order_date))
order by quater asc;

/*yearly  total orders and total revenue trends*/
select year(o.order_date) as year , count(o.order_id) as total_orders, sum(oi.quantity * oi.price_at_purchase) as total_revenue
from store_db.orders as o join store_db.order_items as oi
on o.order_id = oi.order_id 
where o.order_id is not null
group by year(o.order_date)
order by year asc;


 /*Top 5 Average Order Value by state  and city */
SELECT 
    TRIM(SUBSTRING_INDEX(c.address, ',', -1)) AS state,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.address, ',', -2), ',', 1)) AS city,
    round(AVG(o.total_price),2) AS avg_order_value,
    COUNT(o.order_id) AS total_orders,
    round(SUM(o.total_price),0) AS total_revenue
FROM 
    customer c
JOIN 
    orders o ON c.customer_id = o.customer_id
WHERE 
    c.address IS NOT NULL
GROUP BY 
    state,city
ORDER BY 
    avg_order_value DESC
    limit 5;
 


/*Which  top 10 suppliers provide the most revenue-generating products*/
select 
	s.supplier_id,p.product_name,
    s.supplier_name,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue,
    COUNT(DISTINCT p.product_id) AS total_products_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders
from 
	store_db.suppliers as s
join 
	store_db.product as p on s.supplier_id = p.supplier_id
join 
	store_db.order_items as oi on p.product_id=oi.product_id
where supplier_name is not null
group by s.supplier_id,s.supplier_name,p.product_name
order by total_revenue desc
limit 10;


    
/*What is the relationship between product ratings and sales volume?*/
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    round(AVG(r.rating), 2) AS avg_rating,
    SUM(oi.quantity) AS total_units_sold, 
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue 
FROM 
    product p
LEFT JOIN 
    reviews r ON p.product_id = r.product_id 
JOIN 
    order_items as oi ON p.product_id = oi.product_id
where r.rating is not null
GROUP BY 
    p.product_id, p.product_name, p.category
ORDER BY 
    avg_rating DESC;
    
    /*how many transaction completed,failed,pending */
    select 
		p.payment_method,
        count(p.payment_id) as total_transaction,
        sum(case when p.transaction_status = 'Completed' then 1 else 0 end) as Total_completed,
        sum(case when p.transaction_status = 'Failed' then 1 else 0 end) as Total_failed,
        sum(case when p.transaction_status = 'Pending' then 1 else 0 end) as Total_pending
    from store_db.payment as p
    where p.payment_id is not null
    group by p.payment_method;
    
    /*What is the lifetime value (LTV) of a customer*/
    SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    Round(SUM(o.total_price),0)AS total_revenue,
    ROUND(SUM(o.total_price) / COUNT(o.order_id), 2) AS avg_order_value,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifespan_days,
    ROUND(SUM(o.total_price) / (DATEDIFF(MAX(o.order_date), MIN(o.order_date)) / 365), 2) AS annual_ltv
FROM 
    customer c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    total_revenue DESC
    limit 10;
    
  
/*2024 Customer Cohort Revenue and LTV Analysis*/   
SELECT 
    cohort_month, 
    COUNT(DISTINCT customer_id) AS total_customers,
    round(SUM(total_price),0) AS total_revenue,
    ROUND(SUM(total_price) / COUNT(DISTINCT customer_id), 2) AS avg_ltv
FROM (
    SELECT 
        c.customer_id,
        DATE_FORMAT(MIN(o.order_date), '%Y-%m') AS cohort_month, 
        o.total_price
    FROM 
        customer c
    JOIN 
        orders o ON c.customer_id = o.customer_id
    WHERE 
        YEAR(o.order_date) = 2024 
    GROUP BY 
        c.customer_id, o.total_price
) cohort_data
GROUP BY cohort_month
ORDER BY cohort_month ASC;


-- cohort of customer retained
WITH first_purchase AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
),
monthly_purchases AS (
    SELECT 
        o.customer_id,
        fp.cohort_month,
        DATE_FORMAT(o.order_date, '%Y-%m') AS purchase_month
    FROM orders o
    JOIN first_purchase fp ON o.customer_id = fp.customer_id
)
SELECT 
    cohort_month, 
    purchase_month, 
    COUNT(DISTINCT customer_id) AS customers_retained
FROM monthly_purchases
GROUP BY cohort_month, purchase_month
ORDER BY cohort_month, purchase_month;












