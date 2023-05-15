Use classicmodels

-- General queries 
-- Q1 Who is at the top of the organization (i.e.,  reports to no one).

select * from employees
where reportsto is null

-- Q2 Who reports to William Patterson?

select * from employees
where reportsto = ( select employeenumber from employees
                    where firstname = 'william' and lastname = 'patterson')
                    
or 

SELECT e1.* FROM employees e1
JOIN employees e2
ON e1.reportsTo = e2.employeeNumber
WHERE e2.firstname = 'William' AND e2.lastname = 'Patterson';

-- Q3 List all the products purchased by Herkku Gifts.

select * from products
select * from customers

select p.productname from products p
join orderdetails od on p.productcode = od.productcode
join orders o on od.ordernumber = o.ordernumber
join customers c on o.customernumber = c.customernumber
where c.customername = 'Herkku Gifts'

-- Q4 Compute the commission for each sales representative, assuming the commission 
--    is 5% of the value of an order. Sort by employee last name and first name.

select * from employees
select * from customers
select * from orders
select * from orderdetails

select e.firstname, e.lastname, sum(od.priceeach*0.05) comission
from employees e 
join customers c on e.employeenumber = c.salesrepemployeenumber
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
group by e.employeenumber
order by 1,2

-- Q5 What is the difference in days between the most recent and oldest order date in the 
--    Orders file?

select * from orders

select orderdate, shippeddate, datediff(shippeddate , orderdate) diff
from orders

-- Q6 Compute the average time between order date and ship date for each customer ordered 
--    by the largest difference.

select * from customers
select * from orders

select c.customernumber, o.shippeddate, o.orderdate, avg(datediff(shippeddate,orderdate)) avg_time 
from orders o
join customers c on o.customernumber = c.customernumber
group by 1,2,3
order by 4 desc

-- Q7 What is the value of orders shipped in August 2004?

select * from orders
select * from orderdetails

SELECT SUM(od.quantityOrdered * od.priceEach) AS total_value
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE o.shippedDate BETWEEN '2004-08-01' AND '2004-08-31';

-- this query is for number of order by dates on augest 2004.

select o.shippeddate, count(od.productcode) tol_values 
from orders o
join orderdetails od on o.ordernumber = od.ordernumber
where shippeddate like '%2004-08%'
group by 1


-- Q8 Compute the total value ordered, total amount paid, and their difference for each
--    customer for orders placed in 2004 and payments received in 2004 (Hint; Create views 
--    for the total paid and total ordered).

select * from orders
select * from payments
select * from customers
select * from orderdetails

CREATE VIEW total_ordered AS
  SELECT c.customerNumber, SUM(od.quantityOrdered * od.priceEach) AS total_ordered
  FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  WHERE YEAR(o.orderDate) = 2004
  GROUP BY c.customerNumber;

CREATE VIEW total_paid AS
  SELECT c.customerNumber, SUM(p.amount) AS total_paid
  FROM customers c
  JOIN payments p ON c.customerNumber = p.customerNumber
  WHERE YEAR(p.paymentDate) = 2004
  GROUP BY c.customerNumber;

SELECT c.customerName,
       COALESCE(t0.total_ordered, 0) AS total_ordered,
       COALESCE(tp.total_paid, 0) AS total_paid,
       COALESCE(tp.total_paid, 0) - COALESCE(t0.total_ordered, 0) AS difference
FROM customers c
LEFT JOIN total_ordered t0 ON c.customerNumber = t0.customerNumber
LEFT JOIN total_paid tp ON c.customerNumber = tp.customerNumber;

-- or using CTE

WITH total_ordered AS (
  SELECT c.customerNumber, SUM(od.quantityOrdered * od.priceEach) AS total_ordered
  FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  WHERE YEAR(o.orderDate) = 2004
  GROUP BY c.customerNumber
),
total_paid AS (
  SELECT c.customerNumber, SUM(p.amount) AS total_paid
  FROM customers c
  JOIN payments p ON c.customerNumber = p.customerNumber
  WHERE YEAR(p.paymentDate) = 2004
  GROUP BY c.customerNumber
)
SELECT c.customerName,
       COALESCE(t0.total_ordered, 0) AS total_ordered,
       COALESCE(tp.total_paid, 0) AS total_paid,
       COALESCE(tp.total_paid, 0) - COALESCE(t0.total_ordered, 0) AS difference
FROM customers c
LEFT JOIN total_ordered t0 ON c.customerNumber = t0.customerNumber
LEFT JOIN total_paid tp ON c.customerNumber = tp.customerNumber;

-- Q9 List the employees who report to those employees who report to Diane Murphy. Use the CONCAT 
--    function to combine the employee's first name and last name into a single field for reporting.

select * from employees

select concat(firstname,' ', lastname) fullname from employees
where reportsto in ( select employeenumber from employees
                    where reportsto in (select employeenumber from employees
									   where firstname = 'Diane' and lastname = 'Murphy')
				   ) 
                   
-- Q10 What is the percentage value of each product in inventory sorted by the highest percentage first 
--    (Hint: Create a view first).

select * from products

create view product_percents
as
select productcode, buyprice, MSRP, round(((buyprice/MSRP)*100),2) percentage_per_product 
from products
group by 1,2,3
order by 4 desc

select * from product_percents

-- Q11 Write a function to convert miles per gallon to liters per 100 kilometers.

Delimiter //

CREATE FUNCTION mpg_to_lp100k(mpg FLOAT)
RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    -- Conversion constants
    DECLARE km_per_mile FLOAT;
    DECLARE liters_per_gallon FLOAT;
    DECLARE km_per_liter FLOAT;
    DECLARE lp100k FLOAT;

    SET km_per_mile = 1.60934;
    SET liters_per_gallon = 3.78541;

    -- Convert mpg to km/L
    SET km_per_liter = (mpg * km_per_mile) / liters_per_gallon;

    -- Convert km/L to L/100km
    SET lp100k = 100 / km_per_liter;

    RETURN lp100k;
END //

delimiter ;

SELECT mpg_to_lp100k(30);

-- Q12 Write a procedure to increase the price of a specified product category by a given percentage. 
--     You will need to create a product table with appropriate data to test your procedure. Alternatively, 
--     load the ClassicModels database on your personal machine so you have complete access. 
--     You have to change the DELIMITER prior to creating the procedure.

select * from products

DELIMITER //

CREATE PROCEDURE increase_price_by_category(IN category_name VARCHAR(255), IN percentage FLOAT)
BEGIN
    UPDATE products
    SET MSRP = MSRP + (MSRP * percentage / 100)
    WHERE productname = category_name;
END//

DELIMITER ;

call increase_price_by_category('1969 Harley Davidson Ultimate Chopper', 10);

-- Q13 What is the value of payments received in July 2004?

select sum(amount) total_value from payments
where paymentdate between '2004-07-01' and '2004-07-30'

-- Q14 What is the ratio of the value of payments made to orders received for each month of 2004? 
--     (i.e., divide the value of payments made by the orders received)?

select * from payments

SELECT
    DATE_FORMAT(paymentdate, '%Y-%m') AS month,
    SUM(amount) / COUNT(DISTINCT orderNumber) AS ratio
FROM payments
JOIN orders ON payments.customerNumber = orders.customerNumber
WHERE YEAR(paymentdate) = 2004
GROUP BY month;

-- Q15 What is the difference in the amount received for each month of 2004 compared to 2003?

Select * from payments

WITH monthly_payments AS (
    SELECT YEAR(paymentDate) AS year,
		   MONTH(paymentDate) AS month,
           SUM(amount) AS total_amount
    FROM payments
    WHERE YEAR(paymentDate) IN (2003 , 2004)
    GROUP BY YEAR(paymentDate) , MONTH(paymentDate)
)
SELECT p1.month,
	   p1.total_amount AS amount_2003,
       p2.total_amount AS amount_2004,
       p2.total_amount - p1.total_amount AS difference
FROM monthly_payments p1
JOIN monthly_payments p2 ON p1.month = p2.month
WHERE p1.year = 2003 AND p2.year = 2004;

-- Q16 Write a procedure to report the amount ordered in a specific month and year for 
--     customers containing a specified character string in their name.

select * from customers
select * from orders
select * from orderdetails

Delimiter //

create procedure reportamountorder(in s_month int, in s_year int, in s_name varchar(50))
begin
	select c.customername, sum(od.quantityordered * od.priceeach) total_amount
    from customers c
    join orders o on c.customernumber = o.customernumber
    join orderdetails od on o.ordernumber = od.ordernumber
    where month(o.orderdate) = s_month
          and year(o.orderdate) = s_year
          and c.customername like concat('%', s_name, '%')
    group by 1;
end //

delimiter ;
    
call reportamountorder (9, 2004, 'Atelier graphique')

-- Q17 Write a procedure to change the credit limit of all customers in a specified 
--     country by a specified percentage.

select * from customers

select country, sum(creditlimit) from customers
group by 1

drop procedure changecreditlimit

delimiter //

create procedure changecreditlimit (in s_country varchar (50), in s_percentage int)
begin
	update customers
    set creditlimit = creditlimit + (creditlimit * s_percentage/100)
    where country = s_country;
end // 

delimiter ; 

call changecreditlimit ('France', 90)  

select country, sum(creditlimit) from customers
group by 1

-- Q18 Basket of goods analysis: A common retail analytics task is to analyze each basket 
--     or order to learn what products are often purchased together. Report the names of 
--     products that appear in the same order ten or more times.

select * from products
select * from orderdetails

select p1.productname productname1, p2.productname productname2, count(*) same_time_order
from orderdetails od1
join products p1 on p1.productcode = od1.productcode
join orderdetails od2 on od1.ordernumber = od2.ordernumber
join products p2 on od2.productcode = p2.productcode
where p1.productname < p2.productname
group by 1,2
having same_time_order >= 10

-- Q19 ABC reporting: Compute the revenue generated by each customer based on their orders. 
--     Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.

select * from customers
select * from orderdetails

with total_revenue as (
select sum(od.quantityordered * od.priceeach) total
from orderdetails od 
)
select c.customername, sum(od.quantityordered * od.priceeach) revenue, 
sum(od.quantityordered*od.priceeach)/(select total from total_revenue) * 100 percentage
from customers c 
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
group by 1
order by 1

-- Q20 Compute the profit generated by each customer based on their orders. Also, show each customer's 
--     profit as a percentage of total profit. Sort by profit descending.

select * from customers
select * from orderdetails

with total_profit as (
	select sum((od.priceeach - p.buyprice) * od.quantityordered) total
    from orderdetails od
    join products p on od.productcode = p.productcode
),
customer_profit as (
	select c.customernumber, c.customername, sum((od.priceeach - p.buyprice) * od.quantityordered) profit
	from customers c
	join orders o on c.customernumber = o.customernumber
	join orderdetails od on o.ordernumber = od.ordernumber
	join products p on od.productcode = p.productcode
	group by 1,2
)
select cp.customername,
	   cp.profit,
       cp.profit/(select total from total_profit) * 100 percentage
from customer_profit cp 
order by 2 desc

-- Q21 Compute the revenue generated by each sales representative based on the orders from the customers 
--     they serve.

select * from customers
select * from orders
select * from orderdetails

select c.salesrepemployeenumber, sum(od.quantityordered*od.priceeach) revenue 
from customers c
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
group by 1

-- Q22 Compute the profit generated by each sales representative based on the orders from the customers 
--     they serve. Sort by profit generated descending.

select * from customers
select * from orderdetails

select c.salesrepemployeenumber, sum((od.priceeach - p.buyprice) * od.quantityordered) profit
from customers c
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
join products p on od.productcode = p.productcode
group by 1 
order by 2 desc

-- Q23 Compute the revenue generated by each product, sorted by product name.

select * from products
select * from orderdetails

select p.productcode, p.productname, sum(od.quantityordered * od.priceeach) revenue
from products p 
join orderdetails od on p.productcode = od.productcode
group by 1,2
order by 2

-- Q24 Compute the profit generated by each product line, sorted by profit descending.

select * from products
select * from orderdetails

select p.productline, sum((od.priceeach - p.buyprice) * od.quantityordered) profit
from products p
join orderdetails od on p.productcode = od.productcode
group by 1
order by 2 desc

-- Q25 Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.

select * from products
select * from orderdetails

WITH product_sales AS (
    SELECT YEAR(o.orderDate) AS year,
		   od.productcode,
           SUM(od.quantityordered * od.priceeach) AS total_sales
    FROM orderdetails od
    join orders o on od.ordernumber = o.ordernumber
    WHERE YEAR(orderDate) IN (2003 , 2004)
    GROUP BY 1, 2
)
SELECT p1.productcode,
	   p1.total_sales AS sales_2003,
       p2.total_sales AS sales_2004,
       (p1.total_sales) / (p2.total_sales) AS ratio
FROM product_sales p1
JOIN product_sales p2 ON p1.productcode = p2.productcode
WHERE p1.year = 2003 AND p2.year = 2004;

-- Q26 Compute the ratio of payments for each customer for 2003 versus 2004.

select * from customers
select * from payments

with total_amount as (
	select customernumber,
    year(paymentdate) year,
    sum(amount) total
    from payments 
    where year(paymentdate) in (2003, 2004)
    group by 1,2
)
select p1.customernumber,
	   p1.total as amount_2003,
       p2.total as amount_2004,
       (p1.total) / (p2.total) as ration
from total_amount p1 
join total_amount p2 on p1.customernumber = p2.customernumber
where p1.year = 2003 and p2.year = 2004

-- Q27 Find the products sold in 2003 but not 2004.

select * from products
select * from orders

select distinct p.productcode, p.productname, year(o.orderdate) year
from products p 
join orderdetails od on p.productcode = od.productcode
join orders o on od.ordernumber = o.ordernumber
where year(o.orderdate) = 2003
and not exists (select 1
				  from orderdetails od2
                  join orders o2 on od2.ordernumber = o2.ordernumber
                  where year(o2.orderdate) = 2004 
                  and od1.productcode = p.productcode);
                  
-- Q28 Find the customers without payments in 2003.

select * from payments
select * from customers

select distinct c.customernumber, c.customername
from customers c 
where c.customernumber not in  ( select 1 from payments p
		                        where not year(p.paymentdate) = 2003)
                  
                  



	   














  











