/**************************************************************************
 Program:  kidcount_precprof.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  10/22/2010
 UPDATED:  10/25/2010 ZM Added code for the performance_table_09 table indicator
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Calculates the percentage by grade of dcps and pcsb proficiency for Kid Counts 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";
libname dcd "D:\DCData\Libraries\schools\Raw";
libname kc  "D:\DCData\Libraries\Schools\Raw\kidscount";
options mprint symbolgen;

/*The school-by-grade testscore files*/

data kc.Testscore_0607 (drop=rperc: mperc: math_below: math_bas: read_below: read_bas:);
	set 
		dcd.Pcsb_0607_wide
		dcd.Dcps_0607_wide;
		run;
data kc.Testscore_0708 (drop=rperc: mperc: math_below: math_bas: read_below: read_bas:);
	set
		dcd.Pcsb_0708_wide
		dcd.Dcps_0708_wide;
	run;

data kc.Testscore_0809 (drop=rperc: mperc: math_below: math_bas: read_below: read_bas:);
	set dcd.testscore_0809;
run;

/*Summing levels and dividing by total for percents */

%macro sum (year);

/*********** DCPS SCHOOLS *****************************/

proc means data=kc.testscore_&year. (where=(dcps="1")) noprint;
	var _numeric_;
	output out = dcps_testsum_&year. (keep= _numeric_) sum=;
run;


data /*kc.*/dcps_scores_&year. /*(keep = read_perc: math_perc:)*/;
	set dcps_testsum_&year.;
	%do i=3 %to 10;
		%if &i. ne 9 %then %do;
			read_proficient_&i._&year. = sum(of read_prof_&i._&year., read_adv_&i._&year.);
			math_proficient_&i._&year. = sum(of math_prof_&i._&year., math_adv_&i._&year.);
			read_perc_prof_&i._&year. = (read_proficient_&i._&year./read_num_students_&i._&year.)*100;
			math_perc_prof_&i._&year. = (math_proficient_&i._&year./math_num_students_&i._&year.)*100;
		%end;
	%end;
run;



/************** PCSB SCHOOLS *************************/

proc means data=kc.testscore_&year. (where=(dcps="0")) noprint;
	var _numeric_;
	output out = pcsb_testsum_&year. (keep= _numeric_) sum=;
run;

data kc.pcsb_scores_&year. (keep = read_perc: math_perc:);
	set pcsb_testsum_&year.;
	%do i=3 %to 10;
		%if &i. ne 9 %then %do;
			read_proficient_&i._&year. = sum(of read_prof_&i._&year., read_adv_&i._&year.);
			math_proficient_&i._&year. = sum(of math_prof_&i._&year., math_adv_&i._&year.);
			read_perc_prof_&i._&year. = (read_proficient_&i._&year./read_num_students_&i._&year.)*100;
			math_perc_prof_&i._&year. = (math_proficient_&i._&year./math_num_students_&i._&year.)*100;
		%end;
	%end;
run;

/*************** PRINT TO EXCEL FOR COMPARISON *********************/

ods html file="D:\DCData\Libraries\Schools\Raw\kidscount\dcps_scores_&year..xls" style=minimal;
proc print data=kc.dcps_scores_&year. noobs;
run;
ods html close;

ods html file="D:\DCData\Libraries\Schools\Raw\kidscount\pcsb_scores_&year..xls" style=minimal;
proc print data=kc.pcsb_scores_&year. noobs;
run;
ods html close;

%mend sum;
%sum(0607);
%sum(0708)
%sum(0809);

/*** The Performance table 09 indicator **************/

data dcps_city_proficient (keep=dcps_tot: dcps_read_proficient dcps_math_proficient n);
	set dcps_testsum_0809;
	dcps_tot_num_read = sum(of read_num:);
	dcps_tot_num_math = sum(of math_num:);
	dcps_tot_prof_read = sum(of read_prof:) + sum(of read_adv:);
	dcps_tot_prof_math = sum(of math_prof:) + sum(of math_adv:);
	dcps_read_proficient=(dcps_tot_prof_read/dcps_tot_num_read)*100;
	dcps_math_proficient=(dcps_tot_prof_math/dcps_tot_num_math)*100;
	n=_N_;
run;

data pcsb_city_proficient (keep=pcsb_tot: pcsb_read_proficient pcsb_math_proficient n);
	set pcsb_testsum_0809;
	pcsb_tot_num_read = sum(of read_num:);
	pcsb_tot_num_math = sum(of math_num:);
	pcsb_tot_prof_read = sum(of read_prof:) + sum(of read_adv:);
	pcsb_tot_prof_math = sum(of math_prof:) + sum(of math_adv:);
	pcsb_read_proficient=(pcsb_tot_prof_read/pcsb_tot_num_read)*100;
	pcsb_math_proficient=(pcsb_tot_prof_math/pcsb_tot_num_math)*100;
	n=_N_;
run;

data kc.city_proficient (keep = dcps_read_proficient dcps_math_proficient pcsb_read_proficient pcsb_math_proficient
						read_proficient math_proficient);
	merge 
		dcps_city_proficient
		pcsb_city_proficient;
	by n;
	
	tot_read_num=pcsb_tot_num_read + dcps_tot_num_read;
	tot_math_num=pcsb_tot_num_math + dcps_tot_num_math;
	tot_prof_math = pcsb_tot_prof_math + dcps_tot_prof_math;
	tot_prof_read = pcsb_tot_prof_read + dcps_tot_prof_read;
	read_proficient= (tot_prof_read/tot_read_num) *100;
	math_proficient= (tot_prof_math/tot_math_num) *100;
run;

ods html file="D:\DCData\Libraries\Schools\Raw\kidscount\city_procifiency.xls" style=minimal;
proc print data=kc.city_proficient noobs;
run;
ods html close;
