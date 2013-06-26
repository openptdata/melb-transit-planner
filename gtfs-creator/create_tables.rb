#!/usr/bin/env  rvm 1.9.3-p327 do ruby
require 'rubygems'
require 'sqlite3'

   out_db = SQLite3::Database.open "ptv-gtfs.db"  
   
   out_db.execute "drop table if exists calendar"; 
   out_db.execute "CREATE TABLE calendar(service_id INTEGER PRIMARY KEY, monday INTEGER, tuesday INTEGER, wednesday INTEGER, thursday INTEGER, friday INTEGER, saturday INTEGER, sunday INTEGER, start_date TEXT, end_date TEXT)"                                                                                                                    
            
   out_db.execute "INSERT INTO calendar VALUES(1, 1, 1, 1, 1, 1, 0, 0, '20130101', '20131231')" # Weekday
   out_db.execute "INSERT INTO calendar VALUES(2, 0, 0, 0, 0, 0, 1, 0, '20130101', '20131231')" # Saturday
   out_db.execute "INSERT INTO calendar VALUES(3, 0, 0, 0, 0, 0, 0, 1, '20130101', '20131231')" # Sunday
   
   out_db.execute "drop table if exists routes";
   out_db.execute "CREATE TABLE routes(route_id INTEGER PRIMARY KEY, agency_id INTEGER, route_short_name TEXT, route_long_name TEXT, route_type INTEGER, route_color TEXT)" 

   out_db.execute "drop table if exists trips";
   out_db.execute "CREATE TABLE trips(trip_id INTEGER PRIMARY KEY, service_id INTEGER, route_id INTEGER)"
   
   out_db.execute "drop table if exists stops";
   out_db.execute "CREATE TABLE stops(stop_id INTEGER PRIMARY KEY, stop_name TEXT, stop_lat real, stop_lon real)"
   
   out_db.execute "drop table if exists stop_times";    
   out_db.execute "CREATE TABLE stop_times(trip_id INTEGER, arrival_time TEXT, departure_time TEXT, stop_id INTEGER, stop_sequence INTEGER)"                                                                                                                                                                                                                                      


   