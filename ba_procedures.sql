DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;
delimiter //
CREATE PROCEDURE addYear (IN year INT, IN factor DOUBLE)
BEGIN
INSERT INTO bayear VALUES (year, factor);
END
//
delimiter ;

delimiter //
CREATE PROCEDURE addDay (IN year INT, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
INSERT INTO baday(weekday, factor, year) VALUES (day, factor, year);
END
//
delimiter ;

delimiter //
CREATE PROCEDURE addDestination (IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
INSERT INTO baairport VALUES (airport_code, name, country);
END
//
delimiter ;

delimiter //
CREATE PROCEDURE addRoute (IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT, IN routeprice DOUBLE)
BEGIN
DECLARE route_id INT;
SELECT baroute.id INTO route_id FROM baroute WHERE baroute.cityofArr = arrival_airport_code AND baroute.cityofDep = departure_airport_code;

IF (route_id IS NULL) THEN
SELECT MAX(baroute.id) INTO route_id FROM baroute;
SET route_id = route_id+1;
IF (route_id IS NULL) THEN
SET route_id = 0;
END IF;
END IF;
INSERT INTO baroute VALUES (route_id, year, routeprice, departure_airport_code, arrival_airport_code);

END
//
delimiter ;

delimiter //
CREATE PROCEDURE addFlight (IN departure_airport_code varchar(3), IN arrival_airport_code varchar(3), IN year INT, IN day VARCHAR(10), IN departure_time TIME)
BEGIN
DECLARE day_id INT;
DECLARE weekly_flight INT;
DECLARE week INT;
DECLARE route INT;
SET week = 1;

SELECT baday.id INTO day_id FROM baday, bayear WHERE baday.weekday = day AND baday.year = bayear.year AND bayear.year = year;

SELECT baroute.id INTO route FROM baroute WHERE baroute.cityofDep = departure_airport_code AND baroute.cityofArr = arrival_airport_code AND baroute.year = year;

INSERT INTO baweeklyschedule(departuretime, route, day) VALUES (departure_time, route, day_id);

SELECT baweeklyschedule.id INTO weekly_flight FROM baweeklyschedule WHERE baweeklyschedule.day = day_id AND baweeklyschedule.route = route AND baweeklyschedule.departuretime = departure_time;


WHILE (week <= 52) DO 
INSERT INTO baflight(week, weeklyflight) VALUES(week, weekly_flight);
SET week = week + 1;
END WHILE;

END
//

CREATE FUNCTION calculateFreeSeats(flightnumber INT) RETURNS INT
BEGIN
DECLARE seats INT;
SELECT baflight.bookedseats INTO seats FROM baflight WHERE baflight.flightno = flightnumber;
RETURN 40 - seats;
END
//


CREATE FUNCTION calculatePrice(flightnumber INT) RETURNS DOUBLE
BEGIN
DECLARE routeprice DOUBLE;
DECLARE weekdayfactor DOUBLE;
DECLARE bookedpassengers INT;
DECLARE profitfactor DOUBLE;

SET bookedpassengers = 40 - calculateFreeSeats(flightnumber);

SELECT baroute.price INTO routeprice FROM baroute, baweeklyschedule, baflight,baday WHERE baflight.flightno = flightnumber AND baflight.weeklyflight = baweeklyschedule.id AND baweeklyschedule.day=baday.id AND baday.year = baroute.year AND  baroute.id = baweeklyschedule.route;

SELECT baday.factor INTO weekdayfactor FROM baday, baweeklyschedule, baflight WHERE baflight.flightno = flightnumber AND baflight.weeklyflight = baweeklyschedule.id AND baday.id = baweeklyschedule.day;

SELECT bayear.factor INTO profitfactor FROM bayear, baday, baweeklyschedule, baflight WHERE baflight.flightno = flightnumber AND baflight.weeklyflight = baweeklyschedule.id AND baday.id = baweeklyschedule.day AND baday.year = bayear.year;

RETURN routeprice*weekdayfactor*(bookedpassengers+1)*profitfactor/40;

END
//
delimiter ;
