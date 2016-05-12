/**************************************************************************
 Program:  transform_enroll.sas
 Project:  schools
 Author:   S.Zhang 3/24/2014
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description: Transforms enrollment file to usable format for creating summary files
 Looks at audited enrollment. 
**************************************************************************/

libname enroll "D:\DCData\Libraries\Schools\enrollment";
option nofmterr; 

%macro create_public();
data enroll.enroll_to_merge_1314 (drop= grade);
	set enroll.allenrollment_1314;
	if grade ^="total" then delete; 
run;
%mend;

%create_public();
