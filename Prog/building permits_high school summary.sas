/**************************************************************************
 Program:  building permits_high school summary
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  5/9/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( Schools )
%DCData_lib( Mar)
%DCData_lib (Realprop)
%DCData_lib (DCRA)

proc mapimport out=seniorhigh_map
  datafile="L:\Libraries\Schools\Maps\CURRENT\School_Attendance_Zones_Senior_High.shp";  
run;

proc sort data=seniorhigh_map; by OBJECTID;
run;

goptions reset=global border;

/*not working: says missing lat and lon variable
proc gproject 
 data = Realprop.Sales_res_clean
 LATLON
 out= work.Sales_res_clean_xy; 
  id ssl;
run;
*/
data newconstruction;
set DCRA.Building_Permits_in_2017 (drop=objectid);
if (PERMIT_SUB="NEW BUILDING") and (PERMIT_TYP="CONSTRUCTION");
rename LATITUDE=y;
rename LONGITUDE=x;
run;

proc ginside includeborder
  data=work.newconstruction
  map=seniorhigh_map
  out=seniorhigh_map_join;
  id OBJECTID;
run;

proc freq data = seniorhigh_map_join;
	tables OBJECTID;
run;

proc export data=DCRA.Building_Permits_in_2017
   outfile='L:\Libraries\Schools\Raw\ODCA demand factor\buildingpermits.csv'
   dbms=csv
   replace;
run;
