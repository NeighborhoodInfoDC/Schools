/**************************************************************************
 Program:  Master School Import.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   S. Litschwartz
 Created:  08/25/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Imports master school file from spread sheets;
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\schoolmacros.sas";
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\Enrollment\School Formats.sas"; 
%DCData_lib( Schools)
%let filepath = D:\DCData\Libraries\schools\raw\;



*Read file in from excel, make sure to have open while importing.;
filename dat dde "excel|&filepath[master_school_file_final_082010_SophieLitschwartz_082011.xls]master_school_file_final_082010! r2c1:r326c245" ;
	data schools.master_school_file_final_082011(Label="Master School File, Updated 8/2011");
		infile dat   notab missover dlm='09'x dsd lrecl=3000;
		informat 
			Notes_2009				$250.	
			Notes_2008				$250.
			Master_school_name		$50.
			School_Name_2009		$50.
			School_Name_2008		$50.
			UI_ID					$7.
			Sch_2009_address		$100.
			Sch_2009_zip			$5.
			Sch_2008_address		$100.
			Sch_2008_zip			$5.
			Sch_2007_address		$100.
			Sch_2007_zip			$5.
			Sch_2006_address		$100.
			Sch_2006_zip			$5.
			Sch_2005_address		$100.
			Sch_2005_zip			$5.
			Sch_2004_address		$100.
			Sch_2004_zip			$5.
			Sch_2003_address		$100.
			Sch_2003_zip			$5.
			SEO_SchNum				$3.
			School_Number			$3.	
			DCPS					$1.
			PUBC					$1.
			grade_min_2010			$8. 
			grade_max_2010			$8. 
			grade_min_2009			$8. 
			grade_max_2009			$8. 
			grade_min_2008			$8. 
			grade_max_2008			$8. 
			grade_min_0708			$8. 
			grade_max_2007			$8. 
			Notes_2010				$250.
			School_Name_2010		$50.	
			Sch_2010_address		$100.
			Sch_2010_zip			$5.
			Sch_2000_address		$100.
			Sch_2000_zip			$5.
			Sch_2001_address		$100.
			Sch_2001_zip			$5.
			Sch_2002_address		$100.
			Sch_2002_zip			$5.
			only_master				$12.
			only_1011				$12.
			only_0003				$12.
			addr_var_2000			$32.
			anc2002_2000			$2.
			cluster2000_2000		$2.	
			cluster_tr2000_2000		$2.
			geo2000_2000			$12.
			geoblk2000_2000			$15.
			psa2004_2000			$3.
			ward2002_2000			$1.
			zip_match_2000			$5.
			dcg_num_parcels_0001	$3.	
			x_coord_2000			8.
			y_coord_2000			8.
			ssl_2000				$12.
			UNITNUMBER_2000			$12.
			ui_proptype_2000		$12.	
			str_addr_unit_2000		$12.
			dcg_match_score_2000	$3.	
			addr_var_2001			$32.
			anc2002_2001			$2.
			cluster2000_2001		$2.
			cluster_tr2000_2001		$2.
			geo2000_2001			$12.
			geoblk2000_2001			$15.
			psa2004_2001			$3.
			ward2002_2001			$1.
			zip_match_2001			$5.
			dcg_num_parcels_0102	$3.	
			x_coord_2001			8.
			y_coord_2001			8.
			ssl_2001				$12.
			UNITNUMBER_2001			$12.
			ui_proptype_2001		$12.
			str_addr_unit_2001		$12.
			dcg_match_score_2001	$3.	
			addr_var_2002			$32.
			anc2002_2002			$2.
			cluster2000_2002		$2.	
			cluster_tr2000_2002		$2.
			geo2000_2002			$12.
			geoblk2000_2002			$15.
			psa2004_2002			$3.
			ward2002_2002			$1.
			zip_match_2002			$5.
			dcg_num_parcels_0203	$3.	
			x_coord_2002			8.
			y_coord_2002			8.	
			ssl_2002				$12.
			UNITNUMBER_2002			$12.
			ui_proptype_2002		$12.
			str_addr_unit_2002		$12.
			dcg_match_score_2002	$3.	
			addr_var_2003			$32.
			anc2002_2003			$2.
			cluster2000_2003		$2.
			cluster_tr2000_2003		$2.
			geo2000_2003			$12.
			geoblk2000_2003			$15.
			psa2004_2003			$3.
			ward2002_2003			$1.
			zip_match_2003			$5.
			dcg_num_parcels_0304	$3.	
			x_coord_2003			8.
			y_coord_2003			8.	
			ssl_2003				$12.
			UNITNUMBER_2003			$12.
			ui_proptype_2003		$12.	
			str_addr_unit_2003		$12.
			dcg_match_score_2003	$3.
			Sch_0405_address_std	$32.
			addr_var_2004			$32.
			anc2002_2004			$2.
			cluster2000_2004		$2.	
			cluster_tr2000_2004		$2.
			geo2000_2004			$12.
			geoblk2000_2004			$15.
			psa2004_2004			$3.
			ward2002_2004			$1.
			zip_match_2004			$5.
			dcg_num_parcels_0405	$3.	
			x_coord_2004			8.
			y_coord_2004			8.
			ssl_2004				$12.
			Sch_0405_address_match	$32.
			UNITNUMBER_2004			$12.
			ui_proptype_2004		$12.
			str_addr_unit_2004		$12.
			dcg_match_score_2004	$3.
			addr_var_2005			$32.
			anc2002_2005			$2.
			cluster2000_2005		$2.
			cluster_tr2000_2005		$2.	
			geo2000_2005			$12.
			geoblk2000_2005			$15.
			psa2004_2005			$3.
			ward2002_2005			$1.
			zip_match_2005			$5.
			dcg_num_parcels_0506	$3.
			x_coord_2005			8.
			y_coord_2005			8.
			ssl_2005				$12.
			UNITNUMBER_2005			$12.
			ui_proptype_2005		$12.
			str_addr_unit_2005		$12.
			dcg_match_score_2005	$3.
			addr_var_2006			$32.
			anc2002_2006			$2.
			cluster2000_2006		$2.	
			cluster_tr2000_2006		$2.
			geo2000_2006			$12.
			geoblk2000_2006			$15.
			psa2004_2006			$3.
			ward2002_2006			$1.
			zip_match_2006			$5.
			dcg_num_parcels_0607	$3.	
			x_coord_2006			8.
			y_coord_2006			8.
			ssl_2006				$12.
			UNITNUMBER_2006			$12.
			ui_proptype_2006		$12.
			str_addr_unit_2006		$12.
			dcg_match_score_2006	$3.
			addr_var_2007			$32.
			anc2002_2007			$2.
			cluster2000_2007		$2.
			cluster_tr2000_2007		$2.
			geo2000_2007			$12.
			geoblk2000_2007			$15.
			psa2004_2007			$3.
			ward2002_2007			$1.
			zip_match_2007			$5.
			dcg_num_parcels_0708	$3.
			x_coord_2007			8.
			y_coord_2007			8.
			ssl_2007				$12.
			UNITNUMBER_2007			$12.
			ui_proptype_2007		$12.
			str_addr_unit_2007		$12.
			dcg_match_score_2007	$3.	
			addr_var_2008			$32.
			anc2002_2008			$2.
			cluster2000_2008		$2.	
			cluster_tr2000_2008		$2.
			geo2000_2008			$12.
			geoblk2000_2008			$15.
			psa2004_2008			$3.
			ward2002_2008			$1.
			zip_match_2008			$5.
			dcg_num_parcels_0809	$3.
			x_coord_2008			8.
			y_coord_2008			8.
			ssl_2008				$12.
			UNITNUMBER_2008			$12.
			ui_proptype_2008		$12.
			str_addr_unit_2008		$12.	
			dcg_match_score_2008	$3.
			addr_var_2009			$32.
			anc2002_2009			$2.
			cluster2000_2009		$2.	
			cluster_tr2000_2009		$2.
			geo2000_2009			$12.
			geoblk2000_2009			$15.
			psa2004_2009			$3.
			ward2002_2009			$1.
			zip_match_2009			$5.
			dcg_num_parcels_0910	$3.
			x_coord_2009			8.
			y_coord_2009			8.
			ssl_2009				$12.
			UNITNUMBER_2009			$12.
			ui_proptype_2009		$12.
			str_addr_unit_2009		$12.
			dcg_match_score_2009	$3.	
			addr_var_2010			$32.
			anc2002_2010			$2.
			cluster2000_2010		$2.
			cluster_tr2000_2010		$2.
			geo2000_2010			$12.
			geoblk2000_2010			$15.
			psa2004_2010			$12.
			ward2002_2010			$1.
			zip_match_2010			$5.
			dcg_num_parcels_1011	$3.	
			x_coord_2010			8.
			y_coord_2010			8.
			ssl_2010				$12.
			UNITNUMBER_2010			$12.
			ui_proptype_2010		$12.	
			str_addr_unit_2010		$12.
			dcg_match_score_2010	$3.	
			PUMA_2000				$12.
			PUMA_2001				$12.
			PUMA_2002				$12.
			PUMA_2003				$12.
			PUMA_2004				$12.
			PUMA_2005				$12.
			PUMA_2006				$12.
			PUMA_2007				$12.
			PUMA_2008				$12.
			PUMA_2009				$12.
			PUMA_2010				$12.
			;

		input   
			Notes_2009			$	
			Notes_2008			$
			Master_school_name	$
			School_Name_2009	$
			School_Name_2008	$
			UI_ID				$
			Sch_2009_address	$
			Sch_2009_zip		$
			Sch_2008_address	$	
			Sch_2008_zip		$
			Sch_2007_address	$
			Sch_2007_zip		$
			Sch_2006_address	$	
			Sch_2006_zip		$
			Sch_2005_address	$	
			Sch_2005_zip		$
			Sch_2004_address	$
			Sch_2004_zip		$
			Sch_2003_address	$
			Sch_2003_zip		$
			SEO_SchNum			$
			School_Number		$
			DCPS				$
			PUBC				$
			grade_min_2010		$	
			grade_max_2010		$
			grade_min_2009		$
			grade_max_2009		$
			grade_min_2008		$
			grade_max_2008		$
			grade_min_0708		$
			grade_max_2007		$
			Notes_2010			$
			School_Name_2010	$	
			Sch_2010_address	$	
			Sch_2010_zip		$
			Sch_2000_address	$	
			Sch_2000_zip		$
			Sch_2001_address	$
			Sch_2001_zip		$
			Sch_2002_address	$
			Sch_2002_zip		$
			only_master			$
			only_1011			$
			only_0003			$
			addr_var_2000		$
			anc2002_2000		$
			cluster2000_2000	$
			cluster_tr2000_2000	$
			geo2000_2000		$
			geoblk2000_2000		$
			psa2004_2000		$
			ward2002_2000		$
			zip_match_2000		$
			dcg_num_parcels_0001 $	
			x_coord_2000			
			y_coord_2000
			ssl_2000			$
			UNITNUMBER_2000		$
			ui_proptype_2000	$	
			str_addr_unit_2000	$
			dcg_match_score_2000	$
			addr_var_2001			$
			anc2002_2001			$
			cluster2000_2001		$
			cluster_tr2000_2001		$
			geo2000_2001			$
			geoblk2000_2001			$
			psa2004_2001			$
			ward2002_2001			$
			zip_match_2001			$
			dcg_num_parcels_0102	$
			x_coord_2001
			y_coord_2001
			ssl_2001				$
			UNITNUMBER_2001			$
			ui_proptype_2001		$
			str_addr_unit_2001		$
			dcg_match_score_2001	$
			addr_var_2002			$
			anc2002_2002			$
			cluster2000_2002		$
			cluster_tr2000_2002		$
			geo2000_2002			$
			geoblk2000_2002			$
			psa2004_2002			$
			ward2002_2002			$
			zip_match_2002			$
			dcg_num_parcels_0203	$
			x_coord_2002
			y_coord_2002
			ssl_2002				$
			UNITNUMBER_2002			$
			ui_proptype_2002		$
			str_addr_unit_2002		$
			dcg_match_score_2002	$
			addr_var_2003			$
			anc2002_2003			$
			cluster2000_2003		$
			cluster_tr2000_2003		$
			geo2000_2003			$
			geoblk2000_2003			$
			psa2004_2003			$
			ward2002_2003			$
			zip_match_2003			$
			dcg_num_parcels_0304	$	
			x_coord_2003
			y_coord_2003
			ssl_2003				$
			UNITNUMBER_2003			$
			ui_proptype_2003		$
			str_addr_unit_2003		$
			dcg_match_score_2003	$	
			Sch_0405_address_std	$
			addr_var_2004			$
			anc2002_2004			$
			cluster2000_2004		$
			cluster_tr2000_2004		$
			geo2000_2004			$
			geoblk2000_2004			$
			psa2004_2004			$
			ward2002_2004			$
			zip_match_2004			$
			dcg_num_parcels_0405	$	
			x_coord_2004		
			y_coord_2004
			ssl_2004				$
			Sch_0405_address_match  $
			UNITNUMBER_2004			$
			ui_proptype_2004		$
			str_addr_unit_2004		$
			dcg_match_score_2004	$	
			addr_var_2005			$
			anc2002_2005			$
			cluster2000_2005		$
			cluster_tr2000_2005		$
			geo2000_2005			$
			geoblk2000_2005			$	
			psa2004_2005			$
			ward2002_2005			$
			zip_match_2005			$
			dcg_num_parcels_0506	$
			x_coord_2005		
			y_coord_2005
			ssl_2005				$
			UNITNUMBER_2005			$
			ui_proptype_2005		$
			str_addr_unit_2005		$	
			dcg_match_score_2005	$
			addr_var_2006			$
			anc2002_2006			$
			cluster2000_2006		$
			cluster_tr2000_2006		$
			geo2000_2006			$
			geoblk2000_2006			$
			psa2004_2006			$
			ward2002_2006			$
			zip_match_2006			$
			dcg_num_parcels_0607	$	
			x_coord_2006
			y_coord_2006
			ssl_2006				$
			UNITNUMBER_2006			$
			ui_proptype_2006		$
			str_addr_unit_2006		$
			dcg_match_score_2006	$	
			addr_var_2007			$
			anc2002_2007			$
			cluster2000_2007		$
			cluster_tr2000_2007		$
			geo2000_2007			$
			geoblk2000_2007			$
			psa2004_2007			$
			ward2002_2007			$
			zip_match_2007			$
			dcg_num_parcels_0708	$
			x_coord_2007			$
			y_coord_2007
			ssl_2007
			UNITNUMBER_2007
			ui_proptype_2007
			str_addr_unit_2007
			dcg_match_score_2007
			addr_var_2008
			anc2002_2008
			cluster2000_2008
			cluster_tr2000_2008
			geo2000_2008
			geoblk2000_2008
			psa2004_2008
			ward2002_2008
			zip_match_2008
			dcg_num_parcels_0809
			x_coord_2008
			y_coord_2008
			ssl_2008
			UNITNUMBER_2008
			ui_proptype_2008
			str_addr_unit_2008
			dcg_match_score_2008
			addr_var_2009
			anc2002_2009
			cluster2000_2009
			cluster_tr2000_2009
			geo2000_2009
			geoblk2000_2009
			psa2004_2009
			ward2002_2009
			zip_match_2009
			dcg_num_parcels_0910
			x_coord_2009
			y_coord_2009
			ssl_2009
			UNITNUMBER_2009
			ui_proptype_2009
			str_addr_unit_2009
			dcg_match_score_2009
			addr_var_2010
			anc2002_2010
			cluster2000_2010
			cluster_tr2000_2010
			geo2000_2010
			geoblk2000_2010
			psa2004_2010
			ward2002_2010
			zip_match_2010
			dcg_num_parcels_1011
			x_coord_2010
			y_coord_2010
			ssl_2010
			UNITNUMBER_2010
			ui_proptype_2010
			str_addr_unit_2010
			dcg_match_score_2010
			PUMA_2000
			PUMA_2001
			PUMA_2002
			PUMA_2003
			PUMA_2004
			PUMA_2005
			PUMA_2006
			PUMA_2007
			PUMA_2008
			PUMA_2009
			PUMA_2010
 ;
		run;
