USE Flights
GO

CREATE FUNCTION ScheduleForAGivenFlight(@flight_date date)
RETURNS TABLE
AS
RETURN
(
  SELECT 
     f.flight_number, 
	 f.flight_date,
	 s.dept_city,
	 s.dept_time,
	 s.arrv_city,
	 s.arrv_time
  FROM 
     Flights f
  INNER JOIN 
     Schedules s ON s.flight_number = f.flight_number
  WHERE f.flight_date = @flight_date
);
GO

SELECT * FROM dbo.ScheduleForAGivenFlight('2012-06-20')

DROP FUNCTION dbo.ScheduleForAGivenFlight
GO

CREATE FUNCTION CountOfPassengersWhoFlewWithGivenCompany(@code char(2), @begin_date date, @end_date date)
RETURNS integer
AS
BEGIN
   DECLARE @countOfPassengers integer;
   SET @countOfPassengers = (SELECT SUM(f.occ_econ_cap + f.occ_buss_cap) 
                             FROM Flights f
							 WHERE f.airline_code = @code AND 
							 f.flight_date >= @begin_date AND 
							 f.flight_date <= @end_date)
   RETURN @countOfPassengers;
END;
GO

DROP FUNCTION dbo.CountOfPassengersWhoFlewWithGivenCompany
GO

CREATE FUNCTION GetBeginDate()
RETURNS date
AS
BEGIN
   DECLARE @begin_date date;
   SET @begin_date = CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) AS date);
   RETURN @begin_date;
END;
GO

DROP FUNCTION dbo.GetBeginDate
GO

CREATE FUNCTION GetEndDate()
RETURNS date
AS
BEGIN
   DECLARE @end_date date;
   SET @end_date = CAST(DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) AS date);
   RETURN @end_date;
END;
GO

DROP FUNCTION dbo.GetEndDate
GO

CREATE VIEW v_info_about_airlines_company AS
  SELECT
     DISTINCT(a.name),
	 s.*,
	 (SELECT dbo.CountOfPassengersWhoFlewWithGivenCompany(a.code, dbo.GetBeginDate(), dbo.GetEndDate())) AS CountOfPassengers
  FROM 
     Airlines a
  INNER JOIN 
     Flights f ON (a.code = f.airline_code)
  INNER JOIN 
  (SELECT * FROM ScheduleForAGivenFlight(CAST(GETDATE() AS date))) AS s
  ON (f.flight_number = s.flight_number)
GO

DROP VIEW v_info_about_airlines_company
GO

SELECT * FROM dbov_info_about_airlines_company

-- TESTING THE VIEW
 
INSERT INTO FLIGHTS
    VALUES('DL', 1215, '2018-01-15', 427, 'USD', 385, 270, 52, 50, ((50*1.5 + 270)*427), 17);
   
INSERT INTO FLIGHTS
    VALUES('DL', 1211, '2017-12-30', 668, 'USD', 385, 300, 52, 0, (300*668), 17);
 
INSERT INTO FLIGHTS
    VALUES('DL', 1212, '2017-12-11', 422.92, 'USD', 385, 250, 52, 50, ((50*1.5 + 250)*422.92), 17);
   
INSERT INTO FLIGHTS
    VALUES('DL', 1213, '2017-12-03', 669.94, 'USD', 385, 200, 52, 50, ((50*1.5 + 200)*669.94), 17);
   
INSERT INTO SCHEDULES
    VALUES('DL', 1215, 'US', 'NEW YORK', 'JFK', '12:00:00', 'US', 'SAN FRANSISCO', 'SFO', '15:03:00', 182, 2679);
   
INSERT INTO SCHEDULES
    VALUES('DL', 1211, 'IT', 'ROME', 'FCO', '19:05:00', 'DE', 'FRANKFURT', 'FRA', '21:05:00', 125, 845);
 
INSERT INTO SCHEDULES
    VALUES('DL', 1212, 'US', 'SAN FRANSISCO', 'SFO', '12:02:00', 'US', 'NEW YORK', 'JFK', '15:03:00', 182, 2679);
   
INSERT INTO SCHEDULES
    VALUES('DL', 1213, 'DE', 'FRANKFURT', 'FRA', '19:02:00', 'IT', 'ROME', 'FCO', '21:05:00', 125, 845);

SELECT * FROM v_info_about_airlines_company