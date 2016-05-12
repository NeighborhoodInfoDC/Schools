/**************************************************************************
 Program:  DCPCS_kids_count_2006.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/19/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read PCSB (Public Charter School Board) testing data 2006.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Schools )

data dcpcs_kids_count_data_2006;
  set Schools.dcpcs_kids_count_data_2006;
  where grade ~= 'All';
  ngrade = 1 * grade;
run;

proc summary data=dcpcs_kids_count_data_2006;
  class ngrade;
  var Reading___Tested  Math___Tested;
  var Reading___Met_NCLB_Standard / weight=Reading___Tested;
  var Math___Met_NCLB_Standard / weight=Math___Tested;
  output out=Dcps_sum_scores 
    sum( Reading___Tested  Math___Tested ) =
    mean(Reading___Met_NCLB_Standard Math___Met_NCLB_Standard )=;
run;

proc print data=Dcps_sum_scores noobs;
  format Reading___Met_NCLB_Standard Math___Met_NCLB_Standard 8.1;
run;

