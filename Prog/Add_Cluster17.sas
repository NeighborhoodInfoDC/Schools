/**************************************************************************
 Program:  Add Cluster17.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  03/16/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description: Add Cluster 17 to Master School File and Recreate summary files. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( schools )

libname msf "L:\Libraries\Schools\Data\Master school file\14_15_data";
libname enroll "L:\Libraries\Schools\Data\Enrollment";

%let earliestY=2000;
%let prevY=13;
%let newY1=14;
%let newY2=15;

data add17;
	set msf.msf0014; 

%Block00_to_cluster17(invar=geoblk2000_2000, outvar=cluster2017_2000)
%Block00_to_cluster17(invar=geoblk2000_2001, outvar=cluster2017_2001)
%Block00_to_cluster17(invar=geoblk2000_2002, outvar=cluster2017_2002)
%Block00_to_cluster17(invar=geoblk2000_2003, outvar=cluster2017_2003)
%Block00_to_cluster17(invar=geoblk2000_2004, outvar=cluster2017_2004)
%Block00_to_cluster17(invar=geoblk2000_2005, outvar=cluster2017_2005)
%Block00_to_cluster17(invar=geoblk2000_2006, outvar=cluster2017_2006)
%Block00_to_cluster17(invar=geoblk2000_2007, outvar=cluster2017_2007)
%Block00_to_cluster17(invar=geoblk2000_2008, outvar=cluster2017_2008)
%Block00_to_cluster17(invar=geoblk2000_2009, outvar=cluster2017_2009)
%Block00_to_cluster17(invar=geoblk2000_2010, outvar=cluster2017_2010)
%Block00_to_cluster17(invar=geoblk2000_2011, outvar=cluster2017_2011)
%Block00_to_cluster17(invar=geoblk2000_2012, outvar=cluster2017_2012)
%Block00_to_cluster17(invar=geoblk2000_2013, outvar=cluster2017_2013)
%Block00_to_cluster17(invar=geoblk2000_2014, outvar=cluster2017_2014)


run;
/* test
proc print data=add17;
where cluster2017_2014 = ' ' and cluster2000_2014 ~= ' ';
var ui_id;
run;
*/

proc sort data=add17;
by ui_id;

/*begin FROM schools_14_15.sas swapped add17 for nmast.msf00&newY1. */ 
/*merge msf and enrollment file*/
data enroll_to_merge;
	set enroll.allenrollment_1415;
	if grade NE 'total' then delete;
run;

data msf_enroll;
	merge add17 enroll_to_merge;
	by ui_id;
run;


/*HANDLE SPECIAL SCHOOLS*/
%macro handle_special();
data msf_enroll;
	set msf_enroll;
	/*virtual schools - count toward city total but not at any lower levels of geography*/
	if ui_id='3201605' then do;
		%do i=2003 %to 2014;
			open_&i. = 1; 
			city_&i. =1;
		%end;
	end;
	/*not real schools*/
	if ui_id='01X02700' or ui_id='01X11800' or ui_id='01X15300' or ui_id='01X17500' or ui_id='01X17600' or ui_id='01X17700' or ui_id='01X90200' then do;
		%do i=2001 %to 2014;
			open_&i.=.;
		%end;
	end;

run;

%mend handle_special;
%handle_special();


/*create dummy variables for summary files*/
%macro create_dummies();
data msf00&newY1._dum;
	set msf_enroll;

	first_dig = substr(ui_id, 1,1);

	%do i=&earliestY. %to 20&newY1.;
	school_present_&i.=1;
	if first_dig=1 then dcps_present_&i.=1; else dcps_present_&i.=0;
	if first_dig=2 or first_dig=3 then charter_present_&i.=1; else charter_present_&i.=0;
	%end;

	/*for enrollment figures*/
	%do i=1 %to &newY1.;
		%let val=%sysfunc(putn(&i,z2.));
		%let val2=%sysfunc(sum(&val.,1));
		%let val2=%sysfunc(putn(&val2.,z2.));

		if dcps=1 then do; 
			aud_dcps_20&val. = aud_&val.&val2.; 
			aud_charter_20&val. = 0;
		end;
		else if dcps=0 then do;
			aud_charter_20&val.=aud_&val.&val2.; 
			aud_dcps_20&val. = 0; 
		end;

		/*rename enrollment vars for easy looping in next step*/
		drop aud_20&val.;
		rename aud_&val.&val2. = aud_20&val.;
	%end;
	/*fill enrollment based on school type*/

run;
%mend;
%create_dummies();


/*HANDLE SPECIAL SCHOOLS - after dummy creation - where it's not a school but enrollment counts*/
%macro handle_special2();
/*
if ui_id=01X02700 or ui_id=01X11800 or ui_id=01X15300 or ui_id=01X17500 or ui_id=01X17600 or ui_id=01X17700 or ui_id=01X90200
consolidated headstart - 1022500
pre-k incentive program - */
data msf00&newy1._dum;
	set msf00&newy1._dum;
	/*count toward enrollment but not as a school*/
	/*headstart*/
	if ui_id='1022500' then do;
		%do i=&earliestY. %to 2013;
			dcps_present_&i.=0;
			school_present_&i.=0;
		%end;
	end;
run;

%mend handle_special2;
%handle_special2();



/************************** START CREATE SUMMARY FILES******************************************
LH edited to remove overwriting of files*/

%macro Summarize( level= );

  %local filesuf level_lbl level_fmt file_lbl;

  ** Get standard geography information **;


  %let level = %upcase( &level );

  %if %sysfunc( putc( &level, $geoval. ) ) ~= %then %do;
    %let filesuf = %sysfunc( putc( &level, $geosuf. ) );
    %let level_lbl = %qsysfunc( putc( &level, $geodlbl. ) );
    %let level_fmt = %sysfunc( putc( &level, $geoafmt. ) );
  %end;
  %else %do;
    %err_mput( macro=Summarize, 
               msg=Level (LEVEL=&level) is not recognized. )
    %goto exit;
  %end;

  %let file_lbl = "Open Schools, DC, &level_lbl";
  ** Summarize by specified geographic level **;
%do i=&earliestY. %to 20&newY1.;
  proc summary data=msf00&newy1._dum nway completetypes;
      class &level._&i. /preloadfmt;
      format &level._&i. &level_fmt;
    var school_present_&i. dcps_present_&i. charter_present_&i.;
    output 
      out=MSFs&filesuf._&i. (rename=(&level._&i.=&level) drop=_freq_ _type_) 
      sum(school_present_&i. dcps_present_&i. charter_present_&i.)=;
    /** Note: Add labels here if variables are not labeled **/
	 label school_present_&i. = "Number of Schools Open, &i.";
	 label dcps_present_&i. = "Number of DCPS Schools Open, &i.";
	 label charter_present_&i. = "Number of Charter Schools Open, &i.";

  run;
%end;

%do i=2001 %to 20&newY1.;
  proc summary data=msf00&newy1._dum nway completetypes;
      class &level._&i. /preloadfmt;
      format &level._&i. &level_fmt;
    var aud_&i. aud_dcps_&i. aud_charter_&i.;
    output 
      out=MSFe&filesuf._&i. (rename=(&level._&i.=&level) drop=_freq_ _type_) 
      sum( aud_&i. aud_dcps_&i. aud_charter_&i.)=;
	 label aud_&i. = "Total Enrolled at All Schools, &i.";
	 label aud_dcps_&i. = "Total Enrolled at DCPS Schools, &i.";
	 label aud_charter_&i. = "Total Enrolled at Charter Schools, &i.";
  run;
%end;

data merge_MSF_sum&filesuf.;
	merge %do i=&earliestY. %to 20&newY1.; MSFs&filesuf._&i. %end; %do i=2001 %to 20&newY1.; MSFe&filesuf._&i.  %end;;
	by &level;
run;
  ** Recode missing number of sales to 0 **;
%let varlist = school_present charter_present dcps_present aud aud_dcps aud_charter;

data MSF_sum&filesuf (label=&file_lbl);
    set merge_MSF_sum&filesuf;
	%do j=1 %to 6;
		%let var = %scan(&varlist.,&j.," ");
		%do i=&earliestY. %to 20&newY1.;
		if &var._&i. =. then &var._&i. =0;
		%end;
	%end;
	/*no 2000 enrollment data*/
	drop aud_2000 aud_dcps_2000 aud_charter_2000;
  run;


 /* %file_info( data=schools.MSF_sum&filesuf, printobs=5 )*/

  run;
  %exit:

  /*
  %Dc_update_meta_file(
  ds_lib=Schools,
  ds_name=MSF_sum&filesuf,
  creator_process=schools_14_15,
  restrictions=None,
  revisions=%str(Updated with 2014-2015 SY data)
)
  */
  %Finalize_data_set(
	data=MSF_sum&filesuf,
	out=MSF_sum&filesuf,
	outlib=schools,
	label=&file_lbl.,
	sortby=&level.,
	register_metadata=Y,
	restrictions=None,
	revisions=New File.
	)


%mend Summarize;

/** End Macro Definition **/

%Summarize( level=cluster2017 )
