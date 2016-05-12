/**************************************************************************
 Program:  Test_min_max_2006.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/09/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Calculate min & max test scores for schools for DCPS,
PCSB, and BOE.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Schools )

** DCPS **;

proc sql;
  create table dcps as
  select * from 
  schools.dcps_math_2006  (keep=schno estgrade m6tst m6excd) as math, 
  schools.dcps_read_2006 (keep=schno estgrade r6tst r6excd) as read
  where math.schno = read.schno and math.estgrade = read.estgrade;
quit;
run; 

proc summary data=dcps nway;
  var m6excd / weight=m6tst;
  var r6excd / weight=r6tst;
  class schno;
  output out=dcps_sch mean=;
run;

proc means data=dcps_sch n min max;
  var r6excd m6excd;
  label
    r6excd = 'Reading % Met NCLB Standard'
    m6excd = 'Math % Met NCLB Standard';
  title2 'DCPS';
run;

** PCSB **;

proc means data=Schools.dcpcs_kids_count_data_2006 n min max;
 where grade = 'All';
  var Reading___Met_NCLB_Standard  Math___Met_NCLB_Standard ;
  title2 'PCSB';
run;

** BOE **;

proc sql;
  create table boe as
  select * from 
  schools.boe_math_2006  (keep=schno estgrade m6tst m6excd) as math, 
  schools.boe_read_2006 (keep=schno estgrade r6tst r6excd) as read
  where math.schno = read.schno and math.estgrade = read.estgrade;
quit;
run; 

proc summary data=boe nway;
  var m6excd / weight=m6tst;
  var r6excd / weight=r6tst;
  class schno;
  output out=boe_sch mean=;
run;

proc means data=boe_sch n min max;
  var r6excd m6excd;
  label
    r6excd = 'Reading % Met NCLB Standard'
    m6excd = 'Math % Met NCLB Standard';
  title2 'BOE';
run;

