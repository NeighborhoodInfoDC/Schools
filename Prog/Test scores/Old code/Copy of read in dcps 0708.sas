/**************************************************************************
 Program:  read in dcps 0708.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   M.Grosz 
 Created:  06/30/10
 UPDATED:  07/20/10 ZM
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: compiles reported files from all available years into one file;
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
%let year = 0708;

/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
filename dat dde "excel|K:\Metro\PTatian\DCData\Libraries\Schools\Test Scores\UI_ID\[testscore_dcps_0708.xls]sheet1! r2c2:r156c122" ;
	data testscore_dcps_0708; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			UI_ID 			$14. 
			osse_schoolname $30. 
			num_students_3_&year.   8.
			read_adv_3_&year.		8.
			read_prof_3_&year.		8.
			read_bas_3_&year.		8.
			read_below_3_&year.		8.
			math_adv_3_&year.		8.
			math_prof_3_&year.		8.
			math_bas_3_&year.		8.
			math_below_3_&year.	    8.
			num_students_4_&year.   8.
			read_adv_4_&year.		8.
			read_prof_4_&year.		8.
			read_bas_4_&year.		8.
			read_below_4_&year.		8.
			math_adv_4_&year.		8.
			math_prof_4_&year.		8.
			math_bas_4_&year.		8.
			math_below_4_&year.		8.
			num_students_5_&year.   8.
			read_adv_5_&year.		8.
			read_prof_5_&year.		8.
			read_bas_5_&year.		8.
			read_below_5_&year.		8.
			math_adv_5_&year.		8.
			math_prof_5_&year.		8.
			math_bas_5_&year.		8.
			math_below_5_&year.		8.
			num_students_6_&year.   8.
			read_adv_6_&year.		8.
			read_prof_6_&year.		8.
			read_bas_6_&year.		8.
			read_below_6_&year.		8.
			math_adv_6_&year.		8.
			math_prof_6_&year.		8.
			math_bas_6_&year.		8.
			math_below_6_&year.		8.
			num_students_7_&year.   8.
			read_adv_7_&year.		8.
			read_prof_7_&year.		8.
			read_bas_7_&year.		8.
			read_below_7_&year.		8.
			math_adv_7_&year.		8.
			math_prof_7_&year.		8.
			math_bas_7_&year.		8.
			math_below_7_&year.		8.
			num_students_8_&year.   8.
			read_adv_8_&year.		8.
			read_prof_8_&year.		8.
			read_bas_8_&year.		8.
			read_below_8_&year.		8.
			math_adv_8_&year.		8.
			math_prof_8_&year.		8.
			math_bas_8_&year.		8.
			math_below_8_&year.		8.
			num_students_10_&year.  8.
			read_adv_10_&year.		8.
			read_prof_10_&year.		8.
			read_bas_10_&year.		8.
			read_below_10_&year.	8.
			math_adv_10_&year.		8.
			math_prof_10_&year.		8.
			math_bas_10_&year.		8.
			math_below_10_&year.	8.
			rperc_adv_3_&year.		8.
			mperc_adv_3_&year.		8.
			rperc_prof_3_&year.		8.
			mperc_prof_3_&year.		8.
			rperc_bas_3_&year.		8.
			mperc_bas_3_&year.		8.
			rperc_below_3_&year.	8.
			mperc_below_3_&year.	8.
			rperc_adv_4_&year.		8.
			mperc_adv_4_&year.		8.
			rperc_prof_4_&year.		8.
			mperc_prof_4_&year.		8.
			rperc_bas_4_&year.		8.
			mperc_bas_4_&year.		8.
			rperc_below_4_&year.	8.
			mperc_below_4_&year.	8.
			rperc_adv_5_&year.		8.
			mperc_adv_5_&year.		8.
			rperc_prof_5_&year.		8.
			mperc_prof_5_&year.		8.
			rperc_bas_5_&year.		8.
			mperc_bas_5_&year.		8.
			rperc_below_5_&year.	8.
			mperc_below_5_&year.	8.
			rperc_adv_6_&year.		8.
			mperc_adv_6_&year.		8.
			rperc_prof_6_&year.		8.
			mperc_prof_6_&year.		8.
			rperc_bas_6_&year.		8.
			mperc_bas_6_&year.		8.
			rperc_below_6_&year.	8.
			mperc_below_6_&year.	8.
			rperc_adv_7_&year.		8.
			mperc_adv_7_&year.		8.
			rperc_prof_7_&year.		8.
			mperc_prof_7_&year.		8.
			rperc_bas_7_&year.		8.
			mperc_bas_7_&year.		8.
			rperc_below_7_&year.	8.
			mperc_below_7_&year.	8.
			rperc_adv_8_&year.		8.
			mperc_adv_8_&year.		8.
			rperc_prof_8_&year.		8.
			mperc_prof_8_&year.		8.
			rperc_bas_8_&year.		8.
			mperc_bas_8_&year.		8.
			rperc_below_8_&year.	8.
			mperc_below_8_&year.	8.
			rperc_adv_10_&year.		8.
			mperc_adv_10_&year.		8.
			rperc_prof_10_&year.	8.
			mperc_prof_10_&year.	8.
			rperc_bas_10_&year.		8.
			mperc_bas_10_&year.		8.
			rperc_below_10_&year.	8.
			mperc_below_10_&year.	8.;
 
		input 		
					UI_ID 			
					osse_schoolname
					num_students_3_&year.
					read_adv_3_&year.		
					read_prof_3_&year.		
					read_bas_3_&year.		
					read_below_3_&year.	
					math_adv_3_&year.		
					math_prof_3_&year.		
					math_bas_3_&year.		
					math_below_3_&year.
					num_students_4_&year.
					read_adv_4_&year.		
					read_prof_4_&year.		
					read_bas_4_&year.		
					read_below_4_&year.	
					math_adv_4_&year.		
					math_prof_4_&year.		
					math_bas_4_&year.		
					math_below_4_&year.	
					num_students_5_&year.
					read_adv_5_&year.		
					read_prof_5_&year.		
					read_bas_5_&year.		
					read_below_5_&year.	
					math_adv_5_&year.		
					math_prof_5_&year.		
					math_bas_5_&year.		
					math_below_5_&year.	
					num_students_6_&year.
					read_adv_6_&year.		
					read_prof_6_&year.		
					read_bas_6_&year.		
					read_below_6_&year.	
					math_adv_6_&year.		
					math_prof_6_&year.		
					math_bas_6_&year.		
					math_below_6_&year.	
					num_students_7_&year.
					read_adv_7_&year.		
					read_prof_7_&year.		
					read_bas_7_&year.		
					read_below_7_&year.	
					math_adv_7_&year.		
					math_prof_7_&year.		
					math_bas_7_&year.		
					math_below_7_&year.	
					num_students_8_&year.
					read_adv_8_&year.		
					read_prof_8_&year.		
					read_bas_8_&year.		
					read_below_8_&year.	
					math_adv_8_&year.		
					math_prof_8_&year.		
					math_bas_8_&year.		
					math_below_8_&year.	
					num_students_10_&year.
					read_adv_10_&year.		
					read_prof_10_&year.	
					read_bas_10_&year.		
					read_below_10_&year.	
					math_adv_10_&year.		
					math_prof_10_&year.	
					math_bas_10_&year.		
					math_below_10_&year.	
					rperc_adv_3_&year.		
					mperc_adv_3_&year.		
					rperc_prof_3_&year.	
					mperc_prof_3_&year.	
					rperc_bas_3_&year.		
					mperc_bas_3_&year.		
					rperc_below_3_&year.	
					mperc_below_3_&year.	
					rperc_adv_4_&year.		
					mperc_adv_4_&year.		
					rperc_prof_4_&year.	
					mperc_prof_4_&year.	
					rperc_bas_4_&year.		
					mperc_bas_4_&year.		
					rperc_below_4_&year.	
					mperc_below_4_&year.	
					rperc_adv_5_&year.		
					mperc_adv_5_&year.		
					rperc_prof_5_&year.	
					mperc_prof_5_&year.	
					rperc_bas_5_&year.		
					mperc_bas_5_&year.		
					rperc_below_5_&year.	
					mperc_below_5_&year.	
					rperc_adv_6_&year.		
					mperc_adv_6_&year.		
					rperc_prof_6_&year.	
					mperc_prof_6_&year.	
					rperc_bas_6_&year.		
					mperc_bas_6_&year.		
					rperc_below_6_&year.	
					mperc_below_6_&year.	
					rperc_adv_7_&year.		
					mperc_adv_7_&year.		
					rperc_prof_7_&year.	
					mperc_prof_7_&year.	
					rperc_bas_7_&year.		
					mperc_bas_7_&year.		
					rperc_below_7_&year.	
					mperc_below_7_&year.	
					rperc_adv_8_&year.		
					mperc_adv_8_&year.		
					rperc_prof_8_&year.	
					mperc_prof_8_&year.	
					rperc_bas_8_&year.		
					mperc_bas_8_&year.		
					rperc_below_8_&year.	
					mperc_below_8_&year.	
					rperc_adv_10_&year.	
					mperc_adv_10_&year.	
					rperc_prof_10_&year.	
					mperc_prof_10_&year.	
					rperc_bas_10_&year.	
					mperc_bas_10_&year.	
					rperc_below_10_&year.
					mperc_below_10_&year.;
		run;
	data testscore_dcps_0708 (drop =
			num_students_3_&year.
			num_students_4_&year.
			num_students_5_&year.
			num_students_6_&year.
			num_students_7_&year.
			num_students_8_&year.
			num_students_10_&year.
			num_students_3_&year.
			num_students_4_&year.
			num_students_5_&year.
			num_students_6_&year.
			num_students_7_&year.
			num_students_8_&year.
			num_students_10_&year.)

;
		set testscore_dcps_0708;
		read_num_students_3_&year. = num_students_3_&year.;
		read_num_students_4_&year. = num_students_4_&year.;
		read_num_students_5_&year. = num_students_5_&year.;
		read_num_students_6_&year. = num_students_6_&year.;
		read_num_students_7_&year. = num_students_7_&year.;
		read_num_students_8_&year. = num_students_8_&year.;
		read_num_students_10_&year.= num_students_10_&year.;
		math_num_students_3_&year. = num_students_3_&year.;
		math_num_students_4_&year. = num_students_4_&year.;
		math_num_students_5_&year. = num_students_5_&year.;
		math_num_students_6_&year. = num_students_6_&year.;
		math_num_students_7_&year. = num_students_7_&year.;
		math_num_students_8_&year. = num_students_8_&year.;
		math_num_students_10_&year. = num_students_10_&year.;
	run;

	proc contents data=testscore_dcps_0708;
	run;
	proc print data=testscore_dcps_0708 (obs=1);
	run;
/*create crosswalk including UI_ID, master school name and all 0708 variables*/
data crosswalk0708;
	set gen.Master_school_newgeo_082010;
	keep UI_ID master_school_name Sch_2007_address Sch_2007_zip 
		 DCPS addr_var_2007 anc2002_2007 cluster2000_2007 
		 cluster_tr2000_2007 geo2000_2007 geoblk2000_2007 psa2004_2007 
		 ward2002_2007 zip_match_2007 dcg_num_parcels_0708 x_coord_2007 y_coord_2007
		 ssl_2007 UNITNUMBER_2007 ui_prototype_2007 dcg_match_score_2007; 
	run;
	proc sort data = crosswalk0708;
		by UI_ID;
		run;
/*sort testscore data*/
	proc sort data = testscore_dcps_0708;
		by UI_ID;
		run;
/*merge testscore data and crosswalk, label all variables*/
	data dcd.testscore_dcps_0708;
		merge crosswalk0708 testscore_dcps_0708 (in = a); 
		by UI_ID;
		if a; 
		label 				
		UI_ID = "Unique School ID";
		run; 
	%macro addmissing; 
		%do i=3 %to 10;
			%if &i. ne 9 %then %do;
				if math_num_students_&i._&year.  = 0 then do;
					read_adv_&i._&year. 	= .;
					read_prof_&i._&year.    = .;
					read_bas_&i._&year.     = .;
					read_below_&i._&year.   = .;
					math_adv_&i._&year.     = .;
					math_prof_&i._&year.    = .;
					math_bas_&i._&year.     = .;
					math_below_&i._&year.   = .;
				end;
			%end;
		%end;
	%mend addmissing;
*replace non-meaningful zeros with ".";
	data dcd.Dcps_0708_wide;
		set dcd.testscore_dcps_0708; 
		%addmissing;
		run;  

