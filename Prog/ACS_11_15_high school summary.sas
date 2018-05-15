/**************************************************************************
Program:  ACS_11_15 high school summary.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  5/7/2018
 Version:  SAS 9.2
 Environment:  Local Windows session
 
 Description:  Summarize tract level demand factors (population and education) to senior high shcool level
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( Realprop )
%DCData_lib( Police )
%DCData_lib( Schools )

%Transform_geo_data(
keep_nonmatch=n,
dat_ds_name=ACS.Acs_2011_15_dc_sum_tr_tr10,
dat_org_geo=geo2010,
dat_count_vars=totpop_2011_15 pop25andoverwcollege_2011_15,
dat_prop_vars=,
wgt_ds_name=Schools.Wt_tr10_seniorhigh,
wgt_org_geo=Geo2010,
wgt_new_geo=seniorhigh,
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=ACS_2011_15_seniorhigh,
out_ds_label=%str(ACS_2011_2015 Population and education attainment from tract 2010 to senior high school boundaries),
calc_vars=
 pctcollege = 100 *  pop25andoverwcollege_2011_15/ totpop_2011_15;
,
calc_vars_labels=
 pctcollege = "Percent with college degree or higher"

)


