/**************************************************************************
 Program:  Test Scores Import.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   S. Litschwartz
 Created:  08/19/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Imports test score files from spread sheets;
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
/*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;*/
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\schoolmacros.sas";
options sasautos=(uiautos sasautos) compress=binary ;
%DCData_lib( Schools)
%let filepath = D:\DCData\Libraries\schools\raw\;
%global yearlist subject level_num level_perc levlabel_num levlabel_perc;
%let yearlist= 2006 2007 2008 2009;/*add years for new test data*/
%let subject= Math Read;  
%let level_num=_num _bb _b _p _adv;
%let level_perc=_bb _b _p _adv;
%let levlabel_num= "Total Tested" "Below Basic" "Basic" "Proficient" "Advanced";
%let levlabel_perc="Below Basic" "Basic" "Proficient" "Advanced";


***** NOTE - The years on the raw spread sheet refer to the SPRING of that school year. EG: 2008 means SY 2007-2008.
			For all other years in the data set the year refers to FALL of that school year. EG:2008 means SY 2008-2009;
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

%macro testimport (year=,row=);
%let rawyear = %eval(&year.+1);
/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/

filename dat dde "excel|&filepath.\[Testscores_UI_ID_2007-2010_SophieLitschwartz_8_22_2011.xls]&rawyear.! r2c2:r&row.c23" ;
	data testscore_&year.; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			UI_ID  				$7.
			DCPS				$1.
			SchoolName			$8.
			Grade 				$5.
			read_num		8.
			read_bb			8.
			read_b			8.
			read_p			8.
			read_adv			8.
			read_bb_perc		8.
			read_b_perc			8.
			read_p_perc			8.
			read_adv_perc		8.
			math_num			8.
			math_bb			8.
			math_b			8.
			math_p			8.
			math_adv			8.
			math_bb_perc		8.
			math_b_perc			8.
			math_p_perc			8.
			math_adv_perc		8.
;

		input
			
			UI_ID  		$		
			DCPS			$
			SchoolName	$	
			Grade  		$	
			read_num		
			read_bb		
			read_b		
			read_p		
			read_adv		
			read_bb_perc	
			read_b_perc		
			read_p_perc	
			read_adv_perc
			math_num	
			math_bb		
			math_b		
			math_p		
			math_adv		
			math_bb_perc
			math_b_perc		
			math_p_perc		
			math_adv_perc	
		;
		Year=&year.;
		if DCPS=1 then SchoolType='1';
		if DCPS=0 then SchoolType='2';length pad $2.;

		if grade in ('1','2','3','4','5','6','7','8','9') then pad=grade;
		%zpad(pad);
		if grade in ('1','2','3','4','5','6','7','8','9') then grade=pad;
		drop _i_ pad;length pad $2.;

		if grade='TOTAL' then grade='total';
	 	else if grade='Total' then grade='total';
		
run;
%mend;



/*need to add import for new test data*/
%testimport (year=2006, row=888);
%testimport (year=2007, row=937);
%testimport (year=2008, row=870);
%testimport (year=2009, row=915);




%macro label;
%local i s l c var varlist varlist_num  varlist_perc sublbl levlbl;  
data Schools.testscore_all (Label="Test Scores from All School 0607-0910");
set %varrange(testscore_,&yearlist.);
	label
		%let varlist_num=%varrange(&subject.,&level_num.);
		%do i=1 %to 10;
			%if &i. gt 5 %then %do;
				%let s=2;
				%let l=%eval(&i. - 5);
			%end;
			%else %do; 
				%let s=1;
				%let l=&i.;
			%end;
			%let var=%scan(&varlist_num.,&i.,' ');		
			%let sublbl=%scan(&subject.,&s.,' ');
			%let levlbl=%scan(&levlabel_num.,&l.,' ',q);
			&var.=Number &sublbl., &levlbl.
		%end;
		%let varlist=%varrange(&subject.,&level_perc.);
		%let varlist_perc=%varrange(&varlist.,_perc);
		%do i=1 %to 8;
			%if &i. gt 4 %then %do;
				%let s=2;
				%let l=%eval(&i. - 4);
			%end;
			%else %do; 
				%let s=1;
				%let l=&i.;
			%end;
			%let var=%scan(&varlist_perc.,&i.,' ');		
			%let sublbl=%scan(&subject.,&s.,' ');
			%let levlbl=%scan(&levlabel_perc.,&l.,' ',q);
			&var.=Share &sublbl., &levlbl. (%)
		%end;
		UI_ID="UI ID"
		Year="Year"
		SchoolType="School Type"
	;
	%let varlist=%varrange(&subject.,&level_perc.);
		%let varlist_perc=%varrange(&varlist.,_perc);
		%let c=%sysfunc(countw("&varlist_perc.",' ',));
		%do i=1 %to &c.;
			%let var=%scan(&varlist_perc.,&i.,' ');
			&var.=100*&var.;	
		%end;
	Format SchoolType $Schtype. UI_ID $Uischid.;
	drop DCPS SchoolName;
run;	
%mend;
%label;	
			
%file_info(data=Schools.testscore_all)

