/**************************************************************************
 Program:  PCSB schbygrd_long_enroll.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/20/2010
 UPDATED:  08/10/2010 Updated with New master school geocode file
		   05/05/2011 - R Pitingolo - Updated filepaths for new directory structure.
		   7/19/2011 Updated file/library paths,put master file merge into comments, cleaned up totals lables SLL
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Creates all-school, grade-over-year enrollment file; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
%include "K:\Metro\SLitschw\Code Library\macrolibrary.sas";
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos) compress=binary ;
%DCData_lib( Schools)

proc sort  data=schools.Pcsb_longenroll out=Pcsb_longenroll;
by UI_ID;
run;
/*transpose enrollment with grades*/
%Super_transpose(  
  data=Pcsb_longenroll ,     /** Input data set **/
  out=Pcsb_longenroll1,      /** Output data set **/
  var=%yearrange2(aud_,2001,2009) %yearrange2(rep_,2001,2009), /** List of variables to transpose **/
  id=Grade ,       /** Input data set var. to use for transposing **/
  by=UI_ID Master_School_Name  /** List of BY variables (opt.) **/
)


/**************Label All Variables********************/

%macro label;
	data PCSB_longenroll2;
				set PCSB_longenroll1;	
				label
					%let macro_grade = PS PK K 1 2 3 4 5 6 7 8 9 10 11 12 Adult;
					%do grd=1 %to 16;
					%let i=%scan(&macro_grade,&grd,' ');
						%do yr=2001 %to 2009;
							%let yr2=%eval(&yr. + 1);
							%let x=%substr(&yr.,3,2);
							%let y=%substr(&yr2.,3,2);	
							aud_&x.&y._&i. = "Audited Enrollment 20&x.-&y. Grade &i."
							rep_&x.&y._&i. = "October Certified Enrollment 20&x.-&y. Grade &i."
						%end;
					%end;
				UI_ID="UI ID"
				Master_School_Name="Master School Name"	
				;
		run;
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

		proc sort data=Pcsb_longenroll_&i.;
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

 %macro totals;
	
	data PCSB_allsch_lngenrl;
	set PCSB_longenroll2;
	%let macro_year = 0102 0203 0304 0405 0506 0607 0708 0809 0910;
		%do yr=1 %to 9;
		%let i=%scan(&macro_year, &yr,' ');
		%let j = %substr(&i,1,2);
		%let k = %substr(&i,3,2);
		aud_&i._total = sum(of aud_&i._PS, aud_&i._PK, aud_&i._K, aud_&i._1, aud_&i._2, aud_&i._3,
								aud_&i._4, aud_&i._5, aud_&i._6, aud_&i._7, aud_&i._8, aud_&i._9,
								aud_&i._10, aud_&i._11, aud_&i._12, aud_&i._Adult);
		label
			aud_&i._total = "Total Audited Enrollment 20&j.-&k.";
			rep_&i._total = sum(of rep_&i._PS, rep_&i._PK, rep_&i._K, rep_&i._1, rep_&i._2, rep_&i._3,
								rep_&i._4, rep_&i._5, rep_&i._6, rep_&i._7, rep_&i._8, rep_&i._9,
								rep_&i._10, rep_&i._11, rep_&i._12, rep_&i._Adult);
		label
			rep_&i._total = "Total October Certified Enrollment 20&j.-&k.";
	
		%end;
	run;
%mend totals;
%totals;

proc sort data=PCSB_allsch_lngenrl;
by UI_ID;
run;


data schools.PCSB_allsch_lngenrl(label="PCSB Audited and Certified Enrollment");
set PCSB_allsch_lngenrl;
run;

%file_info(data=Schools.PCSB_allsch_lngenrl)

ods html file="D:\DCData\Libraries\schools\data\PCSB Audited and Certified Enrollment File.xls" style=minimal; 
	proc print data= schools.PCSB_allsch_lngenrl label noobs;
		title "Audited and Certified Enrollment";
		title1 "PCSB";
	run;
ods html close; 
