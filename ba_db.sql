-- Drop the tables that references other tables first to get rid of constraints. Do it the other way around for creating the tables
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS bapayment;
DROP TABLE IF EXISTS baticket;
DROP TABLE IF EXISTS bacontact;
DROP TABLE IF EXISTS bapassenger;
DROP TABLE IF EXISTS bareservation;
DROP TABLE IF EXISTS baflight;
DROP TABLE IF EXISTS baweeklyschedule;
DROP TABLE IF EXISTS baday;
DROP TABLE IF EXISTS baroute;
DROP TABLE IF EXISTS bacreditcard;
DROP TABLE IF EXISTS baairport;
DROP TABLE IF EXISTS bapassport;
DROP TABLE IF EXISTS bayear;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE baairport (airportcode varchar(3), country varchar(30), name varchar(30), primary key (airportcode));

CREATE TABLE bayear (year integer, factor double, primary key (year));

CREATE TABLE bapassport (passportno integer, name varchar(30), primary key (passportno));

CREATE TABLE baday (id integer, weekday varchar(10), factor double, year integer, primary key (id), foreign key (year) references bayear(year));

CREATE TABLE baroute (id integer, year integer, price double, cityofDep varchar(3), cityofArr varchar(3), primary key (id, year), foreign key (cityofDep) references baairport(airportcode), foreign key (cityofArr) references baairport(airportcode));

CREATE TABLE baweeklyschedule (id integer, departuretime time, route integer, day integer, primary key (id), foreign key (route) references baroute(id), foreign key (day) references baday(id));

CREATE TABLE baflight (flightno integer, week integer, bookedseats integer DEFAULT 0, weeklyflight integer, primary key (flightno), foreign key(weeklyflight) references baweeklyschedule(id));

CREATE TABLE bareservation (reservationno integer, nrofseats integer, flight integer, contact integer, payment integer, primary key (reservationno), foreign key (flight) references baflight(flightno));

CREATE TABLE bapassenger (passportno integer, reservationno integer, ticket integer, primary key(passportno, reservationno), foreign key (passportno) references bapassport(passportno), foreign key (reservationno) references bareservation(reservationno));

CREATE TABLE bacontact (passportno integer, phoneno BIGINT, email varchar(30), primary key (passportno), foreign key (passportno) references bapassenger(passportno));

ALTER TABLE bareservation ADD CONSTRAINT fk_res_cont foreign key (contact) references bacontact (passportno);

CREATE TABLE baticket (ticketno integer, passenger integer, reservationno integer, primary key (ticketno), foreign key (reservationno) references bareservation(reservationno), foreign key (passenger) references bapassenger(passportno));

ALTER TABLE bapassenger ADD CONSTRAINT fk_passenger_ticket foreign key (ticket) references baticket (ticketno);

CREATE TABLE bacreditcard (cardnumber BIGINT, name VARCHAR(30), primary key (cardnumber));

CREATE TABLE bapayment (id integer, totalprice double, creditcard BIGINT, booking integer, primary key (id), foreign key (creditcard) references bacreditcard(cardnumber), foreign key (booking) references bareservation(reservationno));

ALTER TABLE bareservation ADD CONSTRAINT fk_res_payment foreign key (payment) references bapayment(id);
