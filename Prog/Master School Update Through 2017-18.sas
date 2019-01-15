/**************************************************************************
 Program:  Master School Update Through 2017.sas
 Library:  Schools
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  01/15/2019
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Takes most recent master school file

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Schools )
libname old 'L:\Libraries\Schools\Data\Master school file\14_15_data';
libname enroll 'L:\Libraries\Schools\Data\Enrollment';

/* Use old MSF for data prior to 2014 */
data schools_00_14;
	set old.Msf_final_00_14_flip;

	/* Keeping only the geoblk2000 geo var to add others back on later */
	keep ui_id master_school_name dcps year school_name geoblk2000 aud; 
run;


/*Use Enrollment files for school directory for 2015, 2016 and 2017 */
data schools_15_16;
	set enroll.Enroll_15_16;
	year = 2015;
run;

data schools_16_17;
	set enroll.Enroll_16_17;
	year = 2016;
run;

data schools_17_18;
	set enroll.Enroll_17_18;
	year = 2017;
run;


/* Stack 2015, 2016 and 2017 dataseets */
data schools_15_18;
	set schools_15_16 schools_16_17 schools_17_18;

	if SchoolType = 1 then dcps = 1;
		else if SchoolType = 2 then dcps = 0;

	aud = total;

	ui_id_c = put(ui_id,z7.);
	drop ui_id;

	rename School_Name = master_school_name;

run;


/* Use GInside to geocode X/Y to block */
proc mapimport out=block_shp_in
  datafile="L:\Libraries\OCTO\Maps\Census_Blocks__2010.shp";  
run;

proc sort data=block_shp_in out=block_shp (keep = x y geoid10); 
	by geoid10;
run;

goptions reset=global border;

proc ginside includeborder
  data=schools_15_18
  map=block_shp
  out=schools_15_18_join;
  id geoid10;
run;


/* Use DC Data Macros to convert blocks to standard geos */
data Schools_00_14_geo;
	set Schools_00_14;

	%Block00_to_anc12;
	%Block00_to_bpk;
	%Block00_to_city;
	%Block00_to_cluster17;
	%Block00_to_psa12;
	%Block00_to_stantoncommons;
	%Block00_to_tr00;
	%Block00_to_tr10;
	%Block00_to_vp12;
	%Block00_to_ward12;
run;

data schools_15_18_geo;
	set schools_15_18_join;

	geoblk2010 = geoid10;
	ui_id = ui_id_c;

	%Block10_to_anc12;
	%Block10_to_bpk;
	%Block10_to_city;
	%Block10_to_cluster17;
	%Block10_to_psa12;
	%Block10_to_stantoncommons;
	%Block10_to_tr00;
	%Block10_to_tr10;
	%Block10_to_vp12;
	%Block10_to_ward12;

	keep ui_id master_school_name year dcps aud 
		 geoblk2010 Anc2012 bridgepk city cluster2017 Psa2012 stantoncommons Geo2000 Geo2010 VoterPre2012 Ward2012;
run;


/* Combine old and new data together */
data schools_00_18_combined;
	set Schools_00_14_geo schools_15_18_geo;
run;

proc sort data = schools_00_18_combined;
	by ui_id year;
run;
