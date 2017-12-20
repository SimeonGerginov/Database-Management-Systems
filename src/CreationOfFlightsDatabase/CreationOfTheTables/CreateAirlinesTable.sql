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