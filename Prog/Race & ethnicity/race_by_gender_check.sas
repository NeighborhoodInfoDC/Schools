/************************************************
Program: race_by_gender_check.sas

Author: ZM

Date: 1/28/2011

Description: Read in and proc compare hand-entered DCPS and PCSB race and ethnicity
			 by gender data to check for accuracy

Modifications:

*************************************************/

libname re "D:\DCData\Libraries\Schools\Raw\race_ethnicity";
libname dat "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Race & ethnicity";

/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/

%macro readin;
%let i= 0607 0708 0809 0910;
%do yr=1 %to 4;
%let year = %scan(&i.,&yr.,' ');

	%let y=RK mc;
	%do nm=1 %to 1;
	%let name=%scan(&y.,&nm.,' ');

		%let z=PCSB DCPS;
		%do tp=1 %to 2;
		%let type= %scan(&z.,&tp.,' ');

			filename dat dde "excel|D:\DCData\Libraries\Schools\Raw\race_ethnicity\[&type. &year._&name..xls]Audited! r3c1:r350c15" ;
				data dat.&type._&year.; 
					infile dat notab missover dlm='09'x dsd;
					informat 
					master_school_name $20.
					UI_ID			   $8.
					total_all			8.
					total_female		8.
					total_male			8.
					ap_female			8.
					ap_male				8.
					black_female		8.
					black_male			8.
					hispanic_female		8.
					hispanic_male		8.
					other_female		8.
					other_male			8.
					white_female		8.
					white_male			8.
						
			;
					input
					master_school_name $
					UI_ID			   $
					total_all				
					total_female		
					total_male			
					ap_female			
					ap_male				
					black_female		
					black_male			
					hispanic_female		
					hispanic_male		
					other_female		
					other_male			
					white_female		
					white_male	
			;
			if UI_ID = "" then delete;
			run;

		%end;
	%end;
%end;
%mend;
%readin;



options mprint symbolgen;

%macro missing;

%let i= 0607 0708 0809 0910;
%do yr=1 %to 4;
%let year = %scan(&i.,&yr.,' ');

	%let y=RK mc;
	%do nm=1 %to 2;
	%let name=%scan(&y.,&nm.,' ');

		%let z=PCSB DCPS;
		%do tp=1 %to 2;
		%let type= %scan(&z.,&tp.,' ');

		data &type._&year._&name._nomiss;
			set &type._&year._&name.;
			if total_all =. then total_all = 99999;
			if total_female =. then total_female = 99999;
			if total_male =. then total_male = 99999;
			if ap_female =. then ap_female = 99999;
			if ap_male =. then ap_male = 99999;
			if black_female =. then black_female = 99999;
			if black_male =. then black_male = 99999;
			if hispanic_female =. then hispanic_female = 99999;
			if hispanic_male =. then hispanic_male = 99999;
			if other_female =. then other_female = 99999;
			if other_male =. then other_male = 99999;
			if white_female =. then white_female = 99999;
			if white_male =. then white_male = 99999;

		run;

		%end;
	%end;
%end;

%mend;
%missing;


%macro compare;
%let i= 0607 0708 0809 0910;
%do yr=1 %to 4;
%let year = %scan(&i.,&yr.,' ');

	%let z=PCSB DCPS;
	%do tp=1 %to 2;
	%let type= %scan(&z.,&tp.,' ');

		proc sort data=&type._&year._mc_nomiss;
		by UI_ID;
		run;
		proc sort data=&type._&year._rk_nomiss;
		by UI_ID;
		run;

		proc compare base=&type._&year._mc_nomiss compare=&type._&year._rk_nomiss out=&type._&year._diff_nomiss outdif;
		id UI_ID;
		run;
	

ods html file="D:\DCData\Libraries\Schools\Raw\race_ethnicity\&type._&year._nomissdiff.xls" style=minimal;
proc print data=&type._&year._diff_nomiss noobs;
run;
ods html close;

	%end;
%end;

%mend;
%compare;
