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
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\schoolmacros.sas";
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\Enrollment\School Formats.sas"; 
%DCData_lib( Schools)
/*store all geos that profiles are being created for in a global variable*/
%global geos totvars changevars totschl geolabel schl_label enr_label;
%let geos=ward2002_ psa2004_ zip_match_ anc2002_ cluster2000_ cluster_tr2000_;
%let geolabel="Ward" "PSA" "Zip Code" "ANC" "Neighborhood Cluster" "Census Tract"; 
%let totschl=totalschools totalDCPS totalPCSB;
%let schl_label="Public Schools/Campuses" "DCPS Schools" "PCSB Schools"; 
%let totenr= totalaudenr DCPSaudenr PCSBaudenr totalrepenr DCPSrepenr PCSBrepenr;
%let enr_label="Audited" "October Certified";
%let changevars= change_totalaudenr change_DCPSaudenr change_PCSBaudenr change_totalrepenr 
				change_DCPSrepenr change_PCSBrepenr;
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


proc sort data=schools.Master_school_file_final_082010 out=geo;
by UI_ID;
run;

/*keep only the geos we want to sum over*/
data geo2;
set geo;
keep UI_ID
%yearrange1(&geos.,2000,2010)/*outputs each geo for all years*/
;
run;


data ind1;
merge geo2(in=g) allenr(in=e);
by UI_ID;
if e;
run;

	proc sort data=ind1 out=ind2;
				by ward2002_2001 UI_ID;
			run;

/*counts total schools,total audited enrollment, and total reported enrollment. Overall,DCPS,and PCSB is calculated for each.*/
%macro enrollment_ind;
%local x geo yr lbl var i j k y1 y2;/*keeps these variables only in this macro*/
%do x=1 %to 6;
	%let geo=%scan(&geos.,&x.,' ');/*pulls each geo type from global geos and runs code over each*/
	%let lbl=%scan(&geolabel.,&x.,' ',q);
		%do yr=2001 %to 2009;
			%let yr2=%eval(&yr. + 1);
			%let y1=%substr(&yr.,3,2);
			%let y2=%substr(&yr2.,3,2);

			proc sort data=ind1 out=ind2;
				by &geo.&yr. UI_ID;
			run;
			

			data &geo.&yr._1;
				set ind2;
				by &geo.&yr.;
				year=&yr.;
				label year="Year";
				retain count_tot count_dcps count_pcsb 0;
				retain audenr_tot audenr_dcps audenr_pcsb 0;
				retain repenr_tot repenr_dcps repenr_pcsb 0;
							
				/*find indicators for total in geo*/
				if first.&geo.&yr. then do;
					count_tot=1;
					audenr_tot=aud_&y1.&y2._total;
					repenr_tot=rep_&y1.&y2._total;
				end;
		
				else do;
					count_tot=count_tot+1;
					audenr_tot=sum(of audenr_tot aud_&y1.&y2._total);
					repenr_tot=sum(of repenr_tot rep_&y1.&y2._total);
				end;

			    /*find indicators for dcps schools in geo*/
				if first.&geo.&yr. and SchoolType=1 then do;
					count_dcps=1;
					audenr_dcps=aud_&y1.&y2._total;
					repenr_dcps=rep_&y1.&y2._total;
				end;

				else if first.&geo.&yr. and SchoolType=2 then do;
					count_dcps=0;
					audenr_dcps=0;
					repenr_dcps=0;
				end;

				else if SchoolType=1 then do; 
					count_dcps=count_dcps+1;
					audenr_dcps=sum(of audenr_dcps aud_&y1.&y2._total);
					repenr_dcps=sum(of repenr_dcps rep_&y1.&y2._total);
				end;

				else do;
					count_dcps=count_dcps;
					audenr_dcps=audenr_dcps;
					repenr_dcps=repenr_dcps;
				end;

				/*find indicators for pcsb schools in geo*/
				if first.&geo.&yr. and SchoolType=2 then do; 
					count_pcsb=1;
					audenr_pcsb=aud_&y1.&y2._total;
					repenr_pcsb=rep_&y1.&y2._total;
				end;

				else if first.&geo.&yr. and SchoolType=1 then do;
					count_pcsb=0;
					audenr_pcsb=0;
					repenr_pcsb=0;
				end;

				else if SchoolType=2 then do;
					count_pcsb=count_pcsb+1;
					audenr_pcsb=sum(of audenr_pcsb aud_&y1.&y2._total);
					repenr_pcsb=sum(of repenr_pcsb rep_&y1.&y2._total);
				end;

				else do;
					count_pcsb=count_pcsb;
					audenr_pcsb=audenr_pcsb;
					repenr_pcsb=repenr_pcsb;
				end;

				/*last is the total for each geo area, this code takes the total and stores it in a new variable*/
				if last.&geo.&yr. then do; 
					totalschools=count_tot;
					totalDCPS=count_dcps;
					totalPCSB=count_pcsb;
					totalaudenr=audenr_tot;
					DCPSaudenr=audenr_dcps;
					PCSBaudenr=audenr_pcsb;
					totalrepenr=repenr_tot;
					DCPSrepenr=repenr_dcps;
					PCSBrepenr=repenr_pcsb;
				end;

				label
					/*label school variables*/
					%do i=1 %to 3;
						%let svar=%scan(&totschl.,&i.,' ');
						%let slbl=%scan(&schl_label.,&i.,' ',q);
						&svar.=Total Number of &slbl. in &lbl.
					%end;
					
					/*label enrollment variables*/
					%do i=1 %to 6; 
						%if &i. gt 3 %then %do;
							%let k=2;
							%let j=%eval(&i.-3);
						%end;
						%else %do; 
							%let k=1;
							%let j=&i.;
						%end;
						%let evar=%scan(&totenr.,&i.,' ');
						%let slbl=%scan(&schl_label.,&j.,' ',q);	
						%let elbl=%scan(&enr_label.,&k.,' ',q);
									&evar.=Total Enrollment at &slbl. in &lbl., &elbl.				
					%end;
				 ;
			run;
		


			data &geo.&yr.;
				set &geo.&yr._1;
				by &geo.&yr.;
				if last.&geo.&yr.;
				if &geo.&yr. ne ' ' ;
				rename &geo.&yr.=&geo.;
				keep &geo.&yr. year &totenr. &totschl.;
			run;
		%end;
		data &geo.;
			set %yearrange1(&geo.,2001,2009);
			/*label geo variable*/
			label &geo.=&lbl.;
		run;
	%end;
%mend;
%enrollment_ind;



%macro yrchange;
%local geo x yr lbl j k v slbl eblb cvar enr;
%do x=1 %to 6;
	%let geo=%scan(&geos.,&x.,' ');
	%let lbl=%scan(&geolabel.,&x.,' ',q);	
	proc sort data=&geo. out=&geo.1;
		by &geo.;
	run;
	data &geo.2;
		set &geo.1;
		*calc % change for all enrollment variables;
			Y1=lag(year);/*pulls year of observation before current observation*/
			%do v=1 %to 6;
				%let enr=%scan(&totenr.,&v.,' ');/*pulls all enrollment variables*/
				L1=lag(&enr.);/*pulls variable from previous observation*/ 
				if year=Y1+1 then do;/*only takes change is the previous observation is from the year before the current observation*/
					change_&enr.=%pctchg(L1,&enr.);
				end;
				/*label change variables*/
				%if &v. gt 3 %then %do;
					%let k=2;
					%let j=%eval(&v.-3);
				%end;
				%else %do; 
					%let k=1;
					%let j=&v.;
				%end;
				%let cvar=%scan(&changevars.,&v.,' ');
				%let slbl=%scan(&schl_label.,&j.,' ',q);
				%let elbl=%scan(&enr_label.,&k.,' ',q);
				label &cvar.=Percentage Change in Total Enrollment at &slbl. in &lbl., &elbl.;				
			%end;	
		drop Y1 L1;
	run;
%end;
%mend;
%yrchange;

%macro allgeos;
%local x geo;
%do x=1 %to 6;
	%let geo=%scan(&geos.,&x.,' ');
	%let lbl=%scan(&geolabel.,&x.,' ',q);		
	proc sort data=&geo.2;
		by year;
	run;

	proc means data=&geo.2; 
		output out=sumdat1 (where=(_STAT_ in ('MIN','MAX','MEAN') ));
		by year;
	run;
 
	%Super_transpose(  
  		data=sumdat1 ,     /** Input data set **/
  		out=sumdat2,      /** Output data set **/
  		var=&totenr. &totschl. &changevars. , /** List of variables to transpose **/
  		id=_Stat_ ,       /** Input data set var. to use for transposing **/
  		by=year  /** List of BY variables (opt.) **/
		)

	data &geo.3;
		merge &geo.2(in=v) sumdat2 ;
		by year;
		if v;
	run;
	proc sort data=&geo.3 out=Schools.&geo.(Label=&lbl. Profile Data);
		by &geo.;
	run;
%end;
%mend;
%allgeos;

