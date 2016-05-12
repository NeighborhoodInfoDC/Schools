/**************************************************************************
 Program:  Peter_schools_check.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/02/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Peter Tatian check of new schools enrollment and
testing data sets.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Schools )

%File_info( data=Schools.test_allgrades_city, freqvars=year grade )
%File_info( data=Schools.test_city )

%File_info( data=Schools.test_allgrades_tr00, freqvars=year grade geo2000 )
%File_info( data=Schools.test_tr00 )

run;
