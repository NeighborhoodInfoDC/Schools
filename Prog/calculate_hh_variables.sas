libname ipums "F:\DCDATA\Libraries\Schools\Data";
/*NOTE: UNIVERSE IS ADULTS 18 AND OVER NOT IN GROUP QUARTERS*/
/*
* keep only adults not in group quarters
data ipums.adults;
	set ipums.usa_00001;
	keep only adults not in group quarters
	if age<18 	or gqtype ^= 0 then delete; 
run;


data ipums.adults_reduced;
	set ipums.adults (keep=SERIAL NUMPREC famunit citizen workedyr empstat incearn INCTOT FTOTINC INCWAGE INCBUS00 INCSS INCWELFR INCINVST 
							INCRETIR INCSUPP INCOTHER FOODSTMP educd educ);
	count=1;
	if citizen=0 then born_in_us=1; else born_in_us=0;
	if citizen in (0:2) then born_or_nat=1; else born_or_nat=0;
	if citizen=3 then non_citizen=1; else non_citizen=0;
	if workedyr = 3 then worked=1; else worked = 0;
	if empstat = 1 then employed=1; else employed=0;
run;

*/
proc means noprint data=ipums.adults_reduced MAX ;
	by serial; 
	var educ educd; 
	output out = results1 (drop=_type_ rename=(_freq_=num_adults)) max=hh_a_educ hh_a_educd;
run;

proc means noprint data=ipums.adults_reduced SUM;
	by serial; 
	var born_in_us born_or_nat non_citizen worked employed; 
	output out = results2 (drop=_type_ rename=(_freq_=num_adults)) sum=hh_a_born_in_us hh_a_born_or_nat hh_a_non_citizen hh_a_worked hh_a_employed; 
run;

proc sort data=ipums.adults_reduced nodupkey out=results3 (keep= serial numprec); by serial; run;

/*NOTE: UNIVERSE IS ADULTS 18 AND OVER NOT IN GROUP QUARTERS*/


data ipums.all_reduced (drop = workedyr empstat gqtype);
	set ipums.usa_00001 (keep = age SERIAL NUMPREC famunit workedyr empstat incearn INCTOT FTOTINC INCWAGE INCBUS00 INCSS INCWELFR INCINVST 
				INCRETIR INCSUPP INCOTHER FOODSTMP gqtype educd);
	if workedyr = 3 then worked=1; else worked = 0;
	if empstat = 1 then employed=1; else employed=0;
	if age<=18 and educd in (0:61) then dependent =1; else dependent=0;
	if gqtype^=0 then delete;
run;

data ipums.all_reduced_15;
	set ipums.all_reduced;
	if age<15 then delete;
run;

/*dependency and work*/
proc means noprint data=ipums.all_reduced sum;
	by serial; 
	var employed dependent; 
	output out = hh_depend_work (drop=_type_) sum=hh_all_worked hh_dependents;
run;

/*income benefits receipt*/
proc means noprint data=ipums.all_reduced_15 sum;
	by serial; 
	var incearn INCSS INCWELFR INCINVST INCRETIR INCSUPP INCOTHER; 
	output out = hh_income (drop=_type_) sum=hh_incearn hh_INCSS hh_INCWELFR hh_INCINVST hh_INCRETIR hh_INCSUPP hh_INCOTHER;
run;

data hh_income;
	set hh_income;
	hh_all_other = sum(hh_INCSS, hh_INCWELFR, hh_INCINVST, hh_INCRETIR, hh_INCSUPP, hh_INCOTHER);
run;

/*keep only not in group quarters**** household composition variables*/
data ipums.not_in_gq;
	set ipums.usa_00001;
	if gqtype ^= 0 then delete; 
	count=1;
run;

proc sort data=ipums.not_in_gq; by serial famunit; run;

proc means noprint data=ipums.not_in_gq N;
	by serial FAMUNIT; 
	var count; 
	output out = results4;
run;

data ipums.results4_r;
	set results4;
	if _STAT_ ^= "N" then delete;
run;

proc means noprint data=ipums.results4_r;
	by serial;
	var count;
	output out= num_families_in_hh;
run;

data ipums.num_families_in_hh (rename=(_freq_ = num_families));
	set num_families_in_hh;
	if _STAT_ ^= "N" then delete;
run;

/*single person families*/
data ipums.single_person_fam;
	set ipums.results4_r;
	if _freq_ ^= 1 then delete;
run;

proc means noprint data=ipums.single_person_fam;
	by serial;
	var count;
	output out= num_single_families;
run;

data ipums.num_single_families (rename=(_freq_ = num_single_fam));
	set num_single_families;
	if _STAT_ ^= "N" then delete;
run;

data ipums.families;
	merge ipums.num_families_in_hh (keep=serial num_families) ipums.num_single_families (keep=serial num_single_fam);
	by serial;
	if num_single_fam=. then num_single_fam=0;
	num_notsingle_fam= num_families - num_single_fam;
	if num_families = 1 then hh_fam_category = 1;
	else if num_notsingle_fam=1 and num_single_fam>0 then hh_fam_category = 2;
	else if num_families>1 and num_single_fam=0 then hh_fam_category=3;
	else if num_families>1 and num_single_fam>0 and num_notsingle_fam>0 then hh_fam_category = 4;
	else if num_single_fam=num_families then hh_fam_category = 5; 
run;

proc freq data=ipums.families; tables hh_fam_category; run;
/*merge all household level variables*/
data ipums.hh_results;
	merge results3 results1 results2 hh_income hh_depend_work ;
	by serial;
	num_children=numprec-num_adults;
run;

proc surveyfreq data=youth_in_p_sorted; 
      strata strata;
      cluster cluster;
      weight perwt;
      table bpl_region*employed /  chisq ; 
	  ods output chisq=bpl_chi;
run ;
