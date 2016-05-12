/**************************************************************************
 Program:  minmax_14_15.sas
 Project:  schools
 Author:   S.Zhang 5/3/2013
 Created:  3/24/2014
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description: Identifies the min and max grades in a school based on the 
 audited enrollments. This programs also flags schools that are open. 
**************************************************************************/

libname enroll "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Enrollment";
option nofmterr; 

data minmax;
	set enroll.allenrollment_1415;
	if grade ="total" then delete; 
	if grade = "Adult" then grade_n = 13;
	else if grade = "K" then grade_n =0;
	else if grade ="PK" then grade_n = -1;
	else if grade = "PS" then grade_n=-2;
	else grade_n = grade*1; 
run;

%macro calc_min_max(y1,y2);
data minmax;
	set minmax;
	/*works by copying the grade number into the enrollment variable where enrollment>0*/
	if aud_&Y1.&y2.>0 and grade_n<13 then aud_&Y1._n = grade_n;
	else aud_&Y1._n = .;
	/*sets adult flag, whether there are adult learners in the school*/
	if aud_&Y1.&y2.>0 and grade_n=13 then adult_flag_&y1. = 1;
	else adult_flag_&y1. = 0;
run;
%mend;

%calc_min_max(01,02);
%calc_min_max(02,03);
%calc_min_max(03,04);
%calc_min_max(04,05);
%calc_min_max(05,06);
%calc_min_max(06,07);
%calc_min_max(07,08);
%calc_min_max(08,09);
%calc_min_max(09,10);
%calc_min_max(10,11);
%calc_min_max(11,12);
%calc_min_max(12,13);
%calc_min_max(13,14);
%calc_min_max(14,15);
data test;
	set minmax;
run;

option mprint mlogic;

%macro generate();
proc means data = minmax n max min;
	class ui_id;
	var 
		%do i = 01 %to 14; %let val=%sysfunc(putn(&i,z2.));
			aud_&val._n adult_flag_&val. 
		%end;;
	output out= minmax 
	min(%do i = 01 %to 14;%let val=%sysfunc(putn(&i,z2.));
			aud_&val._n 
		%end;)=%do i = 01 %to 14; %let val=%sysfunc(putn(&i,z2.));
			grade_min_20&val.
		%end; 
	max(%do i = 01 %to 14; %let val=%sysfunc(putn(&i,z2.));
			aud_&val._n  adult_flag_&val. 
		%end;)=%do i = 01 %to 14; %let val=%sysfunc(putn(&i,z2.));
			grade_max_20&val. adult_flag_20&val. 
		%end;;
run;
%mend;

%generate();

%macro set_open_flag();
data minmax_and_open (drop=_type_ _freq_); 
	set minmax ; 
	if _type_=0 then delete; 
	/*set open flag*/
	%do i=2001 %to 2014;
		if grade_min_&i. =. AND grade_max_&i. =. AND adult_flag_&i.=0 then enroll_open_&i.=0;
		else enroll_open_&i.=1;
	%end;
run; 
%mend set_open_flag;

%set_open_flag();

data enroll.minmax_1415; set minmax_and_open; run;
