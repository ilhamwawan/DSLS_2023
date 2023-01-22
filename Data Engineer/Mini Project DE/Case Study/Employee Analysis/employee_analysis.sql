with employee_order as (
select a.FirstName,LastName,Title,
c.UnitPrice,c.Quantity,(UnitPrice*(1-Discount)) as Price,
e.TerritoryDescription
from Northwind.dbo.Employees  a
left join Northwind.dbo.Orders b on a.EmployeeID=b.EmployeeID
left join Northwind.dbo.[Order Details] c  on b.OrderID=c.OrderID
left join Northwind.dbo.EmployeeTerritories d on a.EmployeeID=d.EmployeeID
left join Northwind.dbo.Territories e on d.TerritoryID=e.TerritoryID
)

select FirstName,LastName,Title,
sum(UnitPrice) as Total_UnitPrice,
sum(Quantity) as Total_Quantity,
sum(Price) as Total_PriceAfterDiscount,
TerritoryDescription
from employee_order
group by FirstName,LastName,Title,TerritoryDescription