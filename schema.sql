DROP DATABASE IF EXISTS rentruck;
CREATE DATABASE rentruck;
USE rentruck;
-- Customer tables
CREATE TABLE IF NOT EXISTS Customer(
    CustomerID CHAR(10) NOT NULL PRIMARY KEY,
    ClientName VARCHAR(16),
    ClientNumber UNSIGNED BIGINT NOT NULL,
    ClientAddress VARCHAR(32),
    CHECK(ClientNumber BETWEEN 1000000000 AND 9999999999)
);

CREATE TABLE IF NOT EXISTS Customer_type(
    CustomerID CHAR(10) NOT NULL PRIMARY KEY,
    Type CHAR(1) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CHECK(Type IN('0','1'))
);

-- Weight class
CREATE TABLE IF NOT EXISTS Weight_class(
    Class VARCHAR(16) NOT NULL PRIMARY KEY,
    CONSTRAINT Allowed_Classes CHECK(Class IN('tourism','heavy','superheavy'))
);

-- Driver and Vehicle
CREATE TABLE IF NOT EXISTS Driver(
    DriverID VARCHAR(16) NOT NULL PRIMARY KEY,
    LicenseClass VARCHAR(10) NOT NULL,
    FOREIGN KEY (LicenseClass) REFERENCES Weight_class(Class)
);

CREATE TABLE IF NOT EXISTS Vehicle(
    VehicleID VARCHAR(16) NOT NULL PRIMARY KEY,
    OdometerMiles INT NOT NULL,
    VehicleClass VARCHAR(10) NOT NULL,
    FOREIGN KEY (VehicleClass) REFERENCES Weight_class(Class),
    CHECK(OdometerMiles>=0)
);

-- Reservations and Rentals
CREATE TABLE IF NOT EXISTS Reservation(
    ReservationID CHAR(16) NOT NULL PRIMARY KEY,
    DateOfBooking DATE NOT NULL,
    RendezvousPlace VARCHAR(32),
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    ExpectedDuration INT NOT NULL,
    TypeOfVehicle VARCHAR(10) NOT NULL,
    CustomerID CHAR(10) NOT NULL,
    FOREIGN KEY (TypeOfVehicle) REFERENCES Weight_class(Class),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CHECK (
    AppointmentDate > DateOfBooking AND 
    AppointmentDate <= DATE(DateOfBooking, '+1 year')
)
);

CREATE TABLE IF NOT EXISTS Rental(
    RentalID CHAR(16) NOT NULL PRIMARY KEY,
    CustomerID CHAR(10) NOT NULL,
    ReservationID CHAR(16) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
);

-- Mission and Sheet
CREATE TABLE IF NOT EXISTS Mission(
    MissionID CHAR(10) NOT NULL PRIMARY KEY,
    StartDay DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndDay DATE NOT NULL,
    EndTime TIME NOT NULL,
    StartMiles INT NOT NULL,
    EndMiles INT NOT NULL,
    RentalID CHAR(16) NOT NULL,
    DriverID VARCHAR(16) NOT NULL,
    VehicleID VARCHAR(16) NOT NULL,
    FOREIGN KEY (RentalID) REFERENCES Rental(RentalID),
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID),
    CHECK(EndDay>StartDay OR (EndDay=StartDay AND EndTime>StartTime)),
    CHECK(EndTime<='18:00:00'),
    CHECK(StartTime>='08:00:00'),
    CHECK(StartMiles>0 AND EndMiles>StartMiles)
);

CREATE TABLE IF NOT EXISTS Sheet(
    SheetID CHAR(10) NOT NULL PRIMARY KEY,
    MissionID CHAR(10) NOT NULL,
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID)
);

-- Invoice tables
CREATE TABLE IF NOT EXISTS Invoice(
    InvoiceID CHAR(10) NOT NULL PRIMARY KEY,
    IssueDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    CustomerID CHAR(10) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE IF NOT EXISTS Invoice_line(
    InvoiceID CHAR(10) NOT NULL,
    MissionID CHAR(10) NOT NULL,
    DurationCost DECIMAL(10,2) NOT NULL,
    MileageCost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY(InvoiceID, MissionID),
    FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID),
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID)
);

CREATE TABLE IF NOT EXISTS Payment_type(
    PaymentType VARCHAR(10) NOT NULL PRIMARY KEY,
    CONSTRAINT Allowed_Types CHECK(PaymentType IN('cash','credit','check'))
);

CREATE TABLE IF NOT EXISTS Payment_instance(
    TypeID VARCHAR(16) NOT NULL PRIMARY KEY,
    PaymentType VARCHAR(10) NOT NULL,
    FOREIGN KEY (PaymentType) REFERENCES Payment_type(PaymentType)
);

CREATE TABLE IF NOT EXISTS Invoice_payment(
    PaymentID CHAR(10) NOT NULL PRIMARY KEY,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentType VARCHAR(10) NOT NULL,
    TypeID VARCHAR(16) NOT NULL,
    PaymentDate DATE NOT NULL,
    InvoiceID CHAR(10) NOT NULL,
    CustomerID CHAR(10) NOT NULL,
    FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (PaymentType) REFERENCES Payment_type(PaymentType),
    FOREIGN KEY (TypeID) REFERENCES Payment_instance(TypeID)
);

-- Cash, Credit Card, Check
CREATE TABLE IF NOT EXISTS Cash_type(
    TypeID VARCHAR(16) NOT NULL PRIMARY KEY,
    FOREIGN KEY (TypeID) REFERENCES Payment_instance(TypeID)
);

CREATE TABLE IF NOT EXISTS Credit_card_type(
    TypeID VARCHAR(16) NOT NULL,
    CardID CHAR(16) NOT NULL PRIMARY KEY,
    CardName VARCHAR(32) NOT NULL,
    ExpirationDate DATE NOT NULL,
    FOREIGN KEY (TypeID) REFERENCES Payment_instance(TypeID)
);

CREATE TABLE IF NOT EXISTS Check_type(
    TypeID VARCHAR(16) NOT NULL,
    CheckNumber VARCHAR(8) NOT NULL,
    SenderBankNb VARCHAR(16) NOT NULL,
    ReceiverName CHAR(8) NOT NULL,
    PRIMARY KEY(CheckNumber,SenderBankNb),
    FOREIGN KEY (TypeID) REFERENCES Payment_instance(TypeID),
    CHECK(ReceiverName='RENTRUCK')
);