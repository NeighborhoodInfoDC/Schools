/**************************************************************************
 Program:  Test Scores Import.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   S. Litschwartz
 Created:  08/19/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: perform checks on the test score data
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\schoolmacros.sas";
options sasautos=(uiautos sasautos) compress=binary ;
%DCData_lib( Schools)

/*check to make sure all schools and grades are in the test data*/

/*create data set from the test data that is just a list of UI-ID's, Grades, and Years*/
data schools.schoollist_test;
set schools.TestScore_all;
keep UI_ID Grade Year test;
test=1;
run;

proc sort data= schools.schoollist_test;
by UI_ID Grade year;
run;

/*create data set from the enrollment data that is just a list of UI-ID's, Grades, and Years*/

%macro sep;
%do yr=2006 %to 2009;
	%let y1=%substr(&yr.,3,2);
	%let yr2=%eval(&yr.+1);
	%let y2=%substr(&yr2.,3,2);
	data schoollist_enrolllment_&yr.;
		set schools.Dcps_longenroll  schools.PCSB_longenroll;
		if Grade in ('3' '4' '5' '6' '7' '8' '10');
		if aud_&y1.&y2. ne .; 
		rename aud_&y1.&y2.=enrollment;
		year=&yr.;
		keep UI_ID Grade enr aud_&y1.&y2. year Master_School_Name;
		enr=1;
	run;
%end;
%mend;
%sep;
data schools.schoollist_enrolllment;
set schoollist_enrolllment_2006 schoollist_enrolllment_2007 schoollist_enrolllment_2008 schoollist_enrolllment_2009;
run;




proc sort data= schools.schoollist_enrolllment;
by UI_ID Grade year;
run;
 
/*compare the two lists*/
data Schools.test_comp;
merge schools.schoollist_enrolllment schools.schoollist_test;
by UI_ID Grade year;
if test=. or enr=.;
if grade not in ('total' 'Total' 'TOTAL');
run;

/*
proc datasets lib=schools memtype=data;
   modify test_comp; 
     attrib _all_ label=' '; 
	 attrib _all_ format=; 
run;
quit;*/



proc sort data=schools.allenr;
by UI_ID Grade;
run;

proc transpose data=schools.TestScore_all out=schools.test_comp prefix=read_num;
var read_num;
id year;
by UI_ID Grade;
run;

proc sort data=Schools.Test_comp;
by UI_ID Grade;
run;

proc compare base=Schools.Test_comp compare=schools.allenr  printall;
by UI_ID Grade;
var read_num2006 read_num2007 read_num2008 read_num2009;
with aud_0607 aud_0708 aud_0809 aud_0910; 
run;
