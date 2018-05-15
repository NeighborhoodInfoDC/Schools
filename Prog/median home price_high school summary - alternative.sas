/**************************************************************************
 Program:  median home price_high school summary
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

proc import datafile="L:\Libraries\Schools\Raw\block_high_school_crosswalk.csv" out=work.crosswalk
dbms=csv replace;
run;

data crosswalk;
set crosswalk(rename=(geoblk2010=geoblk2010num));
geoblk2010 = put(geoblk2010num, 7.);
drop DOBnum;
run;

proc sort data=crosswalk;
by geoblk2010;
run;


/*
proc sort data = Realprop.Sales_res_clean;
by geoblk2010;
run;
*/
proc sort data=Realprop.Sales_res_clean;
by geoblk2010;
run;
data combined;
merge Realprop.Sales_res_clean crosswalk;
by geoblk2010;
run;

proc means median data = combined; 
by seniorhigh;
var saleprice;
output out=medianhomesale_seniorhigh;
run;

proc export data=medianhomesale_seniorhigh
   outfile='L:\Libraries\Schools\Raw\ODCA demand factor\medianhomesale.csv'
   dbms=csv
   replace;
run;
