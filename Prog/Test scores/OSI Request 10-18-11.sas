/**************************************************************************
 Program:  OSI Request 10-18-11
 Project:  Kids Count
 Author:   S. Litschwartz
 Created:  10/18/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Creates school enrollment indicators; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\Enrollment\School Formats.sas";
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\schoolmacros.sas";  
%DCData_lib( Schools)
%global level_num level_perc;
%let level_num=_num _bb _b _p _adv;
%let level_perc=_bb_perc _b_perc _p_perc _adv_perc;

data allenr;
set schools.allenrollment;
	UI_ID2=UI_ID;
	rename UI_ID=School_Name;
	Label UI_ID="School Name";
	Label UI_ID2="UI ID";
run;


data test09;
set schools.Testscore_all;
	UI_ID2=UI_ID;
	rename UI_ID=School_Name;
	Label UI_ID="School Name";
	Label UI_ID2="UI ID";
	if year='2009';
	grade=LOWCASE(grade);
run;

proc datasets lib=work memtype=data;
	modify test09; 
    	 rename UI_ID2=UI_ID;
		 label Year='Fall year';
	modify allenr; 
    	rename UI_ID2=UI_ID;
run;
quit;

proc summary data=test09 nway completetypes;
		class grade schooltype/preloadfmt;
		var %varrange(read,&level_perc.)/weight=read_num;
		var %varrange(math,&level_perc.)/weight=math_num;
		output out=test09_by_type (drop=_freq_ _type_)  
		Sum(%varrange(read,&level_num.) %varrange(math,&level_num.))=%varrange(read,&level_num.) %varrange(math,&level_num.)
		mean(%varrange(math,&level_perc.))=%varrange(math,&level_perc.) 
		mean(%varrange(read,&level_perc.))=%varrange(read,&level_perc.);
run;


ods html file="K:\Metro\PTatian\DCData\Libraries\Schools\OSI Requests\aud-oct-enrollment.xls" style=minimal; 
	proc print data=allenr label noobs;
		title "Audited Enrollment and October Certified by School by Grade Over Time";
	run;
ods html close; 


ods html file="K:\Metro\PTatian\DCData\Libraries\Schools\OSI Requests\testscore-0910.xls" style=minimal; 
	proc print data=test09 label noobs;
		title "2009-10 Test Scores by School by Grade";
	run;
ods html close; 

ods html file="K:\Metro\PTatian\DCData\Libraries\Schools\OSI Requests\testscore-0910-by school type.xls" style=minimal; 
	proc print data=Test09_by_type label noobs;
		title "2009-10 Test Scores by DCPS and Public Charters by Grade";
	run;
ods html close; 


Oct certified and audited enrollments by school by grade over time
2009-10 test scores by school by grade
2009-10 test scores by DCPS and Public Charters by grade


ods html file="K:\Metro\PTatian\DCData\Libraries\Schools\Schools 1011 Files\Longitudinal Enrollment 2001-2009\dcps_rep_enrolltotal.xls" style=minimal; 
	proc print data= dcd.DCPS_allsch_lngenrl label noobs;
		var
			UI_ID
			Master_school_name
			School_name_2009
			total_rep_0102
			total_rep_0203
			total_rep_0304
			total_rep_0405
			total_rep_0506
			total_rep_0607
			total_rep_0708
			total_rep_0809
			total_rep_0910
			;
		title "Reported Enrollment Totals";
		title1 "DCPS";
	run;
ods html close; 




Oct certified and audited enrollments by school by grade over time
2009-10 test scores by school by grade
2009-10 test scores by DCPS and Public Charters by grade














