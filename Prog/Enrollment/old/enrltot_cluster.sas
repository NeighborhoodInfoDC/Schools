/**************************************************************************
 Program:  PCSB_enrltot_wardcluster.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  008/05/2010
 UPDATED:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Prepares PSCB enrollment data for State of DC indicators tables 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 


libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";
libname dcd "D:\DCData\Libraries\schools\lngenrol";
libname sch "D:\DCData\Libraries\schools\data";
libname Planning "D:\DCData\Libraries\Planning\Data";

%let type=DCPS;
data testscores_&type.;
      set dcd.&type._allsch_lngenrl;
      run;
%macro cluster;
%do year=2001 %to 2009;
data clusters;
     set "K:\Metro\MGrosz\general map files\DC Shape Files\DC_Clusters\nbhclusply.sas7bdat";
	  /*format cluster_tr2000_&year. $8.;*/
      if name = "Cluster 1"  then cluster_tr2000_&year. = '01';
      if name = "Cluster 10" then cluster_tr2000_&year. = '10';
      if name = "Cluster 11" then cluster_tr2000_&year. = '11';
      if name = "Cluster 12" then cluster_tr2000_&year. = '12';
      if name = "Cluster 13" then cluster_tr2000_&year. = '13';
      if name = "Cluster 14" then cluster_tr2000_&year. = '14';
      if name = "Cluster 15" then cluster_tr2000_&year. = '15';
      if name = "Cluster 16" then cluster_tr2000_&year. = '16';
      if name = "Cluster 17" then cluster_tr2000_&year. = '17';
      if name = "Cluster 18" then cluster_tr2000_&year. = '18';
      if name = "Cluster 19" then cluster_tr2000_&year. = '19';
      if name = "Cluster 2"  then cluster_tr2000_&year. = '02';
      if name = "Cluster 20" then cluster_tr2000_&year. = '20';
      if name = "Cluster 21" then cluster_tr2000_&year. = '21';
      if name = "Cluster 22" then cluster_tr2000_&year. = '22';
      if name = "Cluster 23" then cluster_tr2000_&year. = '23';
      if name = "Cluster 24" then cluster_tr2000_&year. = '24';
	  if name = "Cluster 25" then cluster_tr2000_&year. = '25';
	  if name = "Cluster 26" then cluster_tr2000_&year. = '26';
	  if name = "Cluster 27" then cluster_tr2000_&year. = '27';
	  if name = "Cluster 28" then cluster_tr2000_&year. = '28';
	  if name = "Cluster 29" then cluster_tr2000_&year. = '29';
	  if name = "Cluster 3"  then cluster_tr2000_&year. = '03';
      if name = "Cluster 30" then cluster_tr2000_&year. = '30';
      if name = "Cluster 31" then cluster_tr2000_&year. = '31';
      if name = "Cluster 32" then cluster_tr2000_&year. = '32';
      if name = "Cluster 33" then cluster_tr2000_&year. = '33';
      if name = "Cluster 34" then cluster_tr2000_&year. = '34';
	  if name = "Cluster 35" then cluster_tr2000_&year. = '35';
	  if name = "Cluster 36" then cluster_tr2000_&year. = '36';
	  if name = "Cluster 37" then cluster_tr2000_&year. = '37';
	  if name = "Cluster 38" then cluster_tr2000_&year. = '38';
	  if name = "Cluster 39" then cluster_tr2000_&year. = '39';
	  if name = "Cluster 4"  then cluster_tr2000_&year. = '04';
	  if name = "Cluster 5"  then cluster_tr2000_&year. = '05';
	  if name = "Cluster 6"  then cluster_tr2000_&year. = '06';
	  if name = "Cluster 7"  then cluster_tr2000_&year. = '07';
	  if name = "Cluster 8"  then cluster_tr2000_&year. = '08';
	  if name = "Cluster 9"  then cluster_tr2000_&year. = '09';
	
  run;

	proc sort data=clusters;
	  by cluster_tr2000_&year.;
	run;

	proc sort data=testscores_&type.;
		by cluster_tr2000_&year.;
	run; 	

      data enrol_clst2000_&year. (rename = (new_name = cluster_tr2000_&year.));
	      merge testscores_&type. clusters;
	            by cluster_tr2000_&year.;
				if &type._total_rep_&year. = . then &type._total_rep_&year. = 0;
	            format new_name $CLUS00A.;
	            new_name = cluster_tr2000_&year.;
	            drop cluster_tr2000_&year.;
      run;
 %end;
%mend cluster;
 %cluster 

%macro means (year1=, year2=);
	proc means data=enrol_clst2000_&year1. noprint;
			class cluster_tr2000_&year1.;
			var &type._total_rep_&year2.; 
			     output out=&type.tot_rep_&year1._clstr2000 sum=;
			run;

	/*data &type.tot_rep_&year1._city (keep = city &type._total_rep_&year2.);
		retain city total_rep_&year2.;
		set &type.tot_rep_&year1._clstr2000;
		length city $1.;
		label city = "Washington, D.C.";
		if _type_ = 0 then city = '1';
		if _type_ = 1 then delete;
		run;*/

	data &type.tot_rep_&year1._clstr2000 (drop= _type_ _freq_);
		set &type.tot_rep_&year1._clstr2000;
		where cluster_tr2000_&year1. ne '';
		if &type._total_rep_&year2. = . then &type._total_rep_&year2. = 0;
		if cluster_tr2000_&year1. = "Cl" then delete;
		rename cluster_tr2000_&year1. = cluster_tr2000;
		
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


data &type._TotalrepEnrl_clstr2000;
	merge
		&type.tot_rep_2001_clstr2000 &type.tot_rep_2002_clstr2000 &type.tot_rep_2003_clstr2000
		&type.tot_rep_2004_clstr2000 &type.tot_rep_2005_clstr2000 &type.tot_rep_2006_clstr2000
		&type.tot_rep_2007_clstr2000 &type.tot_rep_2008_clstr2000 &type.tot_rep_2009_clstr2000
		;
	by cluster_tr2000;
run;	

data allsch_TotalrepEnrl_clstr2000;
	merge Pcsb_totalrepenrl_clstr2000 DCPS_totalrepenrl_clstr2000;
	by cluster_tr2000;
run;

%macro tots;
  data sch.allsch_TotalrepEnrl_clstr2000;
   %let macro_year = 0102 0203 0304 0405 0506 0607 0708 0809 0910;
		%do yr=1 %to 9;
		%let i=%scan(&macro_year, &yr,' '); 
	set	allsch_TotalrepEnrl_clstr2000;
		allsch_rep_&i. = PCSB_total_rep_&i. + DCPS_total_rep_&i.;
		label allsch_rep_&i. = "Total October Certified Enrollment &i";
    %end;
	run;
%mend tots;
%tots
;

%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
%DCData_lib( Planning )
rsubmit;

%macro Upload_dat( lib=, data=, revisions=New file. );

  proc upload status=no
    data=&lib..&data 
    out=&lib..&data;
  run;
  
  x "purge [DCData.General.data]&data..*";
  
  run;
  
%macro skip;
%Dc_update_meta_file(
    ds_lib=&lib,
    ds_name=&data,
    creator_process=&data..sas,
    restrictions=None,
    revisions=%str(&revisions)
  )
 %mend skip;  
  run;

%mend Upload_dat;

/*%Upload_dat (lib=Planning, data=testscores_city)
%Upload_dat (lib=Planning, data=testscores_cltr00)
%Upload_dat (lib=Planning, data=testscores_wd02)
*/
*%Upload_dat (lib=Planning, data=enrolment_pkps_city);
%Upload_dat (lib=Planning, data=enrolment_pkps_cltr00)
%Upload_dat (lib=Planning, data=enrolment_pkps_wd02)


run;
endrsubmit;

signoff;
















