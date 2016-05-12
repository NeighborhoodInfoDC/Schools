/**************************************************************************
 Program:  Schools_08_09.sas
 Library:  Schools
 Project:  NeighborhodInfo DC
 Author:   E. Guernsey
 Created:  11/23/2008
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Reading in 2008 2009 School File

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
libname SEO 'E:\SEO_PGP\Data';
libname RawSeo 'E:\SEO_SEP\Raw';
libname Data 'K:\Metro\MAturner\SEO Project\SEP\Data'; /*For non-confidential data*/
libname RawData 'K:\Metro\MAturner\SEO Project\SEP\Data\Raw';
***DBMS Copied Excel Data into SAS format;

data schools_08_09 (keep= school_name_2008_2009 notes master_school_name UI_ID Sch_0809_address sch_0809_zip
SEO_SchNum School_Number);
set data.Master_school_file;
/*New Charter Schools*/
if master_school_name = "ACHIEVEMENT PREPARATORY ACADEMY PCS" then UI_ID = "02105000";
if master_school_name = "CENTER CITY  PCS - Congress Heights" then UI_ID = "02105100";
if master_school_name = "CENTER CITY PCS - Brentwood" then UI_ID = "02105101";
if master_school_name = "CENTER CITY PCS - Brightwood" then UI_ID = "02105102";
if master_school_name = "CENTER CITY  PCS - Capitol Hill" then UI_ID = "02105103";
if master_school_name = "CENTER CITY  PCS - Shaw" then UI_ID = "02105104";
if master_school_name = "CENTER CITY  PCS - Trinidad" then UI_ID = "02105105";
if master_school_name = "CENTER CITY PCS - Petworth" then UI_ID = "02105106";
if master_school_name = "EXCEL ACADEMY PCS" then UI_ID = "02105200";
if master_school_name = "IMAGINE SOUTHEAST PCS" then UI_ID = "02105300";
if master_school_name = "KIPP DC - LEAP " then UI_ID = "02105400";
if master_school_name = "MEI FUTURES ACADEMY PCS" then UI_ID = "02105500";
if master_school_name = "THEA BOWMAN PRE0ARATORY ACADEMY PCS" then UI_ID = "02105600";
if master_school_name = "WASHINGTON YU YING PCS" then UI_ID = "02105700";

/*Addition of Charter Campuses*/
if master_school_name = "APPLETREE EARLY LEARNING PCS (at Amidon)" then UI_ID = "02104402";
if master_school_name = "APPLETREE EARLY LEARNING PCS (Columbia Heights)" then UI_ID = "02104401";
if master_school_name = "DC PREPARATORY ACADEMY - Edgewood Elementary" then UI_ID = "02102401";
if master_school_name = "DC PREPARATORY ACADEMY- Benning Elementary" then UI_ID = "02102402";
if master_school_name = "HOPE COMMUNITY PCS - Lamond" then UI_ID = "02103601";
if master_school_name = "HOWARD ROAD ACADEMY PCS - G Street" then UI_ID = "02100801";
if master_school_name = "HOWARD ROAD ACADEMY PCS - Pennsylvania Avenue" then UI_ID = "02100802";
if master_school_name = "IDEAL ACADEMY (lower school ES-MS)" then UI_ID = "03200401";
if master_school_name = "MARY MCLEOD BETHUNE - Brookland Campus" then UI_ID = "03202203";
if master_school_name = "MAYA ANGELOU PCS MIDDLE SCHOOL - Evans " then UI_ID = "02101103";
if master_school_name = "ROOTS PCS - PK-K" then UI_ID = "03201301";
if master_school_name = "WASHINGTON LATIN - Upper School" then UI_ID = "02104701";
if master_school_name = "WILLIAM E. DOAR, JR. PCS - Northwest" then UI_ID = "02103203";
if master_school_name = "CAPITAL CITY PUBLIC CHARTER SCHOOL Upper School" then UI_ID = "02100102";
if master_school_name = "COMMUNITY ACADEMY PCS - Amos III Armstrong" then UI_ID = "03201606";

/*DCPS UI_ID based on SEO School Number*/
if master_school_name = "PHELPS ARCH., CONST. & ENGINER. HIGH SCHOOL" then UI_ID = "01047800";
if master_school_name = "CHOICE ACADEMY MS/HS Hamilton" then UI_ID = "01094701";
if master_school_name = "YOUTH ENGAGEMENT ACADEMY" then UI_ID = "01047400";
if master_school_name = "COLUMBIA HEIGHTS EDUCATION CENTER" then UI_ID = "01044200";
if master_school_name = "TWILIGHT ACADEMY AT BALLOU" then UI_ID = "01096000";
if master_school_name = "TRANSITION ACADEMY AT SHADD" then UI_ID = "01095300";
if master_school_name = "DOUGLAS TRANSITIONAL ACADEMY" then UI_ID = "01095200";
if master_school_name = "WOODSON ACADEMY" then UI_ID = "01093300";

/*Not in Student File from 2007-08 or 2008-09*/
if master_school_name = "CARLOS ROSARIO EL Haynes" then UI_ID = "";
if master_school_name = "WASHINGTON ACADEMY" then UI_ID = "";
if master_school_name = "EARLY CHILDHOOD ACADEMY (Pre-School)" then UI_ID = "";
if master_school_name = "E.L. HAYNES PCS (Upper School)" then UI_ID = "";
if master_school_name = "FILLMORE ARTS CENTER - East" then UI_ID = "";
if master_school_name = "FILLMORE ARTS CENTER - West" then UI_ID = "";

if master_school_name = "" and UI_ID = "" then delete;

/*Trouble geocoding KIPP-AIM @ 2600 Douglass Place SE so changed to 2601 Douglass Place SE*/
	if UI_ID ="02103800" then Sch_0809_address = "2601 Douglass Place SE";
	if UI_ID ="02103800" then Sch_0809_zip="20020";

if UI_ID = "02101000" then Sch_0809_address = "4301 13TH ST NW";
if UI_ID = "02101000" then Sch_0708_address = "4301 13TH ST NW";
run;

rsubmit;
	  proc upload 	status = no  
		inlib = Work 
		outlib = Work
		memtype = (data);
		select schools_08_09;
	  run; 
	*%corrections (
		infile = Students, 
		correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt, 
		outfile = students_clean, 
		repl_var = stu_street);

	%DC_geocode(
		data=Work.schools_08_09, 
		out=Work.schools_08_09_geo, 
		staddr=Sch_0809_address, 
		zip = Sch_0809_zip, 
		id = ui_id,


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
	  	select  schools_08_09_geo;
	run;
  endrsubmit;
proc contents data=schools_08_09_geo;
run;
/*6 UNMATCHED ADDRESSES, 
All are Schools without Addresses except Oak Hill which is in Maryland*/;


data data.Sch0809_list_geo;
  set  schools_08_09_geo;
  rename
		 ssl = sch_ssl
		 addr_var = sch_addr_var
		 anc2002 = sch_anc2002
		 cluster2000 = sch_cluster2000
		 cluster_tr2000 = sch_cluster_tr2000
		 geo2000 = sch_geo2000
		 geoblk2000 = sch_geoblk2000
		 psa2004 = sch_psa2004
		 UNITNUMBER = sch_UNITNUMBER
		 ward2002 = sch_ward2002
		 zip_match = sch_zip_match 
		 dcg_num_parcels = sch_dcg_num_parcels
		 x_coord = sch_x_coord
		 y_coord = sch_y_coord
		 ui_proptype = sch_ui_proptype
		 str_addr_unit = sch_str_addr_unit
		 dcg_match_score = sch_dcg_match_score ; 
run;

***ONLY RUN THE PROGRAM TO HERE FOR NOW. MAY NEED BELOW PROGRAMMING LATER***;


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
