proc freq data=enrol_ward2002_2009;
table ward2002_2009;
where PCSB_total_rep_0910 > 0;
run;

data test1;
set enrol_ward2002_2009;
where pcsb_total_rep_0910 > 0;
keep ward2002_2009 UI_ID master_school_name PCSB_total_rep_0910;
run;

proc sort data=test1;
by ward2002_2009;
run;

proc means sum data=test1;
run;

proc means sum data=dcd.pcsb_allsch_lngenrl;
var PCSB_total_rep_0910;
run;

proc freq data=enrol_ward2002_2009;
table ward2002_2009;
where PCSB_total_rep_0910 > 0;
run;

data test1;
set enrol_ward2002_2009;
where pcsb_total_rep_0910 > 0;
keep ward2002_2009 UI_ID master_school_name PCSB_total_rep_0910;
run;

proc sort data=test1;
by ward2002_2009;
run;

proc means sum data=test1;
run;

proc means sum data=dcd.pcsb_allsch_lngenrl_2;
var 
 rep_0910_PS  rep_0910_PK  rep_0910_K  rep_0910_1  rep_0910_2  rep_0910_3 
rep_0910_4  rep_0910_5  rep_0910_6  rep_0910_7  rep_0910_8  rep_0910_9 
rep_0910_10  rep_0910_11  rep_0910_12  rep_0910_Adult;
run;

proc means sum data=dcd.dcps_longenroll; 
var rep_0708 rep_0809 rep_0910;

run;

proc sort data=dcd.pcsb_longenroll;
by UI_ID;
run;

proc means data=dcd.dcps_longenroll;
class UI_ID;
var rep_0708;
output out = test3 sum=;
run;
proc print data = test3;
run;


/* Finding the coding errors by grade and by year */

proc means data=dcd.Pcsb_longenroll;
var aud_0708;
class grade;
output out=test sum=;
run;

data TEST1 (keep= master_school_name UI_ID grade aud_0708);
set dcd.Pcsb_longenroll;
where grade = "K" and aud_0708 ne .;
run;
