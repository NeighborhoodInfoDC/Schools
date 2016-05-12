/**************************************************************************
 Program:  schools_11_12_newgeo.sas
 Project:  schools
 Author:   S.Zhang 5/3/2013
 Created:  5/3/2013
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description: Merge DCPS and PCBS data to master school file
 Modifications:
**************************************************************************/
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";*/
%include "L:\SAS\Inc\StdLocal.sas";
%DCData_lib( library=Schools)

libname nmast "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file\11_13_data";
libname enroll "D:\DCData\Libraries\Schools\enrollment";
option nofmterr mprint mlogic; 

/*where census block shape file is saved*/
libname map "D:\DCData\Libraries\Schools\SAS Map Files\MD State Plane Maps";

/********** CLEANING *******************************/
%macro process_dcps(y1,y2);

data dcps&y1.&y2. ( 
	keep=ui_id notes_20&y1. school_name_20&y1. sch_20&y1._address sch_20&y1._zip x_coord_20&y1. y_coord_20&y1. dcps pubc);
	set nmast.Dcps&y1._&y2. (rename=(
	name=school_name_20&y1.
	address=sch_20&y1._address
	zip_code=sch_20&y1._zip
	x=x_coord_20&y1. 
	y=y_coord_20&y1.   
	%if &y1.=12 %then col2=notes_2012;));
	dcps=1;
	pubc=0;
run;

%mend process_dcps;

%process_dcps(11,12);
%process_dcps(12,13);


%macro process_pcsb(y1,y2);
/*doesn't come with zip*/
data pcsb&y1.&y2. ( keep=ui_id notes_20&y1. school_name_20&y1. sch_20&y1._address x_coord_20&y1. y_coord_20&y1.);
	set nmast.pcsb&y1._&y2. (rename=(
	name=school_name_20&y1.
	%if &y1.=12 %then address=sch_20&y1._address;));
	x_coord_20&y1.=input(x,best12.);
	y_coord_20&y1.=input(y,best12.);

run;

%mend process_pcsb;

%process_pcsb(11,12);
%process_pcsb(12,13);


/*sort and merge*/
%macro sort_merge(sb);

proc sort data=&sb.1112; by ui_id; run;

proc sort data=&sb.1213; by ui_id; run;

data &sb._merged;
	merge &sb.1213 &sb.1112 ;
	by ui_id;
	%if &sb.=pcsb %then %do;
		dcps=0;
		pubc=1;
	%end;
run;
%mend sort_merge;

%sort_merge(dcps);
/*take out filmore arts centers*/
data dcps_merged; set dcps_merged; if ui_id = "" then delete; run;
%sort_merge(pcsb);

data both_merged;
	length ui_id $ 8;
	length school_name_2012 $ 72;
	length school_name_2011 $ 72;
	set dcps_merged pcsb_merged;
run;

/* produced sorted data set of new data for master school file*/
proc sort data=both_merged; by ui_id; run;

proc sort data=nmast.msf0010 out=msf0010S; by ui_id; run;

data msf0010S;
	set msf0010S (rename=(dcps=dcpsi pubc=pubci));
	dcps=input(dcpsi,best12.);
	pubc=input(pubci,best12.);
run;

/*merge new data to old data*/
data all_years;
	retain ui_id master_school_name;
	merge both_merged msf0010S;
	by ui_id;
	if ui_id='2100304' then delete;
run;

/*fill out closed and missing master school name and missing addresses*/
%macro fill_closed_or_missing(y1);
data all_years;
	set all_years;
	if compare(school_name_20&y1.,'')=0 then do;
		if compare(school_name_2010,'CLOSED')=0 then school_name_20&y1.="CLOSED";
	end;
	/*close out newly closed schools*/
	if (ui_id="1056700" OR ui_id="1095300") then
		school_name_20&y1. = "CLOSED";
	if (ui_id="1041500" AND 12 = &y1.) then school_name_20&y1. = "CLOSED";

	if compare(school_name_20&y1.,'')=0 then do;
		if (
		ui_id='1022500' OR
		ui_id='1023500' OR
		ui_id='1024400' OR
		ui_id='1027800' OR
		ui_id='1029300' OR
		ui_id='1030400' OR
		ui_id='1031100' OR
		ui_id='1021900' OR
		ui_id='1033500' OR
		ui_id='1034800' OR
		ui_id='1035400' OR
		ui_id='1041000' OR
		ui_id='1043000' OR
		ui_id='1086000' OR
		ui_id='1093300' OR
		ui_id='1094900' OR
		ui_id='1095500' OR
		ui_id='1096000' OR
		ui_id='1099600' OR
		ui_id='2100204' OR
		ui_id='2100801' OR
		ui_id='2101101' OR
		ui_id='2101700' OR
		ui_id='2103203' OR
		ui_id='2104300' OR
		ui_id='2104600' OR
		ui_id='2104900' OR
		ui_id='2105600' OR
		ui_id='3200006' OR
		ui_id='3200100' OR
		ui_id='3200400' OR
		ui_id='3200700' OR
		ui_id='3201602' OR
		ui_id='3202300') then school_name_20&y1.="CLOSED";
	end;
	
	/*delete middle - keep with original upper school*/
	if ui_id="2100304" then delete;

	/*missing address - PRE-ENGINEERING SWSC DUNBAR*/
	if ui_id="1094000" then do;
		school_name_20&y1. = master_school_name;
		sch_20&y1._address = "1301 NEW JERSEY AVENUE NW";
		sch_20&y1._zip = "20001";
		x_coord_20&y1. = 398725.55;
		y_coord_20&y1. = 137851.55;
	end;

	/*missing address - BOOKER EVENING*/
	if ui_id="3200005" then do;
		school_name_20&y1. = master_school_name;
		sch_20&y1._address = "1346 FLORIDA AVENUE NW";
		sch_20&y1._zip = "20009";
		x_coord_20&y1. = 397295.64;
		y_coord_20&y1. = 139117.57;
	end;

	/*Roots PK-K combined with main entry */
	if ui_id="3201301" then do;
		school_name_20&y1. = master_school_name;
		sch_20&y1._address = "COMBINED";
		sch_20&y1._zip = .;
		x_coord_20&y1. = .;
		y_coord_20&y1. = .;
		notes_20&y1. = "combined pk-k with main school, no longer separate entry";
	end;
run;
%mend fill_closed_or_missing;

%fill_closed_or_missing(11);
%fill_closed_or_missing(12);

/*fills out entries with no address*/
%macro fill_virtual(y);
data all_years;
	set all_years;
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
%mend fill_virtual;

%fill_virtual(11);
%fill_virtual(12);

/*for administrative addresses - correcting old*/
data all_years;
	set all_years;
	if (ui_id = '01X02700' OR 
		ui_id = '01X11800' OR 
		ui_id = '01X15300' OR 
		ui_id = '01X17500' OR 
		ui_id = '01X17600' OR 
		ui_id = '01X17700' OR 
		ui_id = '01X90200') then do;
			sch_2006_address = "AVAILABLE";
			sch_2006_zip = .;
			sch_2005_address = "AVAILABLE";
			sch_2005_zip = .;
			sch_2004_address = "AVAILABLE";
			sch_2004_zip = .;
			sch_2004_zip = .;
		end;
run;

/*this macro fills school name as closed if address indicates it's closed */
%macro edit_old(y);
data all_years;
	set all_years;
	if compare(sch_20&y._address,'CLOSED')=0 then school_name_20&y.="CLOSED";
run;
%mend edit_old;

%edit_old(10);
%edit_old(09);
%edit_old(08);
%edit_old(07);
%edit_old(06);
%edit_old(05);
%edit_old(04);
%edit_old(03);
%edit_old(02);
%edit_old(01);
%edit_old(00);

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

%complete_close(11);
%complete_close(12);
%complete_close(10);
%complete_close(09);
%complete_close(08);
%complete_close(07);
%complete_close(06);
%complete_close(05);
%complete_close(04);
%complete_close(03);
%complete_close(02);
%complete_close(01);
%complete_close(00);



data all_years;
	set all_years;
	if ui_id="2104403" then school_name_2011 = "AppleTree Early Learning PCS- Douglas Knoll";
	if ui_id="2104404" then school_name_2011 = "AppleTree Early Learning PCS- Lincoln Park";
	if ui_id="2104406" then school_name_2012 = "AppleTree Early Learning PCS - Parkland";
	if ui_id="2106700" then master_school_name = school_name_2012;
	if ui_id="2104405" then master_school_name = school_name_2012;
	if ui_id="2103100" then master_school_name = "E.L. Haynes PCS - Georgia Avenue";
	if ui_id="2103101" then master_school_name = "E.L. Haynes PCS - Kansas Avenue (Grades 9-12)";
	if ui_id="2103102" then master_school_name = "E.L. Haynes PCS - Kansas Avenue (Grades PS-3)";
	if ui_id="1049000" then master_school_name = school_name_2011;
	if ui_id="2106209" then master_school_name = school_name_2012;
	if ui_id="2106500" then master_school_name = school_name_2011;
	if ui_id="3200006" then master_school_name = school_name_2011;

	/*set master school name for those missing a name*/
	if compare(master_school_name,'')=0 then do;
		if compare(school_name_2011,'')=0 then master_school_name=school_name_2012;
		else if compare(school_name_2011,school_name_2012)=0 then master_school_name=school_name_2012;
	end;
run;


/*subset out the ones that might be closed*/
/*
data closed_subset2;
	set all_years;
	if compare(school_name_2011,'')=1 AND compare(school_name_2012,'')=1 then delete;
	if compare(school_name_2012,'')=1 then delete;
run;
*/
/*subset out the ones without master school names*/
/*data missing_mastername2;
	set all_years;
	if compare(master_school_name,'')=1 then delete;
run;
*/


/*keep original with old geographies*/
data nmast.all_years_original; set all_years; run;

/*drop all old geography variables*/
%macro drop_old_geo();
data all_years (keep = ui_id master_school_name dcps pubc  
	%do i=2000 %to 2012;
		school_name_&i. sch_&i._address sch_&i._zip x_coord_&i. y_coord_&i. notes_&i. 
	%end;
	);
	set all_years;
run;
%mend drop_old_geo;

%drop_old_geo();

/*check for missing addresses*** SCOTUS*/
%macro check_addr();
	data discrepancies (keep= ui_id master_school_name 
			%do i=2000 %to 2012; 
				school_name_&i. x_coord_&i. sch_&i._address discrep_flag_&i. notes_&i.
			%end;);
		set all_years;
		/* checks if school is listed as something other than closed, but there is no x coordinate */
		%do i=2000 %to 2012;
		if  x_coord_&i. =. AND (compare(sch_&i._address,'CLOSED') NE 0 AND compare(sch_&i._address,'') NE 0 AND compare(sch_&i._address,'.') NE 0) then do; 
			discrep_flag_&i. = 1;
			discrep_master = 1;
			end;
		%end;
		if discrep_master = . then delete; 
	 run;

%mend;

%check_addr();

/*merge with grade min/max file*/
proc sort data=enroll.minmax out=minmax; by ui_id; run;

data all_years;
	merge all_years minmax;
	by ui_id;
run;

/*set open flag*/
%macro set_open_flag_msf();
data all_years;
	set all_years ; 
	/*set open flag*/
	%do i=2000 %to 2012;
		if x_coord_&i. ^=. AND y_coord_&i. ^=. then open_&i.=1;
		else open_&i.=0;
	%end;
run; 
%mend set_open_flag_msf;

%set_open_flag_msf();

%macro fill_dcps();
	data all_years;
		set all_years;
		first_dig = substr(ui_id, 1,1);

		%do i=2000 %to 2012;
			if first_dig=1 then dcps =1;
			else if first_dig=2 or first_dig=3 then dcps=0; 
		%end;
%mend;

%fill_dcps();

/*************************GEOCODING*************************************/
/*convert select variables to char*/
%macro convert_to_char(geo, fmt);
	%do i=2000 %to 2012;
	char_&geo._&i. = put(&geo._&i., &fmt.) ; 
	drop &geo._&i. ; 
	if strip(char_&geo._&i. )='.' then char_&geo._&i. = ' ';
	rename char_&geo._&i.=&geo._&i. ;
	%end;
%mend;

proc sort data=all_years; by ui_id; run;


%macro geo;

	%let dsets = anc block00 cluster_tr2000 psa tract ward zip_profiles;
	%let dvars = anc_id BLKIDFP00 cluster00 psa geoid name zipcode;
	%let rname = anc2012 geoblk2000 cluster_tr2000 psa2012 geo2010 ward2012 zip;
	%let words = %sysfunc(countw(&dsets.));

/* change 2000-2005 X Y data to numeric*/
data master_w;
	set master_w;
	%do i=0 %to 5;
		newage = input(age,3.0); 
		drop age; 
		rename newage=age;
	%end;
run;
/*sort map variables by ID*/
%do i = 1 %to &words.;
		%let dset = %scan(&dsets.,&i.," ");
		%let dvar = %scan(&dvars.,&i.," ");
		%let rn = %scan(&rname.,&i.," ");
		%let word = %scan(&words.,&i.," ");

		proc sort data= map.&dset._md; by &dvar.; run;

/*Geocode*/
%do y=2000 %to 2012;
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


%do i=2000 %to 2012;
proc sort data = Block00_&i. (rename=(geoblk2000_&i.=geoblk2000)); by ui_id; run;

data other_geocode_&i.;
	set Block00_&i.;
		%Block00_to_anc02()
		%Block00_to_cluster00()
		%Block00_to_eor()
		%Block00_to_psa04()
		%Block00_to_tr00()
		%Block00_to_ward02()
		%Block00_to_city()
		%Block00_to_vp12()
run;

data other_geocode_&i. (keep = ui_id geoblk2000_&i. geo2000_&i. cluster2000_&i. anc2002_&i. psa2004_&i. ward2002_&i. eor_&i. city_&i. voterpre2012_&i.);
	set other_geocode_&i.;
	rename geoblk2000=geoblk2000_&i. geo2000=geo2000_&i. cluster2000=cluster2000_&i.
		anc2002=anc2002_&i. psa2004=psa2004_&i. ward2002=ward2002_&i. eor=eor_&i. city=city_&i. voterpre2012=voterpre2012_&i.;
run;
%end;


	data all_years_geo (drop=geoblk2000);
		merge %do y=2000 %to 2012; 
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

	data nmast.msf0012;
	retain ui_id master_school_name %do i=2012 %to 2000 %by -1;
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

data nmast.msf0012;
	set nmast.msf0012;
	%do i=2000 %to 2012;
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

data nmast.msf0012;
	set nmast.msf0012;
	label master_school_name="Master School Name";
	label dcps="DCPS School";
	%do i=2000 %to 2012;
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
data msf_enroll;
	merge nmast.msf0012 enroll.enroll_to_merge;
	by ui_id;
run;

/*HANDLE SPECIAL SCHOOLS*/
%macro handle_special();
data msf_enroll;
	set msf_enroll;
	/*virtual schools - count toward city total but not at any lower levels of geography*/
	if ui_id='3201605' then do;
		%do i=2003 %to 2012;
			open_&i. = 1; 
			city_&i. =1;
		%end;
	end;
	/*consolidated headstart*/
	if ui_id='1022500' then do;
		%do i=2000 %to 2009;
			open_&i.=1;
			city_&i. =1;
		%end;
	end;
	/*pre-k incentive program*/
	if ui_id='1099600' then do;
		%do i=2005 %to 2009;
			open_&i.=1;
			city_&i. =1;
		%end;
	end;
	/*oakhill academy*/
	if ui_id='1086000' then do;
		%do i=2001 %to 2009;
			open_&i.=1;
			city_&i.=1;
		%end;
	end;	
	/*not real schools*/
	if ui_id='01X02700' or ui_id='01X11800' or ui_id='01X15300' or ui_id='01X17500' or ui_id='01X17600' or ui_id='01X17700' or ui_id='01X90200' then do;
		%do i=2001 %to 2012;
			open_&i.=.;
		%end;
	end;

run;

%mend handle_special;
%handle_special();

/*create dummy variables for summary files*/
%macro create_dummies();
data msf0012_dum;
	set msf_enroll;

	first_dig = substr(ui_id, 1,1);

	%do i=2000 %to 2012;
	school_present_&i.=1;
	if first_dig=1 then dcps_present_&i.=1; else dcps_present_&i.=0;
	if first_dig=2 or first_dig=3 then charter_present_&i.=1; else charter_present_&i.=0;
	%end;

	/*for enrollment figures*/
	%do i=1 %to 12;
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
data msf0012_dum;
	set msf0012_dum;
	/*count toward enrollment but not as a school*/
	/*headstart*/
	if ui_id='1022500' then do;
		%do i=2000 %to 2012;
			dcps_present_&i.=0;
			school_present_&i.=0;
		%end;
	end;
	/*pre-k incentive*/
	if ui_id='1099600' then do;
		%do i=2005 %to 2009;
			dcps_present_&i.=0;
			school_present_&i.=0;
		%end;
	end;
	/*oakhill academy*/
	if ui_id='1086000' then do;
		%do i=2001 %to 2009;
			dcps_present_&i.=0;
			school_present_&i.=0;
		%end;
	end;	

run;

%mend handle_special2;
%handle_special2();


/** START CREATE SUMMARY FILE**/

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
%do i=2000 %to 2012;
  proc summary data=msf0012_dum nway completetypes;
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

%do i=2001 %to 2012;
  proc summary data=msf0012_dum nway completetypes;
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
	merge %do i=2000 %to 2012; MSFs&filesuf._&i. %end; %do i=2001 %to 2012; MSFe&filesuf._&i.  %end;;
	by &level;
run;
  ** Recode missing number of sales to 0 **;
%let varlist = school_present charter_present dcps_present aud aud_dcps aud_charter;

data schools.MSF_sum&filesuf (label=&file_lbl);
    set schools.MSF_sum&filesuf;
	%do j=1 %to 6;
		%let var = %scan(&varlist.,&j.," ");
		%do i=2000 %to 2012;
		if &var._&i. =. then &var._&i. =0;
		%end;
	%end;
	/*no 2000 enrollment data*/
	drop aud_2000 aud_dcps_2000 aud_charter_2000;
  run;


  %file_info( data=schools.MSF_sum&filesuf, printobs=5 )

  run;
  %exit:

%mend Summarize;

/** End Macro Definition **/
%summarize( level= voterpre2012 )
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

/*identify observations that didn't merge properly*/
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
data nmast.msf0012_public (drop=pubc first_dig %do i=2000 %to 2012; notes_&i. city_&i. sch_&i._zip enroll_open_&i. %end;);
	retain ui_id master_school_name dcps;
	set nmast.msf0012;
		if ui_id="1026501" then delete;
		%do i=2000 %to 2012;
		format eor_&i.;
		format eor_&i. $eor_alt.;
		if eor_&i. = 9 then eor_&i. =0;
		%end;
run;

data nmast.msf0012_public_enroll (drop=pubc first_dig %do i=2000 %to 2012; notes_&i. city_&i. sch_&i._zip enroll_open_&i. %end; rep_: schooltype);
	retain ui_id master_school_name dcps;
	set msf_enroll;
		if ui_id="1026501" then delete;
		%do i=2000 %to 2012;
		format eor_&i.;
		format eor_&i. $eor_alt.;
		if eor_&i. = 9 then eor_&i. =0;
		%end;
		/*for enrollment figures*/
	%do i=1 %to 12;
		%let val=%sysfunc(putn(&i,z2.));
		%let val2=%sysfunc(sum(&val.,1));
		%let val2=%sysfunc(putn(&val2.,z2.));
		/*rename enrollment vars for easy looping in next step*/
		rename aud_&val.&val2. = aud_20&val.;
	%end;
run;
	
%mend;

%create_public();



/*test consistency across geographies and across MSF and enrollment*/
%macro testing_consistency();
	/*check school total consistency across summary files: in Work.running_sumry, all totals should be the same*/
	%let fname =anc02 anc12 city cltr00 cl00 eor psa04 psa12 tr00 tr10 wd02 wd12 zip;
	%do j=1 %to 13;
		%let filename = %scan(&fname.,&j.," ");
	proc means data=schools.msf_sum_&filename. sum;
		var %do i=2000 %to 2012; school_present_&i. dcps_present_&i. charter_present_&i. %end; %do i=2001 %to 2012; aud_&i. aud_dcps_&i. aud_charter_&i. %end;;
		output out=sumry_&filename. sum(%do i=2000 %to 2012; school_present_&i. dcps_present_&i. charter_present_&i. %end; %do i=2001 %to 2012; aud_&i. aud_dcps_&i. aud_charter_&i. %end;)= 
			%do i=2000 %to 2012; school_tot_&i. dcps_tot_&i. charter_tot_&i. %end; %do i=2001 %to 2012; aud_tot_&i. aud_dcps_tot_&i. aud_charter_tot_&i. %end;;
	run;
	data sumry_&filename.;
		set sumry_&filename.;
		geoname = "&filename";
	run;
	proc append base=running_sumry data=sumry_&filename. force; run;
	%end;

	/*check if geocoded zips match up with original zips; the zip_mismatch flag should not be raised*/
	data zip_mismatch;
		set nmast.msf0012;
	%do i=2000 %to 2012;
		if zip_&i. ^= sch_&i._zip and zip_&i. ^=' ' and sch_&i._zip ^=. then do; zip_mismatch_&i.=1; master_mismatch=1; end;
	%end;
	if master_mismatch ^=1 then delete;
	run;

	/*find schools with missing dcps*/
	data missing_dcps;
		set nmast.msf0012;
		if dcps ^=. then delete;
	run;

	/*check if there are any schools with enrollments where the school is marked as closed*/
	data uncounted_enroll (keep= ui_id master_school_name flag_uncounted: aud_: open_:);
		set msf0012_dum;
		%do i=2001 %to 2012;
			if open_&i.=0 and aud_&i.>0 then do; flag_uncounted=1; flag_uncounted_&i. = 1; end; 
		%end;
		if flag_uncounted^=1 then delete;
	run;

	/*check if there are any schools with enrollments where the school is not geocoded into DC*/
	data uncounted2_enroll (keep= ui_id master_school_name flag_uncounted: aud_: open_: city_:);
		set msf0012_dum;
		%do i=2001 %to 2012;
			if city_&i.^=1 and aud_&i.>0 then do; flag_uncounted=1; flag_uncounted_&i. = 1; end; 
		%end;
		if flag_uncounted^=1 then delete;
	run;
%mend;
/*%testing_consistency();*/

