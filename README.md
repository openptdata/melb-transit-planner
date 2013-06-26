melb-transit-planner
====================

This project's goal is to provide an open journey planner for Victoria.

The project consists initially of some ruby code that is used to convert the propreierty formated public transport timetables into the GTFS standard. 

The GTFS output can then be feed into tools such as the Open Trip Planner (OTP) software. 

A website has been setup to run the OTP software with a current version of the timetables at http://melbourne.openptdata.org. 

The API at this site can also be used to develop against. The API endpoint being http://melbourne.openptdata.org/opentripplanner-api-webapp/ws/plan and documentation for the API can be found here http://opentripplanner.org/apidoc/0.9.2/resource_Planner.html#path__plan.html (or you can explore the API calls made by the website).

Happy to take feature requests and pull requests on the code. 

The next additions to the project are planned to be:

* smooth path lines between stops (using something like http://bmander.com/makeshapes/)
* document how to access timetable data (iPhone backup extract)
* integrate bike sharing info (stop location and real time availability)
* wheelchair information
* Android app

Any direct enquires can be sent to openptdata@gmail.com


