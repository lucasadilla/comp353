USE rentruck;

SHOW TABLES;

SELECT COUNT(*) AS CustomerCount FROM Customer;
SELECT COUNT(*) AS CustomerTypeCount FROM Customer_type;
SELECT COUNT(*) AS WeightClassCount FROM Weight_class;
SELECT COUNT(*) AS DriverCount FROM Driver;
SELECT COUNT(*) AS VehicleCount FROM Vehicle;
SELECT COUNT(*) AS ReservationCount FROM Reservation;
SELECT COUNT(*) AS RentalCount FROM Rental;
SELECT COUNT(*) AS MissionCount FROM Mission;
SELECT COUNT(*) AS SheetCount FROM Sheet;
SELECT COUNT(*) AS InvoiceCount FROM Invoice;
SELECT COUNT(*) AS InvoiceLineCount FROM Invoice_line;
SELECT COUNT(*) AS PaymentTypeCount FROM Payment_type;
SELECT COUNT(*) AS PaymentInstanceCount FROM Payment_instance;
SELECT COUNT(*) AS InvoicePaymentCount FROM Invoice_payment;
SELECT COUNT(*) AS CashTypeCount FROM Cash_type;
SELECT COUNT(*) AS CreditCardTypeCount FROM Credit_card_type;
SELECT COUNT(*) AS CheckTypeCount FROM Check_type;

-- Returns 0 rows when FKs are correct
SELECT * FROM Rental r
LEFT JOIN Customer c ON r.CustomerID = c.CustomerID
LEFT JOIN Reservation res ON r.ReservationID = res.ReservationID
WHERE c.CustomerID IS NULL OR res.ReservationID IS NULL;