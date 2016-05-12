**********************************************
Program: kidscount_testscore_typebyyear.sas

Author: ZM

Date: 3/22/2011

Modifications:

*********************************************;

*libname kids "D:\dcdata\libraries\schools\raw";
libname sch "D:\DCData\Libraries\Schools\Data";
options nomprint nosymbolgen;


***** Sum all relevant variables from 'master' dataset;

%macro sum ;

	proc means data=sch.testscore_allsch_allyr noprint;
		var read_p: read_adv: math_p: math_adv: read_num: math_num:;
		class DCPS;
		output out = kc_testscore (drop = read_p_perc: read_adv_perc: math_p_perc: math_adv_perc:) sum= ;
	run;

%mend;
%sum

***** Produce sum numbers for each year and type  ******;

%macro rename;

*** sum variables to create proficiency ratios ******; 

data sch.kc_testscore_pcts (keep = dcps type:);
set kc_testscore;


%do year = 2007 %to 2010;
	%do gr = 3 %to 10;
		%if &gr. ne 9 %then %do;
		
		type_read_prof_&year._&gr. = sum(of read_p_&year._&gr. read_adv_&year._&gr.)/read_num_&year._&gr.;
		type_math_prof_&year._&gr. = sum(of math_p_&year._&gr. math_adv_&year._&gr.)/math_num_&year._&gr.;	

		%end;
	%end;
%end;

run;

%mend;
%rename 



