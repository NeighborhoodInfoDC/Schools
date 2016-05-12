/**************************************************************************
 Program:  School Formats
 Project:  SCHOOLS DCDATA 
 Author:   S. Litschwartz
 Created:  08/9/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Creates school formats; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Schools,mprint=y )

proc format library=Schools;
value $SchType
"0"="Charter"
"1"="DCPS"
;
run;


%Data_to_format(FmtLib=schools,
				FmtName=$uischid,
				Desc="UI school ID",
				Data=schools.Master_school_file_final_082011,
				Value=ui_id,
				Label=master_school_name,
				OtherLabel=,
				Print=Y,
				Contents=Y)


proc format library=Schools ;
value $Grade NOTSORTED 
"01"="Grade 1"
"02"="Grade 2"
"03"="Grade 3"
"04"="Grade 4"
"05"="Grade 5"
"06"="Grade 6"
"07"="Grade 7"
"08"="Grade 8"
"09"="Grade 9"
"10"="Grade 10"
"11"="Grade 11"
"12"="Grade 12"
"total"="Total"
;
run;
