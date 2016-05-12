/**************************************************************************
 Program:  School Formats
 Project:  SCHOOLS DCDATA 
 Author:   S. Litschwartz
 Created:  11/12/2013
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Creates school formats; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Schools,mprint=y )

proc format library=nmast;
value $SchType
"0"="Charter"
"1"="DCPS"
;
run;

proc format library=nmast;
value $open
"0"="Not Open"
"1"="Open"
;
run;

%Data_to_format(FmtLib=nmast,
				FmtName=$uischid,
				Desc="UI School ID",
				Data=nmast.msf0012,
				Value=ui_id,
				Label=master_school_name,
				OtherLabel=,
				Print=Y,
				Contents=Y)


proc format library=nmast ;
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
