/**************************************************************************
 Program:  schools_14_15.sas
 Project:  schools
 Author:   S.Zhang 
 Created:  5/7/2015
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description: Adds newest year (2014-2015)
 Modifications:
**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";

%DCData_lib( library=Schools)

libname nmast "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file\14_15_data";
libname omast "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file\13_14_data";
libname enroll "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Enrollment";
option nofmterr mprint mlogic; 

/*where census block shape file is saved*/
libname map "K:\Metro\PTatian\DCData\Libraries\Schools\Maps";

/*reflecting reference years*/
%let earliestY=2000;
%let prevY=13;
%let newY1=14;
%let newY2=15;


/*neeeed to fix - tktktk*/
proc datasets lib=enroll nolist;
       modify allenrollment_1314;
           format ui_id;          *Remove formats;
       quit;
   run;

/********** CLEANING *******************************/
/*re-name variables in new school directory*/
%macro rename_variables(y1,y2);
data new_directory ( keep=ui_id notes_20&y1. school_name_20&y1. sch_20&y1._address x_coord_20&y1. y_coord_20&y1.);
	/*length ui_id $ 8;*/
	set nmast.schools_&y1.&y2. (rename=(
	name=school_name_20&y1.
	notes=notes_20&y1.
	address=sch_20&y1._address));
	/*
	ui_idC = put(ui_id, 8.) ; 
	drop ui_id; 
	rename UI_idC=UI_ID ;
	*/
	x_coord_20&y1.=input(x,best12.);
	y_coord_20&y1.=input(y,best12.);
run;

%mend rename_variables;
%rename_variables(&newY1.,&newY2.);

/* produced sorted data set of new data for master school file*/
proc sort data=new_directory; by ui_id; run;
/*update to MSF from previous year*/
proc sort data=omast.msf0013 out=old_msf; by ui_id; run;

options nofmterr;
/*merge new data to old data*/
data all_years;
	retain ui_id master_school_name;
	length ui_id $ 8;
	merge new_directory old_msf;
	by ui_id;
run;

/*fill out closed and missing master school name and missing addresses*/
%macro fill_closed_or_missing(y);
data all_years;
	set all_years;
	/*if not in directory and closed last year, mark as closed*/
	if compare(school_name_20&y.,'')=0 then do;
		if compare(school_name_20&prevY.,'CLOSED')=0 then school_name_20&y.="CLOSED";
	end;
	/*close out newly closed schools -- NEED TO EDIT MANUALLY*/
	if compare(school_name_20&y.,'')=0 then do;
		if (
		ui_id='3200005' OR
		ui_id='3200004' OR
		ui_id='1094000' OR
		ui_id='3201606' OR
		ui_id='2104402' OR
		ui_id='2103401' 
 ) then school_name_20&y.="CLOSED";
	end;

/*fills out entries with no address -- programs with no enrollment numbers and no fixed address, but exist*/
if (ui_id='01X02700' OR
	ui_id='01X11800' OR
	ui_id='01X15300' OR
	ui_id='01X17500' OR
	ui_id='01X17600' OR
	ui_id='01X17700' OR
	ui_id='01X90200') then do;
		school_name_20&y. = "AVAILABLE";
		sch_20&y._address = "AVAILABLE";
		sch_20&y._zip = .;
		x_coord_20&y. = .;
		y_coord_20&y. = .;
	end;
run;
%mend fill_closed_or_missing;

%fill_closed_or_missing(14);


/*this macro ensures address information indicates it's closed for new data*/
%macro complete_close(y);
data all_years;
	set all_years;
	if (compare(school_name_20&y.,'CLOSED')=0 OR compare(school_name_20&y.,'DEMOLISHED')=0) AND compare(school_name_20&y.,'') NE 0 then do;
		sch_20&y._address = "CLOSED";
		sch_20&y._zip = .;
		x_coord_20&y. = .;
		y_coord_20&y. = .;
	end;
run;
%mend complete_close;

%complete_close(14);

data all_years;
	set all_years;
	/*set master school name for those missing a name (like new schools that just opened that year*/
	if compare(master_school_name,'')=0 then do;
		if compare(school_name_20&prevY.,'')=0 then do; master_school_name=school_name_20&newY1.; new_school=1; end;
		else new_school=0;
	end;

run;

/*CHECKS*/
/*subset out the ones that might be closed but weren't succesfully closed out, should be empty if it's right*/
/*
data unclosed_subset;
	set all_years;
	if compare(school_name_2014,'')=1 then delete;
run;
*/
/*subset out the new schools*/
/*
data new_schools;
	set all_years;
	if new_school=0 then delete;
run;
*/

/*keep original with old geographies*/
/*data nmast.all_years_original; set all_years; run;*/

/*drop all old geography variables and old enrollment*/
%macro drop_old_geo();
data all_years (keep = ui_id master_school_name dcps pubc  
	%do i=&earliestY. %to 20&newY1.;
		school_name_&i. sch_&i._address sch_&i._zip x_coord_&i. y_coord_&i. notes_&i. 
	%end;
	);
	set all_years;
run;
%mend drop_old_geo;
%drop_old_geo();

/*check for missing addresses*** SCOTUS*/
/*disregard discrepancies linked to the 01X schools
--check for discrepancies in the current year (discrep_flag_CURRENT YEAR)
--past discrepancies are intentional (for example, virtual schools with no addresses)*/
%macro check_addr();
	data discrepancies (keep= ui_id master_school_name 
			%do i=&earliestY. %to 20&newY1.; 
				school_name_&i. x_coord_&i. sch_&i._address discrep_flag_&i. notes_&i.
			%end;);
		set all_years;
		/* checks if school is listed as something other than closed, but there is no x coordinate */
		%do i=&earliestY. %to 20&newY1.;
		if  x_coord_&i. =. AND (compare(sch_&i._address,'CLOSED') NE 0 AND compare(sch_&i._address,'') NE 0 AND compare(sch_&i._address,'.') NE 0) then do; 
			discrep_flag_&i. = 1;
			discrep_master = 1;
			end;
		%end;
		if discrep_master = . then delete; 
	 run;
%mend;
%check_addr();

/*merge with grade min/max file, generated based on the enrollment data*/
proc sort data=enroll.minmax_&newY1.&newY2. out=minmax; by ui_id; run;

data all_years;
	merge all_years minmax;
	by ui_id;
run;

/*set open flag*/
%macro set_open_flag_msf();
data all_years;
	set all_years ; 
	/*set open flag*/
	%do i=&earliestY. %to 20&newY1.;
		if x_coord_&i. ^=. AND y_coord_&i. ^=. then open_&i.=1;
		else open_&i.=0;
	%end;
run; 
%mend set_open_flag_msf;

%set_open_flag_msf();

/*set as DCPS or charter*/
%macro fill_dcps();
	data all_years;
		set all_years;
		first_dig = substr(ui_id, 1,1);
		%do i=&earliestY. %to 20&newY1.;
			if first_dig=1 then dcps =1;
			else if first_dig=2 or first_dig=3 then dcps=0; 
		%end;
	run;
%mend;

%fill_dcps();

/*************************GEOCODING*************************************/
/*convert select variables to char*/
%macro convert_to_char(geo, fmt);
	%do i=2000 %to 20&newY1.;
	char_&geo._&i. = put(&geo._&i., &fmt.) ; 
	drop &geo._&i. ; 
	if strip(char_&geo._&i. )='.' then char_&geo._&i. = ' ';
	rename char_&geo._&i.=&geo._&i. ;
	%end;
%mend;

proc sort data=all_years; by ui_id; run;

/*just geocodes current year*/
%macro geo;

	%let dsets = anc block00 cluster_tr2000 psa tract ward zip_profiles;
	%let dvars = anc_id BLKIDFP00 cluster00 psa geoid name zipcode;
	%let rname = anc2012 geoblk2000 cluster_tr2000 psa2012 geo2010 ward2012 zip;
	%let words = %sysfunc(countw(&dsets.));

/*sort map variables by ID*/
%do i = 1 %to &words.;
		%let dset = %scan(&dsets.,&i.," ");
		%let dvar = %scan(&dvars.,&i.," ");
		%let rn = %scan(&rname.,&i.," ");
		%let word = %scan(&words.,&i.," ");

		proc sort data= map.&dset._md; by &dvar.; run;

/*Geocode*/
%do y=2000 %to 20&newY1.;
		data geocoded_&y.;
		set all_years (keep= ui_id x_coord_&y. y_coord_&y.);
			rename x_coord_&y.=x y_coord_&y.=y;
			if x_coord_&y. =. then delete;
		run;

		proc ginside data = geocoded_&y. map = map.&dset._md out = &dset._&y.;
			id &dvar.;
		run;
		
		data &dset._&y.;
			set &dset._&y.;
			keep ui_id &dvar.;
			rename &dvar. = &rn._&y.;
		run;

		proc sort data = &dset._&y.; by ui_id; run;
	%end;
%end;



%do y=2000 %to 20&newY1.;
proc sort data = Block00_&y. (rename=(geoblk2000_&y.=geoblk2000)); by ui_id; run;

data other_geocode_&y.;
	set Block00_&y.;
		%Block00_to_anc02()
		%Block00_to_cluster00()
		%Block00_to_eor()
		%Block00_to_psa04()
		%Block00_to_tr00()
		%Block00_to_ward02()
		%Block00_to_city()
		%Block00_to_vp12()
run;

data other_geocode_&y. (keep = ui_id geoblk2000_&y. geo2000_&y. cluster2000_&y. anc2002_&y. psa2004_&y. ward2002_&y. eor_&y. city_&y. voterpre2012_&y.);
	set other_geocode_&y.;
	rename geoblk2000=geoblk2000_&y. geo2000=geo2000_&y. cluster2000=cluster2000_&y.
		anc2002=anc2002_&y. psa2004=psa2004_&y. ward2002=ward2002_&y. eor=eor_&y. city=city_&y. voterpre2012=voterpre2012_&y.;
run;
%end;

/*merge current year to old years*/
	data all_years_geo (drop=geoblk2000);
		merge %do y=2000 %to 20&newY1.; 
			other_geocode_&y.
			%do i = 1 %to &words.; 
				%let word = %scan(&words.,&i.," ");
				%let dset = %scan(&dsets.,&i.," ");
				&dset._&y.
			%end;
			%end;
			all_years;
		by ui_id;
	run;

	data all_years_geo;
		set all_years_geo;
		%convert_to_char(zip, z5.);
		%convert_to_char(psa2012, z3.);
	run;

	data nmast.msf00&newY1.;
	retain ui_id master_school_name %do i=20&newY1. %to &earliestY. %by -1;
		school_name_&i. sch_&i._address geoblk2000_&i. geo2000_&i. geo2010_&i. cluster2000_&i. cluster_tr2000_&i. 
			anc2002_&i. anc2012_&i. psa2004_&i. psa2012_&i. ward2002_&i. ward2012_&i. zip_&i. eor_&i. city_&i. voterpre2012_&i.
	%end;;
	set all_years_geo;
	run;
%mend geo;
%geo;

/*APPLY FORMATS TO MSF*/
%macro apply_geo_formats(level=);

  %local level_lbl level_fmt;

  ** Get standard geography information **;
  %let level = %upcase( &level );

  %if %sysfunc( putc( &level, $geoval. ) ) ~= %then %do;
    %let level_lbl = %qsysfunc( putc( &level, $geodlbl. ) );
    %let level_fmt = %sysfunc( putc( &level, $geoafmt. ) );
  %end;
  %else %do;
    %err_mput( macro=Summarize, 
               msg=Level (LEVEL=&level) is not recognized. )
    %goto exit;
  %end;

data nmast.msf00&newY1.;
	set nmast.msf00&newY1.;
	%do i=&earliestY. %to 20&newY1.;
      	format &level._&i. &level_fmt;
	  	label &level._&i.= "&i - &level_lbl";
	 %end;
run;

  %exit:

%mend apply_geo_formats;

%macro apply_fmts_and_lbls();
%apply_geo_formats( level=city )
%apply_geo_formats( level=anc2002 )
%apply_geo_formats( level=anc2012 )
%apply_geo_formats( level=psa2004 )
%apply_geo_formats( level=psa2012 )
%apply_geo_formats( level=eor )
%apply_geo_formats( level=geo2000 )
%apply_geo_formats( level=geo2010 )
%apply_geo_formats( level=geoblk2000 )
%apply_geo_formats( level=cluster_tr2000 )
%apply_geo_formats( level=cluster2000 )
%apply_geo_formats( level=ward2002 )
%apply_geo_formats( level=ward2012 )
%apply_geo_formats( level=zip )
%apply_geo_formats( level=voterpre2012 )

data nmast.msf00&newY1.;
	set nmast.msf00&newY1.;
	label master_school_name="Master School Name";
	label dcps="DCPS School";
	%do i=&earliestY. %to 20&newY1.;
	label school_name_&i.="&i. - School Name";
	label sch_&i._address="&i. - Street Address";
	label open_&i.="&i. - School Open";
	label x_coord_&i. = "&i. - X Coordinate";
	label y_coord_&i. = "&i. - Y Coordinate";
	label grade_min_&i. = "&i. - Lowest Grade";
	label grade_max_&i. = "&i. - Highest Grade";
	label adult_flag_&i. = "&i. - Adult Enrollees ";
	%end;
run;
%mend;
%apply_fmts_and_lbls();

/*merge msf and enrollment file*/
data enroll_to_merge;
	set enroll.allenrollment_1415;
	if grade NE 'total' then delete;
run;

data msf_enroll;
	merge nmast.msf00&newY1. enroll_to_merge;
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


/************************** START CREATE SUMMARY FILES******************************************not run.*/

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

data schools.MSF_sum&filesuf.;
	merge %do i=&earliestY. %to 20&newY1.; MSFs&filesuf._&i. %end; %do i=2001 %to 20&newY1.; MSFe&filesuf._&i.  %end;;
	by &level;
run;
  ** Recode missing number of sales to 0 **;
%let varlist = school_present charter_present dcps_present aud aud_dcps aud_charter;

data schools.MSF_sum&filesuf (label=&file_lbl);
    set schools.MSF_sum&filesuf;
	%do j=1 %to 6;
		%let var = %scan(&varlist.,&j.," ");
		%do i=&earliestY. %to 20&newY1.;
		if &var._&i. =. then &var._&i. =0;
		%end;
	%end;
	/*no 2000 enrollment data*/
	drop aud_2000 aud_dcps_2000 aud_charter_2000;
  run;


  %file_info( data=schools.MSF_sum&filesuf, printobs=5 )

  run;
  %exit:

  %Dc_update_meta_file(
  ds_lib=Schools,
  ds_name=MSF_sum&filesuf,
  creator_process=schools_14_15,
  restrictions=None,
  revisions=%str(Updated with 2014-2015 SY data)
)


%mend Summarize;

/** End Macro Definition **/

%Summarize( level=city )
%Summarize( level=anc2002 )
%Summarize( level=anc2012 )
%Summarize( level=psa2004 )
%Summarize( level=psa2012 )
%Summarize( level=eor )
%Summarize( level=geo2000 )
%Summarize( level=geo2010 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=cluster2000 )
%Summarize( level=ward2002 )
%Summarize( level=ward2012 )
%Summarize( level=zip )
%Summarize( level=voterpre2012 )


/*identify observations where there's no enrollment to merge on*/
data unmatched;
	set msf_enroll;
	if schooltype^=. then delete;
run;

proc sort data=msf_enroll out=msf_sorted; by master_school_name; run;

proc format;
value $eor_alt 
 '1' = 'East of the River'
 '0' = 'Not East of the River'
;
run;

%macro create_public();
data nmast.msf00&newY1._public (drop=pubc first_dig new_school %do i=&earliestY. %to 20&newY1.; notes_&i. city_&i. sch_&i._zip enroll_open_&i. %end;);
	retain ui_id master_school_name dcps;
	set nmast.msf00&newY1.;
		%do i=&earliestY. %to 20&newY1.;
		format eor_&i.;
		format eor_&i. $eor_alt.;
		if eor_&i. = 9 then eor_&i. =0;
		%end;
run;

data nmast.msf00&newY1._public_enroll (drop=pubc first_dig new_school %do i=&earliestY. %to 20&newY1.; notes_&i. city_&i. sch_&i._zip enroll_open_&i. %end; rep_: schooltype);
		retain ui_id master_school_name dcps %do i=20&newY1. %to &earliestY. %by -1;
		school_name_&i. sch_&i._address geoblk2000_&i. geo2000_&i. geo2010_&i. cluster2000_&i. cluster_tr2000_&i. 
			anc2002_&i. anc2012_&i. psa2004_&i. psa2012_&i. ward2002_&i. ward2012_&i. zip_&i. eor_&i. city_&i. voterpre2012_&i.
		%end; x_: y_: aud_: open_:;
	set msf_enroll;
		/*if ui_id="1026501" then delete;*/
		%do i=&earliestY. %to 20&newY1.;
		format eor_&i.;
		format eor_&i. $eor_alt.;
		if eor_&i. = 9 then eor_&i. =0;
		%end;
		/*for enrollment figures*/
	%do i=1 %to &newY1.;
		%let val=%sysfunc(putn(&i,z2.));
		%let val2=%sysfunc(sum(&val.,1));
		%let val2=%sysfunc(putn(&val2.,z2.));
		/*rename enrollment vars for easy looping in next step*/
		drop aud_20&val.;
		rename aud_&val.&val2. = aud_20&val.;
	%end;
run;
	
%mend;

%create_public();



/*test consistency across geographies and across MSF and enrollment*/
%macro testing_consistency();
	/*check school total consistency across summary files: in Work.running_sumry, all totals should be the same
	%let fname =anc02 anc12 city cltr00 cl00 eor psa04 psa12 tr00 tr10 wd02 wd12 zip;
	%do j=1 %to 13;
		%let filename = %scan(&fname.,&j.," ");
	proc means data=schools.msf_sum_&filename. sum;
		var %do i=&earliestY. %to 20&newY1.; school_present_&i. dcps_present_&i. charter_present_&i. %end; %do i=2001 %to 20&newY1.; aud_&i. aud_dcps_&i. aud_charter_&i. %end;;
		output out=sumry_&filename. sum(%do i=&earliestY. %to 20&newY1.; school_present_&i. dcps_present_&i. charter_present_&i. %end; %do i=2001 %to 20&newY1.; aud_&i. aud_dcps_&i. aud_charter_&i. %end;)= 
			%do i=&earliestY. %to 20&newY1.; school_tot_&i. dcps_tot_&i. charter_tot_&i. %end; %do i=2001 %to 20&newY1.; aud_tot_&i. aud_dcps_tot_&i. aud_charter_tot_&i. %end;;
	run;
	data sumry_&filename.;
		set sumry_&filename.;
		geoname = "&filename";
	run;
	proc append base=running_sumry data=sumry_&filename. force; run;
	%end;
	*/
	/*check if geocoded zips match up with original zips; the zip_mismatch flag should not be raised*/
	data zip_mismatch;
		set nmast.msf00&newY1._public_enroll;
	%do i=&earliestY. %to 20&newY1.;
		if zip_&i. ^= sch_&i._zip and zip_&i. ^=' ' and sch_&i._zip ^=. then do; zip_mismatch_&i.=1; master_mismatch=1; end;
	%end;
	if master_mismatch ^=1 then delete;
	run;

	/*find schools with missing dcps*/
	data missing_dcps;
		set nmast.msf00&newY1.;
		if dcps ^=. then delete;
	run;

	/*check if there are any schools with enrollments where the school is marked as closed*/
	data uncounted_enroll (keep= ui_id master_school_name flag_uncounted: aud_: open_:);
		set nmast.msf00&newY1._public_enroll;
		%do i=2001 %to 20&newY1.;
			if open_&i.=0 and aud_&i.>0 then do; flag_uncounted=1; flag_uncounted_&i. = 1; end; 
		%end;
		if flag_uncounted_2013^=1 then delete;
	run;

	/*check if there are any schools with enrollments where the school is not geocoded into DC*/
	data uncounted2_enroll (keep= ui_id master_school_name flag_uncounted: aud_: open_: city_:);
		set nmast.msf00&newY1._public_enroll;
		%do i=2001 %to 20&newY1.;
			if city_&i.^=1 and aud_&i.>0 then do; flag_uncounted=1; flag_uncounted_&i. = 1; end; 
		%end;
		if flag_uncounted^=1 then delete;
	run;
%mend;
/*%testing_consistency();*/

