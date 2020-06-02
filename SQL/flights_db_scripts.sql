--1. В каких городах больше одного аэропорта?

SELECT
city ->> 'ru' city, COUNT (airport_code )
FROM airports_data ad 
GROUP BY 1
HAVING COUNT (airport_code ) > 1 ;

--2. В каких аэропортах есть рейсы, которые обслуживаются самолетами с максимальной дальностью перелетов?

SELECT 
DISTINCT f2.departure_airport 
FROM flights f2 
WHERE f2.aircraft_code IN (
	SELECT 
	ad.aircraft_code 
	FROM aircrafts_data ad 
	WHERE ad.range = (SELECT MAX(a.range) FROM aircrafts_data a) ) ;

--3. Были ли брони, по которым не совершались перелеты?По логике БД посадочный талон 

SELECT 
DISTINCT b.book_ref , bp.boarding_no   
FROM bookings b 
LEFT JOIN tickets  USING (book_ref)
LEFT JOIN ticket_flights t USING (ticket_no)
LEFT JOIN boarding_passes bp USING (ticket_no)
WHERE bp.boarding_no  IS NULL;

--4. Самолеты каких моделей совершают наибольший % перелетов?

SELECT 
ad.model ->> 'ru' model,
(ROUND (
		COUNT (*)::real /	
		(SELECT COUNT (*) FROM flights f2 )
		* 100
		) || '%' ) as percent
FROM flights f JOIN aircrafts_data ad USING (aircraft_code)
GROUP BY 1
ORDER BY COUNT (*) DESC;

--5. Были ли города, в которые можно добраться бизнес - классом дешевле, чем эконом-классом?

SELECT
DISTINCT a.flight_no || ' ' || (f.departure_city , f.arrival_city ) route,
a.max_ecn,
b.min_bsn
FROM 
	(
	SELECT 
	fv.flight_no ,
	MAX (t.amount) max_ecn
	FROM flights_v fv 
	JOIN ticket_flights t USING (flight_id)
	GROUP BY 1, t.fare_conditions
	HAVING t.fare_conditions = 'Economy'
	) as a
JOIN 
	(
	SELECT 
	fv.flight_no ,
	MIN (t.amount) min_bsn
	FROM flights_v fv 
	JOIN ticket_flights t USING (flight_id)
	GROUP BY 1, t.fare_conditions
	HAVING t.fare_conditions = 'Business'
	) as b 
	USING (flight_no)
JOIN  flights_v f USING (flight_no)
WHERE a.max_ecn > b.min_bsn
ORDER BY 1;

--Второй вариант запроса короче, но выполняется дольше.

SELECT 
DISTINCT fv.flight_no || ' ' || (fv.departure_city , fv.arrival_city ) route,
MAX (t.amount) FILTER (WHERE t.fare_conditions = 'Economy') OVER (PARTITION BY fv.flight_no) AS max_ecn,
MIN (t.amount) FILTER (WHERE t.fare_conditions = 'Business') OVER (PARTITION BY fv.flight_no) AS min_bsn
FROM flights_v fv 
JOIN ticket_flights t USING (flight_id)
ORDER BY 1;

--6. Узнать максимальное время задержки вылетов самолетов

SELECT 
MAX ( f.actual_departure - f.scheduled_departure ) 
FROM flights f ;

--7. Между какими городами нет прямых рейсов?

SELECT 
combin.dep city_departure, 
combin.arr city_arrival
FROM (
	-- combinations with repeat
	SELECT DISTINCT 
	a.city as dep, 
	b.city as arr 
	FROM airports a 
	CROSS JOIN  airports b
	WHERE a.city <> b.city
	ORDER BY 1
	) as combin 
-- left join will show which couples of cities how many flights have
LEFT JOIN flights_v fv ON (combin.dep = fv.departure_city and combin.arr = fv.arrival_city )
GROUP BY 1, 2
-- filter couples of cities with no direct flights
HAVING COUNT (fv.flight_id ) = 0 
ORDER BY 1;

--8. Между какими городами пассажиры делали пересадки?

SELECT 
a.dep_city,
a.arr_city transfer,
a.next_arr_city
FROM (
	SELECT 
	tf.ticket_no ,
	f.flight_no , 
	a1.city ->> 'ru' dep_city, 
	a2.city ->> 'ru' arr_city,
	f.scheduled_departure , 
	f.scheduled_arrival ,
	LEAD (f.scheduled_departure) OVER (PARTITION BY tf.ticket_no ORDER BY f.scheduled_departure) next_scheduled_departure,
	LEAD (a2.city ->> 'ru' ) OVER (PARTITION BY tf.ticket_no ORDER BY f.scheduled_departure) next_arr_city
	FROM ticket_flights tf 
	JOIN flights f using (flight_id)
	JOIN airports_data a1 ON (f.departure_airport = a1.airport_code )
	JOIN airports_data a2 ON (f.arrival_airport = a2.airport_code)
) AS a
GROUP BY 1,2,3
HAVING MIN(a.next_scheduled_departure - a.scheduled_arrival) < '24:00:00';

--9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов в самолетах, обслуживающих эти рейсы.

WITH route AS (
SELECT 
	DISTINCT f.flight_no , 
	f.departure_airport,  
	f.arrival_airport, 
	ROUND (6372.795 * ACOS(	SIN(a.coordinates[1]*PI()/180)  *
					SIN(b.coordinates[1]*PI()/180) + 
					COS(a.coordinates[1]*PI()/180) *
					COS(b.coordinates[1]*PI()/180) *
					COS(a.coordinates[0]*PI()/180 - b.coordinates[0]*PI()/180)
   							) :: decimal , 3 ) AS distance_km ,
	f.aircraft_code  
	FROM flights f 
	JOIN airports a ON (f.departure_airport = a.airport_code) 
	JOIN airports b ON (f.arrival_airport = b.airport_code)
	ORDER BY 1)
SELECT 
route.flight_no ,  
route.departure_airport , 
route.arrival_airport ,
route.distance_km distance_km ,
ad.range aircraft_range_km,
route.distance_km < ad.range IS TRUE  AS "check"
FROM route
JOIN aircrafts_data ad ON (route.aircraft_code = ad.aircraft_code )
ORDER BY 1;
 
