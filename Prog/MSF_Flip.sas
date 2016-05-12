
/**************************************************************************
 Program:  MSF_Flip.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   G. MacDonald
 Created:  10/30/2013
 Version:  SAS 9.2
 Environment:  Windows
 
 Description:  Flip the column-wide master school file into a DB-like format
	where each row is a unique school-year combination.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
libname nmast "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file\14_15_data";

%macro flip;
	
	%let startyr = 2001;
	%let endyr = 2014;

	%let stay_vars = ui_id master_school_name dcps /*pubc*/;

	%let flip_vars_pt1 = school_name_!sch_!geoblk2000_!geo2000_!geo2010_!cluster2000_!cluster_tr2000_!anc2002_!anc2012_!psa2004_!psa2012_!ward2002_!ward2012_!zip_!eor_!city_!notes_!x_coord_!y_coord_!grade_min_!grade_max_!adult_flag_!open_!aud_;

	%let flip_vars_pt2 = x!x_address!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x;

	%let num_stay_vars = %sysfunc(countw(&stay_vars.));

	%let num_flip_vars = %sysfunc(countw(&flip_vars_pt1.));

	%do i = &startyr. %to &endyr.;

		data temp_&i.;
			length year 8. /*sch_zip_new 8.*/ school_name_new $256. sch_address_new $256.;
			set nmast.msf0014_public_enroll;
			keep 
				ui_id year /*sch_zip_new*/ school_name_new sch_address_new 
				%do j = 1 %to &num_flip_vars.;
					%let q = %scan(&flip_vars_pt1.,&j.,"!");
					%let r = %scan(&flip_vars_pt2.,&j.,"!");
					%let t = %sysfunc(tranwrd(&r.,%str(x),%str()));
					%let s = &q.&i.&t.;
					&s. 
				%end;
			;
			rename
				%do j = 1 %to &num_flip_vars.;
					%let q = %scan(&flip_vars_pt1.,&j.,"!");
					%let r = %scan(&flip_vars_pt2.,&j.,"!");
					%let u = %sysfunc(tranwrd(&r.,%str(x),%str()));
					%let s = %substr(&q.,1,%eval(%length(&q.) - 1));
					%let t = &s.&u.;
					&q.&i.&u. = &t. 
				%end;
			;
			year = &i.;
		run;

		data temp_&i.;
			set temp_&i.;
			/*sch_zip_new = sch_zip;*/
			school_name_new = school_name;
			sch_address_new = sch_address;
			drop /*sch_zip*/ school_name sch_address;
			rename /*sch_zip_new = sch_zip*/ school_name_new = school_name sch_address_new = sch_address;
		run;

	%end;

	proc sort data = nmast.msf0014_public_enroll (keep = &stay_vars.) out = stay_vars; by ui_id; run;
		
	data all;
		set
			%do i = &startyr. %to &endyr.;
				temp_&i. 
			%end;
		;
	run;

	proc sort data = all; by ui_id; run;

	data nmast.msf_final_00_14_flip;
		merge stay_vars all;
		by ui_id;
	run;

%mend flip;
%flip;
