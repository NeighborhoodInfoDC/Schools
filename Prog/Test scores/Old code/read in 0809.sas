/**************************************************************************
 Program:  read in 0809.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/05/2010
 UPDATED:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Translates 0809 schools data from "long" to "wide"; 
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
%let year=0809;

/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
filename dat dde "excel|K:\Metro\PTatian\DCData\Libraries\Schools\Test Scores\UI_ID\[testscore_dcps_pcsb_0809.xls]sheet1! r2c2:r870c14" ;
	data testscore_0809; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			SchoolName			$8.
			UI_ID  				$8.
			Grade 				$8.
			read_num_students	8.
			read_below			8.
			read_bas			8.
			read_prof			8.
			read_adv			8.
			math_num_students	8.
			math_below			8.
			math_bas			8.
			math_prof			8.
			math_adv			8.;

		input
			SchoolName	$		
			UI_ID  		$		
			Grade 		$		
			read_num_students	
			read_below			
			read_bas			
			read_prof			
			read_adv			
			math_num_students	
			math_below			
			math_bas			
			math_prof			
			math_adv;			
			run;

/*create crosswalk including UI_ID, master school name and all 0809 variables*/
data crosswalk0809;
	set gen.Master_school_newgeo_082010;
	keep UI_ID master_school_name Sch_2008_address Sch_2008_zip 
		 DCPS addr_var_2008 anc2002_2008 cluster2000_2008 
		 cluster_tr2000_2008 geo2000_2008 geoblk2000_2008 psa2004_2008 
		 ward2002_2008 zip_match_2008 dcg_num_parcels_0809 x_coord_2008 y_coord_2008
		 ssl_2008 UNITNUMBER_2008 dcg_match_score_2008; 
	run;
	proc sort data = crosswalk0809;
		by UI_ID;
		run;
/*sort testscore data*/
	proc sort data = testscore_0809;
		by UI_ID;
		run;
/*merge testscore data and crosswalk, label all variables*/
	data dcd.testscore_0809;
		merge crosswalk0809 testscore_0809 (in = a); 
		by UI_ID;
		if a; 
		run; 
%macro grade_sep;
		%do i=3 %to 10;
			 %if &i. ne 9 %then %do;
				data testscore_0809_&i. 
				(keep = UI_ID read_num_students_&i._&year. read_below_&i._&year. 
					read_bas_&i._&year. read_prof_&i._&year.  read_adv_&i._&year. math_num_students_&i._&year. 	math_below_&i._&year.		
						math_bas_&i._&year. math_prof_&i._&year. math_adv_&i._&year.);	 	
					set dcd.testscore_0809;
					where grade = "&i.";   
						 read_num_students_&i._&year. 	= read_num_students;	
						 read_below_&i._&year.			= read_below;
						 read_bas_&i._&year.			= read_bas;
						 read_prof_&i._&year.			= read_prof;
						 read_adv_&i._&year.			= read_adv;
						 math_num_students_&i._&year.	= math_num_students;
						 math_below_&i._&year.			= math_below;
						 math_bas_&i._&year.			= math_bas;
						 math_prof_&i._&year.			= math_prof;
						 math_adv_&i._&year.			= math_adv;
						 run;
				%end;
		  %end; 
%mend grade_sep; 
%grade_sep;
%macro newvar;
		%do i=3 %to 10;
			 %if &i. ne 9 %then %do;
				data testscore_0809_&i.;
				set testscore_0809_&i.;
					rperc_below_&i._&year. 		= read_below_&i._&year./read_num_students_&i._&year. ;
					rperc_bas_&i._&year.    	= read_bas_&i._&year./read_num_students_&i._&year. ;
				    rperc_prof_&i._&year.   	= read_prof_&i._&year./read_num_students_&i._&year. ;
					rperc_adv_&i._&year.    	= read_adv_&i._&year./read_num_students_&i._&year. ;
					mperc_below_&i._&year. 		= math_below_&i._&year./math_num_students_&i._&year. ;
					mperc_bas_&i._&year.   		= math_bas_&i._&year./math_num_students_&i._&year. ;
				    mperc_prof_&i._&year.  		= math_prof_&i._&year./math_num_students_&i._&year. ;
					mperc_adv_&i._&year.   		= math_adv_&i._&year./math_num_students_&i._&year. ;
					run;
				%end;
			%end;
%mend newvar;
%newvar;
%macro sort;
	%do i=3 %to 10;
		%if i ne 9 %then %do;
			proc sort data=testscore_0809_&i.;
			by UI_ID;
			run;
		%end;
	%end;
%mend sort;
%sort;
data crosswalk_0809_2;
	set Dcd.testscore_0809
	(keep = UI_ID master_school_name Sch_2008_address Sch_2008_zip 
		 DCPS addr_var_2008 anc2002_2008 cluster2000_2008 
		 cluster_tr2000_2008 geo2000_2008 geoblk2000_2008 psa2004_2008 
		 ward2002_2008 zip_match_2008 dcg_num_parcels_0809 x_coord_2008 y_coord_2008
		 ssl_2008 UNITNUMBER_2008 dcg_match_score_2008);
	run;
proc sort data=crosswalk_0809_2 out= crosswalk_0809_2 nodup;
	by UI_ID;
	run;

data dcd.testscore_0809;
	merge crosswalk_0809_2 testscore_0809_3 testscore_0809_4 testscore_0809_5 testscore_0809_6 
			 testscore_0809_7 testscore_0809_8 testscore_0809_10;
	by UI_ID;
	run;

