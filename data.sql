USE rentruck;

-- Weight class
INSERT INTO Weight_class VALUES
('tourism'),('heavy'),('superheavy');

-- Customers
INSERT INTO Customer VALUES
('C001','AlphaInc','1111111111','Montreal'),
('C002','BetaCorp','2222222222','Laval'),
('C003','GammaLtd','3333333333','Quebec'),
('C004','DeltaCo','4444444444','Ottawa'),
('C005','Epsilon','5555555555','Toronto'),
('C006','ZetaInc','6666666666','Calgary'),
('C007','EtaCorp','7777777777','Vancouver'),
('C008','ThetaLtd','8888888888','Edmonton'),
('C009','IotaCo','9999999999','Halifax'),
('C010','KappaInc','1010101010','Winnipeg');

-- Customer types
INSERT INTO Customer_type VALUES
('C001','1'),('C002','1'),('C003','1'),('C004','0'),('C005','1');

-- Drivers
INSERT INTO Driver VALUES
('D001','tourism'),('D002','heavy'),('D003','superheavy'),
('D004','tourism'),('D005','heavy');

-- Vehicles
INSERT INTO Vehicle VALUES
('V001',1000,'tourism'),('V002',2000,'heavy'),('V003',3000,'superheavy'),
('V004',1500,'tourism'),('V005',2500,'heavy');

-- Reservations
INSERT INTO Reservation VALUES
('R001','2026-01-01','Montreal','2026-02-01','09:00:00',5,'tourism','C001'),
('R002','2026-01-02','Laval','2026-02-02','10:00:00',3,'heavy','C002'),
('R003','2026-01-03','Quebec','2026-02-03','11:00:00',4,'superheavy','C003'),
('R004','2026-01-04','Ottawa','2026-02-04','12:00:00',2,'tourism','C004'),
('R005','2026-01-05','Toronto','2026-02-05','13:00:00',1,'heavy','C005');

-- Rentals
INSERT INTO Rental VALUES
('RE001','C001','R001'),('RE002','C002','R002'),
('RE003','C003','R003'),('RE004','C004','R004'),
('RE005','C005','R005');

-- Missions
INSERT INTO Mission VALUES
('M001','2026-02-01','09:00:00','2026-02-01','17:00:00',100,500,'RE001','D001','V001'),
('M002','2026-02-02','10:00:00','2026-02-02','16:00:00',200,700,'RE002','D002','V002'),
('M003','2026-02-03','11:00:00','2026-02-03','17:00:00',300,900,'RE003','D003','V003'),
('M004','2026-02-04','08:30:00','2026-02-04','15:00:00',150,600,'RE004','D004','V004'),
('M005','2026-02-05','09:30:00','2026-02-05','17:00:00',250,800,'RE005','D005','V005');

-- Sheets
INSERT INTO Sheet VALUES
('S001','M001'),('S002','M002'),('S003','M003'),('S004','M004'),('S005','M005');

-- Invoices
INSERT INTO Invoice VALUES
('I001','2026-02-15',1200,'C001'),
('I002','2026-02-15',800,'C002'),
('I003','2026-02-15',1500,'C003'),
('I004','2026-02-15',600,'C004'),
('I005','2026-02-15',2000,'C005');

-- Invoice lines
INSERT INTO Invoice_line VALUES
('I001','M001',600,600),
('I002','M002',400,400),
('I003','M003',700,800),
('I004','M004',300,300),
('I005','M005',1000,1000);

-- Payment types
INSERT INTO Payment_type VALUES
('cash'),('credit'),('check');

-- Payment instances
INSERT INTO Payment_instance VALUES
('T001','cash'),('T002','credit'),('T003','check');

-- Invoice payments
INSERT INTO Invoice_payment VALUES
('P001',1200,'cash','T001','2026-02-16','I001','C001'),
('P002',800,'credit','T002','2026-02-16','I002','C002'),
('P003',1500,'check','T003','2026-02-16','I003','C003'),
('P004',600,'cash','T001','2026-02-16','I004','C004');

-- Cash, Credit, Check types
INSERT INTO Cash_type VALUES ('T001');
INSERT INTO Credit_card_type VALUES ('T002','CC001','Alpha Card','2027-12-31');
INSERT INTO Check_type VALUES ('T003','CHK001','BANK123','RENTRUCK');