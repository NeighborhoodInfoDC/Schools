/**************************************************************************
 Program:  PCSB_enrltot_ward.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  08/06/2010
 UPDATED:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Produces summary enrollment tables by ward for State of DC report tables; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/

libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";
libname dcd "D:\DCData\Libraries\schools\lngenrol";
libname sch "D:\DCData\Libraries\schools\data";
libname planning "D:\DCData\Libraries\Planning\Data";
%let var = rep; 
%let type = PCSB;
data enroll;
      set dcd.&type._allsch_lngenrl;
      run;  
/* OSSE DCPS total reported numbers don't match UI numbers until we add Oak Hill and/or
	  PreK Incentive to the files.  Hand code the following variables using the files from
	  	21st C. Fund found in <K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Oct_Reported_DCPSfiles\from21CSF > 
	  UI's enrollment files don't "officially" include these schools, so hand code later */

data prekincentive;
	set gen.master_school_newgeo_082010 (keep=UI_ID master_School_name);
	where UI_ID = "1099600" or UI_ID = "1086000";
run;
data enrollment;
	set enroll prekincentive;
	/* Fix the reported variables */
	if UI_ID = "1086000" then DCPS_total_&var._0102 = 118;  /* Oak Hill Academy  */
	if UI_ID = "1086000" then DCPS_total_&var._0203 = 152;
	if UI_ID = "1086000" then DCPS_total_&var._0304 = 164;
	if UI_ID = "1086000" then DCPS_total_&var._0405 = 196;
	if UI_ID = "1086000" then DCPS_total_&var._0506 = 149;
	if UI_ID = "1086000" then DCPS_total_&var._0607 = 103;
	if UI_ID = "1099600" then DCPS_total_&var._0506 = 168;  /* PreK Incentive Program  */
	if UI_ID = "1099600" then DCPS_total_&var._0607 = 352;
	if UI_ID = "1099600" then DCPS_total_&var._0708 = 272;
    if UI_ID = "1099600" then DCPS_total_&var._0102 = .;
	if UI_ID = "1099600" then DCPS_total_&var._0203 = .;
	if UI_ID = "1099600" then DCPS_total_&var._0304 = .;
	if UI_ID = "1099600" then DCPS_total_&var._0405 = .;
	if UI_ID = "3200004" then &var._0405_10 = 57;           /*  Booker T. Washington Day School */
	if UI_ID = "3200004" then &var._0405_11 = 75;
	if UI_ID = "3200004" then &var._0405_12 = 50;
	if UI_ID = "3200004" then &var._0405_adult = 64;
	if UI_ID = "3200004" then PCSB_total_&var._0405 = 293;

	/* Fix the audited variables  
	K:\Metro\PTatian\DCData\Libraries\Schools\Raw\&var.ited Files\Checked &var.ited */

	if UI_ID = "1086000" then DCPS_total_&var._0102 = 73;  /* Oak Hill Academy  */
	if UI_ID = "1086000" then DCPS_total_&var._0203 = 152;
	if UI_ID = "1086000" then DCPS_total_&var._0304 = 160;
	if UI_ID = "1086000" then DCPS_total_&var._0405 = 193;
	if UI_ID = "1086000" then DCPS_total_&var._0506 = 141;
	if UI_ID = "1086000" then DCPS_total_&var._0607 = 102;
	if UI_ID = "1099600" then DCPS_total_&var._0506 = 182;  /* PreK Incentive Program  */
	if UI_ID = "1099600" then DCPS_total_&var._0607 = 338;
	if UI_ID = "1099600" then DCPS_total_&var._0708 = 299;
    if UI_ID = "1099600" then DCPS_total_&var._0102 = .;
	if UI_ID = "1099600" then DCPS_total_&var._0203 = .;
	if UI_ID = "1099600" then DCPS_total_&var._0304 = .;
	if UI_ID = "1099600" then DCPS_total_&var._0405 = .;
	if UI_ID = "3200401" then DCPS_total_&var._0910 = 285;
	if UI_ID = "3200004" then &var._0405_10 = 48;           /*  Booker T. Washington Day School */
	if UI_ID = "3200004" then &var._0405_11 = 49;
	if UI_ID = "3200004" then &var._0405_12 = 30;
	if UI_ID = "3200004" then &var._0405_adult = 56;
	if UI_ID = "3200004" then PCSB_total_&var._0405 = 229;
	
run;

%macro ward;
%do year=2001 %to 2009;
data wards;
     set "K:\Metro\MGrosz\general map files\DC Shape Files\DC_Wards\ward02l.sas7bdat";
	  /*format cluster_tr2000_&year. $8.;*/
      if Ward_label = "Ward 1" then Ward2002_&year. = '1';
      if Ward_label = "Ward 2" then Ward2002_&year. = '2';
      if Ward_label = "Ward 3" then Ward2002_&year. = '3';
      if Ward_label = "Ward 4" then Ward2002_&year. = '4';
      if Ward_label = "Ward 5" then Ward2002_&year. = '5';
      if Ward_label = "Ward 6" then Ward2002_&year. = '6';
      if Ward_label = "Ward 7" then Ward2002_&year. = '7';
      if Ward_label = "Ward 8" then Ward2002_&year. = '8';
      
  run;

	proc sort data=wards;
	  by ward2002_&year.;
	run;

	proc sort data=enrollment;
		by ward2002_&year.;
	run; 	

      data enrol_ward2002_&year._1 (rename = (new_name = ward2002_&year.));
	      merge enrollment wards;
	            by ward2002_&year.;
				if &type._total_&var._&year. = . then &type._total_&var._&year. = 0;
	            format new_name $WARD02A. ;
	            new_name = ward2002_&year.;
	            drop ward2002_&year.;
		run;

		data enrol_ward2002_&year.;
			set enrol_ward2002_&year._1;
				if ward2002_&year. = " " then ward2002_&year. = "non-ward";
				if cluster_tr2000_&year. = " " then cluster_tr2000_&year. = "non-cluster";
				if  anc2002_&year. = "" then anc2002_&year. = "non_anc";
				if  geoblk2000_&year. = "" then geoblk2000_&year. = "non-geoblk";
				if  psa2004_&year. = "" then psa2004_&year. = "non-psa";
				if  str_addr_unit_&year. = "" then str_addr_unit_&year. = "non-str_addr";
      run;
 %end;
%mend ward;
%ward 

%macro means (year1=, year2=);
	proc means data=enrol_ward2002_&year1. noprint;
			class ward2002_&year1.;
			var &type._total_&var._&year2.; 
			     output out=&type.tot_&var._&year1._ward2002 sum=;
			run;

	data &type.tot_&var._&year1._city (keep = city &type._total_&var._&year2.);
		retain city total_&var._&year2.;
		set &type.tot_&var._&year1._ward2002;
		length city $1.;
		label city = "Washington, D.C.";
		if ward2002_&year1. = '' then city = '1';
		if ward2002_&year1. ~= '' then delete;
		run;


	data &type.tot_&var._&year1._ward2002 (drop= _type_ _freq_);
		set &type.tot_&var._&year1._ward2002;
		where ward2002_&year1. ne '';
		if &type._total_&var._&year2. = . then &type._total_&var._&year2. = 0;
		if ward2002_&year1. = "W" then delete;
		if ward2002_&year1. = "non-wa" then delete;
		rename
			ward2002_&year1. = ward2002;
	run;

	


%mend means;
%means (year1=2001, year2=0102)
%means (year1=2002, year2=0203)
%means (year1=2003, year2=0304)
%means (year1=2004, year2=0405)
%means (year1=2005, year2=0506)
%means (year1=2006, year2=0607)
%means (year1=2007, year2=0708)
%means (year1=2008, year2=0809)
%means (year1=2009, year2=0910)
;

data sch.&type._Total&var.Enrl_ward2002;
	merge
		&type.tot_&var._2001_ward2002 &type.tot_&var._2002_ward2002 &type.tot_&var._2003_ward2002
		&type.tot_&var._2004_ward2002 &type.tot_&var._2005_ward2002 &type.tot_&var._2006_ward2002
		&type.tot_&var._2007_ward2002 &type.tot_&var._2008_ward2002 &type.tot_&var._2009_ward2002
		;
	by ward2002;
run;
data sch.&type._Total&var.Enrl_city;
	merge
		&type.tot_&var._2001_city &type.tot_&var._2002_city &type.tot_&var._2003_city
		&type.tot_&var._2004_city &type.tot_&var._2005_city &type.tot_&var._2006_city
		&type.tot_&var._2007_city &type.tot_&var._2008_city &type.tot_&var._2009_city
		;
	by city;
run;

data allsch_Total&var.Enrl_ward2002;
	merge sch.Pcsb_total&var.enrl_ward2002 sch.DCPS_total&var.enrl_ward2002;
	by ward2002;
run;

%macro tots;
	data sch.allsch_Total&var.Enrl_ward2002;
	%let macro_year = 0102 0203 0304 0405 0506 0607 0708 0809 0910;
		%do yr=1 %to 9;
		%let i=%scan(&macro_year, &yr,' ');
	set	allsch_Total&var.Enrl_ward2002;
		allsch_&var._&i. = PCSB_total_&var._&i. + DCPS_total_&var._&i.;
		label allsch_&var._&i. = "Total &var.ited Enrollment &i.";
	%end;
  run;
%mend tots;
%tots
;


data allsch_Total&var.Enrl_city;
	merge sch.Pcsb_total&var.enrl_city sch.DCPS_total&var.enrl_city;
	by city;
run;

%macro tots1;
	data sch.allsch_Total&var.Enrl_city;
     %let macro_year = 0102 0203 0304 0405 0506 0607 0708 0809 0910;
		%do yr=1 %to 9;
		%let i=%scan(&macro_year, &yr,' ');
	set	allsch_Total&var.Enrl_city;
		allsch_&var._&i. = sum(of PCSB_total_&var._&i., DCPS_total_&var._&i.);
		label allsch_&var._&i. = "Total October Certified Enrollment &i";
	%end;
  run;
%mend tots1;
%tots1
;


ods html file= "D:\DCData\Libraries\Schools\Data\&var.city.xls" style=minimal; 
proc print data=sch.allsch_total&var.enrl_city label noobs;
run;

ods html close;

/*
ods html file= "D:\DCData\Libraries\Schools\Data\pcsb_allsch_lngenrl.xls" style=minimal; 
proc print data=dcd.pcsb_allsch_lngenrl label noobs;
var master_school_name UI_ID &var._:;
run;

ods html close;


*/


























