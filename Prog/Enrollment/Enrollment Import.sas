/**************************************************************************
 Program:  Enrollment Import.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   S. Litschwartz
 Created:  08/15/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Imports enrollment files from spread sheets;
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos) compress=binary ;
%DCData_lib( Schools)

options nofmterr;
*this macro pads s variable with leading zeros;
%macro zpad(s);
    * first, recommend aligning the variable values to the right margin to create leading blanks, if they dont exist already;
                &s. = right(&s.);

                * then fill them with zeros;
                if trim(&s.) ~= "" then do;            
                                do _i_ = 1 to length(&s.) while (substr(&s.,_i_,1) = " ");
                                                substr(&s.,_i_,1) = "0";
                                end;
                end;
%mend zpad;

/*import DCPS data*/
/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
filename dat dde "excel|D:\DCData\Libraries\Schools\Raw\[DCPS School-by-Grade Enrollment, Audited and Oct.Cert. 2001-2009_GM.xls]DCPS School-by-Grade Enrollment! r4c1:r2697c23";
*;
data DCPS_longenroll(Label="Raw DCPS Audited and Certified Enrollment File"); 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			Master_School_Name		$50.
			UI_ID					$7.
			DCPS					$14.
			Band					$8.
			Grade					$8.
			aud_0102				8.
			aud_0203				8.
			aud_0304				8.
			aud_0405				8.
			aud_0506				8.
			aud_0607				8.
			aud_0708				8.
			aud_0809				8.
			aud_0910				8.
			rep_0102				8.
			rep_0203				8.
			rep_0304				8.
			rep_0405				8.
			rep_0506				8.
			rep_0607				8.
			rep_0708				8.
			rep_0809				8.
			rep_0910				8.
;

		input
			Master_School_Name	  $
			UI_ID				  $
			DCPS				  $
			Band				  $
			Grade				  $
			aud_0102			
			aud_0203				
			aud_0304			
			aud_0405			
			aud_0506			
			aud_0607				
			aud_0708			
			aud_0809			
			aud_0910						
			rep_0102			
			rep_0203			
			rep_0304			
			rep_0405			
			rep_0506			
			rep_0607			
			rep_0708			
			rep_0809
			rep_0910;

			if grade = "PreK" then grade="PK";
			if grade = "Presch" then grade="PS";
			if grade = "Ad/Ung" then grade="Adult";
			length pad $2.;
			if grade in ('1','2','3','4','5','6','7','8','9') then pad=grade;
			%zpad(pad);
			if grade in ('1','2','3','4','5','6','7','8','9') then grade=pad;
			drop _i_ pad;		
			
		run;

/*import PCSB data*/
/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
/**** NOTE:  This excel file reflects the September, 2010 ZM enrollment fixes for PCSB **/ 
filename dat dde "excel|D:\DCData\Libraries\schools\raw\[pcsb School-by-Grade Enrollment, Audited and Oct.Cert.2001-2009_ZMchanges_GM.xls]Sheet1! r2c1:r1709c22" ;
	data Pcsb_longenroll; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			Master_School_Name		$50.
			UI_ID					$7.
			Band					$8.
			Grade					$8.
			aud_0102				8.
			aud_0203				8.
			aud_0304				8.
			aud_0405				8.
			aud_0506				8.
			aud_0607				8.
			aud_0708				8.
			aud_0809				8.
			aud_0910				8.
			rep_0102				8.
			rep_0203				8.
			rep_0304				8.
			rep_0405				8.
			rep_0506				8.
			rep_0607				8.
			rep_0708				8.
			rep_0809				8.
			rep_0910				8.
;

		input
			Master_School_Name	  $
			UI_ID				  $	
			Band				  $
			Grade				  $
			aud_0102			
			aud_0203				
			aud_0304			
			aud_0405			
			aud_0506			
			aud_0607				
			aud_0708			
			aud_0809			
			aud_0910						
			rep_0102			
			rep_0203			
			rep_0304			
			rep_0405			
			rep_0506			
			rep_0607			
			rep_0708			
			rep_0809
			rep_0910;

			if grade = "PreK" then grade="PK";
			if grade = "Presch" then grade="PS";
			if grade = "Ad/Ung" then grade="Adult";
			length pad $2.;
			if grade in ('1','2','3','4','5','6','7','8','9') then pad=grade;
			%zpad(pad);
			if grade in ('1','2','3','4','5','6','7','8','9') then grade=pad;
			drop _i_ pad;	
		run;


%macro label(file);
	data &file.2;
				set &file. ;	
				label
						%do yr=2001 %to 2009;
							%let yr2=%eval(&yr. + 1);
							%let x=%substr(&yr.,3,2);
							%let y=%substr(&yr2.,3,2);	
							aud_&x.&y. = "Audited Enrollment 20&x.-&y."
							rep_&x.&y. = "October Certified Enrollment 20&x.-&y."
						%end;
				UI_ID="UI ID"
				Master_School_Name="Master School Name"
				Grade="Grade"
				Band="Band"	
				;
				format UI_ID  $Uischid.;
		run;
%mend label;

%label(PCSB_longenroll)
%label(DCPS_longenroll)



 %macro totals(file);

proc summary data=&file.2 nway;
	class UI_ID;
	var
		%do yr=2001 %to 2009;
			%let yr2=%eval(&yr. + 1);
			%let x=%substr(&yr.,3,2);
			%let y=%substr(&yr2.,3,2);	
			aud_&x.&y. rep_&x.&y.
		%end;
	 ;
	output out=&file._totals (drop=_Type_ _Freq_)  
	Sum= ;
run;

data &file._totals2;
set &file._totals;
	length Grade $8 Band $8; 
	Grade='total';
	Band='total';
run;

%mend;


%totals(DCPS_longenroll);
%totals(PCSB_longenroll);

data PCSB_longenroll ;
set Pcsb_longenroll2 Pcsb_longenroll_totals2;
drop Master_School_Name;
run;

proc sort data=PCSB_longenroll out=schools.PCSB_longenroll;
by UI_ID;
run;

data DCPS_longenroll ;
set DCPS_longenroll2 DCPS_longenroll_totals2;
drop Master_School_Name;
run;

proc sort data=DCPS_longenroll out=schools.DCPS_longenroll;
by UI_ID;
run;

/*create permenant data set with all enrollment data*/
data allenrollment(label=" Audited and Certified Enrollment File from PCSB and DCPS") ;
	set schools.DCPS_longenroll (in=a) schools.PCSB_longenroll(in=b) ;
	if a then SchoolType='1';
	if b then SchoolType='2';
	label SchoolType="Type of School";
	format SchoolType $Schtype.;
	drop DCPS Band;
run;

data schools.allenrollment;
	set allenrollment;
	/* Changes all numeric variables with value of 0 to . */
	array change _numeric_; do over change; if change=0 then change=.; end;
run;

proc sort data= schools.allenrollment;
   by UI_ID grade ;
   run;

data checkmaster;
	set schools.allenrollment;
	keep UI_ID SchoolType;
run;

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
			set schools.&yr.;
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
				set schools.&yr.;
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

	data schools.enrollment_&fr.&to._tr;
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

	proc sort data= schools.enrollment_&fr.&to._tr;
	by UI_ID grade;
	run;

	proc sort data = checkmaster; by UI_ID; run;

	proc sort data = schools.&yr. (keep=UI_ID SchoolType) out = &yr.; by UI_ID; run;

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

data allenrollment_1314;
merge schools.allenrollment (drop=SchoolType) schools.enrollment_1011_tr schools.enrollment_1112_tr
	schools.enrollment_1213_tr schools.enrollment_1314_tr;
by UI_ID grade;
run;

proc sort data = allenrollment_1314; by UI_ID; run;

proc sort data = checkmaster; by UI_ID; run;

data allenrollment_1314_2;
	merge allenrollment_1314 checkmaster;
	by UI_ID;
run;

data schools.allenrollment_1314;
	set allenrollment_1314_2;
	where substr(UI_ID,1,1) in ("1","2","3");
	if SchoolType not in ("1","2") then SchoolType = substr(UI_ID,1,1);
run;

%File_info(data=schools.PCSB_longenroll)
%File_info(data=schools.DCPS_longenroll)
%File_info(data=schools.enrollment_1011_tr);
%File_info(data=schools.enrollment_1112_tr);
%File_info(data=schools.enrollment_1213_tr);
%File_info(data=schools.enrollment_1314_tr);
