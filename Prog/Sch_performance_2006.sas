/**************************************************************************
 Program:  Sch_performance_2006.sas
 Library:  Kids06
 Project:  NeighborhoodInfo DC
 Author:   J.Cigna
 Created:  09/22/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  DCPS and BOE School Performance Data for Kids Count 2006 report.

 Modifications:
**************************************************************************/



libname sch06 'D:\DCDATA\Libraries\Schools\data';
libname sch06xls dbexcel5 'D:\DCDATA\Libraries\Schools\data';

*libname schhnc06 'D:\HNC\HNC06\data';
libname schhnc06 'D:\DCDATA\Libraries\Schools\data';
*%include 'K:\Metro\MAturner\hnc2006\programs\schools\formats for school addresses.sas';
*%include 'K:\Metro\MAturner\hnc2006\programs\schools\students\formats for student data.sas';
%include 'D:\DCData\Libraries\Schools\Prog\formats for school addresses.sas';
%include 'D:\DCData\Libraries\Schools\Prog\formats for student data.sas';

proc sort data=schhnc06.school_list_4rmstu; 
by ui_sch_id; 
run; 


%macro schname(test);
data temp_boe_&test.;
set sch06.boe_&test._2006; 
if schname ='BARBARA JORDAN PCS' then ui_sch_id='3_001';
if schname ='BT WASHINGTON PCS' then ui_sch_id='3_002';
if schname ='COMMUNITY ACADEMY - AMOS'    then ui_sch_id='3_006';
if schname ='COMMUNITY ACADEMY - BUTLER' then ui_sch_id='3_007';
if schname ='COMMUNITY ACADEMY - MIDDLE' then ui_sch_id='3_005';
if schname ='COMMUNITY ACADEMY - RAND'  then ui_sch_id='3_008';
if schname ='E WHITLOW STOKES PCS' then ui_sch_id='3_010';
if schname ='HYDE LEADERSHIP PCS' then ui_sch_id='3_012';
if schname ='IDEA PCS' then ui_sch_id='3_014';
if schname ='IDEAL ACADEMY PCS' then ui_sch_id='3_013';
if schname ='KAMIT INSTITUTE' then ui_sch_id='3_016';
if schname ='MARY MCLEOD BETHUNE' then ui_sch_id='3_019';
if schname ='OPTIONS PCS' then ui_sch_id='3_021';
if schname ='WASHINGTON ACADEMY' then ui_sch_id='3_023';
if schname ='YOUNG AMERICA WORKS' then ui_sch_id= '3_024';
run;

proc sort data=temp_boe_&test.;
by ui_sch_id; 
run; 

data BOE_&test._geo;
merge temp_boe_&test(in=a) schhnc06.school_list_4rmstu;
by ui_sch_id; 
if a;
run; 


proc sort data=BOE_&test._geo; 
by ui_sch_id estgrade; 
run; 




proc sort data=sch06.DCPS_&test._2006; 
by schno; 
run; 

proc sort data=schhnc06.school_list_4rmstu out=dcps_geo_list(rename=(school_num=schno)); 
by school_num; 
run; 


data DCPS_&test._geo; 
merge sch06.DCPS_&test._2006(in=a) dcps_geo_list; 
by schno; 
if a;
run;


proc sort data=DCPS_&test._geo; 
by ui_sch_id estgrade; 
run; 

%mend; 
%schname(read);
%schname(math);


data all_sch_performance_2006; 
merge DCPS_Math_geo DCPS_read_geo
BOE_Math_geo BOE_read_geo; 
by ui_sch_id estgrade; 

/*This percent turns out to be exactly the same as the NCLB standard*/
R6ATLPR=sum(of R6PR,R6AD);
M6ATLPR=sum(of M6PR,M6AD);

run; 

proc contents data=all_sch_performance_2006; 
run; 

proc sort data=all_sch_performance_2006;  
by school_type estgrade ward_perm;
run; 



proc summary data=all_sch_performance_2006;
class school_type estgrade;
var 
R6AD R6BB R6BS R6EXCD R6PR R6ATLPR R6SCALE /weight=R6TST;
var R6TST;
var
M6AD M6BB M6BS M6EXCD M6PR M6ATLPR M6SCALE /weight=M6TST; 
var M6TST;
output out=sch06xls.SCOREGRD mean=; 
run; 

proc summary data=all_sch_performance_2006 (where=(estgrade in (3,4,5)));
class school_type ward_perm;
var 
R6AD R6BB R6BS R6EXCD R6PR R6ATLPR R6SCALE /weight=R6TST;
var R6TST;
var
M6AD M6BB M6BS M6EXCD M6PR M6ATLPR M6SCALE /weight=M6TST; 
var M6TST;
output out=sch06xls.SCOREWRD mean=; 
run; 


proc summary data=all_sch_performance_2006; 
class school_type estgrade; 
var R6TST M6TST; 
output out=num_tested_dc_tot sum=;
run;

proc print data=num_tested_dc_tot;

proc freq data=all_sch_performance_2006; 
table schname*school_type; 
run; 