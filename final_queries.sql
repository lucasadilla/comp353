USE rentruck;

-- a) List of customers that are businesses (enterprises/companies)
SELECT c.CustomerID, c.ClientName
FROM Customer c
JOIN Customer_type t ON c.CustomerID = t.CustomerID
WHERE t.Type = '1';

-- b) List of reservations whose reservation number is greater than 1
SELECT *
FROM Reservation
WHERE CAST(SUBSTRING(ReservationID, 2) AS UNSIGNED) > 1;

-- c) List of drivers and vehicles having participated in at least one mission
SELECT DISTINCT d.DriverID, d.FirstName, d.LastName, v.VehicleID, v.Brand
FROM Mission m
JOIN Driver d ON m.DriverID = d.DriverID
JOIN Vehicle v ON m.VehicleID = v.VehicleID;

-- d) List missions between March 11, 2026 and March 18, 2026, with drivers and vehicles
SELECT m.MissionID, m.StartDay, m.EndDay, d.DriverID, d.FirstName, d.LastName, v.VehicleID, v.Brand
FROM Mission m
JOIN Driver d ON m.DriverID = d.DriverID
JOIN Vehicle v ON m.VehicleID = v.VehicleID
WHERE m.StartDay BETWEEN '2026-03-11' AND '2026-03-18';

-- e) List of customers who have not paid their invoices
SELECT DISTINCT c.CustomerID, c.ClientName
FROM Customer c
JOIN Invoice i ON c.CustomerID = i.CustomerID
LEFT JOIN Invoice_payment ip ON i.InvoiceID = ip.InvoiceID
WHERE ip.InvoiceID IS NULL;

-- f) List of drivers who have driven GMC brand vehicles
SELECT DISTINCT d.DriverID, d.FirstName, d.LastName
FROM Driver d
JOIN Mission m ON d.DriverID = m.DriverID
JOIN Vehicle v ON m.VehicleID = v.VehicleID
WHERE v.Brand = 'GMC';

-- g) Customers who have invoices greater than $1000
SELECT DISTINCT c.CustomerID, c.ClientName, i.InvoiceID, i.TotalAmount
FROM Customer c
JOIN Invoice i ON c.CustomerID = i.CustomerID
WHERE i.TotalAmount > 1000;

-- h) List customers with their number of associated invoices
SELECT c.CustomerID, c.ClientName, COUNT(i.InvoiceID) AS NumberOfInvoices
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerID = i.CustomerID
GROUP BY c.CustomerID, c.ClientName
ORDER BY NumberOfInvoices DESC, c.CustomerID;

-- i) Drivers with a mission between Feb 1 and Mar 31, 2026 and > 7000 km
SELECT DISTINCT d.LastName, d.FirstName
FROM Driver d
JOIN Mission m ON d.DriverID = m.DriverID
WHERE m.StartDay BETWEEN '2026-02-01' AND '2026-03-31'
  AND (m.EndMiles - m.StartMiles) > 7000;

-- j) Transaction to update details of a mission given mission ID
START TRANSACTION;
UPDATE Mission
SET EndDay = '2026-02-06',
    EndTime = '17:30:00',
    EndMiles = 900
WHERE MissionID = 'M005';
COMMIT;

-- k) Transaction to cancel a mission (full cancel)
START TRANSACTION;
DELETE FROM Sheet WHERE MissionID = 'M004';
DELETE FROM Invoice_line WHERE MissionID = 'M004';
DELETE FROM Mission WHERE MissionID = 'M004';
COMMIT;

-- k alt) Transaction to cancel part of a mission (end earlier)
-- START TRANSACTION;
-- UPDATE Mission
-- SET EndDay = '2026-02-04',
--     EndTime = '12:00:00',
--     EndMiles = 450
-- WHERE MissionID = 'M004';
-- COMMIT;
