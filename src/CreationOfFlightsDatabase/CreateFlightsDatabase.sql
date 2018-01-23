CREATE DATABASE Flights
GO

USE Flights
GO

CREATE TABLE Airlines (
    code char(2) PRIMARY KEY,
	name varchar(20) NOT NULL
);
GO

CREATE UNIQUE INDEX Index_Airlines_Name
   ON Airlines(name);
GO

CREATE TABLE Flights (
    airline_code char(2) FOREIGN KEY REFERENCES Airlines(code),
	flight_number integer check (flight_number BETWEEN 1000 AND 9999) PRIMARY KEY,
	flight_date date NOT NULL,
	price decimal(12,2) NOT NULL check(price >= 0),
	currency char(3) DEFAULT('EUR'),
	max_econ_cap integer check(max_econ_cap >= 0),
	occ_econ_cap integer,
	max_buss_cap integer check(max_buss_cap >= 0),
	occ_buss_cap integer,
	paymentsum decimal(16,2) check(paymentsum >= 0)
);
GO

ALTER TABLE Flights ADD CONSTRAINT
    EconAndBussCap_Flights CHECK (occ_econ_cap >= 0 AND 
	                              occ_econ_cap <= max_econ_cap AND
	                              occ_buss_cap >= 0 AND occ_buss_cap <= max_buss_cap)
GO

CREATE TABLE Schedules (
    airline_code char(2) FOREIGN KEY REFERENCES Airlines(code),
	flight_number integer check (flight_number BETWEEN 1000 AND 9999) 
	              FOREIGN KEY REFERENCES Flights(flight_number),
	dept_country char(2) NOT NULL,
	dept_city varchar(20) NOT NULL,
	dept_airport char(3) NOT NULL,
	dept_time time NOT NULL,
	arrv_country char(2) NOT NULL,
	arrv_city varchar(20) NOT NULL,
	arrv_airport char(3) NOT NULL,
	arrv_time time NOT NULL,
	flight_time integer check (flight_time >= 0),
	distance integer check (distance >= 0),
	PRIMARY KEY (airline_code, flight_number)
);
GO

ALTER TABLE Schedules ADD CONSTRAINT
    Time_Schedules CHECK (arrv_time > dept_time)
GO

CREATE TABLE Bookings (
    airline_code char(2) FOREIGN KEY REFERENCES Airlines(code),
	flight_number integer check (flight_number BETWEEN 1000 AND 9999) 
	              FOREIGN KEY REFERENCES Flights(flight_number),
	booking_number integer check (booking_number BETWEEN 10000000 AND 99999999)
	               PRIMARY KEY,
	customer_number integer check (customer_number BETWEEN 10000000 AND 99999999)
	                NOT NULL,
	order_date date NOT NULL
);
GO

CREATE TRIGGER trigger_for_order_date
ON Bookings 
FOR INSERT, UPDATE
AS
BEGIN
   DECLARE @flight_date date;
   DECLARE @order_date date;
   SET @flight_date = (SELECT f.flight_date 
                       FROM Flights f 
                       JOIN INSERTED i 
					   ON i.flight_number = f.flight_number);
   SELECT @order_date = i.order_date FROM INSERTED i;

   IF @flight_date <= @order_date
      RAISERROR('order_date must be before flight_date', -1, -1)
END
GO