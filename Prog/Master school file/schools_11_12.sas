/**************************************************************************
 Program:  schools_11_12.sas
 Project:  schools
 Author:   S.Zhang 5/3/2013
 Created:  5/3/2013
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description: Merge DCPS and PCBS data to master school file
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

libname nmast "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file\11_13_data";
libname omast "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file\";
libname enroll "D:\DCData\Libraries\Schools\enrollment";
option nofmterr; 

/*where census block shape file is saved*/
libname map "D:\DCData\Libraries\Schools\SAS Map Files";

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

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

/*************************GEOCODING*************************************/
proc sort data=all_years; by ui_id; run;


%macro geocode_all_years();

/*%let geos = JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC;
%let maps = anc block00 cluster_octo cluster_tr2000 dc psa tract ward zip_new zip_profiles;*/
%do i=2000 %to 2012;
/*
	%do j = 1 %to 10;
      %let g = %scan(&geos., &j.,' ');
	  %let m = %scan(&maps., &j.,' ');
*/

/*data geocoded_&g._&i.;
			set all_years (keep= ui_id x_coord_&i. y_coord_&i.);
			rename x_coord_&i.=x y_coord_&i.=y;
			if x_coord_&i. =. then delete;
	run;
*/
	data geocoded_&i.;
			set all_years (keep= ui_id x_coord_&i. y_coord_&i.);
			rename x_coord_&i.=x y_coord_&i.=y;
			if x_coord_&i. =. then delete;
	run;

	proc ginside data = geocoded_&i. map = map.block00_md out = master_block00_&i.;
			id BLKIDFP00; 
	run;

	proc sort data = master_Block00_&i. (rename=(BLKIDFP00=geoblk2000)); by ui_id; run;

data master_geocode_&i.;
	set master_Block00_&i.;
		%Block00_to_anc02()
		%Block00_to_anc12()
		%Block00_to_city()
		%Block00_to_cluster_tr00()
		%Block00_to_cluster00()
		%Block00_to_eor()
		%Block00_to_psa04()
		%Block00_to_psa12()
		%Block00_to_tr00()
		%Block00_to_tr10()
		%Block00_to_ward02()
		%Block00_to_ward12()
		%Block00_to_zip()
run;

data master_geocode_&i. (keep = ui_id geoblk2000_&i. geo2000_&i. geo2010_&i. cluster2000_&i. cluster_tr2000_&i. anc2002_&i. anc2012_&i. psa2004_&i. psa2012_&i. ward2002_&i. ward2012_&i. zip_&i. eor_&i. city_&i.);
	set master_geocode_&i.;
	rename geoblk2000=geoblk2000_&i. geo2000=geo2000_&i. geo2010=geo2010_&i. cluster2000=cluster2000_&i. cluster_tr2000=cluster_tr2000_&i.
		anc2002=anc2002_&i. anc2012=anc2012_&i. psa2004=psa2004_&i. psa2012=psa2012_&i. ward2002=ward2002_&i. ward2012=ward2012_&i. zip=zip_&i. eor=eor_&i. city=city_&i.;
run;
%end;
%mend geocode_all_years;


%geocode_all_years();

/*MERGE EVERYTHING*/
%macro merge_geocoded();
data all_years_geo;
	retain ui_id master_school_name;
	merge %do i=2012 %to 2000 %by -1;
		master_geocode_&i. 
	%end;
	all_years;
	by ui_id;
run;

data nmast.msf0012;
	retain ui_id master_school_name %do i=2012 %to 2000 %by -1;
		school_name_&i. sch_&i._address geoblk2000_&i. geo2000_&i. geo2010_&i. cluster2000_&i. cluster_tr2000_&i. 
			anc2002_&i. anc2012_&i. psa2004_&i. psa2012_&i. ward2002_&i. ward2012_&i. zip_&i. eor_&i. city_&i. 
	%end;;
	set all_years_geo;
run;
	
%mend merge_geocoded;

%merge_geocoded();

