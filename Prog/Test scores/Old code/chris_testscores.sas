data PCSB_0809_wide;
	set Testscore_0809;
	where DCPS = "0";
run;
data DCPS_0809_wide;
	set Testscore_0809;
	where DCPS = "1";
run;
data PCSB_testscore_allyr;
	merge 
		dcd.PCSB_0607_wide
		dcd.PCSB_0708_wide
		PCSB_0809_wide;
	by UI_ID;
run;
data DCPS_testscore_allyr;
	merge
		dcd.DCPS_0607_wide
		dcd.DCPS_0708_wide
		DCPS_0809_wide;
	by UI_ID;
run;
%macro totals (type=);
	
	data &type._testscore_totals;
	%let macro_year = 0607 0708 0809;
		%do yr=1 %to 3;
		%let i=%scan(&macro_year, &yr,' ');
	set &type._testscore_allyr;
		&type._total_read_num_&i. = sum(of read_num_students_3_&i. read_num_students_4_&i. read_num_students_5_&i. 
							read_num_students_6_&i. read_num_students_7_&i. read_num_students_8_&i.
							read_num_students_10_&i.);
		label
			&type._total_read_num_&i. = "Total &type. students tested in Reading '&i.'";

		&type._total_math_num_&i. = sum(of math_num_students_3_&i. math_num_students_4_&i. math_num_students_5_&i. 
									math_num_students_6_&i. math_num_students_7_&i. math_num_students_8_&i.
									math_num_students_10_&i.);
		label
			&type._total_math_num_&i. = "Total &type. students tested in math '&i.'";


		&type._pct_read_below_&i. = sum(of read_below_3_&i. read_below_4_&i. read_below_5_&i. 
									read_below_6_&i. read_below_7_&i. read_below_8_&i.
									read_below_10_&i.)/(Total_read_num_&i.);
	
		label
			&type._pct_read_below_&i. = "&type. percent below basic reading level '&i.'";


			&type._pct_read_bas_&i. = sum(of read_bas_3_&i. read_bas_4_&i. read_bas_5_&i. 
									read_bas_6_&i. read_bas_7_&i. read_bas_8_&i.
									read_bas_10_&i.)/(Total_read_num_&i.);
		label
			&type._pct_read_bas_&i. = "&type. percent at basic reading level '&i.'";

			&type._pct_read_prof_&i. = sum(of read_prof_3_&i. read_prof_4_&i. read_prof_5_&i. 
									read_prof_6_&i. read_prof_7_&i. read_prof_8_&i.
									read_prof_10_&i.)/(Total_read_num_&i.);
		label
			&type._pct_read_prof_&i. = "&type. percent at proficient reading level '&i.'";


		
		&type._pct_read_adv_&i. = sum(of read_adv_3_&i. read_adv_4_&i. read_adv_5_&i. 
									read_adv_6_&i. read_adv_7_&i. read_adv_8_&i.
									read_adv_10_&i.)/(Total_read_num_&i.);
		label
			&type._pct_read_adv_&i. = "&type. percent at advanced reading level '&i.'";


		&type._pct_math_below_&i. = sum(of math_below_3_&i. math_below_4_&i. math_below_5_&i. 
									math_below_6_&i. math_below_7_&i. math_below_8_&i.
									math_below_10_&i.)/(Total_math_num_&i.);
		label
			&type._pct_math_below_&i. = "&type. percent at below basic math level '&i.'";


			&type._pct_math_bas_&i. = sum(of math_bas_3_&i. math_bas_4_&i. math_bas_5_&i. 
									math_bas_6_&i. math_bas_7_&i. math_bas_8_&i.
									math_bas_10_&i.)/(total_math_num_&i.);
		label
			&type._pct_math_bas_&i. = "&type. percent at basic math level '&i.'";

			&type._pct_math_prof_&i. = sum(of math_prof_3_&i. math_prof_4_&i. math_prof_5_&i. 
									math_prof_6_&i. math_prof_7_&i. math_prof_8_&i.
									math_prof_10_&i.)/(total_math_num_&i.);
		label
			&type._pct_math_prof_&i. = "&type. percent at proficient math level '&i.'";


		
		&type._pct_math_adv_&i. = sum(of math_adv_3_&i. math_adv_4_&i. math_adv_5_&i. 
									math_adv_6_&i. math_adv_7_&i. math_adv_8_&i.
									math_adv_10_&i.)/(total_math_num_&i.);
		label
			&type._pct_math_adv_&i. = "&type. percent at advanced math level '&i.'";



		&type._tot_read_below_&i. = sum(of read_below_3_&i. read_below_4_&i. read_below_5_&i. 
									read_below_6_&i. read_below_7_&i. read_below_8_&i.
									read_below_10_&i.);
		label
			&type._tot_read_below_&i. = "&type. Total below basic reading level '&i.'";


			&type._tot_read_bas_&i. = sum(of read_bas_3_&i. read_bas_4_&i. read_bas_5_&i. 
									read_bas_6_&i. read_bas_7_&i. read_bas_8_&i.
									read_bas_10_&i.);
		label
			&type._tot_read_bas_&i. = "&type. Total basic reading level '&i.'";

			&type._tot_read_prof_&i. = sum(of read_prof_3_&i. read_prof_4_&i. read_prof_5_&i. 
									read_prof_6_&i. read_prof_7_&i. read_prof_8_&i.
									read_prof_10_&i.);
		label
			&type._tot_read_prof_&i. = "&type. Total proficient reading level '&i.'";


		
		&type._tot_read_adv_&i. = sum(of read_adv_3_&i. read_adv_4_&i. read_adv_5_&i. 
									read_adv_6_&i. read_adv_7_&i. read_adv_8_&i.
									read_adv_10_&i.);
		label
			&type._tot_read_adv_&i. = "&type. Total advanced reading level '&i.'";


		&type._tot_math_below_&i. = sum(of math_below_3_&i. math_below_4_&i. math_below_5_&i. 
									math_below_6_&i. math_below_7_&i. math_below_8_&i.
									math_below_10_&i.);
		label
			&type._tot_math_below_&i. = "&type. Total below basic math level '&i.'";


			&type._tot_math_bas_&i. = sum(of math_bas_3_&i. math_bas_4_&i. math_bas_5_&i. 
									math_bas_6_&i. math_bas_7_&i. math_bas_8_&i.
									math_bas_10_&i.);
		label
			&type._tot_math_bas_&i. = "&type. Total basic math level '&i.'";

			&type._tot_math_prof_&i. = sum(of math_prof_3_&i. math_prof_4_&i. math_prof_5_&i. 
									math_prof_6_&i. math_prof_7_&i. math_prof_8_&i.
									math_prof_10_&i.);
		label
			&type._tot_math_prof_&i. = "&type. Total proficient math level '&i.'";


		
		&type._tot_math_adv_&i. = sum(of math_adv_3_&i. math_adv_4_&i. math_adv_5_&i. 
									math_adv_6_&i. math_adv_7_&i. math_adv_8_&i.
									math_adv_10_&i.);
		label
			&type._tot_math_adv_&i. = "&type. Total advanced math level '&i.'";


		&type._totalMprof_0809 = sum(of &type._tot_math_prof_0809, &type._tot_math_adv_0809);
		&type._totalRprof_0809 = sum(of &type._tot_read_prof_0809, &type._tot_read_adv_0809);

%end;
		keep 
			 UI_ID
			 Master_school_name			 			 
			 &type._total_math_num_0809			 
			 &type._total_read_num_0809			 
			 cluster_tr2000_2008			 
			 &type._totalMprof_0809
			 &type._totalRprof_0809;
	run;
%mend totals;
%totals (type=DCPS)
%totals (type=PCSB);

%macro mean (type=, year1=, year2=);
		proc means data=&type._testscore_totals noprint;
			class cluster_tr2000_&year1.;
			var &type._total_read_num_&year2. 
				&type._total_math_num_&year2. 
				&type._totalMprof_0809
				&type._totalRprof_0809;	
			 output out=dcd.&type._chris_cluster_tr2000_&year1. (drop= _type_ _freq_)sum= ;
			run;

%mend mean;
%mean(type=PCSB, year1=2008, year2=0809)
%mean(type=DCPS, year1=2008, year2=0809)

data dcd.testscores_chris_cluster_tr2000 (where=(cluster_tr2000 not in ("Cl", "99", " ")) 
									drop =pcsb_totalRprof_0809 dcps_totalRprof_0809 
									pcsb_totalMprof_0809 dcps_totalMprof_0809 
									pcsb_total_math_num_0809 dcps_total_math_num_0809 
									pcsb_total_read_num_0809 dcps_total_read_num_0809);

	merge
		dcd.pcsb_chris_cluster_tr2000_2008 (rename=(cluster_tr2000_2008=cluster_tr2000))
		dcd.dcps_chris_cluster_tr2000_2008 (rename=(cluster_tr2000_2008=cluster_tr2000));
	by cluster_tr2000;
	read_prof_total=sum(of pcsb_totalRprof_0809, dcps_totalRprof_0809);
	math_prof_total=sum(of pcsb_totalMprof_0809, dcps_totalMprof_0809);
	test_math_total=sum(of pcsb_total_math_num_0809, dcps_total_math_num_0809);
	test_read_total=sum(of pcsb_total_read_num_0809, dcps_total_read_num_0809);
run;
ods html file= "D:\DCData\Libraries\Schools\Prog\Chris\cluster_testscores.xls" style=minimal;
proc print data=dcd.testscores_chris_cluster_tr2000 noobs;
run;
ods html close;
