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
%let geos=ward2002_ psa2004_ zip_match_ anc2002_ cluster2000_ cluster_tr2000_ city;
%let geolabel="Ward" "PSA" "Zip Code" "ANC" "Neighborhood Cluster" "Census Tract" "City";
%let gend=%sysfunc(countw("&geos.",' ',)); 
%let grade = PS PK K 1 2 3 4 5 6 7 8 9 10 11 12 Adult Total;
%let grade_label = "in Grade PS" "in Grade PK" "in Grade K" "in Grade 1" "in Grade 2" "in Grade 3" 
					"in Grade 4" "in Grade 5"  "in Grade 6"  "in Grade 7" "in Grade 8" "in Grade 9" 
					"in Grade 10" "in Grade 11" "in Grade 12" "in Grade Adult" "in All Grades";
%let schl_label="DCPS Schools" "PCSB Schools" "All Public Schools/Campuses"; 
%let enr_label="Audited" "October Certified";



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
	 &var.&i.=&new.&i
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

/*merge in geographies from master school file*/
proc sort data=schools.allenrollment out=allenr;
by UI_ID;
run;

/*take off labels and formats from enrollment data*/
proc datasets lib=work memtype=data;
   modify allenr; 
     attrib _all_ label=' '; 
	 attrib _all_ format=; 
run;
quit;

proc sort data=schools.master_school_file_final_082011 out=geo;
by UI_ID;
run;

/*merge geos on to the enrollment data and then store enrollment data
from each geo in an individual file*/
%macro enr_geofiles;
%local yr geotype;
%do x=1 %to &gend.;
	%let geotype=%scan(&geos.,&x.,' ');/*pulls each geo type from global geos and runs code over each*/
	%let lbl=%scan(&geolabel.,&x.,' ',q);
	%do yr=2001 %to 2009;
		%let yr2=%eval(&yr. + 1);
		%let y1=%substr(&yr.,3,2);
		%let y2=%substr(&yr2.,3,2);
		data &geotype.&yr._1;
			set geo;
			city&yr.=1;
			keep UI_ID &geotype.&yr.;
			rename &geotype.&yr.=&geotype.;
		run;

		proc sort data=&geotype.&yr._1;
		by UI_ID;
		run;

		data &geotype.&yr.;
			merge &geotype.&yr._1(in=g) allenr(in=e);
			by UI_ID;
			if e;
			year=&yr.;
			label year="Year";
			keep year UI_ID &geotype. Master_School_Name SchoolType
			%varrange(aud_&y1.&y2._,&grade.)
			%varrange(rep_&y1.&y2._,&grade.)
			;
			rename
			%vareqrange(aud_&y1.&y2._,aud_,&grade.)
			%vareqrange(rep_&y1.&y2._,rep_,&grade.)
			;
		run;
	%end;
		data &geotype.;
			set %yearrange1(&geotype.,2001,2009);
			if &geotype. ne ' ';
			/*label geo variable*/
			label &geotype.=&lbl.;
		run;	
%end;
%mend;
%enr_geofiles;


%global audvars repvars audvar_sum repvar_sum;
%let audvars=%varrange(aud_,&grade.);/*all audited enrollment variables before sum over geo*/
%let repvars=%varrange(rep_,&grade.);/*all reported enrollment variables before sum over geo*/
%let audvar_sum=%varrange(&audvars.,_sum);/*all audited enrollment variables after sum over geo*/
%let repvar_sum=%varrange(&repvars.,_sum);/*all reported enrollment variables after sum over geo*/


%macro enrollment_ind;
%local g geotype lbl r sumvar;
%do g=1 %to &gend.; 
	%let geotype=%scan(&geos.,&g.,' ');/*pulls each geo type from global geos and runs code over each*/
	%let lbl=%scan(&geolabel.,&g.,' ',q);/*pulls geo label*/

	proc sort data=&geotype.;
		by &geotype. year SchoolType;
	run; 
	
	/*calculate total schools and enrollment totals in each year for all schools*/
	proc means data=&geotype. noprint; 
			output out=allsumdat1(drop=_Type_ _Freq_) N(aud_Total)=tot_schl SUM= /AUTONAME;
			by &geotype. year;
	run;

	/*calculate total schools and enrollment totals in each year for dcps & pcsb schools*/
	proc means data=&geotype. noprint; 
			output out=typesumdat1 (drop=_Type_ _Freq_)  N(aud_Total)=tot_schl SUM= /AUTONAME ;
			by &geotype. year SchoolType;
	run;
	/*collapse dcps and pcsb schools into one entry*/
	%Super_transpose(  
	  		data=typesumdat1 ,     /** Input data set **/
	  		out=typesumdat2,      /** Output data set **/
	  		var=tot_schl &audvar_sum. &repvar_sum. , /** List of variables to transpose **/
	  		id=SchoolType ,       /** Input data set var. to use for transposing **/
	  		by=&geotype. year  /** List of BY variables (opt.) **/
			)

	proc sort data=typesumdat2;
		by &geotype. year;
	run;

	proc sort data=allsumdat1;
		by &geotype. year;
	run;

	/*combine with the all schools totals*/
	data &geotype.sum;
		merge allsumdat1 typesumdat2;
		by &geotype. year;
	run; 
	/*create list of all enrollment variables*/
	%global allsumvars; 
	%let allsumvars=&audvar_sum. &repvar_sum. %varrange(&audvar_sum. &repvar_sum.,_1) %varrange(&audvar_sum. &repvar_sum.,_2);	
	
%end;	
%mend;
%enrollment_ind;





%macro LABEL;
%local geo lbl x cenr totgrd enrollment school enr schl grd;
%let enrollment=aud rep;
%let school=_1 _2  ;  
%do x=1 %to &gend.;
	%let geo=%scan(&geos.,&x.,' ');
	%let lbl=%scan(&geolabel.,&x.,' ',q);
	data &geo.1;
	set &geo.sum;
	label	
		%let totgrd=%sysfunc(countw("&grade.",' ',));/*total grades*/
		%do cenr=1 %to 2;
			%let elbl=%scan(&enr_label.,&cenr.,' ',q);/*enrollment type label*/
			%let enr=%scan(&enrollment.,&cenr.,' ');/*enrollment type*/
			%do cschl=1 %to 3;
				%let slbl=%scan(&schl_label.,&cschl.,' ',q);/*school type label*/
				%let schl=%scan(&school.,&cschl.,' ',q);/*school type label*/
				%do gr=1 %to &totgrd.;
					%let glbl=%scan(&grade_label.,&gr.,' ',q);/*grade label*/
					%let grd=%scan(&grade.,&gr.,' ');/*grade label*/
						/* label enrollment variables*/
						&enr._&grd._sum&schl.=Total Enrollment at &slbl. in &lbl., &elbl., &glbl.
				%end;
						/*label school variables*/
						tot_schl&schl.=Total Number of &slbl. in &lbl.
			%end;
		%end;
		;
	run;
	proc sort data=&geo.1 out=Schools.&geo.enroll_allgrades(Label=&lbl. Profile Enrollment Data, All Grades);
		by &geo. year;
	run;

	data Schools.&geo.enroll_totals(Label=&lbl. Profile Enrollment Data, Totals);
		set Schools.&geo.enroll_allgrades;
		keep &geo. year tot_schl
		%varrange(aud_total_sum tot_schl,_1 _2)
		%varrange(rep_total_sum,_1 _2)
		%varrange(rep_ aud_,total_sum)
		;
	run;
%file_info(data=Schools.&geo.totals)
%file_info(data=Schools.&geo.allgrades)
%end;
%mend;	
%label;










	
	




