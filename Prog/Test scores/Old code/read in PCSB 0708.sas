/**************************************************************************
 Program:  read in PCSB 0708.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/01/2010
 UPDATED:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Translates 0708 PCSB data from "long" to "wide"; 
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
%let year=0708;

/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
filename dat dde "excel|K:\Metro\PTatian\DCData\Libraries\Schools\Test Scores\UI_ID\[testscore_pcsb_0708.xls]sheet1! r2c3:r275c19" ;
	data testscore_pcsb_0708; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			UI_ID 				$8.
			SchoolName 			$8.
			Grade 				$8.
			read_num_students	8.
			read_mean_scale		8.
			rperc_below			8.
			rperc_bas			8.
			rperc_prof			8.
			rperc_adv			8.
			rperc_met_NCLB		8.
			math_num_students	8.
			math_mean_scale		8.
			mperc_below			8.
			mperc_bas			8.
			mperc_prof			8.
			mperc_adv			8.
			mperc_met_NCLB		8.;
		input
			UI_ID 			$			
			SchoolName 		$ 		
			Grade 			$	
			read_num_students	
			read_mean_scale		
			rperc_below			
			rperc_bas			
			rperc_prof			
			rperc_adv			
			rperc_met_NCLB		
			math_num_students	
			math_mean_scale		
			mperc_below			
			mperc_bas			
			mperc_prof			
			mperc_adv			
			mperc_met_NCLB;
			run;

/*create crosswalk including UI_ID, master school name and all 0708 variables*/
data crosswalk0708;
	set gen.Master_school_newgeo_082010;
	keep UI_ID master_school_name Sch_2007_address Sch_2007_zip 
		 DCPS addr_var_2007 anc2002_2007 cluster2000_2007 
		 cluster_tr2000_2007 geo2000_2007 geoblk2000_2007 psa2004_2007 
		 ward2002_2007 zip_match_2007 dcg_num_parcels_0708 x_coord_2007 y_coord_2007
		 ssl_2007 UNITNUMBER_2007 dcg_match_score_2007; 
	run;
	proc sort data = crosswalk0708;
		by UI_ID;
		run;
/*sort testscore data*/
	proc sort data = testscore_pcsb_0708;
		by UI_ID;
		run;
/*merge testscore data and crosswalk, label all variables*/
	data dcd.testscore_pcsb_0708;
		merge crosswalk0708 testscore_pcsb_0708 (in = a); 
		by UI_ID;
		if a; 
		run; 
%macro grade_sep;
		%do i=3 %to 10;
			 %if &i. ne 9 %then %do;
				data pcsb_0708_&i. 
				(keep = UI_ID read_num_students_&i._&year. rperc_below_&i._&year. 
					rperc_bas_&i._&year. rperc_prof_&i._&year.  rperc_adv_&i._&year.			
						math_num_students_&i._&year. 	mperc_below_&i._&year.		
						mperc_bas_&i._&year. mperc_prof_&i._&year. mperc_adv_&i._&year.);	 	
					set dcd.testscore_pcsb_0708;
					where grade = "&i.";   
						 read_num_students_&i._&year. 	= read_num_students;	
						 read_mean_scale_&i._&year.		= read_mean_scale;
						 rperc_below_&i._&year.			= rperc_below;
						 rperc_bas_&i._&year.			= rperc_bas;
						 rperc_prof_&i._&year.			= rperc_prof;
						 rperc_adv_&i._&year.			= rperc_adv;
						 rperc_met_NCLB_&i._&year.		= rperc_met_NCLB;
						 math_num_students_&i._&year.	= math_num_students;
						 math_mean_scale_&i._&year.		= math_mean_scale;
						 mperc_below_&i._&year.			= mperc_below;
						 mperc_bas_&i._&year.			= mperc_bas;
						 mperc_prof_&i._&year.			= mperc_prof;
						 mperc_adv_&i._&year.			= mperc_adv;
						 mperc_met_NCLB_&i._&year.	 	= mperc_met_nclb;
						 run;
				%end;
		  %end; 
%mend grade_sep; 
%grade_sep;
%macro newvar;
		%do i=3 %to 10;
			 %if &i. ne 9 %then %do;
				data pcsb_0708_&i.;
				set pcsb_0708_&i.;
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
			proc sort data=pcsb_0708_&i.;
			by UI_ID;
			run;
		%end;
	%end;
%mend sort;
%sort;
data crosswalk_0708_2;
	set Dcd.testscore_pcsb_0708
	(keep = UI_ID master_school_name Sch_2007_address Sch_2007_zip 
		 DCPS addr_var_2007 anc2002_2007 cluster2000_2007 
		 cluster_tr2000_2007 geo2000_2007 geoblk2000_2007 psa2004_2007 
		 ward2002_2007 zip_match_2007 dcg_num_parcels_0708 x_coord_2007 y_coord_2007
		 ssl_2007 UNITNUMBER_2007 dcg_match_score_2007);
	run;
proc sort data=crosswalk_0708_2 out= crosswalk_0708_2 nodup;
	by UI_ID;
	run;

data dcd.pcsb_0708_wide;
	merge crosswalk_0708_2 pcsb_0708_3 pcsb_0708_4 pcsb_0708_5 pcsb_0708_6 
			 pcsb_0708_7 pcsb_0708_8 pcsb_0708_10;
	by UI_ID;
	run;

