#!/usr/bin/env  rvm 1.9.3-p327 do ruby
require 'rubygems'
require 'sqlite3'

begin
             
    monfri_trips = {}
    
    in_db = SQLite3::Database.open "Metlink-Train.sql"
    out_db = SQLite3::Database.open "ptv-gtfs.db"

    
    out_db.execute "drop table if exists calendar"; 
    out_db.execute "CREATE TABLE calendar(service_id INTEGER PRIMARY KEY, monday INTEGER, tuesday INTEGER, wednesday INTEGER, thursday INTEGER, friday INTEGER, saturday INTEGER, sunday INTEGER, start_date TEXT, end_date TEXT)"                                                                                                                    
     
    out_db.execute "INSERT INTO calendar VALUES(1, 1, 1, 1, 1, 1, 0, 0, '20130101', '20131231')" # Weekday
    out_db.execute "INSERT INTO calendar VALUES(2, 0, 0, 0, 0, 0, 1, 0, '20130101', '20131231')" # Saturday
    out_db.execute "INSERT INTO calendar VALUES(3, 0, 0, 0, 0, 0, 0, 1, '20130101', '20131231')" # Sunday

    out_db.execute "drop table if exists routes";
    out_db.execute "CREATE TABLE routes(route_id INTEGER PRIMARY KEY, agency_id INTEGER, route_short_name TEXT, route_long_name TEXT, route_type INTEGER)" 

    out_db.execute "drop table if exists trips";
    out_db.execute "CREATE TABLE trips(trip_id INTEGER PRIMARY KEY, service_id INTEGER, route_id INTEGER)"
                
    stm = in_db.prepare "SELECT * FROM train_lines" 
    rs = stm.execute 
                
    trip_id = 0
    rs.each do |row|
        puts row.join "\s"  
    
        out_db.execute "INSERT INTO routes VALUES(#{row[0]}, 1, '', '#{row[1]}',0)" 
    end 
    
    out_db.execute "drop table if exists stops";
    out_db.execute "CREATE TABLE stops(stop_id INTEGER PRIMARY KEY, stop_name TEXT, stop_lat real, stop_lon real)"
    
    #CREATE TABLE train_locations(location_id integer primary key,location_name varchar,suburb varchar,latitude real,longitude real,key_id varchar, sec_id varchar, ter_id varchar,lines varchar);
    stm_loc = in_db.prepare "SELECT * FROM train_locations" 
    rs_loc = stm_loc.execute 
    
    rs_loc.each do |row|
        puts row.join "\s"  
        #puts "INSERT INTO stops VALUES(#{row[0]},'#{row[1]}', #{row[3]},#{row[4]})" 

        unless row[3].eql? ''
          out_db.execute "INSERT INTO stops VALUES(#{row[0]},'#{row[1]}', #{row[3]},#{row[4]})"  
        end
    end
 
    out_db.execute "drop table if exists stop_times";    
    out_db.execute "CREATE TABLE stop_times(trip_id INTEGER, arrival_time TEXT, departure_time TEXT, stop_id INTEGER, stop_sequence INTEGER)"                                                                                                                                                                                                                                      
         
    #CREATE TABLE train_stops_monfri(line_id integer,stop_id integer,run_id integer,time integer,destination integer,num_skipped integer, direction varchar, flags varchar);
    stm_monfri = in_db.prepare "select * from train_stops_monfri order by run_id" 
    rs_monfri = stm_monfri.execute 
                                
    sequence = 1 
    current_run_id = -1  
    previous_departure_time = -1 
    midnight_rollover = false
    
    rs_monfri.each do |row|
        #puts row.join "\s"
        if current_run_id.eql? row[2]  
          
          sequence = sequence + 1
        
          # still the same trip, check if the time has rolled over midnight
          if row[3] < previous_departure_time
            puts "Midnight rollover detected"
            
            midnight_rollover = true
            
          end
        else               
          # new trip 
          out_db.execute "INSERT INTO trips(trip_id, service_id, route_id) VALUES (#{row[2]}, 1, #{row[0]})"
          midnight_rollover = false
          sequence = 1;            
          
        end
        current_run_id = row[2]   
        t =  row[3]      
        previous_departure_time = t # save a copy for later
        mm, ss = t.divmod(60)            #=> [4515, 21]
        hh, mm = mm.divmod(60)           #=> [75, 15]
        dd, hh = hh.divmod(24)           #=> [3, 3]  
        
        if midnight_rollover
          hh = hh + 24
        end
        
        time = "%02d:%02d:%02d" % [hh, mm, ss]
             
        stop_times_insert = "INSERT INTO stop_times(trip_id, arrival_time, departure_time, stop_id, stop_sequence) VALUES(#{current_run_id},'#{time}', '#{time}','#{row[1]}', #{sequence})" 
    
        #puts stop_times_insert
        
        out_db.execute stop_times_insert
    
    end         
         
           
rescue SQLite3::Exception => e 
    
    puts "Exception occured #{e.inspect}"
    puts e.backtrace.join("\n")
    
ensure
    stm.close if stm 
    stm_loc.close if stm_loc 
    stm_monfri.close if stm_monfri
    in_db.close if in_db 
    out_db.close if out_db 
end  
 