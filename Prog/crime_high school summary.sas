/**************************************************************************
Program:  Senior High School demand factor summaries.sas
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  5/7/2018
 Version:  SAS 9.2
 Environment:  Local Windows session
 
 Description:  Summarize tract level demand factors to senior high shcool level
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( ACS )
%DCData_lib( Realprop )
%DCData_lib( Police )
%DCData_lib( Schools )

%Transform_geo_data(
keep_nonmatch=n,
dat_ds_name=Police.Crimes_sum_tr10 ,
dat_org_geo=geo2010,
dat_count_vars=crimes_pt1_violent_: crime_rate_pop_:,
dat_prop_vars=,
wgt_ds_name=Schools.Wt_tr10_seniorhigh,
wgt_org_geo=Geo2010,
wgt_new_geo=seniorhigh,
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=Crime_tract2010_to_seniorhigh,
out_ds_label=%str(Violent Crime from tract 2010 to senior high school boundaries),
calc_vars=
 pctviolent_2016 = 100 *  crimes_pt1_violent_2016/ crime_rate_pop_2016;
,
calc_vars_labels=
 pctviolent_2016 = "Violent crime per 100 population"

)

