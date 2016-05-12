
/**************************************************************************
 Program:  schools_09_10.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   M.Grosz 10/28/2009
 Created:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: reads in Master School File as of Oct 2009 and assigns new UI_ID;
 Modifications:
**************************************************************************/
  /*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
%DCData_lib(RealProp)
libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";
libname msf "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\MasterSchoolFile";

*Read file in from excel 2009 Master School File, after Nancy from 21st Century SchoolFund updated the 2008 Master School File;
filename dat dde "excel|K:\Metro\PTatian\DCData\Libraries\Schools\Raw\MasterSchoolFile\[Master School File 11_09_09.xls]master_school_with_minmax! r5c4:r346c34" ;
	data msf.master_school_file_0910;
		infile dat   notab missover dlm='09'x dsd;
		*identify the variables in the whole data set, in order. Have to identify the length, $ is character, . ends the length;
		informat 
				Master_school_name $50. 
				School_Name_2009_2010 $50. 
				School_Name_2008_2009 $50. 
				/*Notes_09_10 $250. 
				Notes_08_09 $250.*/ 
				UI_ID $14. 
				/*UI_ID_OLD $14.*/ 
				Sch_09010_address $100.
				Sch_09010_zip $14. 
				Sch_0809_address $100. 
				Sch_0809_zip $14. 
				Sch_0708_address $100. 
				Sch_0708_zip $14. 
				Sch_0607_address $100.
				Sch_0607_zip $14. 
				Sch_0506_address $100. 
				Sch_0506_zip $14. 
				Sch_0405_address $100. 
				Sch_0405_zip $14. 
				Sch_0304_address $100.
				Sch_0304_zip $14. 
				SEO_SchNum $14. 
				School_Number $14. 
				DCPS 8. 
				PUBC 8. 
				grade_min_1011 $8. 
				grade_max_1011 $8.	
				grade_min_0910 $8. 
				grade_max_0910 $8. 
				grade_min_0809 $8. 
				grade_max_0809 $8. 
				grade_min_0708 $8. 
				grade_max_0708 $8.;
		*Next copy the list of variables and insert into the input statement. Have to include ALL variables -- otherwise it will mess up variable order;
		input   
				Master_school_name  
				School_Name_2009_2010  
				School_Name_2008_2009  
				/*Notes_09_10  
				Notes_08_09*/
				UI_ID  
				/*UI_ID_OLD*/  
				Sch_09010_address 
				Sch_09010_zip   
				Sch_0809_address  
				Sch_0809_zip  
				Sch_0708_address  
				Sch_0708_zip  
				Sch_0607_address 
				Sch_0607_zip  
				Sch_0506_address  
				Sch_0506_zip  
				Sch_0405_address  
				Sch_0405_zip  
				Sch_0304_address 
				Sch_0304_zip   
				SEO_SchNum   
				School_Number   
				DCPS  
				PUBC  
				grade_min_1011   
				grade_max_1011  	
				grade_min_0910   
				grade_max_0910   
				grade_min_0809   
				grade_max_0809   
				grade_min_0708   
				grade_max_0708  ;
		run;

*Need to tweak and assign UI_IDs each year because things change, so minor changes;
/*In 2009, had to reassign Friendship Heights and KIPP new UI_IDs because they were designated as separate schools. Therefore, created an
UI_ID_OLD variable to document FH and KIPP's old IDs*/

data schools_09_10;
	set msf.master_school_file_0910;

	/*New Charter Schools for 2009_10. Only 1 new charter, National Collegiate. Would have given it OSSE sch number but that wasn't included in the Oct 
report file we received from auditor. So putting in place holder now, until we get the OSSE number. PCSB number, 109 (09 for 2009), 1 to start
the first in the 2009 year, and campus 01*/
if master_school_name = "NATIONAL COLLEGIATE PREP" then UI_ID = "2106101";

/*Need to create public charter schools that existed in 2001 and 2002 and closed by 2003 (the first year we started documenting in the master school file*/
/*BOE schools and 1 PCSB--used SEO ID as middle digits*/
if master_school_name = "RICHARD MILBURN - CARVER CAMPUS" then UI_ID = "03102301";
if master_school_name = "RICHARD MILBURN - REABAUT CAMPUS" then UI_ID = "03102302";
if master_school_name = "WORLD PCS OF WASHINGTON" then UI_ID = "03101601";
if master_school_name = "TECHWORLD PCS" then UI_ID = "03101901";

*/Can't assign ASSOCIATES FOR RENEWAL IN EDUCATION (PCSB) the OSSE number from 2001 audit because number (101) already taken. Assigned it its 2002 number*/;
if master_school_name = "ASSOCIATES FOR RENEWAL IN EDUCATION" then UI_ID = "02100001";

/*Addition of Charter Campuses in 2009*/
if master_school_name = "Eagle Academy PCS - New Jersey Ave" then UI_ID = "02102501";
if master_school_name = "Howard Road Academy PCS - MLK Campus" then UI_ID = "02100803";
*/If carlos rosario makes new campus, we've run out of numbers!/*;
if master_school_name = "Carlos Rosario International PCS" then UI_ID = "02100204";


/*Fix existing public charters that were assigned separate UI_IDs (not same LEA) because OSSE assigned them separate numbers*/
/*Reassigning old KIPPS-- can't use original 2001 OSSE number because already taken. So assigned 02106200*/

*if master_school_name = "KIPP DC-KEY ACADEMY" then UI_ID_OLD = "2100900";
if master_school_name = "KIPP DC-KEY ACADEMY" then UI_ID = "2106201";

*if master_school_name = "KIPP DC-AIM ACADEMY" then UI_ID_OLD = "02103800";
if master_school_name = "KIPP DC-AIM ACADEMY" then UI_ID = "02106202";

*if master_school_name = "KIPP DC-WILL ACADEMY (GRADE 5)" then UI_ID_OLD = "2104500";
if master_school_name = "KIPP DC-WILL ACADEMY (GRADE 5)" then UI_ID = "02106203";

*if master_school_name = "KIPP DC - LEAP" then UI_ID_OLD = "2105400";
if master_school_name = "KIPP DC - LEAP" then UI_ID = "02106204";

*/new KIPP campsuses in 2009;
if master_school_name = "KIPP DC - COLLEGE PREPARATORY" then UI_ID = "02106205";
if master_school_name = "KIPP DC - DISCOVERY ACADEMY" then UI_ID = "02106206";
if master_school_name = "KIPP DC - PROMISE ACADEMY" then UI_ID = "02106207";

/*Reassigning old Friendships Edisons -- can't use original 2001 OSSE number because already taken. So assigned 02106300*/

*if master_school_name = "FRIENDSHIP EDISON - BLOW PIERCE CAM" then UI_ID_OLD = "2100400";
if master_school_name = "FRIENDSHIP EDISON - BLOW PIERCE CAM" then UI_ID = "02106301";

*if master_school_name = "FRIENDSHIP EDISON - CHAMBERLAIN CAMPUS" then UI_ID_OLD = "2100500";
if master_school_name = "FRIENDSHIP EDISON - CHAMBERLAIN CAMPUS" then UI_ID = "02106302";

*if master_school_name = "FRIENDSHIP EDISON - WOODRIDGE CAMPUS" then UI_ID_OLD = "2100600";
if master_school_name = "FRIENDSHIP EDISON - WOODRIDGE CAMPUS" then UI_ID = "02106303";

*if master_school_name = "FRIENDSHIP EDISON - CG WOODSON CAM" then UI_ID_OLD = "2100700";
if master_school_name = "FRIENDSHIP EDISON - CG WOODSON CAM" then UI_ID = "02106304";

*if master_school_name = "FRIENDSHIP SOUTHEAST ELEMENTARY ACADEMY" then UI_ID_OLD = "2103500";
if master_school_name = "FRIENDSHIP SOUTHEAST ELEMENTARY ACADEMY" then UI_ID = "02106305";

*/new Friendship campsus in 2009;
if master_school_name = "FRIENDSHIP TECH PREP" then UI_ID = "02106306";

*/Fixing Two Rivers, now that it has a new middle school;
*Making elementary and middle same UI_ID because same governing structure -- I think they should actually have the same campus number, as their leadership is the same;
if master_school_name = "TWO RIVERS PCS-ELEMENTARY" then UI_ID = "2103001";
if master_school_name = "TWO RIVERS PCS-MIDDLE" then UI_ID = "2103001";

*/Fixing SAIL -- Hadn't realized that we had two campuses;
if master_school_name = "SCHOOL For the Arts in Learning (SAIL) PCS" then UI_ID = "2101701";*This one is on H Stret and closed in 2004;
*The other SAIL ON 16th STreet 2101700 is still operating;

*/Assign DCPS new IDs for old schools;
if master_school_name = "Eliot Center" then UI_ID = "1056800";*Operating before 2003 -- gave similar "center" ID;
if master_school_name = "Fletcher Johnson" then UI_ID = "1040300";*Operating before 2003;
if master_school_name = "Terrell Center" then UI_ID = "1035600";*Operating before 2003;
if master_school_name = "Evans Middle School" then UI_ID = "1040800";*Operating before 2003;
if master_school_name = "Health & Human Service SWSC at Eastern c/" then UI_ID = "1056500";*Operating before 2003 -- gave similar "center" ID;

*/Fixing DCALA s.t. each campus has same id;
if master_school_name = "DCALA" then UI_ID = "1096100";
if master_school_name = "DCALA FRESHMAN" then UI_ID = "1096100";
if master_school_name = "DCALA SENIOR" then UI_ID = "1096100";
if master_school_name = "DCALA WEST" then UI_ID = "1096100";
if master_school_name = "DCALA SOUTHEAST" then UI_ID = "1096100";

*/Fixing Headstart s.t. all Headstart programs have same id;
if master_school_name = "CONSOLIDATED HEADSTART" then UI_ID = "1022500";
if master_school_name = "HEADSTART PHASE 2" then UI_ID = "1022500";
if master_school_name = "HEADSTART SPANISH DEVELOPMENT" then UI_ID = "1022500";

if master_school_name = "" and UI_ID = "" then delete;

run;






rsubmit;
	  proc upload 	status = no  
		inlib = Work 
		outlib = Work
		memtype = (data);
		select schools_09_10;
	  run; 
	

	%DC_geocode(
		data=Work.schools_09_10, 
		out=Work.schools_09_10_geo, 
		staddr=Sch_09010_address, 
		zip = Sch_09010_zip, 
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
	  	select  schools_09_10_geo;
	run;
  endrsubmit;
proc contents data=schools_09_10_geo;
run;
/*6 UNMATCHED ADDRESSES, 
All are Schools without Addresses except Oak Hill which is in Maryland*/;


data sch.Sch0910_list_geo;
  set  schools_09_10_geo;
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

***Creating crosswalk;

libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";

data gen.schnum_name_UIID_crosswalk_0910;

            set msf.master_school_file_0910;

  *         keep master_school_name UI_ID school_num dcps_flag  pcsb_flag UI_ID2;
            keep master_school_name UI_ID school_number dcps pcsb ;
			rename school_number = school_num;
			if master_school_name = "DCALA FRESHMAN" then UI_ID = "1096100";
			if master_school_name = "DCALA SENIOR" then UI_ID = "1096100";
			if master_school_name = "DCALA WEST" then UI_ID = "1096100";
			if master_school_name = "DCALA SOUTHEAST" then UI_ID = "1096100";
            UI_ID2 = "0" || UI_ID; 

            run;


 
