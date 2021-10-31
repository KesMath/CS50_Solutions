-- Keep a log of any SQL queries you execute as you solve the mystery.

------------------------
-- RELATIONSHIPS BETWEEN TABLES
-- bank_accounts (person_id is foreign key) -> people
-- flights (origin_airport_id is foreign key & destination_airport_id is foreign key) -> airports, airports
-- passengers (flight_id is foreign key) -> flights
------------------------


-- Initial starting point!
SELECT description
FROM   crime_scene_reports
WHERE  street = 'Chamberlin Street'
       AND month = 7
       AND day = 28
       AND year = 2020 ;
------------------------------------------------------------------------
-- RESULTS:
-- Theft of the CS50 duck took place at 10:15am at the Chamberlin Street courthouse.
-- Interviews were conducted today with three witnesses who were present at the time — each of their interview transcripts mentions the courthouse.
-------------------------------------------------------------------------

-- REASONING: this is a listing of all those who entered the courthouse prior to 10:15am on July 28th
-- NOTE: Query has also been sanitized of those who have exited before that time to reduce scope

 SELECT *
FROM   courthouse_security_logs
WHERE  month = 7
       AND day = 28
       AND hour <= 10
       AND activity = 'entrance'
       AND license_plate NOT IN (SELECT license_plate
                                 FROM   courthouse_security_logs
                                 WHERE  month = 7
                                        AND day = 28
                                        AND hour <= 10
                                        AND activity = 'exit'
                                 EXCEPT
                                 SELECT license_plate
                                 FROM   courthouse_security_logs
                                 WHERE  month = 7
                                        AND day = 28
                                        AND hour >= 10
                                        AND minute > 14
                                        AND activity = 'exit')
EXCEPT
SELECT *
FROM   courthouse_security_logs
WHERE  month = 7
       AND day = 28
       AND hour >= 10
       AND minute > 14
       AND activity = 'entrance'
ORDER  BY license_plate;

------------------------------------------------------------------------
-- RESULTS:
--[id, year, month, day, hour, minute, activity, license plate]
--243	2020	7	28	8	42	entrance	0NTHK55
--237	2020	7	28	8	34	entrance	1106N58
--259	2020	7	28	10	14	entrance	13FNH73
--240	2020	7	28	8	36	entrance	322W7JE
--254	2020	7	28	9	14	entrance	4328GD8
--255	2020	7	28	9	15	entrance	5P2BI95
--256	2020	7	28	9	20	entrance	6P58WS2
--232	2020	7	28	8	23	entrance	94KL13X
--257	2020	7	28	9	28	entrance	G412CB7
--231	2020	7	28	8	18	entrance	L93JTIZ
--258	2020	7	28	10	8	entrance	R3G7486
-------------------------------------------------------------------------


-- CONFIRMATION: Confirming all those people left after 10:15am on July 28, 2020

 SELECT *
FROM   courthouse_security_logs
WHERE  license_plate IN (SELECT license_plate
                         FROM   courthouse_security_logs
                         WHERE  month = 7
                                AND day = 28
                                AND hour <= 10
                                AND activity = 'entrance'
                                AND license_plate NOT IN (SELECT license_plate
                                                          FROM
                                    courthouse_security_logs
                                                          WHERE  month = 7
                                                                 AND day = 28
                                                                 AND hour <= 10
                                                                 AND activity =
                                                                     'exit'
                                                          EXCEPT
                                                          SELECT license_plate
                                                          FROM
                                    courthouse_security_logs
                                                          WHERE  month = 7
                                                                 AND day = 28
                                                                 AND hour >= 10
                                                                 AND minute > 14
                                                                 AND activity =
                                                                     'exit')
                         EXCEPT
                         SELECT license_plate
                         FROM   courthouse_security_logs
                         WHERE  month = 7
                                AND day = 28
                                AND hour >= 10
                                AND minute > 14
                                AND activity = 'entrance')
       AND month = 7
       AND day = 28
       AND activity = 'exit'
ORDER  BY license_plate;

------------------------------------------------------------------------
-- CONFIRMATION RESULTS:
--[id, year, month, day, hour, minute, activity, license plate]
--267	2020	7	28	10	23	  exit      0NTHK55
--268	2020	7	28	10	35	  exit      1106N58
--288	2020	7	28	17	15	  exit	    13FNH73
--266	2020	7	28	10	23	  exit	    322W7JE
--263	2020	7	28	10	19	  exit	    4328GD8
--260	2020	7	28	10	16	  exit      5P2BI95
--262	2020	7	28	10	18	  exit      6P58WS2
--261	2020	7	28	10	18	  exit      94KL13X
--264	2020	7	28	10	20	  exit      G412CB7
--265	2020	7	28	10	21	  exit      L93JTIZ
--290	2020	7	28	17	18	  exit	    R3G7486
-------------------------------------------------------------------------