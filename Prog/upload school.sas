/**************************************************************************
 Program:  upload school.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   S. Litschwartz
 Created:  11/09/11
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 
 Description: Uploading Schools summary datasets and formats to Alpha 

 Modifications: 11/25/2013 - Updated to reflect current files - SXZ
**************************************************************************/



%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
option mprint;


** Define libraries **;
%DCData_lib( library=Schools)

	%put &geo.;
  
   %syslput geosuf=&geosuf;
  %put &geosuf.;
 
  %syslput geo=&geo;

%macro schools_upload(geo=);
%syslput geosuf=&geo;
%let geosuf = %sysfunc( putc( %upcase( &geo. ), $geosuf. ) );
%syslput geosuf=&geosuf;
  rsubmit;  
proc upload status=no
	inlib=Schools
	outlib=Schools memtype=(data);
	select MSF_sum&geosuf.;
run;
endrsubmit;
%mend;


	%schools_upload(geo=city)
	%schools_upload(geo=anc2002)
	%schools_upload(geo=anc2012)
	%schools_upload(geo=psa2004)
	%schools_upload(geo=psa2012)
	%schools_upload(geo=eor)
	%schools_upload(geo=geo2000)
	%schools_upload(geo=geo2010)
	%schools_upload(geo=cluster_tr2000)
	%schools_upload(geo=cluster2000)
	%schools_upload(geo=ward2002)
	%schools_upload(geo=ward2012)
	%schools_upload(geo=zip)

rsubmit; 
proc upload status=no
	inlib=Schools
	outlib=Schools memtype=(catalog);
	select formats;
run;
endrsubmit;

signoff;
