/**************************************************************************
 Program:  Merge_enroll.sas
 Library:  DCDATA
 Project:  schools
 Author:   S. Zhang
 Created:  05/08/2015
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 Description: Merges data
 Modifications: 12/27/18 by Yipeng Su
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/
/*filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos) compress=binary ;*/
libname enroll "D:\DCData\Libraries\Schools\Data\Enrollment";

options nofmterr;


/* Transpose and add new years */

%macro school_transpose(yr,fr,to);

	%let vars = total ps pk k _1 _2 _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 ao;
	%let labels = total PS PK K 01 02 03 04 05 06 07 08 09 10 11 12 Adult;
	%let nv = %sysfunc(countw(&vars.));
	%do i = 1 %to &nv.;
		%let res = %scan(&vars.,&i.," ");
		%let lab = %scan(&labels.,&i.," ");
		data d_final_&res.;
			length grade $8.;
			set enroll.&yr.;
			where enrolltype = "Final";
			keep UI_ID &res. Grade;
			if &res. = 0 then &res. = .;
			rename &res. = aud_&fr.&to.;
			Grade = "&lab.";
			label Grade = "Grade";
		run;
		/* Only audited data from 11-12 on */
		%if &fr. < 11 %then %do;
			data d_rep_&res.;
				length grade $8.;
				set enroll.&yr.;
				where enrolltype = "Reported";
				keep UI_ID &res. Grade;
				rename &res. = rep_&fr.&to.;
				Grade = "&lab.";
				label Grade = "Grade";
			run;
			proc sort data = d_final_&res.; by UI_ID; run;
			proc sort data = d_rep_&res.; by UI_ID; run;
			data d_all_&res.;
				merge d_final_&res. d_rep_&res.;
				by UI_ID;
			run;
		%end;
		%else %do;
			data d_all_&res.; set d_final_&res.; run;
		%end;
	%end;

	data enroll.enrollment_&fr.&to._tr;
		set
			%do i = 1 %to &nv.;
				%let res = %scan(&vars.,&i.," "); 
				d_all_&res. 
			%end;
		;
		label aud_&fr.&to. = "Audited Enrollment 20&fr.-&to." 
			%if &fr. < 11 %then %do;
				rep_&fr.&to. = "October Certified Enrollment 20&fr.-&to."
			%end;
		;
	run;

	proc sort data= enroll.enrollment_&fr.&to._tr;
	by UI_ID grade;
	run;

	proc sort data = checkmaster; by UI_ID; run;

	proc sort data = enroll.&yr. (keep=UI_ID SchoolType) out = &yr.; by UI_ID; run;

	data check_&yr.;
		merge &yr. (in=a) checkmaster(in=b);
		by UI_ID;
		if a and not b;
	run;

	data checkmaster;
		set checkmaster check_&yr.;
	run;

%mend school_transpose;

%school_transpose(enroll10_11,10,11);
%school_transpose(enroll11_12,11,12);
%school_transpose(enroll12_13,12,13);
%school_transpose(enroll13_14,13,14);
%school_transpose(enroll14_15,14,15);
%school_transpose(enroll15_16,15,16);
%school_transpose(enroll16_17,16,17);
%school_transpose(enroll17_18,17,18);

data allenrollment_1718;
merge enroll.allenrollment (drop=SchoolType) enroll.enrollment_1011_tr enroll.enrollment_1112_tr
	enroll.enrollment_1213_tr enroll.enrollment_1314_tr enroll.enrollment_1415_tr enroll.enrollment_1516_tr enroll.enrollment_1617_tr enroll.enrollment_1718_tr;;
by UI_ID grade;
run;

proc sort data = allenrollment_1718; by UI_ID; run;

proc sort data = checkmaster; by UI_ID; run;

data allenrollment_1718_2;
	merge allenrollment_1718 checkmaster;
	by UI_ID;
run;

data enroll.allenrollment_1718;
	set allenrollment_1718_2;
	where substr(UI_ID,1,1) in ("1","2","3");
	if SchoolType not in ("1","2") then SchoolType = substr(UI_ID,1,1);
run;

%File_info(data=enroll.PCSB_longenroll)
%File_info(data=enroll.DCPS_longenroll)
%File_info(data=enroll.enrollment_1011_tr);
%File_info(data=enroll.enrollment_1112_tr);
%File_info(data=enroll.enrollment_1213_tr);
%File_info(data=enroll.enrollment_1314_tr);
%File_info(data=enroll.enrollment_1415_tr);
%File_info(data=enroll.enrollment_1516_tr);
%File_info(data=enroll.enrollment_1617_tr);
%File_info(data=enroll.enrollment_1718_tr);
