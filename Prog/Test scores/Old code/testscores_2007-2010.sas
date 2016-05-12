/**************************************************************************
 Program:  read in 0809.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/05/2010
 UPDATED:  03/22/2011 For different OSSE cut of all years
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Translates OSSE testscore data from "long" to "wide"; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/

%let filepath = K:\Metro\PTatian\DCData\Libraries\Schools\Raw\TestScores\UI_ID;

libname msf "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file";
libname dcd "&filepath.";


***** NOTE - all years refer to the SPRING of that school year. EG: 2008 means SY 2007-2008;

%macro testscores (year=,row=);
%let geoyear = %eval(&year.-1);
/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
filename dat dde "excel|&filepath.\[Testscores_UI_ID_2007-2010.xls]&year.! r2c2:r&row.c23" ;
	data testscore_&year.; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			UI_ID  				$8.
			DCPS				$8.
			SchoolName_&year.			$8.
			Grade_&year. 				$8.
			read_num_&year.			8.
			read_bb_&year.			8.
			read_b_&year.			8.
			read_p_&year.			8.
			read_adv_&year.			8.
			read_bb_perc_&year.		8.
			read_b_perc_&year.			8.
			read_p_perc_&year.			8.
			read_adv_perc_&year.		8.
			math_num_&year.			8.
			math_bb_&year.			8.
			math_b_&year.			8.
			math_p_&year.			8.
			math_adv_&year.			8.
			math_bb_perc_&year.		8.
			math_b_perc_&year.			8.
			math_p_perc_&year.			8.
			math_adv_perc_&year.		8.
;

		input
			
			UI_ID  		$		
			DCPS			$
			SchoolName_&year.	$	
			Grade 		$	
			read_num_&year.		
			read_bb_&year.		
			read_b_&year.		
			read_p_&year.		
			read_adv_&year.		
			read_bb_perc_&year.	
			read_b_perc_&year.		
			read_p_perc_&year.		
			read_adv_perc_&year.
			math_num_&year.		
			math_bb_&year.		
			math_b_&year.		
			math_p_&year.		
			math_adv_&year.		
			math_bb_perc_&year.	
			math_b_perc_&year.		
			math_p_perc_&year.		
			math_adv_perc_&year.	
		;
run;

/*create crosswalk including UI_ID, master school name and all 0809 variables*/
data crosswalk&year.;
	set msf.Master_school_file_final_082010;
	keep UI_ID master_school_name Sch_&geoyear._address Sch_&geoyear._zip 
		 DCPS addr_var_&geoyear. anc2002_&geoyear. cluster2000_&geoyear. 
		 cluster_tr2000_&geoyear. geo2000_&geoyear. geoblk2000_&geoyear. psa2004_&geoyear. 
		 ward2002_&geoyear. zip_match_&geoyear. dcg_num_parcels_0809 x_coord_&geoyear. y_coord_&geoyear.
		 ssl_&geoyear. UNITNUMBER_&geoyear. dcg_match_score_&geoyear.; 
run;
	proc sort data = crosswalk&year.;
		by UI_ID;
		run;
/*sort testscore data*/
	proc sort data = testscore_&year.;
		by UI_ID;
		run;
/*merge testscore data and crosswalk, label all variables*/
	data /*dcd.*/testscore_&year.;
		merge crosswalk&year. testscore_&year. (in = a); 
		by UI_ID;
		if a; 
		run; 
%macro grade_sep;
		%do i=3 %to 10;
			 %if &i. ne 9 %then %do; 
				data testscore_&year._&i. 
				(keep = UI_ID read_num_&year._&i. read_bb_&year._&i. 
					read_b_&year._&i. read_p_&year._&i.  read_adv_&year._&i. math_num_&year._&i. 	math_bb_&year._&i.		
						math_b_&year._&i. math_p_&year._&i. math_adv_&year._&i. read_bb_perc_&year._&i.		
						 read_b_perc_&year._&i.		
						 read_p_perc_&year._&i.		
						 read_adv_perc_&year._&i.	math_bb_perc_&year._&i.		
						 math_b_perc_&year._&i.		
						 math_p_perc_&year._&i.		
						 math_adv_perc_&year._&i.	);	 	
					set testscore_&year.;
					where grade = "&i.";   
						 read_num_&year._&i. 		= read_num_&year.;	
						 read_bb_&year._&i.			= read_bb_&year.;
						 read_b_&year._&i.			= read_b_&year.;
						 read_p_&year._&i.			= read_p_&year.;
						 read_adv_&year._&i.		= read_adv_&year.;
						 read_bb_perc_&year._&i.		= read_bb_perc_&year.;
						 read_b_perc_&year._&i.		= read_b_perc_&year.;
						 read_p_perc_&year._&i.		= read_p_perc_&year.;
						 read_adv_perc_&year._&i.	= read_adv_perc_&year.;
						 math_num_&year._&i.		= math_num_&year.;
						 math_bb_&year._&i.			= math_bb_&year.;
						 math_b_&year._&i.			= math_b_&year.;
						 math_p_&year._&i.			= math_p_&year.;
						 math_adv_&year._&i.		= math_adv_&year.;
						 math_bb_perc_&year._&i.		= math_bb_perc_&year.;
						 math_b_perc_&year._&i.		= math_b_perc_&year.;
						 math_p_perc_&year._&i.		= math_p_perc_&year.;
						 math_adv_perc_&year._&i.	= math_adv_perc_&year.;

					run;
				%end;
		  %end; 
%mend grade_sep; 
%grade_sep;

%macro sort;
	%do i=3 %to 10;
		%if &i. ne 9 %then %do;
			proc sort data=testscore_&year._&i.;
			by UI_ID;
			run;
		%end;
	%end;
%mend sort;
%sort;

data crosswalk_&year._2;
	set /*Dcd.*/testscore_&year.
	(keep = UI_ID master_school_name Sch_&geoyear._address Sch_&geoyear._zip 
		 DCPS addr_var_&geoyear. anc2002_&geoyear. cluster2000_&geoyear. 
		 cluster_tr2000_&geoyear. geo2000_&geoyear. geoblk2000_&geoyear. psa2004_&geoyear. 
		 ward2002_&geoyear. zip_match_&geoyear. dcg_num_parcels_0809 x_coord_&geoyear. y_coord_&geoyear.
		 ssl_&geoyear. UNITNUMBER_&geoyear. dcg_match_score_&geoyear.);
	run;
proc sort data=crosswalk_&year._2 out= crosswalk_&year._2 nodup;
	by UI_ID;
	run;

%macro merge;
data /*dcd.*/testscore_&year.;
	merge crosswalk_&year._2
		%do i=3 %to 10;
			%if &i. ne 9 %then %do;
				 testscore_&year._&i. 
			%end;
		%end;
	;
	by UI_ID;
run;
%mend merge;
%merge
%mend;
%testscores (year=2007, row=888)
%testscores (year=2008, row=937)
%testscores (year=2009, row=870)
%testscores (year=2010, row=915)
