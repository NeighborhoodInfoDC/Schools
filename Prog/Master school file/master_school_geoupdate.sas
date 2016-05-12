/**************************************************************************
 Program:  master_school_geoupdate
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  08/10/2010
 UPDATED:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Updates geocoding for schools with missing addresses in 022010 master school file; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";
libname dcd "D:\DCData\Libraries\schools\Raw";

data schoolsample (keep=
					 DCPS
					 Master_school_name
					 Notes_2008
					 Notes_2009
					 Notes_2010
					 PUBC
					 Sch_2000_address
					 Sch_2000_zip
					 Sch_2001_address
					 Sch_2001_zip
					 Sch_2002_address
					 Sch_2002_zip
					 Sch_2003_address
					 Sch_2003_zip
					 Sch_2004_address
					 Sch_2004_zip
					 Sch_2005_address
					 Sch_2005_zip
					 Sch_2006_address
					 Sch_2006_zip
					 Sch_2007_address
					 Sch_2007_zip
					 Sch_2008_address
					 Sch_2008_zip
					 Sch_2009_address
					 Sch_2009_zip
					 Sch_2010_address
					 Sch_2010_zip
					 School_Name_2008
					 School_Name_2009
					 School_Name_2010
					 School_Number
					 UI_ID
					 addr_var_2000
					 addr_var_2001
					 addr_var_2002
					 addr_var_2003
					 addr_var_2004
					 addr_var_2005
					 addr_var_2006
					 addr_var_2007
					 addr_var_2008
					 addr_var_2009
					 addr_var_2010
					 grade_max_2007
					 grade_max_2008
					 grade_max_2009
					 grade_max_2010
					 grade_min_0708
					 grade_min_2008
					 grade_min_2009
					 grade_min_2010
					 only_0003
					 only_1011
					 only_master);
	set gen.master_school_file_final_082010;
	where 
		UI_ID = "2102400" or 
		UI_ID = "2102401" or
		UI_ID = "1047400" or
		UI_ID = "1095200" or
		UI_ID = "2106202" or
		UI_ID = "2100204" or
		UI_ID = "1026400" or
		UI_ID = "1040800" or
		UI_ID = "3200600" or
		UI_ID = "1056800" or
		UI_ID = "3102302" or
		UI_ID = "3102301" or
		UI_ID = "3101901" or
		UI_ID = "2101200" or
		UI_ID = "2100800" or
		UI_ID = "2100101";
	run;

	** Define libraries **;
/*%DCData_lib( Requests )*/
%DCData_lib( RealProp )  /** Include RealProp library for geocoding tool **/

rsubmit;

** Upload data set to be geocoded (ADDRESSES) to Alpha WORK library **;
  
proc upload status=no
  data=Schoolsample 
  out=Work.Schoolsample;

run;

** Macro to Geocode data set ADDRESSES 2001 - 2009 and save results to Addresses_Geo **;
%macro geofix;
	%do year=2001 %to 2009; 

		%DC_geocode(
		  data=Work.Schoolsample,
		  out=Work.Addresses_geo_&year.,
		  staddr=Sch_&year._address,
		  zip=Sch_&year._zip
		)
		run; 

		proc download status=no
		  	data=Work.Addresses_geo_&year. 
		  	out=Work.Addresses_geo_&year.;
		run;
	%end;
 %mend geofix;
%geofix;
endrsubmit;
signoff;
%macro awesome;
  %do year=2001 %to 2009;
	proc sort data=Addresses_geo_&year.;
		by UI_ID;
	run;

	data Addresses_geo_&year.;
		set Addresses_geo_&year.;
		rename
			anc2002 		= anc2002_&year.
			cluster2000 	= cluster2000_&year.
			cluster_tr2000  = cluster_tr2000_&year.
			geo2000 		= geo2000_&year.
			geoblk2000 		= geoblk2000_&year.
			psa2004 		= psa2004_&year.
			ward2002 		= ward2002_&year.
			x_coord 		= x_coord_&year.
			y_coord 		= y_coord_&year.
			ssl 			= ssl_&year.;
		run;
	data Addresses_geo_&year.;
		set Addresses_geo_&year.;
		label
			anc2002_&year.			= "anc2002_&year."
			cluster2000_&year.		= "cluster2000_&year."
			cluster_tr2000_&year.	= "cluster_tr2000_&year."
			geo2000_&year.			= "geo2000_&year."
			geoblk2000_&year.		= "geoblk2000_&year."
			psa2004_&year.			= "psa2004_&year."
			ward2002_&year.			= "ward2002_&year."
			x_coord_&year.			= "x_coord_&year."
			y_coord_&year.			= "y_coord_&year."
			ssl_&year.				= "ssl_&year.";
		run;
  %end;
%mend awesome;
%awesome;	
data Schoolsample_geo;
	merge
		Addresses_geo_2001 Addresses_geo_2002 Addresses_geo_2003 Addresses_geo_2004 
		Addresses_geo_2005 Addresses_geo_2006 Addresses_geo_2007 Addresses_geo_2008
		Addresses_geo_2009;
	by UI_ID;
run; 
proc sort data=gen.master_school_file_final_082010;
	by UI_ID;
run; 
data master_school_newgeo_082010;
 merge
 	gen.master_school_file_final_082010 Schoolsample_geo;
 by UI_ID;
run;
