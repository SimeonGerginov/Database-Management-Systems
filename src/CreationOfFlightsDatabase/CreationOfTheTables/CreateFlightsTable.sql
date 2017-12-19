USE Flights
GO

CREATE TABLE Flights (
    airline_code char(2) FOREIGN KEY REFERENCES Airlines(code),
	flight_number integer check (flight_number BETWEEN 1000 AND 9999) PRIMARY KEY,
	flight_date date NOT NULL,
	price decimal NOT NULL,
	currency char(3) DEFAULT('EUR'),
	max_econ_cap integer check(max_econ_cap >= 0),
	occ_econ_cap integer check(occ_econ_cap >= 0 And occ_econ_cap < max_econ_cap),
	max_buss_cap integer check(max_buss_cap >= 0),
	occ_buss_cap integer check(occ_buss_cap >= 0 And occ_buss_cap < max_buss_cap),
	paymentsum decimal(16,2)
);