#!/usr/bin/env  rvm 1.9.3-p327 do ruby
require 'rubygems'
require 'sqlite3'

begin
      
    transport_type = ARGV[0].downcase
    transport_type_id = ARGV[1]
    transport_type_color = "#{ARGV[2]}"
      
    puts "Writing transport type #{transport_type}"         
    monfri_trips = {}
    
    in_db = SQLite3::Database.open "Metlink-#{ARGV[0]}.sql"
    out_db = SQLite3::Database.open "ptv-gtfs.db"
    
    stm = in_db.prepare "SELECT * FROM #{transport_type}_lines" 
    rs = stm.execute 
                
    trip_id = 0
    rs.each do |row|
        puts row.join "\s"  
    
        out_db.execute "INSERT INTO routes VALUES(#{row[0]}, 1, '', '#{row[1]}',#{transport_type_id}, '#{transport_type_color}')" 
    end 
    
    #CREATE TABLE #{transport_type}_locations(location_id integer primary key,location_name varchar,suburb varchar,latitude real,longitude real,key_id varchar, sec_id varchar, ter_id varchar,lines varchar);
    stm_loc = in_db.prepare "SELECT * FROM #{transport_type}_locations" 
    rs_loc = stm_loc.execute 
    
    rs_loc.each do |row|
        puts row.join "\s"  

        unless row[3].eql? ''  
          stop_name = row[1].gsub("'", "''")           
           
          begin 
            rows = out_db.execute "select * from stops where stop_id = '#{row[0]}'" 
            
            if rows.length == 0
              #puts "INSERT INTO stops VALUES(#{row[0]},'#{stop_name}', #{row[3]},#{row[4]})"  
              out_db.execute "INSERT INTO stops VALUES(#{row[0]},'#{stop_name}', #{row[3]},#{row[4]})" 
            else
              puts "stop already recorded #{stop_name}"
            end
          
          rescue SQLite3::Exception => es
              puts "Exception occured inserting stops #{es.inspect} - #{row[0]}"
          end
        end
    end
         
    #CREATE TABLE #{transport_type}_stops_monfri(line_id integer,stop_id integer,run_id integer,time integer,destination integer,num_skipped integer, direction varchar, flags varchar);
    stops_sql = "select * from #{transport_type}_stops_monfri order by run_id" 
    
    # tram timetable has mon-thurs, fri, sat, and sun timetables
    if transport_type.eql? "tram"
      stops_sql = "select * from #{transport_type}_stops_monthur order by run_id"
    end   
    
    stm_monfri = in_db.prepare stops_sql
    
    rs_monfri = stm_monfri.execute 
                                
    sequence = 1 
    current_run_id = -1  
    previous_departure_time = -1 
    midnight_rollover = false
    
    rs_monfri.each do |row|
        #puts row.join "\s"  
        
        new_run_id = "1#{transport_type_id}#{row[2]}".to_i
         
        if current_run_id.eql? new_run_id 
          
          sequence = sequence + 1
        
          # still the same trip, check if the time has rolled over midnight
          if row[3] < previous_departure_time
            puts "Midnight rollover detected"
            
            midnight_rollover = true
            
          end
        else               
          # new trip      
          #puts "INSERT INTO trips(trip_id, service_id, route_id) VALUES (#{new_run_id}, 1, #{row[0]})"  
          out_db.execute "INSERT INTO trips(trip_id, service_id, route_id) VALUES (#{new_run_id}, 1, #{row[0]})"
          midnight_rollover = false
          sequence = 1;            
          
        end
        current_run_id = new_run_id  
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
 