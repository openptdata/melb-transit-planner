#!/bin/bash  
rm -Rf out/
mkdir out/

cp agency.txt out/

sqlite3 ptv-gtfs.db <<!
.headers on
.mode csv
.output out/stops.txt
select * from stops; 
!

sqlite3 ptv-gtfs.db <<!
.headers on
.mode csv
.output out/stop_times.txt
select * from stop_times; 
!

sqlite3 ptv-gtfs.db <<!
.headers on
.mode csv
.output out/calendar.txt
select * from calendar; 
!

sqlite3 ptv-gtfs.db <<!
.headers on
.mode csv
.output out/trips.txt
select * from trips; 
!

sqlite3 ptv-gtfs.db <<!
.headers on
.mode csv
.output out/routes.txt
select * from routes; 
!

cd out
zip ptv-gtfs.zip *.txt 