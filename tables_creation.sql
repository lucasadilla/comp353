CREATE TABLE Customer(
	CustomerID CHAR(10) NOT NULL,
	ClientName VARCHAR(16),
	ClientNumber CHAR(10) NOT NULL,
	ClientAddress VARCHAR(32),
	PRIMARY KEY(CustomerID),
);
CREATE TABLE Customer_type(
	CustomerID CHAR(10) NOT NULL,
	Type CHAR(1)NOT NULL,
	PRIMARY KEY(CustomerID),
	FOREIGN KEY CustomerID REFERENCES Customer(CustomerID),
	CHECK(Type IN(‘0’,’1’)),
	CHECK(CustomerID IN(SELECT CustomerID from Customer)),
);
CREATE TABLE Weight_class(
	Class VARCHAR(16), NOT NULL,
	PRIMARY KEY(Class),
	CONSTRAINT Allowed-Classes CHECK(Class IN(‘tourism’,’heavy’,’superheavy)),
);
CREATE TABLE Driver(
	DriverID VARCHAR(16) NOT NULL,
	LicenseClass VARCHAR(10) NOT NULL,
	PRIMARY KEY(DriverID),
	FOREIGN KEY LicenseClass REFERENCES Weight_class(Class),
	CHECK(LicenseClass IN(SELECT Class from Weight_class))
	,
);
CREATE TABLE Vehicle(
	VehicleID VARCHAR(16) NOT NULL,
	OdometerMiles INT NOT NULL,
	VehicleClass VARCHAR(10) NOT NULL,
	PRIMARY KEY(VehicleID),
	FOREIGN KEY VehicleClass REFERENCES Weight_class(Class),
	CHECK(VehicleClass IN(SELECT Class from Weight_class)),
);
CREATE TABLE Reservation(
	ReservationID CHAR(16) NOT NULL,
	DateOfBooking DATE NOT NULL,
	RendezvousPlace VARCHAR(32),
	AppointmentDate DATE NOT NULL,
	AppointmentTime TIME NOT NULL,
	ExpectedDuration INT NOT NULL,
	TypeOfVehicle VARCHAR(10) NOT NULL,
	CustomerID CHAR(10) NOT NULL,
	PRIMARY KEY(ReservationID),
	FOREIGN KEY TypeOfVehicle REFERENCES Weight_class(Class),
	FOREIGN KEY CustomerID REFERENCES Customer(CustomerID),
	CHECK(TypeOfVehicle IN(SELECT Class from Weight_class)),
	CHECK(CustomerID IN(SELECT CustomerID from Customer)),
CHECK (AppointmentDate > DateOfBooking
  AND AppointmentDate <= DateOfBooking + INTERVAL 1 YEAR)
);
CREATE TABLE Rental(
	RentalID CHAR(16) NOT NULL,
	CustomerID CHAR(10) NOT NULL,
	ReservationID CHAR(16) NOT NULL,
	PRIMARY KEY(RentalID),
	FOREIGN KEY CustomerID REFERENCES Customer(CustomerID),
	FOREIGN KEY ReservationID REFERENCES Reservation(ReservationID),
CHECK(CustomerID IN(SELECT CustomerID from Customer)),
CHECK(ReservationID IN(SELECT ReservationID from Reservation)),
);
CREATE TABLE Mission(
	MissionID CHAR(10) NOT NULL,
	StartDay DATE NOT NULL,
	StartTime TIME NOT NULL,
	EndDay DATE NOT NULL,
	EndTime TIME NOT NULL,
	StartMiles INT NOT NULL,
	EndMiles INT NOT NULL,
	RentalID CHAR(16) NOT NULL,
	DriverID VARCHAR(16) NOT NULL,
	VehicleID VARCHAR(16) NOT NULL,
	PRIMARY KEY(MissionID),
	FOREIGN KEY RentalID REFERENCES Rental(RentalID),
	FOREIGN KEY DriverID REFERENCES Driver(DriverID),
	FOREIGN KEY VehicleID REFERENCES Vehicle(VehicleID),
	CHECK(RentalID IN(SELECT RentalID from Rental)),
	CHECK(DriverID IN(SELECT DriverID from Driver)),
	CHECK(VehicleID IN(SELECT VehicleID from Vehicle)),
	CHECK(EndDay>StartDay OR (EndDay=StartDay AND EndTime>StartTime)),
	CHECK(EndTime<='18:00:00'),
	CHECK(StartTime>=’8:00:00’),
	CHECK(StartMiles>0 AND EndMiles>StartMiles),
);
CREATE TABLE Sheet(
	SheetID CHAR(10) NOT NULL,
	MissionID CHAR(10) NOT NULL,
	PRIMARY KEY(SheetID),
	FOREIGN KEY MissionID REFERENCES Mission(MissionID),
	CHECK(MissionID IN(SELECT MissionID from Mission)),
);
