#!/bin/bash                 
./create_tables.rb
./convert_transport.rb Tram 0 75C944  
./convert_transport.rb Train 1 407AC6
./convert_transport.rb VLine 2 8C3F91  
./convert_transport.rb Bus 3 F88D32
./export.sh