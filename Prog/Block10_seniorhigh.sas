/**************************************************************************
 Program:  Block10_seniorhigh.sas
 Library:  Schools
 Project:  ODCA enrollment projection study
 Author:   Yipeng Su
 Created:  5/4/2018
 Version:  SAS 9.4
 Environment:  Windows
 
 Description: Census 2010 blocks (GeoBlk2010) to 
Senior High School Attendance Zone (seniorhigh) correspondence file.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;

libname Cen2010m "&_dcdata_path\Schools\Maps\Census 2010";

*options obs=50;

data Block10_seniorhigh
  (label="Census 2010 blocks (GeoBlk2010) to Senior High School Attendance Zone correspondence file");

  set Cen2010m.Block10_seniorhigh;
  
  ** Census block, block group, and tract IDs **;
  
  length Geo2010 $ 11 GeoBg2010 $ 12 GeoBlk2010 $ 15;
  
  Geo2010 = '11001' || Tract;
  GeoBg2010 = Geo2010 || BlkGrp;
  GeoBlk2010 = Geo2010 || Block;
  
  label
    GeoBlk2010 = 'Full census block ID (2010): sscccttttttbbbb'
    GeoBg2010 = 'Full census block group ID (2010): sscccttttttb'
    Geo2010 = 'Full census tract ID (2010): ssccctttttt';

  ** seniorhigh code **;


    Gis_id = seniorhigh;

  label
    seniorhigh = "Senior High School Attendance Zone";
  
  label 
    Gis_id = "OCTO seniorhigh ID"
    NAME = "seniorhigh code"
    Tract = "OCTO tract ID"
    BlkGrp = "OCTO block group ID"
    Block = "OCTO block ID"
  ;
  
  ** Remove silly formats/informats, unneeded variables **;
  
  format _all_ ;
  informat _all_ ;
  
  keep GeoBlk2010 GeoBg2010 Geo2010 seniorhigh Tract BlkGrp Block Gis_id NAME;

run;

** Find duplicates **;
** Each block should be assigned to only one geographic unit **;

%Dup_check(
  data=Block10_seniorhigh,
  by=GeoBlk2010,
  id=seniorhigh
)

proc sort data=Block10_seniorhigh nodupkey;
  by GeoBlk2010;
run;


** Create correspondence format **;

%Data_to_format( 
  FmtLib=General,
  FmtName=$bk1seniorhigh,
  Data=Block10_seniorhigh,
  Value=GeoBlk2010,
  Label=Senior High School,
  OtherLabel="",
  Desc="Block 2010 to Senior High School corresp",
  Print=N,
  Contents=Y
  )

%Finalize_data_set(
    data=block10_seniorhigh,
    out=block10_seniorhigh,
    outlib=Schools,
    label="Census 2010 blocks (GeoBlk2010) to Senior High School Attendance Zone correspondence file",
    sortby=GeoBlk2010,
    /** Metadata parameters **/
    revisions=New file.,
    /** File info parameters **/
    printobs=5,
    freqvars=
  )
