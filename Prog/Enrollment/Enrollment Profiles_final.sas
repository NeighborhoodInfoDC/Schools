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
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\School Formats.sas"; 
%DCData_lib( Schools)
/*store global variables*/
%global geos gend;
/*update with latest geographies*/
%let geos=GeoBlk2000 ward2012 psa2012 anc2012 geo2010 zip cluster_tr2000;
%let gend=%sysfunc(countw("&geos.",' ',)); /*counts the geos in the list*/


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


/*************** Change this to most recent filename/year *****************/
%global curyr enroll msf;
%let curyr = 2012;
%let enroll = allenrollment_1213;
%let msf = master_school_file_final_00_12;

/*create new year variable*/
%macro yearsep;
%do yr=2001 %to &curyr.;
	%let yr2=%eval(&yr. + 1);
	%let y1=%substr(&yr.,3,2);
	%let y2=%substr(&yr2.,3,2);
	data allenr&yr.;
		set schools.&enroll.;
		year=&yr.;
		label year="Fall Year";
		keep year UI_ID SchoolType Grade aud_&y1.&y2. /* rep_&y1.&y2. */;
		rename aud_&y1.&y2.=aud /* rep_&y1.&y2.=rep */;
		label aud_&y1.&y2.='Audited Enrollment' /* rep_&y1.&y2.='October Certified Enrollment' */;
		run;

		data geo&yr.;
		set schools.&msf.;
		year=&yr.;
		label year="Fall Year";
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
set %yearrange1(allenr,2001,&curyr.);
if UI_ID ne ' ';
run;
data geo;
set %yearrange1(geo,2001,&curyr.);
/* rename zip_match=zip; */
run;	
%mend;
%yearsep;


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
	Ward2012= "Ward (2012)"
	GeoBlk2000= "Full census block ID (2000): sscccttttttbbbb"
	Psa2012= "MPD Police Service Area (2012)"
	Anc2012= "Advisory Neighborhood Commission (2012)"
	Zip= "Zip code (5-digit)"
	geo2010= "Full census tract ID (2010): ssccctttttt"
	cluster_tr2000 = "Neighborhood cluster (tract-based, 2000)"
	;
	if aud not in (.,0) then openschool=1;
	else openschool=0;
run;





** Create remaining geographic IDs **;
data enr_geo;
set allenr_plus_geo;

  ** Census tract **;

  length Geo2000 $ 11;

  Geo2000 = GeoBlk2000;

  label
  Geo2000 = "Full census tract ID (2000): ssccctttttt";

  ** Tract-based neighborhood clusters **;

  /* %Block00_to_cluster_tr00() */


  ** City **;

  length City $ 1;

  city = "1";

  label city = "Washington, D.C.";

  format geo2000 $geo00a. geo2010 $geo10a. anc2012 $anc12a. psa2012 $psa12a. 
         ward2012 $ward12a. zip $zipa. city $city. cluster_tr2000 $CLUS00A16.;

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
  %let file_lbl_allgrd = "School Enrollment All Grades,by Grade/Year, DC, &level_lbl";

  ** Summarize by specified geographic level **;

  proc summary data=Enr_geo nway completetypes;
      class &level. year grade /preloadfmt;
      format &level &level_fmt;
    var aud /* rep */ openschool;
    output 
      out=allenr&filesuf. (drop=_freq_ _type_) 
      sum= ;
	  %let totgrd=%sysfunc(countw("&grade.",' ',));
	  label openschool='Number of Schools';	
  run;
  proc summary data=Enr_geo nway completetypes;
      class &level. year grade schooltype /preloadfmt;
      format &level &level_fmt;
    var aud /* rep */ openschool;
    output 
      out=schltype&filesuf. (drop=_freq_ _type_) 
      sum= ;
		
  run;
   %Super_transpose(  
	  		data=schltype&filesuf. ,     /** Input data set **/
	  		out=schltype2&filesuf.,      /** Output data set **/
	  		var= aud /* rep */ openschool, /** List of variables to transpose **/
	  		id=SchoolType ,       /** Input data set var. to use for transposing **/
	  		by=&level. year grade  /** List of BY variables (opt.) **/
			)
/*merge together sums by schooltype, with sum over all school types*/
	proc sort data=schltype2&filesuf.;
		by &level. year grade;
	run;

	proc sort data=allenr&filesuf.;
		by &level. year grade;
	run;
	
	data enrollment_sum1;
		merge schltype2&filesuf. allenr&filesuf.;	
		by &level. year grade;
	run;

	/*label variables with with school type*/
	data enrollment_sum2;
		set enrollment_sum1 end=eof;
		if eof then call execute('data enrollment_sum3; set enrollment_sum2;');
		 %let j = 1;
      	%let allval = /* rep */ aud openschool;
		%let val=%scan(&allval., &j );
		%do %until (&val. =  );
			if eof then call execute("label &val._DCPS="||'"'||strip(vlabel(&val.))||', DCPS'||'";');
			if eof then call execute("label &val._PCSB="||'"'||strip(vlabel(&val.))||', PCSB'||'";');
			if eof then call execute("label &val.="||'"'||strip(vlabel(&val.))||', All Public Schools'||'";');
        	%let j = %eval( &j + 1 );
        	%let val = %scan( &allval., &j );
		 %end;
		if eof then call execute ('run;');
	run;


	data enrollment_sum4;
		set enrollment_sum3;
	    /*recode missing data as zero*/
	    array a_enroll{*} aud: /* rep: */ openschool:;
	    
	    do i = 1 to dim( a_enroll );
	      if missing( a_enroll{i} ) then a_enroll{i} = 0;
	    end;
	    drop i;    
  	run;

	data  Schools.Enrollment_AllGrades&filesuf. (label=&file_lbl_allgrd);
	set enrollment_sum4;
	run;

	data enrollment_sum5;
		set enrollment_sum4;
		if grade='total';
	run;	
	
	%Super_transpose(  
	  		data=enrollment_sum5,     /** Input data set **/
	  		out=enrollment_sum6,      /** Output data set **/
	  		var=%varrange(aud_ /*rep_ */ openschool_, DCPS PCSB) aud /* rep */ openschool,			 /** List of variables to transpose **/
	  		id=year,       /** Input data set var. to use for transposing **/
	  		by=&level. /** List of BY variables (opt.) **/
			)


	data  Schools.Enrollment_sum&filesuf. (label=&file_lbl);
	   set enrollment_sum6;
  	run;

	  %file_info( data=Schools.Enrollment_AllGrades&filesuf., printobs=5 )
	  %file_info( data=Schools.Enrollment_sum&filesuf., printobs=5 )

 %exit:
%mend;
%Summarize( level=city )
%Summarize( level=anc2012 )
%Summarize( level=psa2012 )
%Summarize( level=geo2010 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2012 )
%Summarize( level=zip )











  






























	
	




