/**************************************************************************
 Program:  MinMaxGrades.sas
 Library:  Schools
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  01/28/2019
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Make to use enrollment files to flag min and max grades.

 Modifications:
**************************************************************************/

%macro minmaxgrades ();

/* Flag adult-only school */
if AO >0 then do;
	adult_flag = 1;
end;

else do;

	/* Flag lowest grade */
	if ps > 0 then grade_min = -2;
		else if pk > 0 then grade_min = -1;
		else if k > 0 then grade_min = 0;
		else if _1 > 0 then grade_min = 1;
		else if _2 > 0 then grade_min = 2;
		else if _3 > 0 then grade_min = 3;
		else if _4 > 0 then grade_min = 4;
		else if _5 > 0 then grade_min = 5;
		else if _6 > 0 then grade_min = 6;
		else if _7 > 0 then grade_min = 7;
		else if _8 > 0 then grade_min = 8;
		else if _9 > 0 then grade_min = 9;
		else if _10 > 0 then grade_min = 10;
		else if _11 > 0 then grade_min = 10;
		else if _12 > 0 then grade_min = 12;

	/* Flag highest grade */
	if _12 > 0 then grade_max = 12;
		else if _11 > 0 then grade_max = 11;
		else if _10 > 0 then grade_max = 10;
		else if _9 > 0 then grade_max = 9;
		else if _8 > 0 then grade_max = 8;
		else if _7 > 0 then grade_max = 7;
		else if _6 > 0 then grade_max = 6;
		else if _5 > 0 then grade_max = 5;
		else if _4 > 0 then grade_max = 4;
		else if _3 > 0 then grade_max = 3;
		else if _2 > 0 then grade_max = 5;
		else if _1 > 0 then grade_max = 1;
		else if k > 0 then grade_max = 0;
		else if pk > 0 then grade_max = -1;
		else if ps > 0 then grade_max = -2;

end;

%mend minmaxgrades;


/* End of macro */
