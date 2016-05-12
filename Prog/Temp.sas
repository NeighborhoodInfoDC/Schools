/**************************************************************************
 Program:  Temp.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/10/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Schools )

%File_info( data=schools.dcps_allsch_lngenrl )

%File_info( data=schools.pcsb_allsch_lngenrl )

run;
