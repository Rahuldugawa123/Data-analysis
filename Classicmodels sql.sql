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
















































