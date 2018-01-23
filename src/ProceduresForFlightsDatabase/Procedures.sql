USE Flights
GO

CREATE PROC Info_About_Flights_Of_AirlinesCompany @code char(2)
AS
   SELECT
   a.name,
   f.flight_number, 
	 f.flight_date,
	 s.dept_city,
	 s.dept_time,
	 s.arrv_city,
	 s.arrv_time,
	 f.airline_code,
	 f.price,
	 f.currency,
	 f.max_econ_cap,
	 f.occ_econ_cap,
	 f.max_buss_cap,
	 f.occ_buss_cap,
	 f.paymentsum,
	 f.flight_code,
	 s.dept_country,
	 s.dept_airport,
	 s.arrv_country,
	 s.arrv_airport,
	 s.flight_time,
	 s.distance
   FROM Airlines a
   INNER JOIN 
        Flights f ON a.code = f.airline_code
   INNER JOIN 
        Schedules s ON a.code = s.airline_code
   WHERE a.code = @code
GO

EXEC Info_About_Flights_Of_AirlinesCompany 'AA';
GO

CREATE PROC InfoForAirlineCompanyFlights @flight_date date, @dept_country char(2)
AS
  SELECT 
   a.name,
	 f.*
  FROM Schedules s
  INNER JOIN 
      Flights f ON f.flight_number = s.flight_number
  INNER JOIN 
      Airlines a ON a.code = s.airline_code
  WHERE f.flight_date = @flight_date AND s.dept_country = @dept_country
GO

EXEC InfoForAirlineCompanyFlights '2012-05-23', 'US'
GO

CREATE FUNCTION GetCountOfReservations(@customer_name varchar(100), @code char(2))
RETURNS integer
AS
BEGIN
   DECLARE @countOfReservations integer;
   SET @countOfReservations = (SELECT COUNT(b.booking_number)
                               FROM Bookings b , Flights f
							   WHERE b.airline_code = @code
							   AND b.customer_name = @customer_name
							   AND YEAR(f.flight_date) = 2012
							   AND b.flight_number = f.flight_number)
   RETURN @countOfReservations
END;
GO

DROP FUNCTION dbo.GetCountOfReservations
GO

DROP PROCEDURE ResultSetProc
GO

EXEC ResultSetProc 1000
GO

CREATE PROC ResultSetProc @flight_number integer
AS
    SELECT DISTINCT(b.customer_name)
    FROM Bookings b 
    WHERE b.flight_number = @flight_number

    SELECT DISTINCT(b.customer_name), a.name, dbo.GetCountOfReservations(b.customer_name, a.code)
    FROM Bookings b, Airlines a 
    WHERE b.flight_number = @flight_number AND b.airline_code = a.code
	--AND dbo.GetCountOfReservations(b.customer_number, a.code) >=3
GO

DROP PROCEDURE ResultSetProc
GO

EXEC ResultSetProc 1000 WITH RESULT SETS
(
  ( 
     customer_name varchar(100)
  ),
  (
     customer_name varchar(100),
	   airline_name varchar(20),
	   bookings_count integer
  )
);

INSERT INTO dbo.Bookings VALUES ('AA', 1000, 203, 2873, '2012-03-20', 'Irene Barth', 1);
INSERT INTO dbo.Bookings VALUES ('AA', 1000, 205, 2873, '2012-03-22', 'Irene Barth', 0);