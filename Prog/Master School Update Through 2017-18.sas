/**************************************************************************
 Program:  Master School Update Through 2017.sas
 Library:  Schools
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  01/15/2019
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Takes most recent master school file and adds 3 newest years
			   of data to bring it up to date as of the 2017-18 school year. 

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

	if school_name = "CLOSED" then status = "CLOSED";

	/* Keeping only the geoblk2000 geo var to add others back on later */
	keep ui_id master_school_name dcps year school_name geoblk2000 aud status; 
run;


/* Use geographic data from 2015/16 file as key for 16/17 and 17/18 */
data school_locations;
	set enroll.Enroll_15_16;
	ui_id_n = ui_id;
	keep ui_id_n x y ;
run;

proc sort data = school_locations; by ui_id_n; run;


/* List closed schools as of 2014 school year */
data closed_schools;
	set Schools_00_14;
	if year = 2014;
	if status = "CLOSED";
	ui_id_n = ui_id+0;
	keep ui_id_n master_school_name dcps status;
run;

proc sort data = closed_schools; by ui_id_n; run;


/*Use Enrollment files for school directory for 2015, 2016 and 2017 */
proc sort data = enroll.Enroll_15_16 
	out = schools_15_16_in (rename = (ui_id=ui_id_n)); 
	by ui_id; 
run;

proc sort data = enroll.Enroll_16_17 
	out = schools_16_17_in (rename = (ui_id=ui_id_n)); 
	by ui_id; 
run;

proc sort data = enroll.Enroll_17_18 
	out = schools_17_18_in (rename = (ui_id=ui_id_n)); 
	by ui_id; 
run;

/* Merge on location data */
data schools_15_16;
	merge schools_15_16_in (in=a) school_locations (in=b) closed_schools (in=c);
	by ui_id_n;
	if a or c;
	
	year = 2015;
run;

data schools_16_17;
	merge schools_16_17_in (in=a) school_locations (in=b) closed_schools (in=c);
	by ui_id_n;
	if a or c;

	if ui_id_n = 1042000 then do; x = -76.9901 ; y = 38.9024; end;
	if ui_id_n = 1094702 then do; x = -77.0155929 ; y = 38.9203028; end;
	if ui_id_n = 1637436 then do; x = -76.9329012 ; y = 38.9065625; end;
	if ui_id_n = 2108500 then do; x= -77.0283249 ; y = 38.9405892; end;
	if ui_id_n = 2108600 then do; x = -77.0414395 ; y = 38.8981258; end;
	if ui_id_n = 2108700 then do; x = -76.9742016 ; y = 38.8556027; end;
	if ui_id_n = 2108800 then do; x = -76.9986698 ; y = 38.9278646; end;

	if school_name = "BRIDGES PCS" then ui_id_n = 2103300;
	if school_name = "CESAR CHAVEZ PCS FOR PUBLIC POLICY - PARKSIDE MS" then ui_id_n = 2100304;
	if school_name = "DC PREP PCS - ANACOSTIA CAMPUS" then ui_id_n = 2102404;

	year = 2016;
run;

data schools_17_18;
	merge schools_17_18_in (in=a) school_locations (in=b) closed_schools (in=c) ;
	by ui_id_n;
	if a or c;

	if ui_id_n = 1042000 then do; x = -76.9901 ; y = 38.9024; end;
	if ui_id_n = 1094702 then do; x = -77.0155929 ; y = 38.9203028; end;
	if ui_id_n = 1637436 then do; x = -76.9329012 ; y = 38.9065625; end;
	if ui_id_n = 2108500 then do; x= -77.0283249 ; y = 38.9405892; end;
	if ui_id_n = 2108600 then do; x = -77.0414395 ; y = 38.8981258; end;
	if ui_id_n = 2108700 then do; x = -76.9742016 ; y = 38.8556027; end;
	if ui_id_n = 2108800 then do; x = -76.9986698 ; y = 38.9278646; end;
	if ui_id_n = 2108701 then do x = -76.9404947; y = 38.8700043; end;
	if ui_id_n = 2108900 then do; x = -77.0360009 ; y = 38.9260056; end;

	if school_name = "BRIDGES PCS" then ui_id_n = 2103300;
	if school_name = "CESAR CHAVEZ PCS FOR PUBLIC POLICY - PARKSIDE MS" then ui_id_n = 2100304;
	if school_name = "DC PREP PCS - ANACOSTIA CAMPUS" then ui_id_n = 2102404;

	year = 2017;
run;


/* Stack 2015, 2016 and 2017 dataseets */
data schools_15_18;
	set schools_15_16 schools_16_17 schools_17_18;

	if SchoolType = 1 then dcps = 1;
		else if SchoolType = 2 then dcps = 0;

	aud = total;

	ui_id = put(ui_id_n,z7.);
	drop ui_id_n;

	if status = " " then do;
		master_school_name = School_Name;
	end;

run;

proc sort data = schools_15_18; by ui_id; run;


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

	drop school_name;
run;

data schools_15_18_geo;
	set schools_15_18_join;

	geoblk2010 = geoid10;

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

	keep ui_id master_school_name year dcps aud status
		 geoblk2010 Anc2012 bridgepk city cluster2017 Psa2012 stantoncommons Geo2000 Geo2010 VoterPre2012 Ward2012;
run;


/* Combine old and new data together */
data schools_00_18_combined;
	set Schools_00_14_geo schools_15_18_geo;

	label year = "Starting year of school year"
		  geoblk2000 = "Full census block ID (2000): sscccttttttbbbb"
		  GeoBlk2010 = "Full census block ID (2010): sscccttttttbbbb"
		  aud = "Audited Enrollment"
		  status = "School operating status"
	;
run;

proc sort data = schools_00_18_combined;
	by ui_id year;
run;


/* Finalize dataset */
%Finalize_data_set( 
  /** Finalize data set parameters **/
  data=schools_00_18_combined,
  out=msf_base,
  outlib=schools,
  label="Master School File, 2000-2018",
  sortby=ui_id year,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(Updated through the 2017-18 school year),
  /** File info parameters **/
  printobs=10,
  freqvars=dcps year Anc2012 bridgepk city cluster2017 Psa2012 stantoncommons Geo2000 Geo2010 VoterPre2012 Ward2012
);
