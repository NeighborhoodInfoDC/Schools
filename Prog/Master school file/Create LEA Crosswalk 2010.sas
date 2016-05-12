/**************************************************************************
 Program:  Create LEA Crosswalk 2010.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   M.Grosz 1/5/10
 Created:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: creates LEA-level file for use when analyzing charter school projections;
 Modifications:
**************************************************************************/
  /*must use dcdata2 signon*/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\";
libname old "D:\SEP";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\general use files";


*find out how many campuses per school;
data LEA_UIID_master_cross (keep = DCPS Master_school_name LEA_UI_ID
									School_Name_2009_2010 School_Name_2010_2011 campuses);
	set gen.Master_school_file_1011_120109;
	LEA_UI_ID = substr( UI_ID, 1, 5);
	if dcps = 1 then delete;
	campuses = 1;/*this is for summing up in later steps*/

	run;	

	proc means data = LEA_UIID_master_cross noprint nway;
		var campuses;
		class LEA_UI_ID;
		output out = LEA_crosswalk_LEA (drop =  _type_ _freq_) sum=;
		run;
	proc sort data = LEA_crosswalk_LEA;
		by LEA_UI_ID;
		run;


		proc sort data = LEA_UIID_master_cross out = LEA_crosswalk (drop = campuses) nodupkey;
		by LEA_UI_ID;
		run;

		data gen.crosswalk_LEA_PCSB_1011;
			merge LEA_crosswalk_LEA (In = a)
					LEA_crosswalk;
					by LEA_UI_ID;
					if a;
				if campuses > 1 then do;
					School_Name_2009_2010 = '';
					School_Name_2010_2011 = '';
					master_school_name_OLD = master_school_name;
					end;
				if LEA_UI_ID = "21001" then master_school_name = "CAPITAL CITY PUBLIC CHARTER SCHOOL";
				if LEA_UI_ID = "21002" then master_school_name = "CARLOS ROSARIO";
				if LEA_UI_ID = "21003" then master_school_name = "CESAR CHAVEZ PS";
				if LEA_UI_ID = "21008" then master_school_name = "HOWARD ROAD ACADEMY PCS";
				if LEA_UI_ID = "21011" then master_school_name = "MAYA ANGELOU PCS";
				if LEA_UI_ID = "21017" then master_school_name = "SAIL - SCHOOL FOR ARTS IN LEARNING";
				if LEA_UI_ID = "21024" then master_school_name = "DC PREPARATORY ACADEMY";
				if LEA_UI_ID = "21025" then master_school_name = "EAGLE ACADEMY";
				if LEA_UI_ID = "21030" then master_school_name = "TWO RIVERS PCS";
				if LEA_UI_ID = "21032" then master_school_name = "WILLIAM E. DOAR, JR. PCS";
				if LEA_UI_ID = "21034" then master_school_name = "EARLY CHILDHOOD ACADEMY";
				if LEA_UI_ID = "21036" then master_school_name = "HOPE COMMUNITY PCS";
				if LEA_UI_ID = "21044" then master_school_name = "APPLETREE EARLY LEARNING PCS";
				if LEA_UI_ID = "21046" then master_school_name = "CITY COLLEGIATE PCS";
				if LEA_UI_ID = "21047" then master_school_name = "WASHINGTON LATIN";
				if LEA_UI_ID = "21051" then master_school_name = "CENTER CITY PCS";
				if LEA_UI_ID = "21062" then master_school_name = "KIPP DC";
				if LEA_UI_ID = "21063" then master_school_name = "FRIENDSHIP EDISON";
				if LEA_UI_ID = "31023" then master_school_name = "RICHARD MILBURN";;
				if LEA_UI_ID = "32000" then master_school_name = "BOOKER T. WASHINGTON";
				if LEA_UI_ID = "32004" then master_school_name = "IDEAL ACADEMY";
				if LEA_UI_ID = "32013" then master_school_name = "ROOTS PCS";;
				if LEA_UI_ID = "32016" then master_school_name = "COMMUNITY ACADEMY";
				if LEA_UI_ID = "32022" then master_school_name = "MARY MCLEOD BETHUNE";
				if LEA_UI_ID = "32024" then master_school_name = "WASHINGTON ACADEMY PCS";
					run;
					
proc print data = gen.crosswalk_LEA_PCSB_1011 noobs;
	where campuses > 1;
	var LEA_UI_ID master_school_name master_school_name_OLD;
	run;

