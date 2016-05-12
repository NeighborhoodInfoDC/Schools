/**************************************************************************
 Program:  Testscores_allsch_allyr
 Library:  Prog\cleaning
 Project:  schools
 Author:   Z. McDade
 Created:  07/15/2010
 UPDATED:  03/22/2011 (ZM) for new OSSE testscore format
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Puts all the DC school test scores into one file for checking; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

libname msf "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Master school file";
libname dcd "&filepath.";
libname sch "D:\DCData\Libraries\Schools\Data";

%macro rename (year=);
%let geoyear = %eval(&year.-1);
	data Testscore_&year._lab;
		set Testscore_&year.;
			%do i=3 %to 10;
			 %if &i. ne 9 %then %do;
				label
						read_num_&year._&i. 		 = "Number tested reading grade &i. &year."			
						read_bb_&year._&i.			 = "Number read below basic grade &i. &year."	
						read_b_&year._&i.			 = "Number read basic grade &i. &year."			
						read_p_&year._&i.			 = "Number read proficient grade &i. &year."			
						read_adv_&year._&i.		 = "Number read advanced grade &i. &year."			
						read_bb_perc_&year._&i.	 = "Percent below basic grade &i. &year."		
						read_b_perc_&year._&i.		 = "Percent basic grade &i. &year."			
						read_p_perc_&year._&i.		 = "Percent proficient grade &i. &year."			
						read_adv_perc_&year._&i. = "Percent advanced grade &i. &year."			
						math_num_&year._&i.		 = "Number tested math grade &i. &year."  				
						math_bb_&year._&i.			 = "Number math below basic grade &i. &year."  		
						math_b_&year._&i.			 = "Number math basic grade &i. &year."  		
						math_p_&year._&i.			 = "Number math proficient grade &i. &year."  		
						math_adv_&year._&i.		 = "Number math advanced grade &i. &year."						
						math_bb_perc_&year._&i.	 = "Percent math below basic grade &i. &year."		
						math_b_perc_&year._&i.		 = "Percent math basic grade &i. &year."			
						math_p_perc_&year._&i.		 = "Percent math proficient grade &i. &year."		
						math_adv_perc_&year._&i. = "Percent math advanced grade &i. &year.";			
					
				%end;
		  %end;
run;

     data Testscore_&year._lab;
		set Testscore_&year._lab;
			
				label
					UI_ID                		= "UI unique school identifier" 
					master_school_name    		= "Master School Name &year."   	
					Sch_&geoyear._address     		= "School Address &year." 
					Sch_&geoyear._zip        		= "Zip Code &year."	
					DCPS				 		= "School is non-Charter" 
					addr_var_&geoyear.        		= "Street Address &year."          
					anc2002_&geoyear.		  		=	"ANC &year."	    
					cluster2000_&geoyear. 	 		=	"Cluster &year."		
					cluster_tr2000_&geoyear.	  	=	"Cluster Tract2000 &year."        
					geo2000_&geoyear.	  			=	"Tract2000 &year."		
					geoblk2000_&geoyear.	 		=	"Block2000 &year."		
					psa2004_&geoyear.		 	 	=	"PSA2004 &year."		
					ward2002_&geoyear.	  			=	"Ward2002 &year."		
					zip_match_&geoyear.		 	=	"ZIP match &year."		
					dcg_num_parcels     	 	=	"Parcels &year."		
					x_coord_&geoyear.	      		=	"X coordinate &year."		
					y_coord_&geoyear.	      		=	"Y coordinate &year."	    
					ssl_&geoyear.		      		=	"SSL &year."	    
					UNITNUMBER_&geoyear. 	  		=	"Unit Number &year."		
					dcg_match_score_&geoyear.  	=	"DCG Match Score &year.";	
			
		run;
%mend rename; 
%rename (year=2007)
%rename (year=2008)
%rename (year=2009)
%rename (year=2010)
;

/*Merge years by UI_ID for one master set*/

%macro sort;
	%do year=2007 %to 2010;		
			proc sort data=testscore_&year._lab;
			by UI_ID;
			run;
	%end;
%mend sort;
%sort;

%macro merge;
data sch.Testscore_allsch_allyr(label="Master Testscore, all school, all year &sysdate.");
	merge
	%do year=2007 %to 2010;		
		 Testscore_&year._lab		
	%end;
	;
	by UI_ID;
run;
%mend merge;
%merge







