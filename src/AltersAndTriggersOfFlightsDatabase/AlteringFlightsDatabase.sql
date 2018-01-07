USE Flights
GO

ALTER TABLE Airlines
ADD currency char(3)
GO

ALTER TABLE Flights
ADD flight_code varchar(4)
GO

ALTER TABLE Flights
ALTER COLUMN paymentsum decimal(16,2)
GO

ALTER TABLE Bookings
ADD customer_name varchar(100)
GO

BULK INSERT Airlines
FROM 'C:\Users\simeo\Desktop\Repos\Database-Management-Systems\src\AltersAndTriggersOfFlightsDatabase\ImportedData\airlines.csv'
WITH 
(
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n',
CHECK_CONSTRAINTS
)
GO

SET DATEFORMAT dmy;
BULK INSERT Flights
FROM 'C:\Users\simeo\Desktop\Repos\Database-Management-Systems\src\AltersAndTriggersOfFlightsDatabase\ImportedData\flights.csv'
WITH 
(
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n',
CHECK_CONSTRAINTS
)
GO

BULK INSERT Schedules
FROM 'C:\Users\simeo\Desktop\Repos\Database-Management-Systems\src\AltersAndTriggersOfFlightsDatabase\ImportedData\schedules.csv'
WITH 
(
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n',
CHECK_CONSTRAINTS
)
GO

BULK INSERT Bookings
FROM 'C:\Users\simeo\Desktop\Repos\Database-Management-Systems\src\AltersAndTriggersOfFlightsDatabase\ImportedData\bookings.csv'
WITH 
(
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n',
CHECK_CONSTRAINTS
)
GO

ALTER TABLE Bookings
ADD fclass integer DEFAULT(0) CHECK(fclass = 0 OR fclass = 1)
GO