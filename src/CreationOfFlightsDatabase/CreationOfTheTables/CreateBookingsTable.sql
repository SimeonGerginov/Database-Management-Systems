USE Flights
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