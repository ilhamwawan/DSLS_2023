with shipping_customer as (
select a.CustomerID,b.CompanyName as ShipperName, ContactTitle as CustomerTitle, City,d.Quantity
from Orders a
left join Shippers b on ShipVia=ShipperID
left join Customers c on  a.CustomerID=c.CustomerID
left join Northwind.dbo.[Order Details] d on a.OrderID=d.OrderID )

select CustomerID, ShipperName, CustomerTitle, City, sum(Quantity) as Freq
from shipping_customer
group by CustomerID, ShipperName, CustomerTitle, City