/**************************************************************************
 Program:  DCPS schbygrd_long_enroll.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/21/2010
 UPDATED:  7/18/2011 Updated file/library paths,
					 put master file merge into comments, cleaned up totals lables SLL
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Creates all-school, grade-over-year enrollment file; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/

libname sch "E:\Schools 0910\data";
libname guf "E:\Schools 0910\data\general use files";
libname rep "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Enrollment\Reported";
libname kdr "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Enrollment";
libname old "D:\DCData\Libraries\schools\Enrollment\Old";
libname gen "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file";
libname dcd "D:\DCData\Libraries\schools\Enrollment";

/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
filename dat dde "excel|K:\Metro\PTatian\DCData\Libraries\Schools\Raw\Enrollment\DCPS\[DCPS School-by-Grade Enrollment, Audited and Oct.Cert. 2001-2009.xls]DCPS School-by-Grade Enrollment! r4c1:r2641c23";
*;

data dcd.DCPS_longenroll; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			Master_School_Name		$50.
			UI_ID					$14.
			DCPS					$14.
			Band					$8.
			Grade					$8.
			aud_0102				8.
			aud_0203				8.
			aud_0304				8.
			aud_0405				8.
			aud_0506				8.
			aud_0607				8.
			aud_0708				8.
			aud_0809				8.
			aud_0910				8.
			rep_0102				8.
			rep_0203				8.
			rep_0304				8.
			rep_0405				8.
			rep_0506				8.
			rep_0607				8.
			rep_0708				8.
			rep_0809				8.
			rep_0910				8.
;

		input
			Master_School_Name	  $
			UI_ID				  $
			DCPS
			Band				  $
			Grade				  $
			aud_0102			
			aud_0203				
			aud_0304			
			aud_0405			
			aud_0506			
			aud_0607				
			aud_0708			
			aud_0809			
			aud_0910						
			rep_0102			
			rep_0203			
			rep_0304			
			rep_0405			
			rep_0506			
			rep_0607			
			rep_0708			
			rep_0809
			rep_0910;

			if grade = "PreK" then grade="PK";
			if grade = "Presch" then grade="PS";
			if grade = "Ad/Ung" then grade="Adult";
			
		run;

%macro Grade_sep;
	%let macro_grade = PS PK K 1 2 3 4 5 6 7 8 9 10 11 12 Adult;
	%do grd=1 %to 16;
	%let i=%scan(&macro_grade,&grd,' ');	
		data DCPS_longenroll_&i. (keep=
				UI_ID
				Master_School_Name
				aud_0102_&i.
				aud_0203_&i.
				aud_0304_&i.
				aud_0405_&i.
				aud_0506_&i.
				aud_0607_&i.
				aud_0708_&i.
				aud_0809_&i.
				aud_0910_&i.
				rep_0102_&i.
				rep_0203_&i.
				rep_0304_&i.
				rep_0405_&i.
				rep_0506_&i.
				rep_0607_&i.
				rep_0708_&i.
				rep_0809_&i.
				rep_0910_&i.);
		set dcd.DCPS_longenroll;
			where grade="&i.";
				
				aud_0102_&i. = aud_0102;				
				aud_0203_&i. = aud_0203;			
				aud_0304_&i. = aud_0304;			
				aud_0405_&i. = aud_0405;			
				aud_0506_&i. = aud_0506;				
				aud_0607_&i. = aud_0607;			
				aud_0708_&i. = aud_0708;			
				aud_0809_&i. = aud_0809;
				aud_0910_&i. = aud_0910;	
				rep_0102_&i. = rep_0102;		
				rep_0203_&i. = rep_0203;		
				rep_0304_&i. = rep_0304;		
				rep_0405_&i. = rep_0405;		
				rep_0506_&i. = rep_0506;		
				rep_0607_&i. = rep_0607;		
				rep_0708_&i. = rep_0708;		
				rep_0809_&i. = rep_0809;
				rep_0910_&i. = rep_0910;

			run;
	%end;
%mend Grade_sep;
%Grade_sep;

/**************Label All Variables********************/

%macro label;
	%let macro_grade = PS PK K 1 2 3 4 5 6 7 8 9 10 11 12 Adult;
	%do grd=1 %to 16;
	%let i=%scan(&macro_grade,&grd,' ');	
		data DCPS_longenroll2_&i.;
		set DCPS_longenroll_&i.;	
		label
			aud_0102_&i. = "Audited Enrollment 2001-02 Grade &i."
			aud_0203_&i. = "Audited Enrollment 2002-03 Grade &i."
			aud_0304_&i. = "Audited Enrollment 2003-04 Grade &i."
			aud_0405_&i. = "Audited Enrollment 2004-05 Grade &i."
			aud_0506_&i. = "Audited Enrollment 2005-06 Grade &i."
			aud_0607_&i. = "Audited Enrollment 2006-07 Grade &i."
			aud_0708_&i. = "Audited Enrollment 2007-08 Grade &i."
			aud_0809_&i. = "Audited Enrollment 2008-09 Grade &i."
			aud_0910_&i. = "Audited Enrollment 2009-10 Grade &i."
			rep_0102_&i. = "October Certified Enrollment 2001-02 Grade &i."
			rep_0203_&i. = "October Certified Enrollment 2002-03 Grade &i."
			rep_0304_&i. = "October Certified Enrollment 2003-04 Grade &i."
			rep_0405_&i. = "October Certified Enrollment 2004-05 Grade &i."
			rep_0506_&i. = "October Certified Enrollment 2005-06 Grade &i."
			rep_0607_&i. = "October Certified Enrollment 2006-07 Grade &i."
			rep_0708_&i. = "October Certified Enrollment 2007-08 Grade &i."
			rep_0809_&i. = "October Certified Enrollment 2008-09 Grade &i."
			rep_0910_&i. = "October Certified Enrollment 2009-10 Grade &i.";
		run;
	%end;
%mend label;
%label;

/*create crosswalk including UI_ID, master school name and all GEOG variables*/

/*here starts merge of master school file on to enrollment file 7/18/2011 SL*/

/*****************************************************************************
data crosswalk_longenroll;
	*set gen.Master_school_newgeo_082010;
	set gen.Master_school_file_final_082010; *Updated 5/5/11 R Pitingolo;
	keep 
		 UI_ID
		 School_name_2009
		 Sch_0405_address_match
		 Sch_0405_address_std
		 Sch_2000_address
		 Sch_2001_address
		 Sch_2001_zip
		 Sch_2002_address
		 Sch_2002_zip
		 Sch_2003_address
		 Sch_2003_zip
		 Sch_2004_address
		 Sch_2004_zip
		 Sch_2005_address
		 Sch_2005_zip
		 Sch_2006_address
		 Sch_2006_zip
		 Sch_2007_address
		 Sch_2007_zip
		 Sch_2008_address
		 Sch_2008_zip
		 Sch_2009_address
		 Sch_2009_zip
		 Sch_2010_address
		 Sch_2010_zip
		 addr_var_2001
		 addr_var_2002
		 addr_var_2003
		 addr_var_2004
		 addr_var_2005
		 addr_var_2006
		 addr_var_2007
		 addr_var_2008
		 addr_var_2009
		 addr_var_2010
		 anc2002_2001
		 anc2002_2002
		 anc2002_2003
		 anc2002_2004
		 anc2002_2005
		 anc2002_2006
		 anc2002_2007
		 anc2002_2008
		 anc2002_2009
		 anc2002_2010
		 cluster2000_2001
		 cluster2000_2002
		 cluster2000_2003
		 cluster2000_2004
		 cluster2000_2005
		 cluster2000_2006
		 cluster2000_2007
		 cluster2000_2008
		 cluster2000_2009
		 cluster2000_2010
		 cluster_tr2000_2001
		 cluster_tr2000_2002
		 cluster_tr2000_2003
		 cluster_tr2000_2004
		 cluster_tr2000_2005
		 cluster_tr2000_2006
		 cluster_tr2000_2007
		 cluster_tr2000_2008
		 cluster_tr2000_2009
		 cluster_tr2000_2010
		 dcg_match_score_2001
		 dcg_match_score_2002
		 dcg_match_score_2003
		 dcg_match_score_2004
		 dcg_match_score_2005
		 dcg_match_score_2006
		 dcg_match_score_2007
		 dcg_match_score_2008
		 dcg_match_score_2009
		 dcg_match_score_2010
		 dcg_num_parcels_0102
		 dcg_num_parcels_0203
		 dcg_num_parcels_0304
		 dcg_num_parcels_0405
		 dcg_num_parcels_0506
		 dcg_num_parcels_0607
		 dcg_num_parcels_0708
		 dcg_num_parcels_0809
		 dcg_num_parcels_0910
		 dcg_num_parcels_1011
		 geo2000_2001
		 geo2000_2002
		 geo2000_2003
		 geo2000_2004
		 geo2000_2005
		 geo2000_2006
		 geo2000_2007
		 geo2000_2008
		 geo2000_2009
		  geo2000_2010
		  geoblk2000_2001
		  geoblk2000_2002
		  geoblk2000_2003
		  geoblk2000_2004
		  geoblk2000_2005
		  geoblk2000_2006
		  geoblk2000_2007
		  geoblk2000_2008
		  geoblk2000_2009
		  geoblk2000_2010
		 psa2004_2001
		 psa2004_2002
		 psa2004_2003
		 psa2004_2004
		 psa2004_2005
		 psa2004_2006
		 psa2004_2007
		 psa2004_2008
		 psa2004_2009
		 psa2004_2010
		 str_addr_unit_2001
		 str_addr_unit_2002
		 str_addr_unit_2003
		 str_addr_unit_2004
		 str_addr_unit_2005
		 str_addr_unit_2006
		 str_addr_unit_2007
		 str_addr_unit_2008
		 str_addr_unit_2009
		 str_addr_unit_2010     
		 ward2002_2001
		 ward2002_2002
		 ward2002_2003
		 ward2002_2004
		 ward2002_2005
		 ward2002_2006
		 ward2002_2007
		 ward2002_2008
		 ward2002_2009
		 ward2002_2010
		 x_coord_2001
		 x_coord_2002
		 x_coord_2003
		 x_coord_2004
		 x_coord_2005
		 x_coord_2006
		 x_coord_2007
		 x_coord_2008
		 x_coord_2009
		 x_coord_2010
		 y_coord_2001
		 y_coord_2002
		 y_coord_2003
		 y_coord_2004
		 y_coord_2005
		 y_coord_2006
		 y_coord_2007
		 y_coord_2008
		 y_coord_2009
		 y_coord_2010
		 zip_match_2001
		 zip_match_2002
		 zip_match_2003
		 zip_match_2004
		 zip_match_2005
		 zip_match_2006
		 zip_match_2007
		 zip_match_2008
		 zip_match_2009
		 zip_match_2010; 
	run;

%macro sort;
	%let macro_grade = PS PK K 1 2 3 4 5 6 7 8 9 10 11 12 Adult;
	%do grd=1 %to 16;
	%let i=%scan(&macro_grade,&grd,' ');	

		proc sort data=DCPS_longenroll_&i.;
		by UI_ID;
	%end;
  run; 
%mend sort;
%sort;



proc sort data=crosswalk_longenroll;
	by UI_ID;
  run; 
**********************************************************************************/
/*here ends merge of master school file on to enrollment file 7/18/2011 SL*/

data DCPS_allsch_lngenrl_1;
	merge 
		/*crosswalk_longenroll (in=a)*/ DCPS_longenroll2_k (in=b) DCPS_longenroll2_PK (in=c)  DCPS_longenroll2_PS (in=d)
		DCPS_longenroll2_1 (in=e) DCPS_longenroll2_2 (in=f) DCPS_longenroll2_3 (in=g) DCPS_longenroll2_4 (in=h) 
		DCPS_longenroll2_5 (in=i) DCPS_longenroll2_6 (in=j) DCPS_longenroll2_7 (in=k) DCPS_longenroll2_8 (in=l) 
		DCPS_longenroll2_9 (in=m) DCPS_longenroll2_10 (in=n) DCPS_longenroll2_11 (in=o)
		DCPS_longenroll2_12 (in=p) DCPS_longenroll2_Adult (in=q);
	by UI_ID;
	if b or c or d or e or f or g or h or i or j or k or l or m or n or o or p or q;
 run; 



 %macro totals;
	
	data DCPS_allsch_lngenrl_2;
	%let macro_year = 0102 0203 0304 0405 0506 0607 0708 0809 0910;
		%do yr=1 %to 9;
		%let i=%scan(&macro_year, &yr,' ');
		%let j = %substr(&i,1,2);
		%let k = %substr(&i,3,2);
	set DCPS_allsch_lngenrl_1;
		total_aud_&i. = sum(of aud_&i._PS aud_&i._PK aud_&i._K aud_&i._1 aud_&i._2 aud_&i._3
								aud_&i._4 aud_&i._5 aud_&i._6 aud_&i._7 aud_&i._8 aud_&i._9
								aud_&i._10 aud_&i._11 aud_&i._12 aud_&i._Adult);
		label
			total_aud_&i. = "Total Audited Enrollment 20&j.-&k.";

		total_rep_&i. = sum(of rep_&i._PS rep_&i._PK rep_&i._K rep_&i._1 rep_&i._2 rep_&i._3
								rep_&i._4 rep_&i._5 rep_&i._6 rep_&i._7 rep_&i._8 rep_&i._9
								rep_&i._10 rep_&i._11 rep_&i._12 rep_&i._Adult);
		label
			total_rep_&i. = "Total October Certified Enrollment 20&j.-&k.";

		%end;
	run;
%mend totals;
%totals;


data dcd.DCPS_allsch_lngenrl;
set DCPS_allsch_lngenrl_2;
run;



ods html file="K:\Metro\PTatian\DCData\Libraries\Schools\Schools 1011 Files\Longitudinal Enrollment 2001-2009\dcps_aud_enrolltotal.xls" style=minimal; 
	proc print data= dcd.DCPS_allsch_lngenrl label noobs;
		var
			UI_ID
			Master_school_name
			School_name_2009
			total_aud_0102
			total_aud_0203
			total_aud_0304
			total_aud_0405
			total_aud_0506
			total_aud_0607
			total_aud_0708
			total_aud_0809
			total_aud_0910
			;
		title "Audited Enrollment Totals";
		title1 "DCPS";
	run;
ods html close; 
ods html file="K:\Metro\PTatian\DCData\Libraries\Schools\Schools 1011 Files\Longitudinal Enrollment 2001-2009\dcps_rep_enrolltotal.xls" style=minimal; 
	proc print data= dcd.DCPS_allsch_lngenrl label noobs;
		var
			UI_ID
			Master_school_name
			School_name_2009
			total_rep_0102
			total_rep_0203
			total_rep_0304
			total_rep_0405
			total_rep_0506
			total_rep_0607
			total_rep_0708
			total_rep_0809
			total_rep_0910
			;
		title "Reported Enrollment Totals";
		title1 "DCPS";
	run;
ods html close; 
