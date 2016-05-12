/**************************************************************************
 Program:  check_msf_enroll.sas
 Project:  schools
 Author:   S.Zhang 
 Created:  7/17/2013
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description: Runs checks between MSF and enrollment file
**************************************************************************/
libname nmast "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file\11_13_data";
libname enroll "D:\DCData\Libraries\Schools\enrollment";

proc sort data=enroll.minmax out=minmaxS; by ui_id; run;

proc sort data=nmast.msf0012 out=msf0012S; by ui_id; run;

data to_check;
	retain ui_id master_school_name;
	merge msf0012S minmaxS;
	by ui_id;
run;

data not_in_enroll;
	set to_check;
	if open_2012 ^= . then delete;
run;

/*check consistency between enrollment and MSF on when things have closed*/
%macro check_open_consistency();
data in_both;
	set to_check;
	if open_2012 = .  then delete;
	%do i=2001 %to 2012;
	/*inconsistent flag is 1 if there is an address and no enrollment, 2 if there is no address but there's enrollment*/
	if x_coord_&i. >0 AND open_&i. = 0 then do; inconsistent_&i. = 1; master_inconsistent = 1; end;
	else if x_coord_&i. = . AND open_&i.=1 then do; inconsistent_&i. = 2; master_inconsistent = 1; end;
	%end;
	if master_inconsistent ^= 1 then delete;
run;
%mend;

%check_open_consistency();
