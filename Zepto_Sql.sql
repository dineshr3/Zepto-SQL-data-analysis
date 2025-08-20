DROP Table if exists zepto;

CREATE TABLE zepto(
Id serial PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent Numeric(5,2),
avaiableQuantity INTEGER,
DiscountedSellingPrice NUMERIC(8,2),
WeightInGms INTEGER,
OutofStock Boolean,
quantity INTEGER
);


SELECT * FROM ZEPTO;

--Data Exploration

--Count of Rows
select count(*) from zepto;

--Sample Data
Select * From Zepto limit 10;

--Null Values
select * from zepto where Name IS Null
or Category is NUll
or mrp is NUll
or discountpercent is NUll
or avaiablequantity is NUll
or discountedsellingprice is NUll
or weightingms is NUll
or outofstock is NUll
or quantity is NUll

--Different Product Categories
select distinct category from zepto order by category;

--Products in Stock vs Out Of Stock
Select outofstock, count(id) from zepto group by outofstock;

--Product Names Present Multiple Times 
Select name, count(id) as "Number of SKUs" 
from zepto
group by name
having count(id)>1
order by count(id) Desc;

--Data Cleaning

--Product With price<0
SELECT * From zepto where mrp=0 or Discountedsellingprice=0;

DELETE FROM zepto
where mrp = 0;

--Convert paise to rupees
Update zepto 
set mrp= mrp/100.0,
discountedsellingprice=discountedsellingprice/100.0;

SELECT mrp, discountedsellingprice from zepto;

-- Q1. Find the top IO best-value products based on the discount percentage.
SELECT Distinct name,mrp,discountpercent from zepto order by discountpercent desc limit 10;

--Q2.What are the Products with High MRP but Out of Stock
SELECT Distinct name,mrp 
from Zepto 
where outofstock =True and mrp >300
order by mrp DESC;

---Q3. Calculate Estimated Revenue for each category
SELECT category,sum(Discountedsellingprice*available_quantity) as Total_revenue
From Zepto
group by category
order by total_revenue desc;

--Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT Distinct name, mrp, discountpercent 
from zepto 
where mrp>500 and discountpercent <10
order by mrp desc,discountpercent desc;

--Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT Category, round(avg(discountpercent),2) As avg_discount
from zepto
group by category
order by avg_discount desc
limit 5;

--Q6. Find the price per gram for products above 100g and sort by best value.
SELECT Distinct name, weightInGms, DiscountedSellingprice, round(discountedsellingprice/weightInGms,2) As Price_per_gram
From zepto 
where weightIngms >=100
order by price_per_gram;

--Q7 .Group the products into categories like Low, Medium, Bulk.
SELECT DIstinct name, weightIngms, 
case 
	when weightIngms<1000 then 'Low'
	when weightIngms<5000 then 'Medium'
	ELse 'Bulk'
	End As Weight_Category
From zepto;

--Q8.What is the Total Inventory Weight Per Category
SELECT Category, sum(weightInGms*available_quantity) as total_weight
from zepto
group by category
order by total_weight;

--Q9. Find the top 3 most expensive products per category
SELECT Category, Name, mrp, rnk
FROM (
  SELECT Category, Name, mrp,
         RANK() OVER (PARTITION BY Category ORDER BY mrp DESC) AS rnk
  FROM zepto
  WHERE mrp IS NOT NULL
) t
WHERE rnk <= 3
ORDER BY Category, rnk, mrp DESC, Name;

--Q10. Find the running total of revenue for each category
SELECT Category, Name, quantity, 
       discountedsellingprice * quantity AS product_revenue,
       SUM(discountedsellingprice * quantity) 
           OVER (PARTITION BY Category ORDER BY Name) AS running_revenue
FROM zepto;

--Q11. Find the average discount per category and also show it beside each product.
SELECT Name, Category, discountpercent,round(AVG(discountpercent) OVER (PARTITION BY Category),2) AS avg_category_discount
FROM zepto;

--Q12. Show each product’s percentage contribution to category revenue.
SELECT Category, Name,
discountedsellingprice * quantity AS product_revenue,
ROUND(100.0 * ( discountedsellingprice * quantity ) /
 SUM(discountedsellingprice * quantity) OVER (PARTITION BY Category), 2
) AS pct_of_category_revenue
FROM zepto;
