use classicmodels

show tables

select * from offices

-- Single entity --
-- Q1 Prepare a list of offices sorted by country, state, city.--

select country, state, city from offices
order by officecode asc

-- Q2 How many employees are there in the company? 

select count(*) from employees

-- Q3 What is the total of payments received? 

select * from payments
select round(sum(amount), 0) from payments

-- Q4 List the product lines that contain 'Cars'. 

select * from products
select distinct productLine from products

select * from products
where productLine in ('Classic Cars', 'Vintage Cars')

-- Q5 Report total payments for October 28, 2004.

select round(sum(amount),0) from payments
where paymentDate = '2004-10-28'

-- Q6 Report those payments greater than $100,000.

select * from payments
where amount > '100000'

-- Q7 List the products in each product line.

select * from productlines l
inner join products p on
l.productline = p.productline

-- Q8 How many products in each product line?

select count(productname) products, productline from products
group by productline

-- Q9 What is the minimum payment received?

select min(amount) min_payment from payments 

-- Q10 List all payments greater than twice the average payment.

select * from payments
where amount > (select avg(amount *2) avg_amount from payments)

-- Q11 What is the average percentage markup of the MSRP on buyPrice?

select MSRP, buyprice, round(((MSRP - buyprice)/buyprice)*100, 2) Markup_percent 
from products
group by 1,2

-- Q12 How many distinct products does ClassicModels sell?

select count(distinct productcode) dis_product, productname 
from products
group by 2

-- Q13 Report the name and city of customers who don't have sales representatives?

select* from customers
select customername, city, salesrepemployeenumber from customers
where salesrepemployeenumber is null

-- Q14 What are the names of executives with VP or Manager in their title? 
-- Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.

select * from employees

select concat(firstname,' ',lastname) fullname, jobtitle
from employees
where jobtitle like '%VP%' or jobtitle like '%Manager%'

-- Q15 Which orders have a value greater than $5,000?

select*from orders
select*from orderdetails

select ordernumber, sum(quantityordered*priceeach) totalvalue 
from orderdetails
group by 1
having totalvalue > 5000

-- One to many relationship 
-- Q1 Report the account representative for each customer.

select * from customers
select * from employees

select c.customername, concat(e.firstname,' ',e.lastname) account_representative
from customers c
join employees e on c.salesrepemployeenumber = e.employeenumber 

-- Q2 Report total payments for Atelier graphique.

select * from payments
select * from customers

select c.customername, sum(p.amount)
from customers c 
join payments p on c.customernumber = p.customernumber 
where customername = 'Atelier graphique'

-- Q3 Report the total payments by date.

select * from orders
select * from payments

select paymentdate, sum(amount) total_amount from payments
group by 1 

-- Q4 Report the products that have not been sold.

select * from products
select * from orderdetails

SELECT *
FROM Products
WHERE productCode NOT IN (
  SELECT productCode
  FROM OrderDetails
);

-- Q5 List the amount paid by each customer.

select * from customers
select * from payments

select c.customernumber, c.customername, sum(p.amount) amount_paid
from customers c 
join payments p on c.customernumber = p.customernumber
jOIN Orders o ON p.customerNumber = o.customerNumber 
group by 1
 
-- Q6 How many orders have been placed by Herkku Gifts?

select * from customers
select * from orders

SELECT c.customerName, COUNT(DISTINCT o.orderNumber) AS totalOrders
FROM Customers c
JOIN Orders o ON c.customerNumber = o.customerNumber
WHERE c.customerName = 'Herkku Gifts';

-- or --
 
SELECT COUNT(*) AS numOrders
FROM Orders
WHERE customerNumber = (
  SELECT customerNumber
  FROM Customers
  WHERE customerName = 'Herkku Gifts'
)

-- Q7 Who are the employees in Boston?

select * from employees
select * from offices

select concat(e.firstname,' ',e.lastname) fullname, o.city
from employees e 
join offices o on e.officecode = o.officecode
where o.city = 'Boston'

-- Q8 Report those payments greater than $100,000. Sort the report 
--    so the customer who made the highest payment appears first.

select * from customers
select * from payments

select c.customernumber, c.customername, sum(p.amount) total_amount
from customers c
join payments p on c.customernumber = p.customernumber
group by 1
having total_amount > 100000
order by total_amount desc

-- Q9 List the value of 'On Hold' orders.

select * from orders
select * from orderdetails 

SELECT SUM(od.quantityOrdered * od.priceEach) AS TotalValue
FROM Orders o
JOIN OrderDetails od ON o.orderNumber = od.orderNumber
WHERE o.status = 'On Hold';

-- Q10 Report the number of orders 'On Hold' for each customer.

select * from customers
select * from orders

select c.customernumber, c.customername, o.status, count(o.ordernumber)
from customers c 
join orders o on c.customernumber = o.customernumber
where o.status = 'On Hold'
group by 1

or 

select count(*) total_order from orders
where status = 'on hold'

-- Many to many relationship 
-- Q1 List products sold by order date.

select * from products
select * from orders
select * from orderdetails

select distinct p.productcode, p.productname, o.orderdate
from products p 
join orderdetails od on p.productcode = od.productcode
join orders o on od.ordernumber = o.ordernumber
order by 3

-- Q2 List the order dates in descending order for orders for the 1940 Ford Pickup Truck.

select distinct p.productcode, p.productname, o.orderdate
from products p 
join orderdetails od on p.productcode = od.productcode
join orders o on od.ordernumber = o.ordernumber
where p.productname = '1940 Ford Pickup Truck'
order by 3 desc

-- Q3 List the names of customers and their corresponding order number where a particular 
--    order from that customer has a value greater than $25,000?

select * from customers
select * from orders
select * from orderdetails

select c.customername, od.ordernumber, sum(od.quantityordered*od.priceeach) total_value
from customers c
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
group by 1,2
having total_value > 25000

-- Q4 Are there any products that appear on all orders?

select * from products
select * from orderdetails

SELECT p.productname
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE NOT EXISTS (
        SELECT 1
        FROM orderdetails od
        WHERE od.productcode = p.productcode
        AND od.ordernumber = o.ordernumber
    )
)

-- Q5 List the names of products sold at less than 80% of the MSRP.

select * from products
select * from orderdetails

select p.productname from products p
join orderdetails od on p.productcode = od.productcode
where od.priceeach < 0.80 * p.MSRP

-- Q6 Reports those products that have been sold with a markup of 100% or more 
--    (i.e.,  the priceEach is at least twice the buyPrice)

select * from products
select * from orderdetails

select p.productcode, p.productname, p.buyprice, od.priceeach from products p
join orderdetails od on p.productcode = od.productcode
where od.priceeach >= 2*p.buyprice

-- Q7 List the products ordered on a Monday.

select * from products
select * from orders

select p.productname from products p 
join orderdetails od on p.productcode = od.productcode
join orders o on od.ordernumber = o.ordernumber
where dayofweek(o.orderdate) = 2

-- Q8 What is the quantity on hand for products listed on 'On Hold' orders?

Select * from products
select * from orders
select * from orderdetails

select p.productname, od.quantityordered, o.status from products p
join orderdetails od on p.productcode = od.productcode
join orders o on od.ordernumber = o.ordernumber
where o.status = 'On Hold'

-- Regular Expressions
-- Q1 Find products containing the name 'Ford'.

select productname from products
where productname like '%Ford%'

-- Q2 List products ending in 'ship'.

select productname from products
where productname like '%ship'

-- Q3 Report the number of customers in Denmark, Norway, and Sweden.

select * from customers

select country, count(customername) total_customer from customers
where country in ('Denmark', 'Norway', 'Sweden')
group by 1

-- Q4 What are the products with a product code in the range S700_1000 to S700_1499?

select * from products
where productcode between 'S700_1000' and 'S700_1499'

-- Q5 Which customers have a digit in their name?

select * from customers

select customername from customers
where customername REGEXP '[0-9]'

-- Q6 List the names of employees called Dianne or Diane.

select * from employees

select firstname, lastname from employees
where firstname = 'Dianne' or firstname = 'Diane'

or 

SELECT firstname,lastname FROM employees
WHERE firstname IN ('Dianne', 'Diane');


-- Q7 List the products containing ship or boat in their product name.

Select * from products
where productname like '%ship%' or productname like '%boat%'

-- Q8 List the products with a product code beginning with S700.

Select * from products
where productcode like 'S700%'

-- Q9 List the names of employees called Larry or Barry.

SELECT firstname,lastname FROM employees
WHERE firstname IN ('larry', 'barry')

-- Q10 List the names of employees with non-alphabetic characters in their names.

SELECT Firstname, Lastname FROM employees
WHERE firstname REGEXP '[^a-zA-Z]' OR lastname REGEXP '[^a-zA-Z]'

-- Q11 List the vendors whose name ends in Diecast

select * from products

select productvendor from products
where productvendor like '%Diecast'

-- Correlated Queries
-- Q1 Who reports to Mary Patterson?

select * from employees

select * from employees
where reportsto = (select employeenumber from employees
					where firstname = 'Mary' and lastname = 'Patterson')
                    
-- Q2 Which payments in any month and year are more than twice the average for that month and year 
--   (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)? Order the results by the 
--    date of the payment. You will need to use the date functions.

select * from payments

select p.paymentdate, p.amount from payments p
join ( select month(paymentdate) month,
			  year(paymentdate) year,
              avg(amount) avg_amount
	   from payments
       group by 1,2) subq
on month(p.paymentdate) = subq.month
and year(p.paymentdate) = subq.year
where p.amount > 2*subq.avg_amount
order by 1

-- Q3 Report for each product, the percentage value of its stock on hand as a percentage of the stock on 
--    hand for product line to which it belongs. Order the report by product line and percentage value 
--    within product line descending. Show percentages with two decimal places.

Select * from products

select p.productcode, p.productname, p.productline, 
	   round(Sum(p.quantityinstock) / (select sum(p1.quantityinstock)
								  from products p1
                                  where p1.productline = p.productline) * 100, 2) stock_percentage
from products p
join products p1 on p.productcode = p1.productcode
group by 1,2,3
order by 3,4 desc

-- Q4 For orders containing more than two products, report those products that constitute more than 50% 
--    of the value of the order.

select * from products
select * from orders
select * from orderdetails

select od.ordernumber, p.productname, sum(od.quantityordered * od.priceeach) value
from orderdetails od
inner join products p on od.productcode = p.productcode
inner join (select ordernumber, sum(quantityordered * priceeach) as totalvalue
			from orderdetails
            group by 1
            having count(*) > 2) as o on od.ordernumber = o.ordernumber
group by 1,2
having value > 0.5 * (select sum(quantityordered * priceeach)
					  from orderdetails 
                      where ordernumber = od.ordernumber)































































