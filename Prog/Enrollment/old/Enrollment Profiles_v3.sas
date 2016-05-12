/**************************************************************************
 Program:  Enrollment Profiles
 Project:  SCHOOLS DCDATA 
 Author:   S. Litschwartz
 Created:  08/4/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Creates school enrollment indicators; 
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\Enrollment\School Formats.sas"; 
%DCData_lib( Schools)
/*store global variables*/
%global geos geolabel grade grade_label schl_label enr_label gend;
%let geos=GeoBlk2000 ward2002 psa2004 anc2002 zip_match cluster2000;
%let gend=%sysfunc(countw("&geos.",' ',)); 
%let grade = PS PK K 1 2 3 4 5 6 7 8 9 10 11 12 Adult Total;
%let grade_label = "in Grade PS" "in Grade PK" "in Grade K" "in Grade 1" "in Grade 2" "in Grade 3" 
					"in Grade 4" "in Grade 5"  "in Grade 6"  "in Grade 7" "in Grade 8" "in Grade 9" 
					"in Grade 10" "in Grade 11" "in Grade 12" "in Grade Adult" "in All Grades";

/*macros for dc data school work*/

*macro to output all variables for a range;
*this macro works for years that are of the form 2002 to 2010;
%macro yearrange1(var,y1,y2);
%local c x v yr;
%let c=%sysfunc(countw("&var.",' ',));
%do x=1 %to &c.;
	%let v=	%scan(&var.,&x.,' ');
	%do yr=&y1. %to &y2.;
		&v.&yr.
	%end;
%end;
%mend;



*this macro works for school years of the form 0910;
%macro yearrange2(var,y1,y2);
%local c x v yr i j;
%let c=%sysfunc(countw("&var.",' ',));
%do x=1 %to &c.;
	%let v=	%scan(&var.,&x.,' ');
	%do yr=&y1. %to &y2.;
		%let yr2=%eval(&yr. + 1);
		%let i=%substr(&yr.,3,2);
		%let j=%substr(&yr2.,3,2);
		&v.&i.&j.
	 %end;
%end;
%mend;


%macro varrange(varlist,range);
%local c1 c2 yr i var a v; 
%let c1=%sysfunc(countw("&range.",' ',));
%let c2=%sysfunc(countw("&varlist.",' ',));
%do v=1 %to &c2.;
	%let var=%scan(&varlist., &v.,' ');
	%do a=1 %to &c1.;
		%let i=%scan(&range., &a.,' ');
		&var.&i.
	%end;
%end;
%mend;	



%macro vareqrange(var,new,range);
%local c yr i; 
%let c=%sysfunc(countw("&range.",' ',));
%do yr=1 %to &c.;
	%let i=%scan(&range., &yr,' ');
	 &var.&i.=&new.&i.
%end;
%mend;	

/*end macros for dc data school work*/



/*allows user to see all global macro variables in the system
data allgeos;
    set sashelp.vmacro;
  run;*/

/*create permenant data set with all enrollment data*/
data schools.allenrollment(label=" Audited and Certified Enrollment File from PCSB and DCPS") ;
set schools.Dcps_allsch_lngenrl (in=a) schools.PCSB_allsch_lngenrl (in=b);
if a then SchoolType='1';
if b then SchoolType='2';
label SchoolType="Type of School";
format SchoolType $Schtype.
run;

/*create new year variable*/
%macro yearsep;
%do yr=2001 %to 2009;
	%let yr2=%eval(&yr. + 1);
	%let y1=%substr(&yr.,3,2);
	%let y2=%substr(&yr2.,3,2);
	data allenr&yr.;
		set schools.allenrollment;
		year=&yr.;
		label year="Year";
		keep year UI_ID Master_School_Name SchoolType
			%varrange(aud_&y1.&y2._,&grade.)
			%varrange(rep_&y1.&y2._,&grade.)
			;
		rename
			%vareqrange(aud_&y1.&y2._,aud_,&grade.)
			%vareqrange(rep_&y1.&y2._,rep_,&grade.)
			;
		run;

		data geo&yr.;
		set schools.master_school_file_final_082011;
		year=&yr.;
		label year="Year";
		keep year UI_ID 
			%varrange(&geos.,_&yr.)
			;
		rename
			%do g=1 %to &gend.; 
				%let geotype=%scan(&geos.,&g.,' ');
				&geotype._&yr.=&geotype.
			%end;
			;

		run;
	%end;
data allenr;
set %yearrange1(allenr,2001,2009);
if UI_ID ne ' ';
run;
data geo;
set %yearrange1(geo,2001,2009);
rename zip_match=zip;
run;	
%mend;
%yearsep;


/*take off labels and formats from enrollment data*/
proc datasets lib=work memtype=data;
   modify allenr; 
     attrib _all_ label=' '; 
	  attrib _all_ format=; 
run;
quit;
/*merge in geos from master school file*/
proc sort data=allenr;
by UI_ID year;
run;

proc sort data=geo;
by UI_ID year;
run;

data allenr_plus_geo;
merge allenr(in=a) geo(in=b);
by UI_ID year;
if a;
label 
Ward2002= "Ward (2002)"
GeoBlk2000= "Full census block ID (2000): sscccttttttbbbb"
Psa2004= "MPD Police Service Area (2004)"
Anc2002= "Advisory Neighborhood Commission (2002)"
Zip= "Zip code (5-digit)"
Cluster2000= "Neighborhood cluster (2000)"
;
if aud_Total not in (.,0) then openschool=1;
else openschool=0;
run;





** Merge files together, create remaining geographic IDs **;

data enr_geo;
set allenr_plus_geo;

  ** Census tract **;

  length Geo2000 $ 11;

  Geo2000 = GeoBlk2000;

  label
  Geo2000 = "Full census tract ID (2000): ssccctttttt";

  ** Tract-based neighborhood clusters **;

  %Block00_to_cluster_tr00()


  ** City **;

  length City $ 1;

  city = "1";

  label city = "Washington, D.C.";

  format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. 
         ward2002 $ward02a. zip $zipa. cluster2000 $clus00a. 
         city $city.;

run;


/** Macro Summarize - Start Definition **/

%macro Summarize( level= );

  %local filesuf level_lbl level_fmt file_lbl;


  %let level = %upcase( &level. );

  %if %sysfunc( putc( &level., $geoval. ) ) ~= %then %do;
    %let filesuf = %sysfunc( putc( &level, $geosuf. ) );
    %let level_lbl = %qsysfunc( putc( &level, $geodlbl. ) );
    %let level_fmt = %sysfunc( putc( &level, $geoafmt. ) );
  %end;
  %else %do;
    %err_mput( macro=Summarize, 
               msg=Level (LEVEL=&level) is not recognized. )
    %goto exit;
  %end;

  %let file_lbl = "School Enrollment, DC, &level_lbl";
  %let file_lbl_allgrd = "School Enrollment All Grades, DC, &level_lbl";

  ** Summarize by specified geographic level **;

  proc summary data=Enr_geo nway completetypes;
      class &level. year /preloadfmt;
      format &level &level_fmt;
    var %varrange(aud_,&grade.)
		%varrange(rep_,&grade.)
		openschool;
    output 
      out=allenr&filesuf. (drop=_freq_ _type_) 
      sum= ;
	  %let totgrd=%sysfunc(countw("&grade.",' ',));
	  label
	  %do gr=1 %to &totgrd.;
	  	%let glbl=%scan(&grade_label.,&gr.,' ',q);/*grade label*/
		%let grd=%scan(&grade.,&gr.,' ');/*grade label*/
		/* label enrollment variables*/
		aud_&grd.=Total Enrollment, "Audited", &glbl., "All Public Schools/Campuses"
		rep_&grd.=Total Enrollment, "October Certified", &glbl., "All Public Schools/Campuses"
	%end;
	openschool=Total Schools, "All Public Schools/Campuses";	
  run;

  proc summary data=Enr_geo nway completetypes;
      class &level. year schooltype/preloadfmt;
      format &level &level_fmt;
    var %varrange(aud_,&grade.)
		%varrange(rep_,&grade.)
		openschool;
    output 
      out=schltype_&filesuf. (drop=_freq_ _type_) 
      sum= ;
		
  run;
   %Super_transpose(  
	  		data=schltype_&filesuf. ,     /** Input data set **/
	  		out=schltype2_&filesuf.,      /** Output data set **/
	  		var=%varrange(aud_,&grade.)
				%varrange(rep_,&grade.)
				openschool, /** List of variables to transpose **/
	  		id=SchoolType ,       /** Input data set var. to use for transposing **/
	  		by=&level. year  /** List of BY variables (opt.) **/
			)
	data allenr_byschltype_&filesuf;
		set schltype2_&filesuf.;
		%let totgrd=%sysfunc(countw("&grade.",' ',));
	  	label
		%do gr=1 %to &totgrd.;
		  	%let glbl=%scan(&grade_label.,&gr.,' ',q);/*grade label*/
			%let grd=%scan(&grade.,&gr.,' ');/*grade label*/
			/* label enrollment variables*/
			aud_&grd._1=Total Enrollment, "Audited", &glbl., "DCPS Schools"
			rep_&grd._1=Total Enrollment, "October Certified", &glbl., "DCPS Schools"
			aud_&grd._2=Total Enrollment, "Audited", &glbl., "PCSB Schools"
			rep_&grd._2=Total Enrollment, "October Certified", &glbl., "PCSB Schools"
		%end;
		openschool_1=Total Schools, "DCPS Schools"
		openschool_2=Total Schools, "PCSB Schools"		
		;
		rename
		%do gr=1 %to &totgrd.;
		  	%let glbl=%scan(&grade_label.,&gr.,' ',q);/*grade label*/
			%let grd=%scan(&grade.,&gr.,' ');/*grade label*/
			/* label enrollment variables*/
			aud_&grd._1=aud_&grd._DCPS
			rep_&grd._1=rep_&grd._DCPS
			aud_&grd._2=aud_&grd._PCSB			
			rep_&grd._2=rep_&grd._PCSB
		%end;
		openschool_1=openschool_DCPS
		openschool_2=openschool_PCSB		
		;
   run;
	data enrollment_sum1;
		merge allenr_byschltype_&filesuf allenr&filesuf.;	
		by &level. year;
	run;

	data enrollment_sum2;
		set enrollment_sum1;
	    /*recode missing data as zero*/
	    array a_enroll{*} aud_: rep_: openschool:;
	    
	    do i = 1 to dim( a_enroll );
	      if missing( a_enroll{i} ) then a_enroll{i} = 0;
	    end;
	    drop i;    
  	run;

	data  Schools.Enrollment_AllGrades&filesuf. (label=&file_lbl_allgrd);
	set enrollment_sum2;
	run;

	data enrollment_sum3;
		set enrollment_sum2;
		keep %varrange(aud_Total rep_Total openschool, _DCPS _PCSB)
			 aud_Total rep_Total openschool year &level.;
	run;	
	
	%Super_transpose(  
	  		data=enrollment_sum3,     /** Input data set **/
	  		out=enrollment_sum4,      /** Output data set **/
	  		var= %varrange(aud_Total rep_Total openschool, _DCPS _PCSB)
			 	 aud_Total rep_Total openschool,			 /** List of variables to transpose **/
	  		id=year,       /** Input data set var. to use for transposing **/
	  		by=&level. /** List of BY variables (opt.) **/
			)


	data  Schools.Enrollment&filesuf. (label=&file_lbl);
	   set enrollment_sum4;
  	run;
	  %file_info( data=Schools.Enrollment_AllGrades&filesuf., printobs=5 )
	  %file_info( data=Schools.Enrollment&filesuf., printobs=5 )

 %exit:
%mend;
%Summarize( level=city )
%Summarize( level=anc2002 )
%Summarize( level=psa2004 )
%Summarize( level=geo2000 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2002 )
%Summarize( level=zip )











  






























	
	




