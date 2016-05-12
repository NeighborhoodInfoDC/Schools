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
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\schoolmacros.sas";
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\Enrollment\School Formats.sas"; 
%DCData_lib( Schools)
/*store all geos that profiles are being created for in a global variable*/
%global geos geolabel test_grades test_grades_label schl_label enr_label yearlist subject level_num level_perc level_perc2 levlabel_num levlabel_perc
		varlist_num_nogrades varlist_perc_nogrades varlist_alltest_nogrades varlist_read_perc varlist_math_perc;
%let geos=ward2002_ psa2004_ zip_match_ anc2002_ cluster2000_ cluster_tr2000_;
%let geolabel="Ward" "PSA" "Zip Code" "ANC" "Neighborhood Cluster" "Census Tract";
 
%let test_grades = _3 _4 _5 _6 _7 _8 _10 _Total;
%let test_grades_label = "in Grade 3" "in Grade 4" "in Grade 5"  "in Grade 6"  "in Grade 7" 
						"in Grade 8" "in Grade 10" "in All Grades";

%let schl_label="All Public Schools/Campuses" "DCPS Schools" "PCSB Schools";  
%let yearlist= 2006 2007 2008 2009;/*add years for new test data*/
%let subject= Math Read;  

%let level_num=_num _bb _b _p _adv _padv;
%let level_perc=_bb _b _p _adv _padv;
%let level_perc2=_bb_perc _b_perc _p_perc _adv_perc _padv_perc;

%let levlabel_num= "Total Tested" "Below Basic" "Basic" "Proficient" "Advanced" "Proficient + Advanced";
%let levlabel_perc="Below Basic" "Basic" "Proficient" "Advanced" "Proficient + Advanced";

%let varlist_num_nogrades=%varrange(&subject.,&level_num.);/*list of total number variables w/o grades*/
%let varlist_math_perc=%varrange(math,&level_perc2.);
%let varlist_read_perc=%varrange(read,&level_perc2.); 
%let varlist_temp=%varrange(&subject.,&level_perc.);
%let varlist_perc_nogrades=%varrange(&varlist_temp.,_perc);/*list of percentage variables w/o grades*/
%let varlist_alltest_nogrades=&varlist_num_nogrades. &varlist_perc_nogrades.;/*list of all test score variables w/o grades*/


/*allows user to see all global macro variables in the system
data allgeos;
    set sashelp.vmacro;
  run;*/
/*add variable that adds adavnced and proficient*/
data alltest;
set Schools.testscore_all;
 read_padv=sum(of read_p read_adv);
 math_padv=sum(of math_p math_adv);
 read_padv_perc=sum(of read_p_perc read_adv_perc);
 math_padv_perc=sum(of math_p_perc math_adv_perc);
 if grade='TOTAL' then fixgrade='total';
 else if grade='Total' then fixgrade='total';
 else fixgrade=grade;
 drop grade;
run;

proc sort data=alltest;
by UI_ID Year fixgrade SchoolType;
run;


/*fix schools repeated entries*/

data repeat;
set alltest;
by UI_ID year fixgrade;
retain count 0;
if first.UI_ID then count=1;
else if first.year then count=1;
else if first.fixgrade then count=1;
else count=count+1;
rename fixgrade=grade;
run;

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

data repeat3;
set repeat2;
if totalcount<2;
run;

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

proc means data=repeat5 noprint;
	var &varlist_read_perc. /weight=read_num;
	var &varlist_math_perc. /weight=math_num;
	output out=repeat6 (drop=_Type_ _Freq_)  Sum(&varlist_num_nogrades.)=&varlist_num_nogrades.
	mean(&varlist_read_perc.)=&varlist_read_perc. mean(&varlist_math_perc.)=&varlist_math_perc. ;
	by UI_ID year;
run;


data repeat7;
set repeat5;
keep UI_ID SchoolType grade;
run;

proc sort data=repeat7 nodupkey;
by UI_ID;
run;

data repeat8;
merge repeat6 repeat7;
by UI_ID;
run;
/*end combine totals*/

/*merge combined totals with rest of data, leave out other data with repeat entries*/

data alltest1;
set repeat8 repeat3;
run;

/*end repeat entry fix*/


proc datasets lib=work memtype=data;
   modify alltest1; 
     attrib _all_ label=' '; 
	 attrib _all_ format=; 
run;
quit;
proc sort data=alltest1;
by  UI_ID Year SchoolType;
run;

%Super_transpose(  
	  		data=alltest1 ,     /** Input data set **/
	  		out=alltest2,      /** Output data set **/
	  		var=&varlist_alltest_nogrades.,/** List of variables to transpose **/
	  		id=Grade ,       /** Input data set var. to use for transposing **/
	  		by=UI_ID Year SchoolType			  /** List of BY variables (opt.) **/
			)

/*create new global lists of new variables*/
%global varlist_num_allgrades varlist_perc_allgrades varlist_alltest_allgrades; 
%let varlist_num_allgrades=%varrange(&varlist_num_nogrades.,&test_grades.);/*list of total number variables w/ grades*/ 
%let varlist_perc_allgrades=%varrange(&varlist_perc_nogrades.,&test_grades.);/*list of percentage variables w/ grades*/
%let varlist_alltest_allgrades=&varlist_num_allgrades. &varlist_perc_allgrades.;/*list of all test score variables w/ grades*/
/*merge in geographies from master school file*/


proc sort data=alltest2;
by UI_ID;
run;


proc sort data=schools.master_school_file_final_082011 out=geo;
by UI_ID;
run;


/*merge geos onto another data set and then store the data
from each geo in an individual file*/
%macro geofiles(geos,geolabel,yearlist,dataset,varlist);
%local yearstart yearend x end lbl geotype yr e g;
%do x=1 %to 6;
	%let geotype=%scan(&geos.,&x.,' ');/*pulls each geo type from global geos and runs code over each*/
	%let lbl=%scan(&geolabel.,&x.,' ',q);/*pulls the label for each geo*/
	%let yearstart=%scan(&yearlist.,1,' ');/*pulls the first year*/
	%let end=%sysfunc(countw("&yearlist.",' ',));/*pulls the last year*/
	%let yearend=%scan(&yearlist.,&end.,' ');
	%do yr=&yearstart. %to &yearend.;
		data &geotype.&yr._1;
			set geo;
			keep UI_ID &geotype.&yr.;
			rename &geotype.&yr.=&geotype.;
		run;

		proc sort data=&geotype.&yr._1;
		by UI_ID;
		run;

		data temp1;
 		set &dataset.;
		if year=&yr.;
		run;

		data &geotype.&yr.;
			merge &geotype.&yr._1(in=g) temp1(in=e);
			by UI_ID;
			if e;
			keep year UI_ID &geotype. SchoolType &varlist.			
			;
		run;
	%end;
		data &geotype.;
			set %yearrange1(&geotype.,&yearstart.,&yearend.);
			if &geotype. ne ' ';
			/*label geo variable*/
			label &geotype.=&lbl.;
		run;	
%end;
%mend;





%geofiles(&geos.,&geolabel.,&yearlist.,alltest2,&varlist_alltest_allgrades.);

/*sum over the geography to create test indicators*/

%macro test_ind;
%local g geotype lbl r sumvar i grade;
%do g=1 %to 6; 
	%let geotype=%scan(&geos.,&g.,' ');/*pulls each geo type from global geos and runs code over each*/
	%let lbl=%scan(&geolabel.,&g.,' ',q);
	proc sort data=&geotype.;
		by &geotype. year SchoolType;
	run; 

%let test_grades = _3 _4 _5 _6 _7 _8 _10 _Total;

%let varlist_math_allgrades=%varrange(&varlist_read_perc.,&test_grades.);/*list of math percentage variables w/ grades*/ 
%let varlist_read_allgrades=%varrange(&varlist_math_perc.,&test_grades.);/*list of read percentage variables w/ grades*/

	proc means data=&geotype. noprint; 
			%do i=1 %to 8;
				%let grade=%scan(&test_grades.,&i.,' ');
				var %varrange(&varlist_read_perc.,&grade.) /weight=read_num&grade.;
				var %varrange(&varlist_math_perc.,&grade.) /weight=Math_num&grade.;
			%end;
			output out=allsumdat1(drop=_Type_ _Freq_) 
				SUM(&varlist_num_allgrades.)=&varlist_num_allgrades. 
				Mean(&varlist_perc_allgrades.)=&varlist_perc_allgrades.;
			by &geotype. year;
	run;
	
	proc means data=&geotype. noprint; 
			%do i=1 %to 8;
				%let grade=%scan(&test_grades.,&i.,' ');
				var %varrange(&varlist_read_perc.,&grade.) /weight=read_num&grade.;
				var %varrange(&varlist_math_perc.,&grade.) /weight=Math_num&grade.;
			%end;
			output out=typesumdat1(drop=_Type_ _Freq_) 
				SUM(&varlist_num_allgrades.)=&varlist_num_allgrades. 
				Mean(&varlist_perc_allgrades.)=&varlist_perc_allgrades.;
			by &geotype. year SchoolType;
	run;


	/*drop the formats before the transpose*/
	proc datasets lib=work memtype=data;
   	modify typesumdat1;  
	 attrib _all_ format=; 
	run;
	quit;
	%Super_transpose(  
	  		data=typesumdat1 ,     /** Input data set**/ 
	  		out=typesumdat2,      /** Output data set **/
	  		var=&varlist_alltest_allgrades., /** List of variables to transpose**/ 
	  		id=SchoolType ,       /** Input data set var. to use for transposing**/
	  		by=&geotype. year  /** List of BY variables (opt.) **/
			)
	proc sort data=typesumdat2;
		by &geotype. year;
	run;

	proc sort data=allsumdat1;
		by &geotype. year;
	run;


	data &geotype.sum;
		merge allsumdat1 typesumdat2;
		by &geotype. year;
	run; 
%end;	
%mend;
%test_ind;



%macro label;
%local geo lbl x y sub l lvl lvl_lbl g grd glbl z tlbl; 
%do x=1 %to 6;
	%let geo=%scan(&geos.,&x.,' ');
	%let lbl=%scan(&geolabel.,&x.,' ',q);
	data &geo.sum1;
	set &geo.sum;
	/*label the All Public Schools/Campuses variables*/
		%do y=1 %to 2;
			%let sub=%scan(&subject.,&y.,' ');
			%do l=1 %to 6;
				%let lvl=%scan(&level_num.,&l.,' ');
				%let lvl_lbl=%scan(&levlabel_num.,&l.,' ',q);
				%do g=1 %to 8;
					%let grd=%scan(&test_grades.,&g.,' ');
					%let glbl=%scan(&test_grades_label.,&g.,' ',q);
					label &sub.&lvl.&grd.=Number Testing &lvl_lbl. in &sub. in &lbl., All Public Schools/Campuses, &glbl.;
				%end;
			%end;
		%end;
		%do y=1 %to 2;
			%let sub=%scan(&subject.,&y.,' ');
			%do l=1 %to 5;
				%let lvl=%scan(&level_perc.,&l.,' ');
				%let lvl_lbl=%scan(&levlabel_perc.,&l.,' ',q);
				%do g=1 %to 8;
					%let grd=%scan(&test_grades.,&g.,' ');
					%let glbl=%scan(&test_grades_label.,&g.,' ',q);
					label &sub.&lvl._perc&grd.=Percent Testing &lvl_lbl. in &sub. in &lbl., All Public Schools/Campuses, &glbl.;
				%end;
			%end;
		%end;
/*label the DCPS and PCSB variables*/
%do z=1 %to 2;
%let tlbl=%scan(&schl_label.,%eval(&z.+1),' ',q);
		%do y=1 %to 2;
				%let sub=%scan(&subject.,&y.,' ');
				%do l=1 %to 6;
					%let lvl=%scan(&level_num.,&l.,' ');
					%let lvl_lbl=%scan(&levlabel_num.,&l.,' ',q);
					%do g=1 %to 8;
						%let grd=%scan(&test_grades.,&g.,' ');
						%let glbl=%scan(&test_grades_label.,&g.,' ',q);
						label &sub.&lvl.&grd._&z.=Number Testing &lvl_lbl. in &sub. in &lbl.,&tlbl., &glbl.;
					%end;
				%end;
			%end;

			%do y=1 %to 2;
				%let sub=%scan(&subject.,&y.,' ');
				%do l=1 %to 5;
					%let lvl=%scan(&level_perc.,&l.,' ');
					%let lvl_lbl=%scan(&levlabel_perc.,&l.,' ',q);
					%do g=1 %to 8;
						%let grd=%scan(&test_grades.,&g.,' ');
						%let glbl=%scan(&test_grades_label.,&g.,' ',q);
						label &sub.&lvl._perc&grd._&z.=Percent Testing &lvl_lbl. in &sub. in &lbl., &tlbl., &glbl.;
					%end;
				%end;
			%end;
		%end;	
	run;
%end;
%mend;	
%label;		



%macro allgeos;
%local x geo lbl;
%do x=1 %to 6;
	%let geo=%scan(&geos.,&x.,' ');
	%let lbl=%scan(&geolabel.,&x.,' ',q);		
	proc sort data=&geo.sum1 out=&geo.3;
		by year;
	run;

	proc means data=&geo.3 noprint; 
		output out=sumdat1 Min= Max= Mean= /AUTONAME AUTOLABEL;
		by year;
	run;



	data &geo.4;
		merge &geo.3(in=v) sumdat1 ;
		by year;
		if v;
	run;



	proc sort data=&geo.4 out=Schools.&geo._test_allgrades(Label=&lbl. Profile Test Data, All Grades, All Indicators);
		by &geo.;
	run;
	
	%let varlist1=%varrange(Math Read,_padv_perc_Total);/*list of all public schools variables*/;
	%let varlist2=%varrange(&varlist1.,_1 _2);/*list of DCPS and PCBS variables*/
	%let varlist3=%varrange(&varlist1. &varlist2., _MIN _MAX _Mean);/*geo min,max and mean variables*/

	data Schools.&geo._test_totals(Label=&lbl. Profile Test Data, Totals, Profile Indicators);
	set Schools.&geo._test_allgrades;
	keep &geo. year &varlist1. &varlist2. &varlist3.
	;
	run;


	%end;
%mend;
%allgeos;




%file_info(data=Schools.&geo._test_totals)
%file_info(data=Schools.&geo._test_allgrades)


%end;
%mend;
%allgeos;
