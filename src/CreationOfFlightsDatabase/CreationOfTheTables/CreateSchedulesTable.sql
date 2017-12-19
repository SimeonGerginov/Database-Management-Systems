USE Flights
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