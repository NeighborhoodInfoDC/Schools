/**************************************************************************
 Program:  Testscores_allsch_allyr_totals.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/15/2010
 UPDATED:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Puts all the DC school test scores into one file for checking; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";
libname dcd "D:\DCData\Libraries\schools\Raw";
data PCSB_0809_wide;
	set Testscore_0809;
	where DCPS = "0";
run;
data DCPS_0809_wide;
	set Testscore_0809;
	where DCPS = "1";
run;
data PCSB_testscore_allyr;
	merge 
		dcd.PCSB_0607_wide
		dcd.PCSB_0708_wide
		PCSB_0809_wide;
	by UI_ID;
run;
data DCPS_testscore_allyr;
	merge
		dcd.DCPS_0607_wide
		dcd.DCPS_0708_wide
		DCPS_0809_wide;
	by UI_ID;
run;
%macro totals (type=);
	
	data &type._testscore_totals;
	%let macro_year = 0607 0708 0809;
		%do yr=1 %to 3;
		%let i=%scan(&macro_year, &yr,' ');
	set &type._testscore_allyr;
		&type._total_read_num_&i. = sum(of read_num_students_3_&i. read_num_students_4_&i. read_num_students_5_&i. 
							read_num_students_6_&i. read_num_students_7_&i. read_num_students_8_&i.
							read_num_students_10_&i.);
		label
			&type._total_read_num_&i. = "Total &type. students tested in Reading '&i.'";

		&type._total_math_num_&i. = sum(of math_num_students_3_&i. math_num_students_4_&i. math_num_students_5_&i. 
									math_num_students_6_&i. math_num_students_7_&i. math_num_students_8_&i.
									math_num_students_10_&i.);
		label
			&type._total_math_num_&i. = "Total &type. students tested in math '&i.'";


		&type._pct_read_below_&i. = sum(of read_below_3_&i. read_below_4_&i. read_below_5_&i. 
									read_below_6_&i. read_below_7_&i. read_below_8_&i.
									read_below_10_&i.)/(Total_read_num_&i.);
	
		label
			&type._pct_read_below_&i. = "&type. percent below basic reading level '&i.'";


			&type._pct_read_bas_&i. = sum(of read_bas_3_&i. read_bas_4_&i. read_bas_5_&i. 
									read_bas_6_&i. read_bas_7_&i. read_bas_8_&i.
									read_bas_10_&i.)/(Total_read_num_&i.);
		label
			&type._pct_read_bas_&i. = "&type. percent at basic reading level '&i.'";

			&type._pct_read_prof_&i. = sum(of read_prof_3_&i. read_prof_4_&i. read_prof_5_&i. 
									read_prof_6_&i. read_prof_7_&i. read_prof_8_&i.
									read_prof_10_&i.)/(Total_read_num_&i.);
		label
			&type._pct_read_prof_&i. = "&type. percent at proficient reading level '&i.'";


		
		&type._pct_read_adv_&i. = sum(of read_adv_3_&i. read_adv_4_&i. read_adv_5_&i. 
									read_adv_6_&i. read_adv_7_&i. read_adv_8_&i.
									read_adv_10_&i.)/(Total_read_num_&i.);
		label
			&type._pct_read_adv_&i. = "&type. percent at advanced reading level '&i.'";


		&type._pct_math_below_&i. = sum(of math_below_3_&i. math_below_4_&i. math_below_5_&i. 
									math_below_6_&i. math_below_7_&i. math_below_8_&i.
									math_below_10_&i.)/(Total_math_num_&i.);
		label
			&type._pct_math_below_&i. = "&type. percent at below basic math level '&i.'";


			&type._pct_math_bas_&i. = sum(of math_bas_3_&i. math_bas_4_&i. math_bas_5_&i. 
									math_bas_6_&i. math_bas_7_&i. math_bas_8_&i.
									math_bas_10_&i.)/(total_math_num_&i.);
		label
			&type._pct_math_bas_&i. = "&type. percent at basic math level '&i.'";

			&type._pct_math_prof_&i. = sum(of math_prof_3_&i. math_prof_4_&i. math_prof_5_&i. 
									math_prof_6_&i. math_prof_7_&i. math_prof_8_&i.
									math_prof_10_&i.)/(total_math_num_&i.);
		label
			&type._pct_math_prof_&i. = "&type. percent at proficient math level '&i.'";


		
		&type._pct_math_adv_&i. = sum(of math_adv_3_&i. math_adv_4_&i. math_adv_5_&i. 
									math_adv_6_&i. math_adv_7_&i. math_adv_8_&i.
									math_adv_10_&i.)/(total_math_num_&i.);
		label
			&type._pct_math_adv_&i. = "&type. percent at advanced math level '&i.'";



		&type._tot_read_below_&i. = sum(of read_below_3_&i. read_below_4_&i. read_below_5_&i. 
									read_below_6_&i. read_below_7_&i. read_below_8_&i.
									read_below_10_&i.);
		label
			&type._tot_read_below_&i. = "&type. Total below basic reading level '&i.'";


			&type._tot_read_bas_&i. = sum(of read_bas_3_&i. read_bas_4_&i. read_bas_5_&i. 
									read_bas_6_&i. read_bas_7_&i. read_bas_8_&i.
									read_bas_10_&i.);
		label
			&type._tot_read_bas_&i. = "&type. Total basic reading level '&i.'";

			&type._tot_read_prof_&i. = sum(of read_prof_3_&i. read_prof_4_&i. read_prof_5_&i. 
									read_prof_6_&i. read_prof_7_&i. read_prof_8_&i.
									read_prof_10_&i.);
		label
			&type._tot_read_prof_&i. = "&type. Total proficient reading level '&i.'";


		
		&type._tot_read_adv_&i. = sum(of read_adv_3_&i. read_adv_4_&i. read_adv_5_&i. 
									read_adv_6_&i. read_adv_7_&i. read_adv_8_&i.
									read_adv_10_&i.);
		label
			&type._tot_read_adv_&i. = "&type. Total advanced reading level '&i.'";


		&type._tot_math_below_&i. = sum(of math_below_3_&i. math_below_4_&i. math_below_5_&i. 
									math_below_6_&i. math_below_7_&i. math_below_8_&i.
									math_below_10_&i.);
		label
			&type._tot_math_below_&i. = "&type. Total below basic math level '&i.'";


			&type._tot_math_bas_&i. = sum(of math_bas_3_&i. math_bas_4_&i. math_bas_5_&i. 
									math_bas_6_&i. math_bas_7_&i. math_bas_8_&i.
									math_bas_10_&i.);
		label
			&type._tot_math_bas_&i. = "&type. Total basic math level '&i.'";

			&type._tot_math_prof_&i. = sum(of math_prof_3_&i. math_prof_4_&i. math_prof_5_&i. 
									math_prof_6_&i. math_prof_7_&i. math_prof_8_&i.
									math_prof_10_&i.);
		label
			&type._tot_math_prof_&i. = "&type. Total proficient math level '&i.'";


		
		&type._tot_math_adv_&i. = sum(of math_adv_3_&i. math_adv_4_&i. math_adv_5_&i. 
									math_adv_6_&i. math_adv_7_&i. math_adv_8_&i.
									math_adv_10_&i.);
		label
			&type._tot_math_adv_&i. = "&type. Total advanced math level '&i.'";
		%end;
		keep 
			 UI_ID
			 Master_school_name
			 &type._tot_math_adv_0607
			 &type._tot_math_adv_0708
			 &type._tot_math_adv_0809
			 &type._tot_math_bas_0607
			 &type._tot_math_bas_0708
			 &type._tot_math_bas_0809
			 &type._tot_math_below_0607
			 &type._tot_math_below_0708
			 &type._tot_math_below_0809
			 &type._tot_math_prof_0607
			 &type._tot_math_prof_0708
			 &type._tot_math_prof_0809
			 &type._tot_read_adv_0607
			 &type._tot_read_adv_0708
			 &type._tot_read_adv_0809
			 &type._tot_read_bas_0607
			 &type._tot_read_bas_0708
			 &type._tot_read_bas_0809
			 &type._tot_read_below_0607
			 &type._tot_read_below_0708
			 &type._tot_read_below_0809
			 &type._tot_read_prof_0607
			 &type._tot_read_prof_0708
			 &type._tot_read_prof_0809
			 &type._total_math_num_0607
			 &type._total_math_num_0708
			 &type._total_math_num_0809
			 &type._total_read_num_0607
			 &type._total_read_num_0708
			 &type._total_read_num_0809
			 cluster_tr2000_2006
			 cluster_tr2000_2007
			 cluster_tr2000_2008
			 ward2002_2006
			 ward2002_2007
			 ward2002_2008
			;
	run;
%mend totals;
%totals (type=DCPS)
%totals (type=PCSB);

/***************** Create the Ward2002 aggregation ************************/

%macro means (type=, year1=, year2=);
		proc means data=&type._testscore_totals noprint;
			class ward2002_&year1.;
			var &type._total_read_num_&year2. &type._total_math_num_&year2. 
				&type._tot_read_prof_&year2. &type._tot_read_adv_&year2. 
				&type._tot_math_prof_&year2. &type._tot_math_adv_&year2.; 
			 output out=&type._testscore_ward2002_&year1. (drop= _type_ _freq_)sum= ;
			run;

%mend means;
%means(type=PCSB, year1=2006, year2=0607)
%means(type=PCSB, year1=2007, year2=0708)
%means(type=PCSB, year1=2008, year2=0809)
%means(type=DCPS, year1=2006, year2=0607)
%means(type=DCPS, year1=2007, year2=0708)
%means(type=DCPS, year1=2008, year2=0809)

%macro combine (type=, year1=, year2=);
  data &type._ward2002_&year1.;
	set &type._testscore_ward2002_&year1.;
		&type._pct_prof_reading_&year2. = (&type._tot_read_prof_&year2. + &type._tot_read_adv_&year2.)/(&type._total_read_num_&year2.);
		&type._pct_prof_math_&year2. = (&type._tot_math_prof_&year2. + &type._tot_math_adv_&year2.)/(&type._total_math_num_&year2.);
		
	
	label
		&type._pct_prof_reading_&year2. = "&type. Percent at or above reading proficiency &year2."
		&type._pct_prof_math_&year2. = "&type. Percent at or above math proficiency &year2."
		ward2002_&year1. = "ward2002";
	rename ward2002_&year1. = ward2002;
  run;

  
%mend combine;
%combine(type=PCSB, year1=2006, year2=0607)
%combine(type=PCSB, year1=2007, year2=0708)
%combine(type=PCSB, year1=2008, year2=0809)
%combine(type=DCPS, year1=2006, year2=0607)
%combine(type=DCPS, year1=2007, year2=0708)
%combine(type=DCPS, year1=2008, year2=0809)

data TEMPORARYFUNK;
  	merge
		Dcps_ward2002_2006
		Dcps_ward2002_2007
		Dcps_ward2002_2008
		Pcsb_ward2002_2006
		Pcsb_ward2002_2007
		Pcsb_ward2002_2008;
	by ward2002;
	run;
%macro last;
 data dcd.testscores_ward2002;
	%let macro_score = 0607 0708 0809;
		%do grd=1 %to 3;
		%let i=%scan(&macro_score,&grd,' ');
	  set TEMPORARYFUNK;
	  where ward2002 ne "W" and ward2002 ne "";
	  city_pct_prof_reading_&i. = (PCSB_tot_read_prof_&i. + PCSB_tot_read_adv_&i. + DCPS_tot_read_prof_&i. + DCPS_tot_read_adv_&i.)/(Pcsb_total_read_num_&i. + DCPS_total_read_num_&i.);
	  city_pct_prof_math_&i. = (PCSB_tot_math_prof_&i. + PCSB_tot_math_adv_&i. + DCPS_tot_math_prof_&i. + DCPS_tot_math_adv_&i.)/(Pcsb_total_math_num_&i. + DCPS_total_math_num_&i.);
	  label 
	  	city_pct_prof_reading_&i. = "Total percent at reading proficiency &i."
		city_pct_prof_math_&i. = "Total percent at math proficiency &i.";
    %end;

	keep
		 DCPS_pct_prof_math_0607
		 DCPS_pct_prof_math_0708
		 DCPS_pct_prof_math_0809
		 DCPS_pct_prof_reading_0607
		 DCPS_pct_prof_reading_0708
		 DCPS_pct_prof_reading_0809
		 PCSB_pct_prof_math_0607
		 PCSB_pct_prof_math_0708
		 PCSB_pct_prof_math_0809
		 PCSB_pct_prof_reading_0607
		 PCSB_pct_prof_reading_0708
		 PCSB_pct_prof_reading_0809
		 city_pct_prof_math_0607
		 city_pct_prof_math_0708
		 city_pct_prof_math_0809
		 city_pct_prof_reading_0607
		 city_pct_prof_reading_0708
		 city_pct_prof_reading_0809
		 ward2002;

  run;
%mend last;
%last

/********Create the Cluster_tr2000 agregation**************/

%macro mean (type=, year1=, year2=);
		proc means data=&type._testscore_totals noprint;
			class cluster_tr2000_&year1.;
			var &type._total_read_num_&year2. &type._total_math_num_&year2. 
				&type._tot_read_prof_&year2. &type._tot_read_adv_&year2. 
				&type._tot_math_prof_&year2. &type._tot_math_adv_&year2.; 
			 output out=&type._tscr_cluster_tr2000_&year1. (drop= _type_ _freq_)sum= ;
			run;

%mend mean;
%mean(type=PCSB, year1=2006, year2=0607)
%mean(type=PCSB, year1=2007, year2=0708)
%mean(type=PCSB, year1=2008, year2=0809)
%mean(type=DCPS, year1=2006, year2=0607)
%mean(type=DCPS, year1=2007, year2=0708)
%mean(type=DCPS, year1=2008, year2=0809)

%macro combined (type=, year1=, year2=);
  data &type._cluster_tr2000_&year1.;
	set &type._tscr_cluster_tr2000_&year1.;
		&type._pct_prof_reading_&year2. = (&type._tot_read_prof_&year2. + &type._tot_read_adv_&year2.)/(&type._total_read_num_&year2.);
		&type._pct_prof_math_&year2. = (&type._tot_math_prof_&year2. + &type._tot_math_adv_&year2.)/(&type._total_math_num_&year2.);
		
	
	label
		&type._pct_prof_reading_&year2. = "&type. Percent at or above reading proficiency &year2."
		&type._pct_prof_math_&year2. = "&type. Percent at or above math proficiency &year2."
		cluster_tr2000_&year1. = "cluster_tr2000";
	rename cluster_tr2000_&year1. = cluster_tr2000;
  run;

  
%mend combined;
%combined(type=PCSB, year1=2006, year2=0607)
%combined(type=PCSB, year1=2007, year2=0708)
%combined(type=PCSB, year1=2008, year2=0809)
%combined(type=DCPS, year1=2006, year2=0607)
%combined(type=DCPS, year1=2007, year2=0708)
%combined(type=DCPS, year1=2008, year2=0809)

data TEMPORARYBEAT;
  	merge
		Dcps_cluster_tr2000_2006
		Dcps_cluster_tr2000_2007
		Dcps_cluster_tr2000_2008
		Pcsb_cluster_tr2000_2006
		Pcsb_cluster_tr2000_2007
		Pcsb_cluster_tr2000_2008;
	by cluster_tr2000;
	run;
%macro lastt;
 data dcd.testscores_cluster_tr2000;
	%let macro_score = 0607 0708 0809;
		%do grd=1 %to 3;
		%let i=%scan(&macro_score,&grd,' ');
	  set TEMPORARYBEAT;
	  where cluster_tr2000 ne "99" and cluster_tr2000 ne "Cl" and cluster_tr2000 ne "";
	  city_pct_prof_reading_&i. = (PCSB_tot_read_prof_&i. + PCSB_tot_read_adv_&i. + DCPS_tot_read_prof_&i. + DCPS_tot_read_adv_&i.)/(Pcsb_total_read_num_&i. + DCPS_total_read_num_&i.);
	  city_pct_prof_math_&i. = (PCSB_tot_math_prof_&i. + PCSB_tot_math_adv_&i. + DCPS_tot_math_prof_&i. + DCPS_tot_math_adv_&i.)/(Pcsb_total_math_num_&i. + DCPS_total_math_num_&i.);
	  label 
	  	city_pct_prof_reading_&i. = "Total percent at reading proficiency &i."
		city_pct_prof_math_&i. = "Total percent at math proficiency &i.";
    %end;

	keep
		 DCPS_pct_prof_math_0607
		 DCPS_pct_prof_math_0708
		 DCPS_pct_prof_math_0809
		 DCPS_pct_prof_reading_0607
		 DCPS_pct_prof_reading_0708
		 DCPS_pct_prof_reading_0809
		 PCSB_pct_prof_math_0607
		 PCSB_pct_prof_math_0708
		 PCSB_pct_prof_math_0809
		 PCSB_pct_prof_reading_0607
		 PCSB_pct_prof_reading_0708
		 PCSB_pct_prof_reading_0809
		 city_pct_prof_math_0607
		 city_pct_prof_math_0708
		 city_pct_prof_math_0809
		 city_pct_prof_reading_0607
		 city_pct_prof_reading_0708
		 city_pct_prof_reading_0809
		 cluster_tr2000;

  run;
%mend lastt;
%lastt

/*****************Aggregate at the City Level*****************************/

%macro city;
 data testscores_city;
	%let macro_score = 0607 0708 0809;
		%do grd=1 %to 3;
		%let i=%scan(&macro_score,&grd,' ');
	  set TEMPORARYFUNK;
	  where  ward2002 = "";
	  city_pct_prof_reading_&i. = (PCSB_tot_read_prof_&i. + PCSB_tot_read_adv_&i. + DCPS_tot_read_prof_&i. + DCPS_tot_read_adv_&i.)/(Pcsb_total_read_num_&i. + DCPS_total_read_num_&i.);
	  city_pct_prof_math_&i. = (PCSB_tot_math_prof_&i. + PCSB_tot_math_adv_&i. + DCPS_tot_math_prof_&i. + DCPS_tot_math_adv_&i.)/(Pcsb_total_math_num_&i. + DCPS_total_math_num_&i.);
	  label 
	  	city_pct_prof_reading_&i. = "Total percent at reading proficiency &i."
		city_pct_prof_math_&i. = "Total percent at math proficiency &i.";
    %end;

	keep
		 DCPS_pct_prof_math_0607
		 DCPS_pct_prof_math_0708
		 DCPS_pct_prof_math_0809
		 DCPS_pct_prof_reading_0607
		 DCPS_pct_prof_reading_0708
		 DCPS_pct_prof_reading_0809
		 PCSB_pct_prof_math_0607
		 PCSB_pct_prof_math_0708
		 PCSB_pct_prof_math_0809
		 PCSB_pct_prof_reading_0607
		 PCSB_pct_prof_reading_0708
		 PCSB_pct_prof_reading_0809
		 city_pct_prof_math_0607
		 city_pct_prof_math_0708
		 city_pct_prof_math_0809
		 city_pct_prof_reading_0607
		 city_pct_prof_reading_0708
		 city_pct_prof_reading_0809
		 ward2002;
  run;


data dcd.testscores_city (drop = ward2002);
		retain city;
		set testscores_city;
		length city 8;
		label city = "Washington, D.C.";
		if ward2002 = '' then city = '1';
		run;

%mend city;
%city


/********Print to Excel *********************

ods html file="K:\Metro\PTatian\DCData\Libraries\Schools\Test Scores\testscore_total.xls" style=minimal; 
%macro print;
proc print data= dcd.Testscore_totals label noobs;
	%let macro_year = 0607 0708 0809;
		%do yr=1 %to 3;
		%let i=%scan(&macro_year, &yr,' ');	

		var
			UI_ID
			master_school_name
			total_read_num_&i.
			total_math_num_&i.
			tot_read_below_&i.
			tot_read_bas_&i.
			tot_read_prof_&i.
			tot_read_adv_&i.
			tot_math_below_&i.
			tot_math_bas_&i.
			tot_math_prof_&i.
			tot_math_adv_&i.
			pct_read_below_&i.
			pct_read_bas_&i.
			pct_read_prof_&i.
			pct_read_adv_&i.
			pct_math_below_&i.
			pct_math_bas_&i.
			pct_math_prof_&i.
			pct_math_adv_&i.
;
	%end;
run;
%mend;
%print;
ods html close; 


**********/
