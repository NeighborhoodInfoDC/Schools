
/**************************************************************************
 Program:  schools_00_03_and_10_11.sas.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   M.Grosz 10/28/2009
 Created:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: adds on 00-03 and 10-11 addresses to master school file, created in schools_09_10;
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



data msf_1011 (rename = (master_school_name = master_school_name_drop1 ));
	set gen.master_school_file_1011_120109;
	keep UI_ID 
		 Notes_10_11             
		 Sch_1011_address        
		 Sch_1011_zip            
		 School_Name_2010_2011   
		 grade_max_1011          
		 grade_min_1011          
		 master_school_name
		 school_number;
		 if UI_ID = '' then delete;
		 if UI_ID = '1022500' and School_Name_2010_2011 = '' then delete;*head start, keep only one;
		 if UI_ID = '1096200' then delete;*DCALA;
		 if UI_ID = '1095500' then delete;*DCALA;
		 if UI_ID = '1094900' then delete;*DCALA;
		 if UI_ID = '2106208' then UI_ID = '2106207';
		 if UI_ID = '2106209' then UI_ID = '2106208';
		run; 
proc sort data= msf_1011 nodupkey;*this sort will get rid of the multiple DCALA and TWo Rivers;
	by UI_ID;
	run;
data msf_0003 (rename = (master_school_name = master_school_name_drop2));
	set gen.master_school_file_0003_120109;
	drop   Sch_0304_address   Sch_0304_zip;
	if UI_ID = '' then delete;
	if UI_ID = '1096200' then delete;*DCALA;
	if UI_ID = '1095500' then delete;*DCALA;
	if UI_ID = '1094900' then delete;*DCALA;
run;
proc sort data= msf_0003 nodupkey;*this sort will get rid of the multiple DCALA and TWo Rivers;
	by UI_ID;
	run;

data masterfile;
	set gen.Master_school_file_0910;
	if UI_ID = '' then delete;
	if UI_ID = '1022500' and School_Name_2008_2009 = '' then delete;*head start, keep only one;
	if UI_ID = '1029400' and School_Name_2008_2009 = '' then delete;*weird patterson duplicate;
	if UI_ID = '1096100' and master_School_Name = 'DCALA FRESHMAN' then delete;*DCALAs are just one;
	if UI_ID = '1096200' then delete;*DCALAs are just one;
	if UI_ID = '2103001' and School_Name_2008_2009 = '' then delete;*two rivers is just one campus;

	*Hardy mistake;
		if UI_ID = '1024600' then do;
			Sch_0607_address = Sch_0506_address;
			Sch_0607_zip = Sch_0506_zip;
			end;
	run;
proc sort data = masterfile;
	by UI_ID;
	run;

data master_school_file_120109 (drop = master_school_name_drop2 master_school_name_drop2 obs);
	merge masterfile (in = a) msf_1011 (in = b) msf_0003 (in = c);
	by UI_ID;
	if a then only_master = 1;
	else if b then only_1011 = 1;
	else if c then only_0003 = 1;
	if UI_ID = '1040300' then delete; *fletcher johnson is a mistake;
	*there should be only 2 new schools, the KIPP GROW and KIPP PROMISE;

	run;

*test the schools that are new, should be only 2;
		data test;
		set master_school_file_120109;
		where only_1011= 1 | only_0003 = 1;
		run;


*Geocode for every year;
	*0001;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0001a,             staddr=Sch_0001_address,             zip = Sch_0001_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0001a;      run;
	  endrsubmit;
	 
	*0102;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0102a,             staddr=Sch_0102_address,             zip = Sch_0102_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0102a;      run;
	  endrsubmit;
	 
	*0203;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0203,             staddr=Sch_0203_address,             zip = Sch_0203_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0203;      run;
	  endrsubmit;
	 
	*0304;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0304,             staddr=Sch_0304_address,             zip = Sch_0304_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0304;      run;
	  endrsubmit;
	 
	*0405;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0405,             staddr=Sch_0405_address,             zip = Sch_0405_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0405;      run;
	  endrsubmit;
	 
	*0506;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0506,             staddr=Sch_0506_address,             zip = Sch_0506_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0506;      run;
	  endrsubmit;
	 
	*0607;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0607,             staddr=Sch_0607_address,             zip = Sch_0607_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0607;      run;
	  endrsubmit;
	 
	*0708;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0708,             staddr=Sch_0708_address,             zip = Sch_0708_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0708;      run;
	  endrsubmit;
	 
	*0809;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo0809,             staddr=Sch_0809_address,             zip = Sch_0809_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo0809;      run;
	  endrsubmit;
	 
	*09010;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo09010,             staddr=Sch_09010_address,             zip = Sch_09010_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo09010;      run;
	  endrsubmit;
	 
	*1011;
	rsubmit;
	        proc upload     status = no              inlib = Work             outlib = Work            memtype = (data);            select master_school_file_120109;        run; 
	            /*%corrections (            infile = Students,             correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt,             outfile = students_clean,             repl_var = stu_street);*/
	      %DC_geocode(            data=master_school_file_120109,             out=master_school_file_geo1011,             staddr=Sch_1011_address,             zip = Sch_1011_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  master_school_file_geo1011;      run;
	  endrsubmit;
	 

*for some strange reason the geocode macro does not work for 4 schools that only appear in 2000 and 2001, so we do these separately;
	  	data geocode_extra01;
				set master_school_file_120109;
				where UI_ID in ('3101601','3101901','3102301','3102302');
				address_fix = Sch_0001_address;
				keep UI_ID Sch_0001_address /*Sch_1011_zip*/  address_fix;
				run;
			rsubmit;
	        proc upload     
				status = no  inlib = Work    outlib = Work   memtype = (data);  select geocode_extra;        run; 
					      %DC_geocode(            data=geocode_extra01,             out=geocode_extra_geo,             staddr=Sch_0001_address,             zip = Sch_0001_zip,             id = id,
					             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
					      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  geocode_extra_geo;      run;
					  endrsubmit;
		proc sort data = Master_school_file_geo0001a;
			by UI_ID;
			run;
		proc sort data = geocode_extra_geo;
			by UI_ID;
			run;
		data Master_school_file_geo0001;
			merge Master_school_file_geo0001 geocode_extra_geo;
				by UI_ID;
				run;


		data geocode_extra02;
				set master_school_file_120109;
				where UI_ID in ('3101601','3101901','3102301','3102302');
				address_fix = Sch_0102_address;
				keep UI_ID Sch_0102_address Sch_0102_zip  address_fix;
				run;
			rsubmit;
	        proc upload     
				status = no  inlib = Work    outlib = Work   memtype = (data);  select geocode_extra02;        run; 
					      %DC_geocode(            data=geocode_extra02,             out=geocode_extra_geo02,             staddr=Sch_0102_address,             zip = Sch_0102_zip,             id = id,
					             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
					      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  geocode_extra_geo02;      run;
					  endrsubmit;
		proc sort data = Master_school_file_geo0102a;
			by UI_ID;
			run;
		proc sort data = geocode_extra_geo02;
			by UI_ID;
			run;
		data Master_school_file_geo0102;
			merge Master_school_file_geo0102 geocode_extra_geo02;
				by UI_ID;

				run;
****************************;

%macro geocompile;
	%do d = 1 %to 11;
	%let grade = 0001 0102 0203 0304 0405 0506 0607 0708 0809 09010 1011;
	%let yr = %scan(&grade,&d,' ');
	%let grade2 = 0001 0102 0203 0304 0405 0506 0607 0708 0809 0910 1011;
	%let yr2 = %scan(&grade2,&d,' ');

	data sch.geo_&yr. (rename = (   
							UNITNUMBER             =UNITNUMBER_&yr2.            
							addr_var               =addr_var_&yr2.              
							anc2002                =anc2002_&yr2.               
							cluster2000            =cluster2000_&yr2.           
							cluster_tr2000         =cluster_tr2000_&yr2.        
							dcg_match_score        =dcg_match_score_&yr2.       
							dcg_num_parcels        =dcg_num_parcels_&yr2.       
							geo2000                =geo2000_&yr2.               
							geoblk2000             =geoblk2000_&yr2.            
							psa2004                =psa2004_&yr2.               
							ssl                    =ssl_&yr2.                   
							str_addr_unit          =str_addr_unit_&yr2.         
							ui_proptype            =ui_proptype_&yr2.           
							ward2002               =ward2002_&yr2.              
							x_coord                =x_coord_&yr2.               
							y_coord                =y_coord_&yr2.               
							zip_match			  = zip_match_&yr2.));			  
		set master_school_file_geo&yr.;
	keep UI_ID
			Sch_0405_address_match Sch_0405_address_std   UNITNUMBER             addr_var               
			anc2002 cluster2000            cluster_tr2000         dcg_match_score        dcg_num_parcels        geo2000                
			geoblk2000             psa2004                ssl                    str_addr_unit          ui_proptype            ward2002               
			x_coord                y_coord                zip_match;
		run; 
		proc sort;
			by UI_ID;
			run;
		%end;
		%mend;
		%geocompile;


		********************************************************************************************************************
		NEXT STEP IS IN ARCMAP, ADD ON PUMA by spatially joining the PUMA shapefile
			note that the x- and y-coordinates will be truncated in this step, so do not use them;

%macro geocompile2;
	%do yr = 2000 %to 2010;
	data sch_puma_&yr._geo (rename = (PUMA = PUMA_&yr.));
		set sch.sch_puma_&yr._geo;
		keep UI_ID PUMA;
		run;
	proc sort data = sch_puma_&yr._geo ;
		by UI_ID;
		run;
		%end;
		%mend;
%geocompile2;

%macro fixes;

data  test3 (drop = master_school_name_drop1 );
	merge master_school_file_120109
			sch.geo_0001
			sch.geo_0102
			sch.geo_0203
			sch.geo_0304
			sch.geo_0405
			sch.geo_0506
			sch.geo_0607
			sch.geo_0708
			sch.geo_0809
			sch.geo_09010
			sch.geo_1011
			sch_puma_2000_geo 
			sch_puma_2001_geo 
			sch_puma_2002_geo 
			sch_puma_2003_geo 
			sch_puma_2004_geo 
			sch_puma_2005_geo 
			sch_puma_2006_geo 
			sch_puma_2007_geo 
			sch_puma_2008_geo 
			sch_puma_2009_geo 
			sch_puma_2010_geo ;
			by UI_ID;
	%do d = 1 %to 11;
	%let grade = 0001 0102 0203 0304 0405 0506 0607 0708 0809 09010 1011;
	%let yr = %scan(&grade,&d,' ');
	%let grade2 = 0001 0102 0203 0304 0405 0506 0607 0708 0809 0910 1011;
	%let yr2 = %scan(&grade2,&d,' ');
	%let grade3 = 2000 2001	2002 2003 2004 2005 2006 2007 2008 2009 2010;
	%let yr3 = %scan(&grade3,&d,' ');
			if Sch_&yr._address = "2600 DOUGLASS RD SE" then do;
			UNITNUMBER_&yr2.    = '';    
			addr_var_&yr2.       = "2600 DOUGLASS PL SE";  
			anc2002_&yr2.         = "ANC 8A";  
			cluster2000_&yr2.      = "Cluster 37";
			cluster_tr2000_&yr2.    = "Cluster 37";
			dcg_match_score_&yr2.   = 37;
			dcg_num_parcels_&yr2.   =.;
			geo2000_&yr2.           ="Tract 74.06";
			geoblk2000_&yr2.        ="110010074064000";
			psa2004_&yr2.           ="PSA 703";
			ssl_&yr2.               ="5872    0950";
			str_addr_unit_&yr2.     ="";
			ui_proptype_&yr2.       ="29";
			ward2002_&yr2.          ="Ward 8";
			x_coord_&yr2.           =401037.25;
			y_coord_&yr2.           =132089.75;
			zip_match_&yr2.		="ZIP 20020";
			PUMA_&yr3. 			= "104";
			end;
		if Sch_&yr._address = "220 HIGH VIEW PLACE SE" then do;
			UNITNUMBER_&yr2.    = '';    
			addr_var_&yr2.       = "200 HIGHVIEW PL SE";  
			anc2002_&yr2.         = "ANC 8C";  
			cluster2000_&yr2.      = "Cluster 39";
			cluster_tr2000_&yr2.    = "Cluster 39";
			dcg_match_score_&yr2.   = 119;
			dcg_num_parcels_&yr2.   =.;
			geo2000_&yr2.           ="Tract 73.02";
			geoblk2000_&yr2.        ="110010073022016";
			psa2004_&yr2.           ="PSA 705";
			ssl_&yr2.               ="6003    0801";
			str_addr_unit_&yr2.     ="";
			ui_proptype_&yr2.       ="10";
			ward2002_&yr2.          ="Ward 8";
			x_coord_&yr2.           =399581.72;
			y_coord_&yr2.           =130478.62;
			zip_match_&yr2.		="ZIP 20020";
			PUMA_&yr3. 			= "104";
			end;
		%end;
		/*KIPP GROW*/
		if UI_ID = '2106208' then master_school_name = "KIPP DC- GROW ACADEMY";
		/*Typos and uncertain addresses for certain schools in 2010*/
			/*these are our assumptions*/
			if UI_ID in ('1029200'/*Adams-Oyster Oyster Campus*/,
						 '1035100'/*Thurgood Marshall Academy*/,
						 '1030700'/*Savoy, might be closing*/) then do;
						UNITNUMBER_1011    	  	=    UNITNUMBER_0910;       
						addr_var_1011      		=    addr_var_0910;             
						anc2002_1011      		=    anc2002_0910;               
						cluster2000_1011     	=    cluster2000_0910;       
						cluster_tr2000_1011     =    cluster_tr2000_0910; 
						dcg_match_score_1011    =	 dcg_match_score_0910;
						dcg_num_parcels_1011    =	 dcg_num_parcels_0910;
						geo2000_1011      		=    geo2000_0910;               
						geoblk2000_1011      	=    geoblk2000_0910;         
						psa2004_1011      		=    psa2004_0910;               
						ssl_1011      			=    ssl_0910;                       
						str_addr_unit_1011      =    str_addr_unit_0910;   
						ui_proptype_1011      	=    ui_proptype_0910;       
						ward2002_1011      		=    ward2002_0910;             
						x_coord_1011      		=    x_coord_0910;               
						y_coord_1011      		=    y_coord_0910;               
						zip_match_1011      	=    zip_match_0910;		 		
						PUMA_2010      			=    PUMA_2009; 
							end;	
			/*fix TWO RIVERS grade configuration, since sorted it out above*/
						if UI_ID = '2103001' then do;
							grade_max_1011 = 8;
							grade_max_0910 = 8;
							end;
			/*IDEA changing its grade-Min*/
							if UI_ID = '3200500' then grade_min_1011 = 6;
			/*there are a few schools fixed above in the geocoding that need their pumas added*/
				if UI_ID = '3101601' then PUMA_2002 = '105';
				if UI_ID = '3101601' then PUMA_2002 = '105';
				if UI_ID = '3101901' then PUMA_2002 = '105';
				if UI_ID = '3102301' then PUMA_2002 = '104';
				if UI_ID = '3102302' then PUMA_2002 = '102';

		run;

		data gen.master_school_file_FINAL_120109;
			set test3;
			%do e = 1 %to 11;
			%let grade2 = 0001 0102 0203 0304 0405 0506 0607 0708 0809 0910 1011;
			%let yr = %scan(&grade2,&e,' ');
			%let grade3 = 2000 2001	2002 2003 2004 2005 2006 2007 2008 2009 2010;
			%let yr3 = %scan(&grade3,&e,' ');
			rename 	/*rename all the variables to have 2000-2010 suffixes*/
				Sch_09010_address = Sch_2009_address
				Sch_09010_zip = Sch_2009_zip
				Notes_08_09 =    Notes_2008       
				Notes_09_10  =   Notes_2009       
				Notes_10_11   =  Notes_2010  
				grade_max_0809	=grade_max_2008
				grade_max_0910	=grade_max_2009
				grade_max_1011	=grade_max_2010
				grade_min_0809	=grade_min_2008
				grade_min_0910	=grade_min_2009
				grade_min_1011	=grade_min_2010

				Sch_&yr._address       = Sch_&yr3._address    
				Sch_&yr._zip           =Sch_&yr3._zip        
				School_Name_2008_2009  =School_Name_2008
				School_Name_2009_2010  =School_Name_2009
				School_Name_2010_2011  =School_Name_2010
				UNITNUMBER_&yr.        =UNITNUMBER_&yr3.     
				addr_var_&yr.          =addr_var_&yr3.       
				anc2002_&yr.           =anc2002_&yr3.        
				cluster2000_&yr.       =cluster2000_&yr3.    
				cluster_tr2000_&yr.    =cluster_tr2000_&yr3. 
				dcg_match_score_&yr.   =dcg_match_score_&yr3.
				geo2000_&yr.           =geo2000_&yr3.        
				geoblk2000_&yr.        =geoblk2000_&yr3.     
				grade_max_0708         =grade_max_2007       
				grade_min_0708         =grade_min_2008       
				only_0003              =only_0003            
				only_1011              =only_1011            
				only_master            =only_master          
				psa2004_&yr.           =psa2004_&yr3.        
				ssl_&yr.               =ssl_&yr3.            
				str_addr_unit_&yr.     =str_addr_unit_&yr3.  
				ui_proptype_&yr.       =ui_proptype_&yr3.    
				ward2002_&yr.          =ward2002_&yr3.       
				x_coord_&yr.           =x_coord_&yr3.        
				y_coord_&yr.           =y_coord_&yr3.        
				zip_match_&yr.         =zip_match_&yr3. ;
				%end;
				run;
	%mend;
	%fixes;
*************************************************************************************
*Find the schools that have not been geocoded, find the fixes, geocode, and then add them in to the data step above;
	/*%macro print;
	%do d = 1 %to 11;
	%let grade = 0001 0102 0203 0304 0405 0506 0607 0708 0809 09010 1011;
	%let yr = %scan(&grade,&d,' ');

	ods html file = "E:\Schools 0910\data\non geocoded DELETE &yr..xls";
			proc print data = Master_school_file_geo&yr.;
				var master_school_name Sch_&yr._address;
					where y_coord = .;
					title "&yr.";
					run;
					ods html close;%end;
					%mend;
			%print;*/


/*data geocode_fix;
	set gen.master_school_file_final_120109;
	*ROUND 1;
				*where Sch_1011_address = "2600 DOUGLASS RD SE" | Sch_1011_address = "220 HIGH VIEW PLACE SE";*
			*	if Sch_1011_address = "2600 DOUGLASS RD SE" then address_fix = "2600 DOUGLASS PL SE";
			*	if Sch_1011_address = "220 HIGH VIEW PLACE SE" then address_fix =  "200 HIGHVIEW PL SE ";
	*Round 2;
		where UI_ID in ('3101601','3101901','3102301','3102302');
		address_fix = Sch_0001_address;
		*if Sch_0001_address = "595 3RD ST NW" then address_fix = "600 3RD ST NW";
		if Sch_0001_address = "401 M STREET SW" then address_fix = "400 M STREET SW";
		if Sch_0001_address = "1027 45th St., NE" then address_fix = "1027 45TH ST NE";
		if Sch_0001_address = "100 PEABODY STREET NW" then address_fix = "2600 DOUGLASS PL SE";/


		keep Sch_1011_address Sch_0001_address Sch_1011_zip  address_fix;
		run;
	rsubmit;

	        proc upload     
status = no  inlib = Work    outlib = Work   memtype = (data);  select geocode_fix;        run; 
	      %DC_geocode(            data=geocode_fix,             out=geocode_fix_geo,             staddr=address_fix,             zip = Sch_1011_zip,             id = id,
	             unit_match=Y,            geo_match=Y,            block_match=Y,            listunmatched=Y,            debug=N);      run;
	      proc download status = no              inlib=work             outlib=work             memtype=(data);            select  geocode_fix_geo;      run;
	  endrsubmit;
	  proc print data = geocode_fix_geo;
	  run;


proc contents data = test4;run;
     
 
        
