---1 Tulis query untuk mendapatkan jumlah customer tiap bulan yang melakukan order pada tahun 1997.

SELECT MONTH(OrderDate) AS bulan,
		COUNT( DISTINCT CustomerID) AS total_customer
FROM Northwind.dbo.Orders
WHERE year(OrderDate) = 1997
GROUP BY MONTH(OrderDate) ;

---2 Tulis query untuk mendapatkan nama employee yang termasuk Sales Representative.
SELECT FirstName,LastName 
FROM Northwind.dbo.Employees 
WHERE Title='Sales Representative'

---3 Tulis query untuk mendapatkan top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997.
SELECT top(5) Quantity,ProductName,OrderDate
FROM Northwind.DBO.[Order Details] a
inner join Northwind.dbo.Products b on a.ProductID=b.ProductID
inner join Orders c on a.OrderID=c.OrderID
WHERE year(OrderDate)=1997 and month(OrderDate)=01
ORDER BY Quantity desc

---4 Tulis query untuk mendapatkan nama company yang melakukan order Chai pada bulan Juni 1997.
SELECT ProductName,CompanyName, OrderDate
FROM Northwind.DBO.[Order Details] a
inner join Northwind.dbo.Products b on a.ProductID=b.ProductID
inner join Orders c on a.OrderID=c.OrderID
inner join Customers d on c.CustomerID =d.CustomerID
WHERE year(OrderDate)=1997 and month(OrderDate)=06 and ProductName='Chai'

---5 Tulis query untuk mendapatkan jumlah OrderID yang pernah melakukan pembelian (unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
WITH TOTAL_PRICE AS (SELECT ORDERID,UnitPrice*Quantity AS Total_Price
FROM [Order Details]),
category_price as(select *, 
case when Total_Price <=100 then '<=100' 
when Total_Price >100 and Total_Price <= 250 then '100<x<=250' 
when Total_Price >250 and Total_Price <= 500 then '250<x<=500' 
else '>500' end as category
from TOTAL_PRICE)

select count(distinct OrderID) as total_orderID, category from category_price group by category

---6 Tulis query untuk mendapatkan Company name pada tabel customer yang melakukan pembelian di atas 500 pada tahun 1997.
SELECT sum(Quantity) as TotalQuantity,CompanyName
FROM Northwind.DBO.[Order Details] a
inner join Northwind.dbo.Products b on a.ProductID=b.ProductID
inner join Orders c on a.OrderID=c.OrderID
inner join Customers d on c.CustomerID =d.CustomerID
WHERE year(OrderDate)=1997 
group by CompanyName
having sum(Quantity)>500


---7 Tulis query untuk mendapatkan nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997.
with penjualan as (SELECT count(distinct c.OrderID) as sales,ProductName,month(OrderDate) as Bulan
FROM Northwind.DBO.[Order Details] a
inner join Northwind.dbo.Products b on a.ProductID=b.ProductID
inner join Orders c on a.OrderID=c.OrderID
inner join Customers d on c.CustomerID =d.CustomerID
where year(OrderDate)=1997
group by ProductName,month(OrderDate))

SELECT * 
FROM
(SELECT sales,ProductName, ROW_NUMBER() OVER(PARTITION BY Bulan ORDER BY sales desc) AS Ranking,Bulan
FROM penjualan
)as a
where Ranking in (1,2,3,4,5)
order by Bulan, Ranking

---8 Buatlah view untuk melihat Order Details yang berisi OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, Harga setelah diskon.
create view order_details
as
SELECT OrderId,b.ProductID, ProductName,a.UnitPrice,Quantity,a.Discount, (a.UnitPrice*(1-Discount)) as Price_AfterDiskon
FROM Northwind.DBO.[Order Details] a
inner join Northwind.dbo.Products b on a.ProductID=b.ProductID

select * from order_details
---9 Buatlah procedure Invoice untuk memanggil CustomerID, CustomerName/company name, OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu.


CREATE PROC Invoice_CustomerId @CustomerID Varchar(50)
AS
SELECT a.CustomerID,a.CompanyName, b.OrderID,b.OrderDate,b.RequiredDate,b.ShippedDate
    FROM Customers a
	inner join Orders b on a.CustomerID=b.CustomerID
    WHERE a.CustomerID = @CustomerID

EXECUTE Invoice_CustomerID SUPRD 
