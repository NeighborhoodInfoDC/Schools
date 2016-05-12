/**************************************************************************
 Program:  read in DCPS 0607.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/02/2010
 UPDATED:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Translates 0607 DCPS data from "long" to "wide"; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/

libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";
libname dcd "D:\DCData\Libraries\schools\Raw";
%let year=0607;

/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
filename dat dde "excel|K:\Metro\PTatian\DCData\Libraries\Schools\Test Scores\UI_ID\[testscore_dcps_0607.xls]sheet1! r2c2:r530c16" ;
	data testscore_dcps_0607; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			UI_ID 					$8.
			SchoolName 				$8.
			Grade 					$8.
			read_num_students		8.
			rperc_below				8.
			rperc_bas				8.
			rperc_prof				8.
			rperc_adv				8.
			math_num_students		8.
			math_mean_scale			8.
			mperc_below				8.
			mperc_bas				8.
			mperc_prof				8.
			mperc_adv				8.
			metDCstandard_math		8.
			metDCstandard_reading 	8.;

		input
			SchoolName 		$
			UI_ID 			$	
			Grade 			$	
			read_num_students
			math_num_students			
			rperc_below			
			rperc_bas			
			rperc_prof			
			rperc_adv					
			mperc_below			
			mperc_bas			
			mperc_prof			
			mperc_adv			
			metDCstandard_math
			metDCstandard_reading;
			run;

/*create crosswalk including UI_ID, master school name and all 0607 variables*/
data crosswalk0607;
	set gen.Master_school_newgeo_082010;
	keep UI_ID master_school_name Sch_2006_address Sch_2006_zip 
		 DCPS addr_var_2006 anc2002_2006 cluster2000_2006 
		 cluster_tr2000_2006 geo2000_2006 geoblk2000_2006 psa2004_2006 
		 ward2002_2006 zip_match_2006 dcg_num_parcels_0607 x_coord_2006 y_coord_2006
		 ssl_2006 UNITNUMBER_2006 dcg_match_score_2006; 
	run;
	proc sort data = crosswalk0607;
		by UI_ID;
		run;
/*sort testscore data*/
	proc sort data = testscore_dcps_0607;
		by UI_ID;
		run;
/*merge testscore data and crosswalk, label all variables*/
	data dcd.testscore_dcps_0607;
		merge crosswalk0607 testscore_dcps_0607 (in = a); 
		by UI_ID;
		if a; 
		run; 
%macro grade_sep;
		%do i=3 %to 10;
			 %if &i. ne 9 %then %do;
				data dcps_0607_&i. 
				(keep = UI_ID read_num_students_&i._&year.  rperc_below_&i._&year. 
					rperc_bas_&i._&year. rperc_prof_&i._&year.  rperc_adv_&i._&year.			
						math_num_students_&i._&year. 	mperc_below_&i._&year.		
						mperc_bas_&i._&year. mperc_prof_&i._&year. mperc_adv_&i._&year.);	 	
					set dcd.testscore_dcps_0607;
					where grade = "&i.";   
						  read_num_students_&i._&year. 		= read_num_students;	
						  rperc_below_&i._&year.			= rperc_below;
						  rperc_bas_&i._&year.				= rperc_bas;
						  rperc_prof_&i._&year.				= rperc_prof;
						  rperc_adv_&i._&year.				= rperc_adv;
						  math_num_students_&i._&year.		= math_num_students;
						  mperc_below_&i._&year.			= mperc_below;
						  mperc_bas_&i._&year.				= mperc_bas;
						  mperc_prof_&i._&year.				= mperc_prof;
						  mperc_adv_&i._&year.				= mperc_adv;				
						 run;
				%end;
		  %end; 
%mend grade_sep; 
%grade_sep;
%macro newvar;
		%do i=3 %to 10;
			 %if &i. ne 9 %then %do;
				data dcps_0607_&i.;
				set dcps_0607_&i.;
					read_below_&i._&year. 	= read_num_students_&i._&year.*(rperc_below_&i._&year./100);
					read_bas_&i._&year.    	= read_num_students_&i._&year.*(rperc_bas_&i._&year./100);
				    read_prof_&i._&year.   	= read_num_students_&i._&year.*(rperc_prof_&i._&year./100);
					read_adv_&i._&year.    	= read_num_students_&i._&year.*(rperc_adv_&i._&year./100);
					math_below_&i._&year. 	= math_num_students_&i._&year.*(mperc_below_&i._&year./100);
					math_bas_&i._&year.   	= math_num_students_&i._&year.*(mperc_bas_&i._&year./100);
				    math_prof_&i._&year.  	= math_num_students_&i._&year.*(mperc_prof_&i._&year./100);
					math_adv_&i._&year.   	= math_num_students_&i._&year.*(mperc_adv_&i._&year./100);
					run;
				%end;
			%end;
%mend newvar;
%newvar;

%macro sort;
	%do i=3 %to 10;
		%if i ne 9 %then %do;
			proc sort data=dcps_0607_&i.;
			by UI_ID;
			run;
		%end;
	%end;
%mend sort;
%sort;
data crosswalk_0607_2;
	set Dcd.testscore_dcps_0607
	(keep = UI_ID master_school_name Sch_2006_address Sch_2006_zip 
		 DCPS addr_var_2006 anc2002_2006 cluster2000_2006 
		 cluster_tr2000_2006 geo2000_2006 geoblk2000_2006 psa2004_2006 
		 ward2002_2006 zip_match_2006 dcg_num_parcels_0607 x_coord_2006 y_coord_2006
		 ssl_2006 UNITNUMBER_2006 dcg_match_score_2006);
	run;
proc sort data=crosswalk_0607_2 out= crosswalk_0607_2 nodup;
	by UI_ID;
	run;

data dcd.dcps_0607_wide;
	merge crosswalk_0607_2 dcps_0607_3 dcps_0607_4 dcps_0607_5 dcps_0607_6 
			 dcps_0607_7 dcps_0607_8 dcps_0607_10;
	by UI_ID;
	run;

