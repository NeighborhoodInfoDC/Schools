/************************************************************************
  Program:  Wt_tr10_seniorhigh
  Project:  ODCA School enrollment projection
  Author:   Yipeng Su
  Created:  5/3/2018
  Version:  SAS 9.4
  Environment:  Windows
  
  Description:  Create weighting file for converting 2010 tracts to
  Senior High School attendance zone

  Modifications:
************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Schools )
%DCData_lib( Census )

%Calc_weights_from_blocks( 
  geo1 = Geo2010,
  geo2 = seniorhigh,
  geo2check=n,
  geo2suf=_hs,
  geo2name=seniorhigh,
  out_ds = Wt_tr10_seniorhigh,
  finalize=y,
  outlib=Schools,
  revisions=New File.,
  block_corr_ds = Schools.Block10_seniorhigh,
  block = GeoBlk2010,
  block_pop_ds = Census.Census_pl_2010_dc (where=(sumlev='750')),
  block_pop_var = p0010001, 
  block_pop_year = 2010
)

