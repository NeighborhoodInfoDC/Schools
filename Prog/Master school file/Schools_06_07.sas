/**************************************************************************
 Program:  Schools_06_07.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   B. Williams
 Created:  06/27/2007
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Reading in 2006-07 DCPS Schools

 Modifications:
**************************************************************************/
  /*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Schools )
%DCData_lib( RealProp )
%include 'k:\metro\maturner\SEO Project\prog\students\formats for student data.sas';
%include 'k:\metro\maturner\SEO Project\prog\students\formats for school addresses.sas';

/**** LOGON TO PGP ****/
libname SEO 'L:\SEO\Data';
libname RawSeo 'L:\SEO\Raw\';
libname KSchl 'K:\Metro\MAturner\SEO Project\Data\Schools';
***DBMS Copied Excel Data into SAS format;

proc contents data = Rawseo.SchCrwlk;
run;
data SchCrwlk_rev;
  set Rawseo.SchCrwlk;
    if seo_schnum = "0957" then ui_sch_id = "9_900"; /*DC Corrections Manual Match*/
	if seo_schnum = "0950" then ui_sch_id = "9_901"; /*DC Dentention Manual Match*/
	if seo_schnum = "0940" then ui_sch_id = "1_114"; /*Dunbar Pre-Engineering Manual Match*/
	if seo_schnum = "0225" then ui_sch_id = "1_032"; /*Headstart Manual Match*/
	if seo_schnum = "0996" then ui_sch_id = "9_903"; /*Pre-K Incentive Manual Match*/
proc sort data = SchCrwlk_rev;
  by ui_sch_id;
run;

proc contents data = schools.school_list_4rmstu;
run;
proc sort data = schools.school_list_4rmstu;
  by ui_sch_id;
run;


data Sch0607_Crosswalk_test;
	merge 	SchCrwlk_rev (in=in1 rename =(school_name=schname ward_perm = ward_21c tr_perm = tr_21c)) 
			schools.school_list_4rmstu (in=in2);
	by ui_sch_id;
	if in1 then L21C = 1;
	if in2 then Stu05 = 1;
	Crossed  = L21C  + Stu05;
run;
proc sort; 
 by  crossed;
run;

proc contents data = Sch0607_Crosswalk_test;
run;

proc freq data = Sch0607_Crosswalk_test;
  table crossed / missing;
run;

proc freq data = Sch0607_Crosswalk_test;
  table schname master_school_name ui_sch_id seo_schnum/ missing;
  where crossed ne 2;
run;

proc sort data = Sch0607_Crosswalk_test; 
 by  seo_schnum;
run;

proc freq data = Sch0607_Crosswalk_test;
  table seo_schnum/ missing;
run;

/**********CHECK FOR ANY FREQUENCY OF 2, 
MEANS THERE IS MORE THAN 1 SCHOOL WITH SAME SEONUM******************************/
	proc freq data = Sch0607_Crosswalk_test;
	  table seo_schnum/ missing;
	run;

	proc freq data = Sch0607_Crosswalk_test;
	  table schname master_school_name ui_sch_id seo_schnum/ missing;
	    where SEO_schNUM ="1003b";
	run;
/**********
CESAR CHAVEZ - HAYES has 2 records
	1 for PSHS - (high school)
	1 for PSMS - (midddle school)
Since the campus are in the same location the will be assigned ONE UI_ID
**********/

/**********CHECK THE SCHOOLS CURRENTLY MISSING SEONUM******************************/
	proc freq data = Sch0607_Crosswalk_test;
	  table SCHOOL_NAME/ missing;
	  where seo_schnum = "";
	run;

data Sch0607_Crosswalk_test (rename = (Sch_type = school_type));
 set Sch0607_Crosswalk_test;

 *******CHANGE SEO SCHOOL NUMBERS PER EMAIL FROM PING**********;
	if school_name = "FLETCHER-JOHNSON EC" then seo_schnum = "0348";
	if school_name = "MCGOGNEY ES" then seo_schnum = "0275";
	if school_name = "PAUL ROBESON SCHOOL" then seo_schnum = "0725";
	if school_name = "TERRELL JHS" then seo_schnum = "0430";
	if school_name = "ROSE SCHOOL" then seo_schnum = "0726";
	if school_name = "SHADD ELEMENTARY SCHOOL" then seo_schnum = "0310";
	if school_name = "VAN NESS ES" then seo_schnum = "0331";
	if school_name = "THE NEW SCHOOL" then seo_schnum = "9937";
	if school_name = "JOS-ARZ THERAPEUTIC PUBLIC CHARTER SCHOOL" then seo_schnum = 	"9935";

 if school_type ne . then sch_type = school_type;
   else if index(sector_type,"DCPS") ne 0 then sch_type = 1;
   else if index(sector_type,"BOE") ne 0 then sch_type = 3;
   else if index(sector_type,"PCSB") ne 0 then sch_type = 2;
	
   seonum = strip(compbl(upcase(seo_schnum)));
  IF SEO_SCHNUM NE "" THEN DO;
   if sch_type = 1 then do;
   	UI_ID = "01" || substr(seonum,1,4) ||  "00";
   end;
   if sch_type = 2 then do;
   	if substr(seonum,5,1) = "" then campusnum = "00";
	if substr(seonum,5,1) = "A" then campusnum = "01";
	if substr(seonum,5,1) = "B" then campusnum = "02";
	if substr(seonum,5,1) = "C" then campusnum = "03";
	if substr(seonum,5,1) = "D" then campusnum = "04";
	if substr(seonum,5,1) = "E" then campusnum = "05";
	if substr(seonum,5,1) = "F" then campusnum = "06";
	if substr(seonum,5,1) = "G" then campusnum = "07";
	if substr(seonum,5,1) = "H" then campusnum = "08";
	if substr(seonum,5,1) = "I" then campusnum = "09";
	if substr(seonum,5,1) = "J" then campusnum = "10";
	if substr(seonum,5,1) = "K" then campusnum = "11";
	if substr(seonum,5,1) = "L" then campusnum = "12";
	if substr(seonum,5,1) = "M" then campusnum = "13";
	UI_ID = "02" || substr(seonum,1,4) || campusnum;
   end;
   if sch_type = 3 then do;
   	if substr(seonum,5,1) = "" then campusnum = "00";
	if substr(seonum,5,1) = "A" then campusnum = "01";
	if substr(seonum,5,1) = "B" then campusnum = "02";
	if substr(seonum,5,1) = "C" then campusnum = "03";
	if substr(seonum,5,1) = "D" then campusnum = "04";
	if substr(seonum,5,1) = "E" then campusnum = "05";
	if substr(seonum,5,1) = "F" then campusnum = "06";
	if substr(seonum,5,1) = "G" then campusnum = "07";
	if substr(seonum,5,1) = "H" then campusnum = "08";
	if substr(seonum,5,1) = "I" then campusnum = "09";
	if substr(seonum,5,1) = "J" then campusnum = "10";
	if substr(seonum,5,1) = "K" then campusnum = "11";
	if substr(seonum,5,1) = "L" then campusnum = "12";
	if substr(seonum,5,1) = "M" then campusnum = "13";
	UI_ID = "03" || substr(seonum,1,4) || campusnum;
   end;
  end;

  Else if SEO_schnum = "" then do;
  if sch_type = 1 then do;
   	UI_ID = "01X" || substr(ui_sch_id,3,3) ||  "00";
   end;
   if sch_type = 2 then do;
	UI_ID = "02X" || substr(ui_sch_id,3,3) ||  "00";
   end;
   if sch_type = 3 then do;
	UI_ID = "03X" || substr(ui_sch_id,3,3) ||  "00";
   end;
   end;
	drop school_type;
run;

proc contents data = Sch0607_Crosswalk_test;
run;

data seo.Sch0607_list;
  set Sch0607_Crosswalk_test;
  rename Building_sq_footage = Bldg_SqFt
  		 Site_sq_footage = Site_SqFt
  		 Building_Zoning = Bldg_Zonging
		 Capacity = Bldg_Capacity
		 ui_sch_id = old_uischid
         PERMANENT_ADDRESS  = PERM_ADDRESS;

  *drop perm_address school_year;
  rename	SEO_school_type = SEO_schCat
			enroll_06_07 = Enroll_0607_21C
			_1CSF_bldgnum = TCSF_bldgnum
			Crossed = Crosswalk_Tally;
			
	
  drop	ID L21C stu05 campusnum seonum
		swing_school swing_x swing_y swing_ssl tot_students
		cluster_swing stfid_swing mtr_mean_dist Mtr_med_dst 
		sch_mean_dist sch_med_dist tr_21c  tr_swing ward_21c ward_swing;
  *drop 	ECU PS PK K G1st G2nd G3rd G4th G5th G6th G7th G8th G9th G10th G11th G12th OTH; 

  drop	tr_perm perm_x perm_y perm_ssl stfid_perm cluster_pe cluster_perm ward_perm;

run;
 
data Sch0607_Crosswalk_ehg;
  set seo.Sch0607_list;
  if school_type = 1 then do;
	DCPS = 1; PUBC = 0; PCSB_PCS = 0; BOE_PCS = 0;
  end;
  if school_type = 2 then do;
	DCPS = 0; PUBC = 1; PCSB_PCS = 1; BOE_PCS = 0;
  end;
  if school_type = 3 then do;
	DCPS = 0; PUBC = 1; PCSB_PCS = 0; BOE_PCS = 1;
  end;

  IF MASTER_SCHOOL_NAME = "" then MASTER_SCHOOL_NAME = SCHNAME;
  if SCHOOL_NAME = "" then SCHOOL_NAME = SCHNAME;

  if MASTER_SCHOOL_NAME IN('','MISSING') THEN MASTER_SCHOOL_NAME = SCHOOL_NAME;

  *SCHOOL_YEAR = "2006-2007";

  format PERM_ADDRESS $75. ;
  PERM_ADDRESS = strip(compbl(upcase(PERM_ADDRESS)));
  Address = strip(compbl(upcase(Address)));

  format sch_address $75.;
  if PERM_ADDRESS ne "" then sch_address = PERM_ADDRESS;
    else sch_address = Address;
 
  *if Perm_address = " " then Perm_address = address;
  *if perm_address = " " then add_err = 1;
  if schname = "WILLIAM E. DOAR, JR. PCS - RHODE ISLAND" then sch_address = "605 RHODE ISLAND AVENUE NE"; 
run;
    
proc contents data = Sch0607_Crosswalk_ehg;
run;


data SEO.Sch0607_list;
  set Sch0607_Crosswalk_ehg;
run;
proc sort;
  by ui_id;
run;

/*
rsubmit;
libname seoalph 'DISK$S_USER03:[DCDATA2]';  *assigns location of DPLACE alpha;
proc upload data=seo.Sch0607_list  
		out = seoalph.Sch0607_list;
run;
endrsubmit;
*/

data schools;
	set SEO.Sch0607_list;
	if schname ="CESAR CHAVEZ PSHS - HAYES" then Zip_Code="20019";
	if schname = "BIRNEY" then sch_address = "2501 MARTIN LUTHER KING AVENUE SE";
	if schname = "THURGOOD MARSHALL ACADEMY" then sch_address = "2427 MARTIN LUTHER KING JR SE";
	if schname = "LECKIE" then sch_address = "4201 MARTIN LUTHER KING AVENUE SW";
	if sch_ADDRESS = "100 PIERCE STREET NW" then ZIP_CODE = "20001";

	*Manual addition by BXW on 8/23/07; 
		*Check in K:\Metro\MAturner\SEO Project\Management\Data;
		* Files: 	schlist_tcsf_check_Charters-PING.xls;
					
		
	if school_name = "BOOKER T. WASHINGTON - EVENING" then sch_address = "1346 FLORIDA AVE NW";
	 if school_name = "BOOKER T. WASHINGTON - EVENING" then zip_CODE = "20009";
	if school_name = "ESF - MARY CENTER AM" then sch_address = "2355 ONTARIO RD NW";
	  if school_name = "ESF - MARY CENTER AM" then zip_CODE = "20009";
	if school_name = "ESF - MARY CENTER PM" then sch_address = "2355 ONTARIO RD NW";
	  if school_name = "ESF - MARY CENTER PM" then zip_CODE = "20009";
	if school_name = "ESF - BANCROFT PM" then sch_address = "1755 NEWTON ST NW";
	  if school_name = "ESF - BANCROFT PM" then zIP_CODE = "20010";
	if school_name = "ESF - BANCROFT AM" then sch_address = "1755 NEWTON ST NW";
	  if school_name = "ESF - BANCROFT AM" then zIP_CODE = "20010";
	if school_name = "DUNBAR PRE-ENGINEERING  SWSC" then sch_address = "1301 NEW JERSEY AVE NW" ;
	  if school_name = "DUNBAR PRE-ENGINEERING  SWSC" then  ZIP_CODE = "20001";
	if school_name = "TERRELL JHS" then sch_address = "1000 1ST St NW" ;
	  if school_name = "TERRELL JHS" then zIP_CODE = "20001";
	if indexw(school_name,'ROSARIO') ne 0 then sch_address = "1100 HARVARD STREET NW" ;
	  if indexw(school_name,'ROSARIO') ne 0 then zIP_CODE = "20009";

**REVISED ON 8/29/2007 PER EMAIL CONFIRMATION FROM TCSF;	
	if school_name = "HOPE COMMUNITY" then sch_address = "6200 KANSAS AVE NE" ;
	  if school_name = "HOPE COMMUNITY" then zIP_CODE = "20011";
	if school_name = "POTOMAC" then sch_address = "1600 TAYLOR ST NE" ;
	  if school_name = "POTOMAC" then zIP_CODE = "20017";
	if school_name = "WASHINGTON MATH AND SCIENCE" then sch_address = "1920 BLADENSBURG RD NE" ;
	  if school_name = "WASHINGTON MATH AND SCIENCE" then zIP_CODE = "20002";
	if school_name = "LATIN AMERICA MONTESSORI" then sch_address = "1375 MISSOURI AVE NW" ;
	  if school_name = "LATIN AMERICA MONTESSORI" then zIP_CODE = "20011";
	if master_school_name = "WASHINGTON ACADEMY PCS" then master_school_name = "WASHINGTON ACADEMY PCS - PENN";
		if school_name = "WASHINGTON ACADEMY PUBLIC CHARTER SCHOOL" then school_name = "WASHINGTON ACADEMY PCS - PENN";
	if school_name = "BELL HIGH SCHOOL" then sch_address = "3101 16TH ST NW" ;
	  if school_name = "BELL HIGH SCHOOL" then zIP_CODE = "20010";
	if school_name = "BRENT ELEMENTARY SCHOOL" then sch_address = "301 N CAROLINA AVE SE" ;
	  if school_name = "BRENT ELEMENTARY SCHOOL" then zIP_CODE = "20003";
	if school_name = "CHOICE ALTERNATIVE PROGRAM" then sch_address = "1800 PERRY ST NE" ;
	  if school_name = "CHOICE ALTERNATIVE PROGRAM" then zIP_CODE = "20018";	
	if school_name = "CHOICE SECONDARY PROGRAM" then sch_address = "2600 DOUGLASS PL SE" ;
	  if school_name = "CHOICE SECONDARY PROGRAM" then zIP_CODE = "20018";
	if school_name = "DC DETENTION FACILITY" then sch_address = "1901 D ST SE" ;
	  if school_name = "DC DETENTION FACILITY" then zIP_CODE = "20003";
	if school_name = "DUKE ELLINGTON SCHOOL" then school_name = "DUKE ELLINGTON SHS OF THE ARTS";
	if school_name = "HARDY MIDDLE SCHOOL" then SWING_address = "1401 BRENTWOOD PKWY NE" ;
	if school_name = "COOKE H.D. ELEMENTARY SCHOOL" then SWING_address = "300 BRYANT ST NW" ;
	  *if school_name = "HARDY MIDDLE SCHOOL" then zIP_CODE = "200";
	if school_name = "JACKIE ROBINSON SCHOOL" then school_name = "JACKIE ROBINSON CENTER";
	if school_name = "MERRITT ELEMENTARY SCHOOL" then school_name = "MERRITT MIDDLE SCHOOL";
	  if MASTER_school_name = "MERRITT ELEMENTARY SCHOOL" then MASTER_school_name = "MERRITT MIDDLE SCHOOL";
	if school_name = "OAK HILL YOUTH CENTER" then school_name = "OAK HILL ACADEMY";
	if school_name = "TAFT ED PROGRAM" then school_name = "TAFT CENTER";
	if school_name = "TERRELL MC ES" then school_name = "TERRELL MC / MCGOGNEY ES";
	if school_name = "TERRELL JHS" then school_name = "RH TERRELL JHS";
	if school_name = "WALKER-JONES ES" then school_name = "WALKER-JONES ES / RH TERRELL EC";
	if school_name = "YOUTH SERVICE CENTER" then school_name = "YOUTH SERVICES CENTER";
	if school_name = "SCHOOL-WITHIN-SCHOOL @ PEABODY" then school_name = "EMILIA REGGIO -SWS- @ PEABODY";
/*	if school_name = "" then sch_address = "" ;
	  if school_name = "" then zIP_CODE = "200";*/
	*if out_of_dc = 1 then delete;
	*if STU_CITY in('NY','NJ','MD','VA') then delete;
	if ui_id = "03X99900" then delete ;*There are 2 Community Acadmeny Online's in the file;
run;

rsubmit;
	  proc upload 	status = no  
		inlib = Work 
		outlib = Work
		memtype = (data);
		select schools;
	  run; 
	*%corrections (
		infile = Students, 
		correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt, 
		outfile = students_clean, 
		repl_var = stu_street);

	%DC_geocode(
		data=Work.schools, 
		out=Work.schools_geo, 
		staddr=sch_address, 
		zip = zip_code, 
		id = ui_id,

		parcelfile = realprop.parcel_geocode_base_new, 
		unit_match=Y,
		geo_match=Y,
		block_match=Y,
		listunmatched=Y,
		debug=N);
	run;
	proc download status = no  
		inlib=work 
		outlib=work 
		memtype=(data);
	  	select  schools_geo;
	run;
  endrsubmit;
/*6 UNMATCHED ADDRESSES, 
All are Schools without Addresses except Oak Hill which is in Maryland*/;

proc freq data=schools_geo;
  table school_name ui_id;
  where dcg_match_score <= 39;
run;

proc freq data=schools_geo;
  table school_name ui_id;
  where SUBSTR(UI_ID,3,1) = "X";
run;

proc contents data=schools_geo;
run;

data seo.Sch0607_list_geo;
  set schools_geo;
  drop 	ECU PS PK K G1st G2nd G3rd G4th G5th G6th G7th G8th G9th G10th G11th G12th OTH ; 

  rename SCHOOL_NUM = schlist_SCHOOL_NUM
         SCHOOL_NAME = schlist_SCHOOL_NAME
		 PCSB_PCS = sch_PCSB_PCS
         age = sch_age
		 sch_address_std = sch_sch_address_std
  		 addr_var = sch_addr_var
		 ssl = sch_ssl
		 anc2002 = sch_anc2002
		 cluster2000 = sch_cluster2000
		 cluster_tr2000 = sch_cluster_tr2000
		 geo2000 = sch_geo2000
		 geoblk2000 = sch_geoblk2000
		 psa2004 = sch_psa2004
		 UNITNUMBER = sch_UNITNUMBER
		 ward2002 = sch_ward2002
		 sch_address_match = sch_sch_address_match
		 zip_match = sch_zip_match 
		 dcg_num_parcels = sch_dcg_num_parcels
		 x_coord = sch_x_coord
		 y_coord = sch_y_coord
		 ui_proptype = sch_ui_proptype
		 zip_code = sch_zip 
		 str_addr_unit = sch_str_addr_unit
		 dcg_match_score = sch_dcg_match_score ;
		* SCHOOL_YEAR = "2006-07";
		***all of the geocoded variables need to be renamed with the sch_ prefix;
PROC SORT;
  BY SCHOOL_TYPE SCHLIST_SCHOOL_NAME;
run;

proc contents data = seo.Sch0607_list_geo;
run;


*****
***JC created a new school category variable for 2006-07, UI_SchCat_0607;

Data schools_2006;
	set Seo.Sch0607_list_geo;

	UI_schCat_0607 = SEO_schCat;
	
	label
	UI_schCat_0607 = "UI School Category for 2006-07";
	
	run;
	
*Check to see variable correctly created;	
*proc freq data=schools_2006;
*table UI_schCat_0607;
*run;


**Need to determine which schools are missing category -- need to
categorize all;
proc print data=schools_2006 (where=(UI_schCat_0607=""));
var schlist_school_name UI_ID;
title "Schools missing school category";
run;

	
**Fix schools that are incorrectly coded or missing coding;

Data schools_2006;
	set schools_2006;
	
	*Change Browne Center from JH to Special Ed;
	if UI_ID="01040400" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change Browne JH from Special ed to Junior High;
	if UI_ID="01027900" then UI_schCat_0607= "JUNIOR HIGH SCHOOL";

	*Change Rose school from xx to Special Ed;
	if UI_ID="01X12400" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change Roosevelt STAY to alternative ed;
	if UI_ID="01045600" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Spingarn STAY to alternative ed;
	if UI_ID="01046100" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Ballou STAY to alternative ed;
	if UI_ID="01046200" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Dunbar pre-engineering to Senior High;
	if UI_ID="01094000" then UI_schCat_0607= "SENIOR HIGH SCHOOL";

	*Change DC Detention facility to unclassified;
	if UI_ID="01095000" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change DC Corrections treatment to unclassified;
	if UI_ID="01095700" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*TWO CODES Change DC Corrections treatment to unclassified;
	if UI_ID="01095700" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Child/Famlily Services treatment to Foster Care;
	if UI_ID="01X02700" then UI_schCat_0607= "FOSTER CARE";

	*Change HEAD START to Early Ed;
	if UI_ID="01022500" then UI_schCat_0607= "EARLY EDUCATION";

	*Change FLETCHER-JOHNSON to ELEMENTARY;
	if UI_ID="01034800" then UI_schCat_0607= "ELEMENTARY";

	*Change McGogney ES to EARLY EDUCATION;
	if UI_ID="01027500" then UI_schCat_0607= "ELEMENTARY";
	
	*Change Apple Tree to Early Education;
	if UI_ID="02104400" then UI_schCat_0607= "EARLY EDUCATION";
	
	*Change Community Academy AMOS II to Early Education;
	if UI_ID="03201604" then UI_schCat_0607= "EARLY EDUCATION";

	*Change Eage Academy to Early Education;
	if UI_ID="02102500" then UI_schCat_0607= "EARLY EDUCATION";
	
	*Change Elilia Reggio to Early Education;
	if UI_ID="01094300" then UI_schCat_0607= "EARLY EDUCATION";
	
	*Change Peabody to Early Education;
	if UI_ID="01030100" then UI_schCat_0607= "EARLY EDUCATION";
	
	*Change Paul Robeson to Special Ed;
	if UI_ID="01072500" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change Residential NonPublic to Residential NonPublic;
	if UI_ID="01X11800" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change Terrell JHS to JUNIOR HIGH;
	if UI_ID="01043000" then UI_schCat_0607= "JUNIOR HIGH SCHOOL";

	*Change Rose to Special Ed;
	if UI_ID="01X12400" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change Shadd ES to Elementary;
	if UI_ID="01031000" then UI_schCat_0607= "ELEMENTARY ";
	if UI_ID="01031000" then schlist_SCHOOL_NAME= "SHADD ELEMENTARY SCHOOL";

	*Change Tuitiion Grant to SPECIAL EDUCATION;
	if UI_ID="01X15300" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change Van Ness ES to ELEMENTARY;
	if UI_ID="01033100" then UI_schCat_0607= "ELEMENTARY";


	*Change CARE CENTER AT SHAW JHS Private to JUNIOR HIGH SCHOOL;
	if UI_ID="01X17500" then UI_schCat_0607= "JUNIOR HIGH SCHOOL";

	*Change CARE CENTER AT SHAW JHS EC to EARLY EDUCATION;
	if UI_ID="01X17600" then UI_schCat_0607= "EARLY EDUCATION";

	*Change CARE CENTER AT SHAW JHS RELIG to EARLY EDUCATION;
	if UI_ID="01X17700" then UI_schCat_0607= "EARLY EDUCATION";

	*Change LASHAWN DCPS Nonpublic to FOSTER;
	if UI_ID="01X90200" then UI_schCat_0607= "FOSTER CARE";

	*Change PRE-K INCENTIVE to Early Education;
	*if UI_ID="01X90300" then UI_schCat_0607= "EARLY EDUCATION";

	*Change PRE-K INCENTIVE to Early Education;
	if UI_ID="01099600" then UI_schCat_0607= "EARLY EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100202" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100202" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100203" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100209" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100205" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100206" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100207" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100208" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Carlos Rosario to Alternative;
	if UI_ID="02100201" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change DC Corrections Treatment to Alternative;
	*if UI_ID="01X90000" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change DC Detention Facility to Alternative;
	*if UI_ID="01X90100" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Dunbar Pre-Engineering to Senior High;
	*if UI_ID="01X11400" then UI_schCat_0607= "SENIOR HIGH SCHOOL";	

	*Change Early Childhood PC to Early Education;
	if UI_ID="02103400" then UI_schCat_0607= "EARLY EDUCATION";

	*Change ESF to Alternative;
	if UI_ID="02104601" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change ESF to Alternative;
	if UI_ID="02104602" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change ESF to Alternative;
	if UI_ID="02104603" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change ESF to Alternative;
	if UI_ID="02104604" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change Head Start consolidated to Early Education;
	if UI_ID="01022500" then UI_schCat_0607= "EARLY EDUCATION";

	*Change St Colletta's to Early Education;
	if UI_ID="03202600" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change City Lights to Special Ed;
	if UI_ID="03202500" then UI_schCat_0607= "SPECIAL EDUCATION";

	*Change Youth Build PC consolidated to Alternative;
	if UI_ID="02103900" then UI_schCat_0607= "ALTERNATIVE EDUCATION";

	*Change New School to Closed;
	if UI_ID="02993700" then UI_schCat_0607= "CHARTER SCHOOL - PCSB";

	*Change Sasha Bruce to back to PCSB;
	if UI_ID="02X03100" then UI_schCat_0607= "CHARTER SCHOOL - PCSB";

	*Change Young America Works ;
	if UI_ID="03202300" then UI_schCat_0607= "CHARTER SCHOOL - BOE";

	*Change Jos-Arz Therapeutic PC Works to BOE;
	if UI_ID="03993500" then UI_schCat_0607= "CHARTER SCHOOL - BOE";

	*Change Community Academy, Online Works back to BOE;
	if UI_ID="03X99900" then UI_schCat_0607= "CHARTER SCHOOL - BOE";


run;


***NEED TO FIX FLAGS NEXT;

data schools_2006;
	set schools_2006;
	
	if UI_schCat_0607 = "EARLY EDUCATION" then HDST_PreF_Flag = 1;
		else HDST_PreF_Flag = 0;

	if UI_ID = "01094000" then SWSC_FLAG = 1;

	if UI_ID = "01095700" then JAIL_Flag = 1;

	if UI_ID = "01095000" then JAIL_Flag = 1;

	if UI_ID = "01094000" then SWSC_FLAG = 1;
	
	if UI_ID = "01094300" then SWSC_FLAG = 1;

	if UI_ID="02100202" then AdultEd_Flag= 1;

	if UI_ID="02100203" then AdultEd_Flag= 1;

	if UI_ID="02100204" then AdultEd_Flag= 1;

	if UI_ID="02100205" then AdultEd_Flag= 1;

	if UI_ID="02100206" then AdultEd_Flag= 1;	

	if UI_ID="02100207" then AdultEd_Flag= 1;

	if UI_ID="02103900" then AdultEd_Flag= 1;
	
	if UI_ID="02100208" then AdultEd_Flag= 1;

	if UI_ID="02100209" then AdultEd_Flag= 1;

	if UI_ID="02104601" then AdultEd_Flag= 1;	

	if UI_ID="02104602" then AdultEd_Flag= 1;

	if UI_ID="02104603" then AdultEd_Flag= 1;

	if UI_ID="02104604" then AdultEd_Flag= 1;

	*FLAG New School to Closed;
	if UI_ID="02993700" then CLOSED0607_FLAG= 1;

	*FLAG Sasha Bruce to Closed;
	if UI_ID="01X17700" then CLOSED0607_FLAG= 1;

	*FLAG Young America Works to Closed;
	if UI_ID="01X17700" then CLOSED0607_FLAG= 1;

	*FLAG Jos-Arz Therapeutic PC Works to Closed;
	if UI_ID="03993500" then CLOSED0607_FLAG= 1;
	
	*FLAG Fletcher Johnson to Closed;
	if UI_ID="01034800" then CLOSED0607_FLAG= 1;
	
	*FLAG McGogney to Closed;
	if UI_ID="01027500" then CLOSED0607_FLAG= 1;
	
	*Change Terrell JHS to Closed;
	if UI_ID="01043000" then CLOSED0607_FLAG= 1;

	*Change Van Ness ES to CLOSED;
	if UI_ID="01033100" then CLOSED0607_FLAG= 1;
	
	*Change CARE CENTER AT SHAW JHS Private to Closed;
	if UI_ID="01X17500" then CLOSED0607_FLAG= 1;
	
	*Change CARE CENTER AT SHAW JHS EC to Closed;
	if UI_ID="01X17600" then CLOSED0607_FLAG= 1;
	
	*Change CARE CENTER AT SHAW JHS RELIG to Closed;
	if UI_ID="01X17700" then CLOSED0607_FLAG= 1;
	
	
	run;


*NOTES: The 2006-07 OSSE Official Audit Report says that NEXT STEP PCS is an ungraded
high school. This is the only school mentioned in the report that is ungraded;


*Check to see if school codes correct;

*proc sort data=schools_2006;
*by sch_school_name;
*run;

*proc freq data=schools_2006;
*table UI_schCat_0607;
*title "Frequency of school category for 2006-07";
*run;

*proc print data=schools_2006;
*where UI_schCat_0607="";
*run;

*proc print data=schools_2006 ;
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "All schools, school category, and flags";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="ELEMENTARY"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Elementary Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="MIDDLE SCHOOL"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Middle Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="JUNIOR HIGH SCHOOL"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Junior High Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="SENIOR HIGH SCHOOL"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Senior HIgh Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="CHARTER SCHOOL - PCSB"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "PCSB Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="CHARTER SCHOOL - BOE"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "BOE Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="SPECIAL EDUCATION"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Special Education Schools/programs and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="ALTERNATIVE EDUCATION"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Alternative Education Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="EARLY EDUCATION"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Early Education Schools and school category";
*run;

*proc print data=schools_2006 (where=(UI_schCat_0607="FOSTER CARE"));
*var sch_school_name UI_ID UI_schCat_0607 school_type CLOSED0607_FLAG HDST_PreK_flag Jail_Flag AdultEd_Flag STAY_Flag SWSC_Flag;
*title "Foster Care and school category";
*run;

 
data seo.Mastr_Schlist_geo;
  set schools_2006;
run;

data seo.Sch0607_list_geo;
  set seo.Mastr_Schlist_geo;
  school_year = "2006-2007";
  drop crosswalk_tally perm_address sch_pcsb_pcs sch_addr_var address sch_sch_address_match
       sch_str_addr_unit sch_zip;
  rename sch_sch_address_std = sch_address_std ;
  format DCPS PCSB_PCS BOE_PCS PubC 2.;
  if school_type = 1 then DCPS =1;
    else DCPS =0;
  if school_type = 2 then PCSB_PCS = 1;
	else PCSB_PCS = 0;
  if school_type = 3 then BOE_PCS = 1;
	else BOE_PCS = 0;
  if school_type > 1 then PubC = 1;
	else PubC = 0;
  if CLOSED0607_FLAG= 1 then delete;	
run;

proc contents data =  seo.Sch0607_list_geo;
run;

rsubmit;
libname seoalph 'DISK$S_USER03:[DCDATA2]';  /*assigns location of DPLACE alpha*/
proc upload data=seo.Sch0607_list_geo  
		out = seoalph.Sch0607_list_geo;
run;
endrsubmit;


proc sort data = kschl.Enrollment;
 by ui_id;
proc sort data = kschl.Program_Type;
 by ui_id;
proc sort data = kschl.Demographic;
 by ui_id;
proc sort data = kschl.Academic;
 by ui_id;
proc sort data = kschl.Bldg_Capacity;
 by ui_id;
proc sort data = kschl.Facilities;
 by ui_id;
proc sort data = kschl.School_Proximity;
 by ui_id;
proc sort data = kschl.Boundary_Distance;
 by ui_id;
run;

proc sort data = seo.Sch0607_list_geo;
  by ui_id;
run;


data DCPS_ReDibV3;
  set SEO.ReDibV3;
  if uibldgnum = 100 then delete;
  drop uibldgnum stu_sch_na;
run;
proc sort;
  by ui_id;
run;
data kschl.TCSF_schall;
  merge	seo.Sch0607_list_geo
  		kschl.Enrollment
		kschl.Program_Type
		kschl.Demographic
		kschl.Academic
		kschl.Bldg_Capacity
		kschl.Facilities
		kschl.School_Proximity
		kschl.Boundary_Distance
		DCPS_ReDibV3;
	by ui_id;
	if ui_id = '01034800' then delete; /*Delete Fletcher Johnsons from File*/
	if ui_id = '' then delete;
	if ui_id = '01031000' then ShrtName = "SHADD";
	if ui_id = '01072500' then ShrtName = "PAUL ROBESON";
	if ui_id = '01072600' then ShrtName = "ROSE";
	if ui_id = '02X03100' then ShrtName = "SASHA BRUCE";
	if ui_id = '01X02700' then ShrtName = "CHILD & FAMILY SERV";
	sch_geo = sch_all;
	if ui_id in('03202600','03202402','03202403') then sch_geo = 1;
	if DCPS_HDQRTS_flag = 1 then sch_geo = .;
run;

proc sort data = kschl.TCSF_schall;
  by pubc ward ShrtName;
run;
