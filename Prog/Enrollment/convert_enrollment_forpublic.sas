option nofmterr;
libname enroll "K:\Metro\PTatian\DCData\Libraries\Schools\Data\Enrollment";

/* Convert enrollment file for public use */

data enrollment;
	set enroll.allenrollment_1415;
	drop rep_0102 rep_0203 rep_0304 rep_0405 rep_0506 rep_0607 rep_0708 rep_0809 rep_0910 rep_1011 schooltype;
	if grade = "K" then grade = "0";
	if grade = "PK" then grade = "-1";
	if grade = "PS" then grade = "-2";
	if grade = "total" then grade = "Total";
run;

proc sort data = enrollment; by ui_id grade; run;

proc transpose data = enrollment out = enrollment_long (drop = _LABEL_);
	by ui_id grade;
run;

data enrollment_long2;
	set enrollment_long;
	year = cat("20",substr(_NAME_,5,2));
	enrollment = COL1;
	label grade = "grade";
	drop _NAME_ COL1;
run;

proc export data = enrollment_long2 outfile = "D:\DCData\Libraries\Schools\Data\enrollment_data_14_15.csv" replace; run;
