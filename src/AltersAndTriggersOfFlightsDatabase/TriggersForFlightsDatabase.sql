USE Flights
GO

CREATE TRIGGER trigger_for_insert_and_update_bookings
ON Bookings 
FOR INSERT,UPDATE
AS
BEGIN
   DECLARE @flight_date date;
   DECLARE @order_date date;
   SET @flight_date = (SELECT f.flight_date FROM Flights f 
                       JOIN INSERTED i 
					   ON i.flight_number = f.flight_number);
   SELECT @order_date = i.order_date FROM INSERTED i;

   IF @order_date > @flight_date
      THROW 51000, 'order_date must be before flight_date.', 1
END
GO

CREATE TRIGGER trigger_for_insert_bookings
ON Bookings 
FOR INSERT
AS
BEGIN
    DECLARE @fclass integer;
	DECLARE @flight_number integer;
	DECLARE @price decimal(12, 2);
	DECLARE @occ_econ_cap integer;
	DECLARE @occ_buss_cap integer;
	DECLARE @sum integer;
	SELECT @fclass = i.fclass FROM INSERTED i;
	SELECT @flight_number = i.flight_number FROM INSERTED i;
	SELECT @price = price FROM Flights WHERE flight_number = @flight_number;

	IF @fclass = 0
	   UPDATE Flights
	   SET occ_econ_cap = occ_econ_cap + 1
	   WHERE flight_number = @flight_number;
	ELSE
	   UPDATE Flights
	   SET occ_buss_cap = occ_buss_cap + 1
	   WHERE flight_number = @flight_number;

	SELECT @occ_econ_cap = occ_econ_cap FROM Flights WHERE flight_number = @flight_number;
	SELECT @occ_buss_cap = occ_buss_cap FROM Flights WHERE flight_number = @flight_number;
	SET @sum = @price * @occ_econ_cap + @price * @occ_buss_cap * 1.5;

	UPDATE Flights
	SET paymentsum = @sum
	WHERE flight_number = @flight_number;
END
GO

CREATE TRIGGER trigger_for_delete_bookings
ON Bookings 
FOR DELETE
AS
BEGIN
    DECLARE @fclass integer;
	DECLARE @flight_number integer;
	DECLARE @price decimal(12, 2);
	DECLARE @occ_econ_cap integer;
	DECLARE @occ_buss_cap integer;
	DECLARE @sum integer;
	SELECT @fclass = d.fclass FROM DELETED d;
	SELECT @flight_number = d.flight_number FROM DELETED d;
	SELECT @price = price FROM Flights WHERE flight_number = @flight_number;

	IF @fclass = 0
	   UPDATE Flights
	   SET occ_econ_cap = occ_econ_cap - 1
	   WHERE flight_number = @flight_number;
	ELSE
	   UPDATE Flights
	   SET occ_buss_cap = occ_buss_cap - 1
	   WHERE flight_number = @flight_number;

	SELECT @occ_econ_cap = occ_econ_cap FROM Flights WHERE flight_number = @flight_number;
	SELECT @occ_buss_cap = occ_buss_cap FROM Flights WHERE flight_number = @flight_number;
	SET @sum = @price * @occ_econ_cap + @price * @occ_buss_cap * 1.5;

	UPDATE Flights
	SET paymentsum = @sum
	WHERE flight_number = @flight_number;
END
GO
-- Tests for the first trigger that verifies order_date is before flight_date
INSERT INTO Bookings
VALUES ('AA', 1000, 201, 4020, '2012-05-20', 'Petar Petkov', 1);
GO

INSERT INTO Bookings
VALUES ('AA', 1000, 201, 4020, '2012-05-24', 'Petar Petkov', 1);
GO

DELETE FROM Bookings
WHERE booking_number = 201;
GO

SELECT occ_buss_cap, max_buss_cap, paymentsum
FROM Flights
WHERE flight_number = 1000;
GO

-- Tests for the second trigger for inserting values
INSERT INTO Bookings
VALUES ('AA', 1000, 201, 4030, '2012-04-18', 'Ivan Petkov', 1);
GO

INSERT INTO Bookings
VALUES ('AA', 1000, 202, 4030, '2012-04-18', 'Ivan Georgiev', 0);
GO

-- Tests for the second trigger for deleting values
DELETE FROM Bookings
WHERE booking_number = 201;
GO

DELETE FROM Bookings
WHERE booking_number = 202;
GO

SELECT occ_econ_cap, max_econ_cap, occ_buss_cap, max_buss_cap, paymentsum
FROM Flights
WHERE flight_number = 1000;
GO

-- Views
CREATE VIEW v_Flights_Schedule AS
  SELECT 
    a.name,
	f.flight_number ,
	f.flight_date,
	f.price,
	s.dept_country,
	s.dept_city
  FROM 
    Airlines a
  INNER JOIN 
    Flights f ON (f.airline_code = a.code)
  INNER JOIN
    Schedules s ON (s.flight_number = f.flight_number)
GO

CREATE VIEW v_Company_Paymentsum AS
  SELECT
    a.name,
	COUNT(DISTINCT f.flight_number) as flights_which_have_reservations,
	SUM(f.paymentsum) as sum_of_all_paymentsums
  FROM 
    Airlines a
  INNER JOIN 
    Flights f ON (f.airline_code = a.code)
  WHERE
    f.occ_econ_cap > 0 AND f.occ_buss_cap > 0
  GROUP BY
    a.name
GO

-- Test for the first view
SELECT * FROM v_Flights_Schedule

-- Test for the second view
SELECT * FROM v_Company_Paymentsum