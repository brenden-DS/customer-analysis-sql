CREATE TABLE goldusers_signup
(userid int,
signup_date date); 

INSERT INTO goldusers_signup (userid,signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users
(userid int,
signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales
(userid int,
created_date date,
product_id int); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-12-17',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product
(product_id int,
product_name text,
price int); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1. What is the total amount each customer spent on click n pay?
SELECT s.userid,  
       sum(price) AS total_spent
FROM product AS p 
JOIN sales AS s 
ON p.product_id = s.product_id
GROUP BY 1;

-- 2. How many days has each customer visited click n pay?
SELECT userid, 
       count(created_date) AS total_days_visited
FROM sales
GROUP BY 1;

-- 3. What was the first product purchased by each customer?
SELECT userid, 
	   first_prod_purchased
FROM   (SELECT s.userid, 
	           p.product_name AS first_prod_purchased,
               ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date ) AS rnk
       FROM product AS p 
       JOIN sales AS s 
	   USING(product_id)) AS M
WHERE rnk = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT s.userid,
       most.product_id,
	   count(most.tot_purchases) AS tot_customer_purchases
FROM sales AS  s 
JOIN (SELECT product_id, 
      count(product_id) AS tot_purchases
      FROM sales
      GROUP BY product_id
      ORDER BY tot_purchases DESC
      LIMIT 1) AS most
USING (product_id)
GROUP BY 1,2
ORDER BY userid;

-- 5. Which item was the most popular for each customer?

SELECT userid,
       product_id,
	   item_popularity
FROM (SELECT userid,
	        product_id,
	       count(product_id) AS item_popularity,
	        ROW_NUMBER() OVER(PARTITiON BY  userid ORDER BY count(product_id) DESC) AS rnk
	  FROM sales
	  GROUP BY 1,2) AS pop
WHERE rnk = 1;

-- 6. Which items were purchased first by the customer after they become a gold member?
SELECT  userid,
        product_id,
        signup_date,
        created_date
FROM (SELECT g.userid,
	         s.product_id,
	         signup_date,
	         created_date,
	         ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date) AS rnk
      FROM sales AS s
      JOIN goldusers_signup AS g 
      USING (userid)
	  WHERE created_date >= signup_date) AS mos
WHERE rnk = 1;

-- 7. Which items were purchased before the customer became a gold member?
SELECT  userid,
        product_id,
        signup_date,
        created_date
FROM    (SELECT g.userid,
                s.product_id,
                signup_date,
                created_date,
                ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date ) AS rnk
        FROM sales AS s
        JOIN goldusers_signup AS g 
		USING (userid)
        WHERE created_date < signup_date) AS mos
WHERE rnk = 1;

-- 8. What is the total orders and total amount spent for each member before they become a member?
SELECT s.userid,
	   sum(p.price) AS tot_amount_spent, 
       count(p.product_id) AS tot_orders
FROM sales AS s 
JOIN goldusers_signup AS g
USING (userid)
JOIN product AS p 
using (product_id)
WHERE s.created_date < g.signup_date
GROUP BY 1;






