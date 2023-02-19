with segmentation_value as
(select b.CustomerID,convert(date,OrderDate) as OrderDate,c.Quantity,(UnitPrice*(1-Discount)) as Price
from Orders b 
inner join [Order Details] c on b.OrderID=c.OrderID
--where year(OrderDate)=1997
),

amount as (
select CustomerID, sum(Quantity) as freq, sum(Price) as Amount
from segmentation_value
group by CustomerID),

last_orderdate as (
SELECT CustomerID, max(OrderDate)as last_payment_date
FROM (
SELECT CustomerID, 
OrderDate, 
DENSE_RANK() over(PARTITION by CustomerID ORDER BY OrderDate DESC) as rnk_
FROM segmentation_value) as lpd
WHERE rnk_ = 1
group by CustomerID),

 rfm_value as (
select a.CustomerID,b.last_payment_date,DATEDIFF(day,b.last_payment_date,CURRENT_TIMESTAMP) as recency,a.freq,a.Amount
from amount a
inner join last_orderdate  b on a.CustomerID=b.CustomerID),

rfm as (
SELECT * 
, NTILE(4) OVER (ORDER BY recency DESC) AS R 
, NTILE(4) OVER (ORDER BY freq DESC ) AS F 
, NTILE(4) OVER (ORDER BY Amount DESC ) AS M 
FROM rfm_value),
rfm_class as (
SELECT * 
, CONCAT(R, F, M) as rfm_class
FROM rfm),

rfm_fix as (
SELECT a.*,
CASE 
    WHEN rfm_class in (111,112,121,122) then 'Best Customers'
    WHEN rfm_class in (131,132,141,142,211,222,311,322,212,221,312,321) THEN 'High-spending New Customers' 
	WHEN rfm_class in(113,114,123,124,133,134,143,144) then 'Lowest-Spending Active Loyal Customers'
	WHEN rfm_class like '4%' then 'Churned Customers'
	when rfm_class in (223,232,233,234,243,244,332,333,334,342,343,344,323,213) then 'Potensial Customer'
ELSE NULL 
END AS rfm_category,b.ContactTitle,b.City,b.Country
FROM rfm_class a
left join Customers b on a.CustomerID=b.CustomerID)

select a.CustomerID,convert(date,OrderDate) as OrderDate, b.rfm_category,ContactTitle,b.City,b.Country from Orders a
left join rfm_fix b on a.CustomerID=b.CustomerID