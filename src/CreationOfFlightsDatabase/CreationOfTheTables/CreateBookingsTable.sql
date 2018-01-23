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