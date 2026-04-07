-- d
SELECT 
    M.MissionID,
    M.StartDay,
    M.EndDay,
    M.DriverID,
    D.LicenseClass,
    M.VehicleID,
    V.VehicleClass
FROM Mission M
JOIN Driver D ON M.DriverID = D.DriverID
JOIN Vehicle V ON M.VehicleID = V.VehicleID
WHERE M.StartDay BETWEEN '2026-02-11' AND '2026-02-18';

-- e
SELECT DISTINCT C.CustomerID, C.ClientName
FROM Customer C
JOIN Invoice I ON C.CustomerID = I.CustomerID
LEFT JOIN Invoice_payment IP ON I.InvoiceID = IP.InvoiceID
WHERE IP.InvoiceID IS NULL;

-- f (to add 'Brand' attribute to Vehicle table)
SELECT DISTINCT D.FirstName, D.LastName
FROM Driver D
JOIN Mission M ON D.DriverID = M.DriverID
JOIN Vehicle V ON M.VehicleID = V.VehicleID
WHERE V.Brand = 'GMC';

-- g
SELECT DISTINCT C.CustomerID, C.ClientName
FROM Customer C
JOIN Invoice I ON C.CustomerID = I.CustomerID
WHERE I.TotalAmount > 1000;

-- h
SELECT 
    C.CustomerID, 
    C.ClientName, 
    COUNT(I.InvoiceID) AS NumberOfInvoices
FROM Customer C
LEFT JOIN Invoice I ON C.CustomerID = I.CustomerID
GROUP BY C.CustomerID, C.ClientName;

-- i (to add 'FirstName' and 'LastName' to Driver table)
SELECT DISTINCT D.FirstName, D.LastName
FROM Driver D
JOIN Mission M ON D.DriverID = M.DriverID
WHERE M.StartDay BETWEEN '2026-02-01' AND '2026-03-30'
  AND (M.EndMiles - M.StartMiles) > 7000;

-- j
UPDATE Mission
SET 
    StartDay = '2026-02-15',
    StartTime = '09:00:00',
    EndDay = '2026-02-16',
    EndTime = '17:00:00',
    StartMiles = 12000,
    EndMiles = 19000
WHERE MissionID = 'M001';

-- k (Delete Entire Mission) (Run each Query separately)
DELETE FROM Sheet
WHERE MissionID = 'M001';

DELETE FROM Invoice_line
WHERE MissionID = 'M001';

DELETE FROM Mission
WHERE MissionID = 'M001';

-- k (End Early)
UPDATE Mission
SET 
    EndDay = '2026-02-15',
    EndTime = '14:00:00',
    EndMiles = 15000
WHERE MissionID = 'M001';