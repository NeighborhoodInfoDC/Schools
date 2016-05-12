
/**************************************************************************
 Program:  predicted schools 2010.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   M.Grosz 10/28/2009
 Created:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: uses the master school file to create school-by-grade dataset of grades we predict next year;
 Modifications:
**************************************************************************/
  /*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib(RealProp)

libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";



data grade_max_diffs (keep = UI_ID master_school_name grade_max_2010 grade_max_2009);
	set gen.master_school_file_FINAL_120109;
	where grade_max_2010 ne grade_max_2009;
	run;
data grade_min_diffs (keep = UI_ID master_school_name grade_min_2010 grade_min_2009);
	set gen.master_school_file_FINAL_120109;
	where grade_min_2010 ne grade_min_2009;
	run;
