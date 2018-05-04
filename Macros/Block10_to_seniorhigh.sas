/**************************************************************************
 Macro:    Block10_to_seniorhigh
 Library:  Macros
 Project:  ODCA school enrollment projection
 Author:   Yipeng Su
 Created:  5/3/2018
 Version:  SAS 9.4
 Environment:  Windows
 
 Description: Convert Census block IDs (2010) to DC new Senior High School Attendance Zone.

 Modifications:
**************************************************************************/

%macro Block10_to_seniorhigh( invar=geoblk2010, outvar=seniorhigh, format=N );

  length &outvar $ 1;
  
  &outvar = put( &invar, $bk1seniorhigh. );
  
  label &outvar = "Senior High School Attendance Zone ";
  
  %if %upcase( &format ) = Y %then %do;
    format &outvar $seniorhigha.;
  %end;

%mend Block10_to_seniorhigh;



