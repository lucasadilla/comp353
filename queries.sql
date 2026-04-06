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

-- a) List of customers that are businesses
SELECT c.CustomerID 
FROM Customer c,Customer_type t 
WHERE c.CustomerID=t.CustomerID AND t.Type='1'

-- b) List of reservations whose reservation number is greater than 1(meaning which reservations have more than 1 rental)
SELECT r.ReservationID
FROM Reservation AS r
JOIN Rental AS t ON r.ReservationID = t.ReservationID
GROUP BY r.ReservationID
HAVING COUNT(t.RentalID) > 1;

-- c) List of drivers and vehicles having participated in at least one mission
SELECT DISTINCT DriverID,VehicleID
FROM Mission