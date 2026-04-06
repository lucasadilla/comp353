USE rentruck;

-- 1. Show all customers
SELECT * FROM Customer;

-- 2. Join Customers with Reservations
SELECT c.ClientName, r.AppointmentDate, r.TypeOfVehicle
FROM Customer c
JOIN Reservation r ON c.CustomerID = r.CustomerID;

-- 3. Total invoice amounts per customer
SELECT CustomerID, SUM(TotalAmount) AS TotalSpent
FROM Invoice
GROUP BY CustomerID;

-- 4. Check driver assignment for missions
SELECT m.MissionID, m.DriverID, d.LicenseClass
FROM Mission m
JOIN Driver d ON m.DriverID = d.DriverID;

-- 5. Payments matching invoices
SELECT i.InvoiceID, ip.Amount, ip.PaymentType
FROM Invoice i
JOIN Invoice_payment ip ON i.InvoiceID = ip.InvoiceID;