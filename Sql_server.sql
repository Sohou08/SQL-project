USE [WideWorldImporters]

-- Question1

SELECT 
    Cu.CustomerID,
	Cu.CustomerName,
	TotalNBOrders,
	TotalNBInvoices,
	OrdersTotalValue,
	InvoicesTotalValue,
	ABS (OrdersTotalValue - InvoicesTotalValue) as AbsoluteValueDifference
From  
     Sales.Customers as Cu 
     JOIN (
			Select 
				Count(O.OrderID) as TotalNBOrders, O.CustomerID
		    From Sales.Orders as O
	    	where O.OrderID in (select it.OrderID from Sales.Invoices it where it.OrderID =O.OrderID) 
			Group by O.CustomerID) as sq
	On sq.CustomerID = Cu.CustomerID
	Join ( select CustomerID, SUM(i.Quantity*i.UnitPrice) as OrdersTotalValue
	      From Sales.OrderLines as i,
		  Sales.Orders as a
		  Where a.OrderID =i.OrderID
		  Group by CustomerID) d
	On d.CustomerID = Cu.CustomerID

	JOIN
	    (  Select CustomerID,Count(Id.InvoiceID) as TotalNBInvoices
			   --SUM(il.Quantity*il.UnitPrice) as InvoicesTotalValue
			    From  
				     Sales.Invoices as Id 
				     --Sales.InvoiceLines as il
			    Group by CustomerID
	     ) as sq1
    ON Cu.CustomerID = sq1.CustomerID 

	JOIN
	    (
		    Select CustomerID, SUM(il.Quantity*il.UnitPrice) as InvoicesTotalValue
			    From  
				     Sales.Invoices as Id, 
				     Sales.InvoiceLines as il
				where Id.InvoiceID = il.InvoiceID 
				Group by CustomerID
		) sq2
	ON sq2.CustomerID = Cu.CustomerID
Order by  TotalNBOrders ASC , CustomerName


--Question2

               Select
			   Top (1)
			   Cu.CustomerID,
			   Cu.CustomerName ,
			   id.InvoiceID,InvoiceLineID, il.UnitPrice
			    From  
				     Sales.Customers as Cu,
					 Sales.Invoices as id
					, Sales.InvoiceLines as il
				where 
				Cu.CustomerID = id.CustomerID 
				and il.InvoiceID = id.InvoiceID
				and Cu.CustomerID =1060
				Order by InvoiceID,InvoiceLineID
				
				Update Sales.InvoiceLines
				Set UnitPrice += 20
				where
				InvoiceLineID = 225394 

--Question3

Select *
from (
Select CustomerName, SUM (il.Quantity * il.UnitPrice) as invoice,   DATENAME(MONTH,iv.InvoiceDate) [Month]--, YEAR(iv.InvoiceDate) [Year],InvoiceDate-- ,
From Sales.Customers Cu,
     Sales.Invoices iv,
	 Sales.InvoiceLines il
where iv.InvoiceID =  il.InvoiceID and Cu.CustomerID = iv.CustomerID --and CustomerName = 'Abel Spirlea'
Group by CustomerName, iv.InvoiceDate
--Order by CustomerName
  ) src
 pivot 
 ( sum(invoice)
 for [Month] in ([January],[February],[March],[April],[May],
    [June],[July],[August],[September],[October],[November],
    [December])
 ) piv;


--Question 4
SELECT 
    cc.CustomerCategoryName,
    ABS (MAX( OrdersTotalValue - InvoicesTotalValue)) as Maxloss,
	MAX(Cu.CustomerName),
	MAX(Cu.CustomerID)
From  
     Sales.Customers Cu
    JOIN Sales.CustomerCategories cc 
	ON Cu.CustomerCategoryID = cc.CustomerCategoryID
     JOIN (
			Select 
			   O.CustomerID
		    From Sales.Orders as O
	    	where  Not exists (select it.OrderID from Sales.Invoices it where it.OrderID =O.OrderID) 
			) as sq
	On sq.CustomerID = Cu.CustomerID
	
	JOIN 
	      (
		    Select CustomerID, SUM(i.Quantity*i.UnitPrice) as OrdersTotalValue
			    From  
				     Sales.Orders as o,
			         Sales.OrderLines i
				where o.OrderID = i.OrderID 
				Group by CustomerID
		   ) sq2 on sq2.CustomerID = Cu.CustomerID
	JOIN
	    (
		    Select CustomerID, SUM(il.Quantity*il.UnitPrice) as InvoicesTotalValue
			    From  
				     Sales.Invoices as Id, 
				     Sales.InvoiceLines as il
				where Id.InvoiceID = il.InvoiceID 
				Group by CustomerID
		) sq3
	ON sq3.CustomerID = Cu.CustomerID
--where Cu.CustomerID = 905
Group by (cc.CustomerCategoryName)
Order bY Maxloss DESC

---Question5
USE [SQLPlayground]
SELECT c.CustomerID
      ,CustomerName
FROM 
     Customer c
     ,Purchase p
where p.CustomerID = c.CustomerID
 and p.Qty > 50

