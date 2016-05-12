/**************************************************************************
 Program:  register_schools.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   S. Zhang
 Created:  11/26/13
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 
 Description: Registering schools summary files with the metadata system

 Modifications: 11/25/2013 - Updated to reflect current files - SXZ
**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
option mprint;

%DCData_lib( Schools )

/*register summary data with alpha*/
rsubmit;

/** Macro Register - Start Definition **/

%macro Register( level=, revisions=%str(New file.) );

  %local filesuf;

  %** Get standard geography information **;

  %let level = %upcase( &level );

  %if %sysfunc( putc( &level, $geoval. ) ) ~= %then %do;
    %let filesuf = %sysfunc( putc( &level, $geosuf. ) );
  %end;
  %else %do;
    %err_mput( macro=Summarize, 
               msg=Level (LEVEL=&level) is not recognized. )
    %goto exit;
  %end;

  ** Register metadata **;

  %Dc_update_meta_file(
    ds_lib=Schools,
    ds_name=msf_sum&filesuf,
    creator_process=schools_11_12_newgeo.sas,
    restrictions=None,
    revisions=&revisions
  )

  run;

  %exit:

%mend Register;

/** End Macro Definition **/

%Register( level=city )
%Register( level=anc2002 )
%Register( level=anc2012 )
%Register( level=psa2004 )
%Register( level=psa2012 )
%Register( level=eor )
%Register( level=geo2000 )
%Register( level=geo2010 )
%Register( level=cluster_tr2000 )
%Register( level=cluster2000 )
%Register( level=ward2002 )
%Register( level=ward2012 )
%Register( level=zip )

run;

endrsubmit;
signoff;
