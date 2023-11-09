USE sales;
#1. How many customers do not have DOB information available?
USE sales;
SELECT COUNT(*) FROM customers WHERE DOB = ' ';

#2. How many customers are there in each pincode and gender combination?
SELECT primary_pincode, gender, COUNT(*) as customer_count FROM customers
GROUP BY primary_pincode, gender;

#3. Print product name and mrp for products which have more than 50000 MRP?
SELECT product_name, mrp FROM products
WHERE mrp > 50000;

#4. How many delivery personal are there in each pincode?
SELECT pincode, COUNT(*) as delivery_person_count FROM delivery_person
  GROUP BY pincode;

#5. For each Pin code, print the count of orders, sum of total amount paid, average amount paid, maximum amount paid, minimum amount paid for the transactions which were paid by 'cash'. Take only 'buy' order types

SELECT delivery_pincode, COUNT(*) as order_count,
    SUM(total_amount_paid) as total_amount,
    AVG(total_amount_paid) as average_amount,
    MAX(total_amount_paid) as max_amount,
    MIN(total_amount_paid) as min_amount
FROM orders
WHERE payment_type = 'cash' AND order_type = 'buy'
GROUP BY delivery_pincode;

#6. For each delivery_person_id, print the count of orders and total amount paid for product_id = 12350 or 12348 and total units > 8. Sort the output by total amount paid in descending order. Take only 'buy' order types.
SELECT delivery_person_id, COUNT(*) as order_count,
    SUM(total_amount_paid) as total_amount_paid
FROM orders
WHERE (product_id = 12350 OR product_id = 12348) AND tot_units > 8 AND order_type = 'buy'
GROUP BY delivery_person_id
ORDER BY total_amount_paid DESC;

#7. Print the Full names (first name plus last name) for customers that have email on "gmail.com"?
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM customers
WHERE email LIKE '%@gmail.com';

#8. Which pincode has average amount paid more than 150,000? Take only 'buy' order types?
SELECT delivery_pincode,   
 AVG(total_amount_paid) as average_amount_paid 
FROM orders 
WHERE order_type = 'buy'
GROUP BY delivery_pincode
HAVING AVG(total_amount_paid) > 150000;

#9. Create following columns from order_dim data -     order_date     Order day     Order month     Order year
SELECT     
STR_TO_DATE(order_date, '%d-%m-%Y') as order_date,    
DAY(STR_TO_DATE(order_date, '%d-%m-%Y')) as Order_day,    
MONTHNAME(STR_TO_DATE(order_date, '%d-%m-%Y')) as Order_month,    
YEAR(STR_TO_DATE(order_date, '%d-%m-%Y')) as Order_year
FROM orders; 

#10. How many total orders were there in each month and how many of them were returned? Add a column for return rate too.return rate = (100.0 * total return orders) / total buy orders Hint: You will need to combine SUM() with CASE WHEN.
SELECT   MONTHNAME(STR_TO_DATE(order_date, '%d-%m-%Y')) AS order_month,    
COUNT(*) as total_orders,    
SUM(CASE WHEN order_type = 'return' THEN 1 ELSE 0 END) as total_returns,    
(100.0 * SUM(CASE WHEN order_type = 'return' THEN 1 ELSE 0 END)) / COUNT(*) as return_rate
FROM orders
GROUP BY order_month;

#11. How many units have been sold by each brand? Also get total returned units for each brand?
SELECT  p.brand,    
SUM(CASE WHEN o.order_type = 'buy' THEN o.tot_units ELSE 0 END) as total_units_sold,    SUM(CASE WHEN o.order_type = 'return' THEN o.tot_units ELSE 0 END) as total_units_returned
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.brand

#12. How many distinct customers and delivery boys are there in each state?
SELECT  p.state,    
COUNT(DISTINCT c.cust_id) as distinct_customers,    
COUNT(DISTINCT dp.delivery_person_id) as distinct_delivery_boys
FROM pincode p
LEFT JOIN Customers c ON p.pincode = c.primary_pincode
LEFT JOIN Delivery_Person dp ON p.pincode = dp.pincode
GROUP BY p.state;

#13. For every customer, print how many total units were ordered, how many units were ordered from their primary_pincode and how many were ordered not from the primary_pincode. Also calulate the percentage of total units which were ordered from primary_pincode(remember to multiply the numerator by 100.0). Sort by the percentage column in descending order.
SELECT   c.cust_id,    
COUNT(o.order_id) as total_units_ordered,    
COUNT(CASE WHEN o.delivery_pincode = c.primary_pincode THEN 1 END) as primary_pincode_unit_orders,    
COUNT(CASE WHEN o.delivery_pincode != c.primary_pincode THEN 1 END) as non_primary_pincode_unit_orders,    
(100.0 * COUNT(CASE WHEN o.delivery_pincode = c.primary_pincode THEN 1 END)) / COUNT(o.order_id) as primary_pincode_unit_orders_percentage
FROM Customers c
LEFT JOIN Orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id
ORDER BY primary_pincode_unit_orders_percentage DESC; 


#14. For each product name, print the sum of number of units, total amount paid, total displayed selling price, total mrp of these units, and finally the net discount from selling price.(i.e. 100.0 - 100.0 * total amount paid / total displayed selling price) & the net discount from mrp (i.e. 100.0 - 100.0 * total amount paid / total mrp).
SELECT   p.product_name,    
SUM(o.tot_units) as total_units,    
SUM(o.total_amount_paid) as total_amount_paid,    
SUM(o.displayed_selling_price_per_unit) as total_displayed_selling_price,    
SUM(p.mrp) as total_mrp,    
100.0 - 100.0 * (SUM(o.total_amount_paid) / SUM(o.displayed_selling_price_per_unit)) 
as selling_price_net_discount,    
100.0 - 100.0 * (SUM(o.total_amount_paid) / SUM(p.mrp)) as mrp_net_discount
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name;

#15. For every order_id (exclude returns), get the product name and calculate the discount percentage from selling price. Sort by highest discount and print only those rows where discount percentage was above 10.10%.
SELECT o.order_id, p.product_name,    
(100.0 - 100.0 * (o.total_amount_paid / o.displayed_selling_price_per_unit)) as discount_percentage
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
WHERE o.order_type = 'buy' -- Exclude returns
HAVING discount_percentage > 10.10
ORDER BY discount_percentage DESC;


# 16. Using the per unit procurement cost in product_dim, find which product category has made the  most  profit in both absolute amount and percentage Absolute Profit     =     Total Amt Sold - Total Procurement Cost Percentage Profit = 100.0 * Total Amt Sold / Total Procurement Cost - 100.0.
SELECT p.category,    
SUM(o.total_amount_paid - p.procurement_cost_per_unit * o.tot_units) as absolute_profit,    
100.0 * SUM(o.total_amount_paid) / SUM(p.procurement_cost_per_unit * o.tot_units) - 100.0 as percentage_profit
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY absolute_profit DESC, percentage_profit DESC
LIMIT 1;


#17. For every delivery person(use their name), print the total number of order ids (exclude returns) by month in separate columns i.e. there should be one row for each delivery_person_id and 12 columns for every month in the year.
SELECT dp.name,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 1 THEN o.order_id END) as Jan,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 2 THEN o.order_id END) as Feb,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 3 THEN o.order_id END) as Mar,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 4 THEN o.order_id END) as Apr,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 5 THEN o.order_id END) as May,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 6 THEN o.order_id END) as Jun,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 7 THEN o.order_id END) as Jul,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 8 THEN o.order_id END) as Aug,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 9 THEN o.order_id END) as Sep,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 10 THEN o.order_id END) as Oct,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 11 THEN o.order_id END) as Nov,
COUNT(CASE WHEN (MONTH(STR_TO_DATE(o.order_date, '%d-%m-%Y'))) = 12 THEN o.order_id END) as 'Dec'
FROM Delivery_Person dp
LEFT JOIN Orders o ON dp.delivery_person_id = o.delivery_person_id AND o.order_type = 'buy'
GROUP BY dp.name;

#18. For each gender - male and female - find the absolute and percentage profit (like in Q15) by product name.
SELECT c.gender, p.product_name,     
SUM(o.total_amount_paid - p.procurement_cost_per_unit * o.tot_units) as absolute_profit,    
100.0 - 100.0 * SUM(o.total_amount_paid) / SUM(o.displayed_selling_price_per_unit) as discount_from_selling_price,    100.0 - 100.0 * SUM(o.total_amount_paid) / SUM(p.mrp) as discount_from_mrp
FROM Customers c
JOIN Orders o ON c.cust_id = o.cust_id
JOIN Products p ON o.product_id = p.product_id
GROUP BY c.gender, p.product_name;

#19. Generally the more numbers of units you buy, the more discount seller will give you. For 'Dell AX420' is there a relationship between number of units ordered and average discount from selling price? Take only 'buy' order types.
SELECT o.tot_units,   
 AVG(100.0 - 100.0 * (o.total_amount_paid / o.displayed_selling_price_per_unit)) as average_discount
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
WHERE p.product_name = 'Dell AX420' AND o.order_type = 'buy'
GROUP BY o.tot_units;

