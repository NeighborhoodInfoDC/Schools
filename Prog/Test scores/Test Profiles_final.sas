/**************************************************************************
 Program:  Test Profiles
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


/*macros for dc data school work*/

*this macro pads s variable with leading zeros;
%macro zpad(s);
    * first, recommend aligning the variable values to the right margin to create leading blanks, if they dont exist already;
                &s. = right(&s.);

                * then fill them with zeros;
                if trim(&s.) ~= "" then do;            
                                do _i_ = 1 to length(&s.) while (substr(&s.,_i_,1) = " ");
                                                substr(&s.,_i_,1) = "0";
                                end;
                end;
%mend zpad;

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


/*create global variables for use in the whole program*/

%global geos gend level_num level_perc; 

/*geo variables*/
%let geos=GeoBlk2000 ward2002 psa2004 anc2002 zip_match cluster2000;
%let gend=%sysfunc(countw("&geos.",' ',)); 
%let level_num=_num _bb _b _p _adv _padv;
%let level_perc=_bb_perc _b_perc _p_perc _adv_perc _padv_perc;


/*allows user to see all global macro variables in the system
data allgeos;
    set sashelp.vmacro;
  run;*/


/*add variable that adds advanced and proficient together, standardized the way total is written*/
data alltest;
	set Schools.testscore_all;
	 read_padv=sum(of read_p read_adv);
	 math_padv=sum(of math_p math_adv);
	 read_padv_perc=sum(of read_p_perc read_adv_perc);
	 math_padv_perc=sum(of math_p_perc math_adv_perc);
	 label 
	 	read_padv ='Number Read, Proficient + Advanced'
		math_padv ='Number Math, Proficient + Advanced'
	 	read_padv_perc ='Share Read, Proficient + Advanced (%)'
		math_padv_perc ='Share Math, Proficient + Advanced (%)'
	  ;
	 
		
run;

/* check that percentages add up to one

proc summary data=alltest nway;
	class year grade;
	var %varrange(read,&level_perc.) / weight=read_num;
	var %varrange(math,&level_perc.)  / weight=math_num;
	output out=temp (drop=_Type_ _Freq_)  
	mean(%varrange(math,&level_perc.))=%varrange(math,&level_perc.) 
	mean(%varrange(read,&level_perc.))=%varrange(read,&level_perc.);
run;

data temptot;
set temp;
 read_tot=sum(of read_bb_perc read_b_perc read_p_perc read_adv_perc);
 math_tot=sum(of math_bb_perc math_b_perc math_p_perc math_adv_perc);
run;
*/

proc sort data=alltest;
	by UI_ID Year grade SchoolType;
run;



/*fix schools repeated entries*/
/*count the total number of entries per school/grade/year*/
data repeat;
	set alltest;
	by UI_ID year grade;
	retain count 0;
	if first.UI_ID then count=1;
	else if first.year then count=1;
	else if first.grade then count=1;
	else count=count+1;
run;

/*merge total count on to each entry*/
data repeat1;
	set repeat;
	if count>1;
	rename count=totalcount;
	keep UI_ID year grade count;
run;

data repeat2;
	merge repeat repeat1;
	by UI_ID year grade;
	drop count;
run;

/*keep entries that don't repeat*/
data repeat3;
	set repeat2;
	if totalcount<2;
run;

/*keep entries that repeat*/
data repeat4;
	set repeat2;
	if totalcount=2;
run;

/*combine totals for schools with upper and lower schools*/
data repeat5;
set repeat4;
if UI_ID in ('2103001','2103201','3200200');
drop totalcount;
run;

proc summary data=repeat5 nway;
	class UI_ID year grade SchoolType;
	var %varrange(read,&level_perc.)  /weight=read_num;
	var %varrange(math,&level_perc.)  /weight=math_num;
	output out=repeat6 (drop=_Type_ _Freq_)  
	Sum(%varrange(read,&level_num.) %varrange(math,&level_num.))=%varrange(read,&level_num.) %varrange(math,&level_num.)
	mean(%varrange(math,&level_perc.))=%varrange(math,&level_perc.) 
	mean(%varrange(read,&level_perc.))=%varrange(read,&level_perc.);
run;

/*end combine totals*/

/*merge combined totals with rest of data, leave out other data with repeat entries*/
data alltest1;
set repeat5 repeat3;
drop totalcount;
run;
/*end repeat entry fix*/


proc sort data=alltest1;
by  UI_ID Year SchoolType;
run;

/*create new year variable*/
%macro yearsep;
	%do yr=2001 %to 2009;
		data geo&yr.;
			set schools.master_school_file_final_082011;
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
	data geo;
		set %yearrange1(geo,2001,2009);
		rename zip_match=zip;
	run;	
%mend;
%yearsep;

proc sort data=geo;
	by UI_ID;
run;

/*merge geo's onto the test data*/
data alltest_plus_geo;
	merge alltest1(in=a) geo(in=b);
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
run;


** Create remaining geographic IDs **;

data test_geo;
set alltest_plus_geo;

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


/** Macro Summarize, creates indicators summed over the geographies and labels variables**/

%macro Summarize( level= );

  %local filesuf level_lbl level_fmt file_lbl j val allval;
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

  %let file_lbl = "School Test Scores, Grades 3-8 and 10, DC, &level_lbl";
  %let file_lbl_allgrd = "School Test Scores All Grades, by Grade/Year, DC, &level_lbl";

  ** Summarize by specified geographic level/year/grade **;

	proc summary data=test_geo nway completetypes;
		class &level. year grade/preloadfmt;
		var %varrange(read,&level_perc.) /weight=read_num;
		var %varrange(math,&level_perc.) /weight=math_num;
		output out=alltest&filesuf. (drop=_freq_ _type_)  
		Sum(%varrange(read,&level_num.) %varrange(math,&level_num.))=%varrange(read,&level_num.) %varrange(math,&level_num.)
		mean(%varrange(math,&level_perc.))=%varrange(math,&level_perc.) 
		mean(%varrange(read,&level_perc.))=%varrange(read,&level_perc.);
	run;

 ** Summarize by specified geographic level/year/grade/schooltype **;

	proc summary data=test_geo nway completetypes;
		class &level. year grade schooltype/preloadfmt;
		var %varrange(read,&level_perc.)/weight=read_num;
		var %varrange(math,&level_perc.)/weight=math_num;
		output out=schltype&filesuf. (drop=_freq_ _type_)  
		Sum(%varrange(read,&level_num.) %varrange(math,&level_num.))=%varrange(read,&level_num.) %varrange(math,&level_num.)
		mean(%varrange(math,&level_perc.))=%varrange(math,&level_perc.) 
		mean(%varrange(read,&level_perc.))=%varrange(read,&level_perc.);
	run;


   %Super_transpose(  
	  		data=schltype&filesuf. ,     /** Input data set **/
	  		out=schltype2&filesuf.,      /** Output data set **/
	  		var=%varrange(read,&level_num.) 
				%varrange(math,&level_num.)
				%varrange(math,&level_perc.) 
				%varrange(read,&level_perc.), /** List of variables to transpose **/

			id=SchoolType,       /** Input data set var. to use for transposing **/
	  		by=&level. year grade  /** List of BY variables (opt.) **/
			)

	/*merge together sums by schooltype, with sum over all school types*/
	data test_sum1;
		merge schltype2&filesuf. alltest&filesuf.;	
		by &level. year grade;
	run;
	
	/*label variables with with school type*/
	data test_sum2;
		set test_sum1 end=eof;
		if eof then call execute('data test_sum3; set test_sum2;');
		 %let j = 1;
      	%let allval = %varrange(read,&level_num.) %varrange(math,&level_num.) 
					%varrange(math,&level_perc.) %varrange(read,&level_perc.);
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
	
	data test_sum4;
		set test_sum3;
	    /*recode missing data
	    array a_test{*} read: math: ;
	    
	    do i = 1 to dim( a_test );
	      if missing( a_test{i} ) then a_test{i} =.a;
	    end;
	    drop i; */
  	run;

	data  Schools.Test_AllGrades&filesuf. (label=&file_lbl_allgrd);
		set test_sum4;
	run;

	data  test_sum5;
		set test_sum4;
		if grade = 'total';
		drop grade;
	run;

	
	%Super_transpose(  
	  		data=test_sum5,     /** Input data set **/
	  		out=test_sum6,      /** Output data set **/
	  		var= &allval. %varrange(&allval.,_DCPS) %varrange(&allval.,_PCSB),	/** List of variables to transpose **/
	  		id=year,       /** Input data set var. to use for transposing **/
	  		by=&level. /** List of BY variables (opt.) **/
			)

	data  Schools.Test_sum&filesuf. (label=&file_lbl);
	   set test_sum6;
  	run;
	  %file_info( data=Schools.Test_AllGrades&filesuf., printobs=5 )
	  %file_info( data=Schools.Test_sum&filesuf., printobs=5 )

 %exit:
%mend;

%Summarize( level=city )
%Summarize( level=anc2002 )
%Summarize( level=psa2004 )
%Summarize( level=geo2000 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2002 )
%Summarize( level=zip )












