--Create Tables
DROP TABLE IF EXISTS books;
CREATE TABLE books(
	book_id SERIAL PRIMARY KEY,
	title VARCHAR(100),
	author VARCHAR(100),
	genre VARCHAR(50),
	published_year INT,
	price NUMERIC(10,2),
	stock INT
);

DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
	customer_id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	email VARCHAR(100),
	phone VARCHAR(15),
	city VARCHAR(50),
	country VARCHAR(150)
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
	order_id SERIAL PRIMARY KEY,
	customer_id INT REFERENCES customers(customer_id),
	book_id INT REFERENCES books(book_id),
	order_date DATE,
	quantity INT,
	total_amount NUMERIC(10,2)
);

SELECT * FROM books;
SELECT * FROM customers;
SELECT * FROM orders;

--Import Data into books Table
COPY books(book_id,title,author,genre,published_year,price,stock)
FROM 'C:\Users\Dell\Documents\sql\ST - SQL ALL PRACTICE FILES\All Excel Practice Files\Books.csv'
CSV HEADER;

--Import Data into customers Table
COPY customers(customer_id,name,email,phone,city,country)
FROM 'C:\Users\Dell\Documents\sql\ST - SQL ALL PRACTICE FILES\All Excel Practice Files\Customers.csv'
CSV HEADER;

--Import Data into orders Table
COPY orders(order_id,customer_id,book_id,order_date,quantity,total_amount)
FROM 'C:\Users\Dell\Documents\sql\ST - SQL ALL PRACTICE FILES\All Excel Practice Files\Orders.csv'
CSV HEADER;


--Basic Questions
--Q1.Retrieve all books in the "Fiction" genre?
SELECT title,genre FROM books
WHERE genre='Fiction';

--Q2.Find books publishes after the year 1950?
SELECT title,published_year FROM books
WHERE published_year>1950;

--Q3.List all customers from the Canada?
SELECT name,country FROM customers
WHERE country='Canada';

--Q4.Show orders placed in November 2023?
SELECT * FROM orders
WHERE order_date BETWEEN '2023-11-01' AND '2023-11-30';

--Q5.Retrieve the total stock of books available?
SELECT SUM(stock) AS "Total_Books" FROM books;

--Q6.Find the details of the most expensive book?
SELECT MAX(price) AS "Most_Expensive_Book" FROM books;
--alternative solution
SELECT title,price FROM books ORDER BY price DESC
LIMIT 1;

--Q7.Show all customers who ordered more than 1 quantity of a book?
SELECT customer_id,quantity FROM orders
WHERE quantity>1;

--Q8.Retrieve all orders where the total amount exceeds $20?
SELECT * FROM orders
WHERE total_amount>20;

--Q9.List all genres available in the Books table?
SELECT DISTINCT(genre) FROM books; 

--Q10.Find the book with the lowest stock?
SELECT MIN(stock) AS "Book_with_Minimum_Stock" FROM books;
--alternate solution
SELECT title,stock FROM books ORDER BY stock
LIMIT 1;

--Q11.Calculate the total revenue generated from all orders?
SELECT SUM(total_amount) AS "Total Revenue" FROM orders;

--Advance Questions
--Q1.Retrieve the total number of books sold for each genre?
SELECT b.genre,SUM(o.quantity) AS "Total_Quantity_Sold" 
FROM
books b
JOIN
orders o
ON
o.book_id=b.book_id
GROUP BY b.genre;

--Q2.Find the average price of books in the "Fantasy" genre?
SELECT genre,AVG(price) AS "Average Price" FROM books
WHERE genre='Fantasy'
GROUP BY genre;

--Q3.List customers who have placed at least 2 orders?
SELECT customer_id,COUNT(order_id) AS "Order Count" FROM orders
GROUP BY customer_id
HAVING COUNT(order_id)>=2;
--alternative solution if we want to fetch customer name also
SELECT o.customer_id,c.name,COUNT(o.order_id) AS "Order Count"
FROM
customers c
JOIN
orders o
ON
c.customer_id=o.customer_id
GROUP BY o.customer_id,c.name
HAVING COUNT(o.order_id)>=2;

--Q4.Find the most frequently ordered book?
SELECT book_id,COUNT(order_id) AS "Order Count" FROM orders
GROUP BY book_id
ORDER BY "Order Count" DESC
LIMIT 1;
--alternative solution to fetch the book name
SELECT o.book_id,b.title,COUNT(o.order_id) AS "Order Count"
FROM
orders o
JOIN 
books b
ON
o.book_id=b.book_id
GROUP BY o.book_id,b.title
ORDER BY "Order Count" DESC
LIMIT 1;

--Q5.Show the top 3 most expensive books of 'Fantasy' Genre?
SELECT book_id,title,price FROM books
WHERE genre='Fantasy'
ORDER BY price DESC
LIMIT 3;

--Q6.Retrieve the total quantity of books sold by each author?
SELECT b.author,SUM(o.quantity) AS "Total Sold"
FROM 
books b
LEFT JOIN
orders o
ON
b.book_id=o.book_id
GROUP BY b.author;

--Q7.List the cities where customers who spent over $30 are located?
SELECT c.city,o.total_amount
FROM
customers c
JOIN
orders o
ON
c.customer_id=o.customer_id
WHERE o.total_amount>30
GROUP BY c.city,o.total_amount;

--alternative and best solution
SELECT DISTINCT c.city
FROM 
customers c
JOIN 
orders o
ON 
c.customer_id = o.customer_id
GROUP BY c.customer_id,c.city
HAVING SUM(o.total_amount) > 30;

--Q8.Find the customer who spent the most on orders?
SELECT o.customer_id,c.name,SUM(o.total_amount) AS "Total Spent"
FROM 
orders o
JOIN
customers c
ON
o.customer_id=c.customer_id
GROUP BY o.customer_id,c.name
ORDER BY "Total Spent" DESC
LIMIT 1;

--Q9.Calculate the stock remaining after fulfilling all orders?
SELECT b.book_id,b.stock,
COALESCE(o.total_ordered,0) AS "Total Ordered",
b.stock-COALESCE(o.total_ordered,0) AS "Remaining Stock"
FROM
books b
LEFT JOIN
(SELECT book_id,SUM(quantity) AS total_ordered FROM orders
GROUP BY book_id) o
ON
b.book_id=o.book_id;
--alternative solution
SELECT b.book_id,b.title,b.stock,COALESCE(SUM(o.quantity),0) AS order_quantity,
b.stock-COALESCE(SUM(o.quantity),0) AS remaining_quantity
FROM 
books b
LEFT  JOIN 
orders o 
ON 
b.book_id=o.book_id
GROUP BY b.book_id ORDER BY b.book_id;
