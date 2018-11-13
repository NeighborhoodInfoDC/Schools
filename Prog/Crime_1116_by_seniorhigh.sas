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
dat_count_vars=crimes_pt1_2016 crime_rate_pop_2016 crimes_pt1_2015 crime_rate_pop_2015 crimes_pt1_2014 crime_rate_pop_2014 crimes_pt1_2013 crime_rate_pop_2013 crimes_pt1_2012 crime_rate_pop_2012 crimes_pt1_2011 crime_rate_pop_2011,
dat_prop_vars=,
wgt_ds_name=Schools.Wt_tr10_seniorhigh,
wgt_org_geo=Geo2010,
wgt_new_geo=seniorhigh,
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=Schools.Crime_tract2010_to_seniorhigh,
out_ds_label=%str(Violent Crime from tract 2010 to senior high school boundaries),
calc_vars=
 pctviolent_2016 = 100 *  crimes_pt1_violent_2016/ crime_rate_pop_2016;
 pctviolent_2015 = 100 *  crimes_pt1_violent_2015/ crime_rate_pop_2015;
 pctviolent_2014 = 100 *  crimes_pt1_violent_2014/ crime_rate_pop_2014;
 pctviolent_2013 = 100 *  crimes_pt1_violent_2013/ crime_rate_pop_2013;
 pctviolent_2012 = 100 *  crimes_pt1_violent_2012/ crime_rate_pop_2012;
 pctviolent_2011 = 100 *  crimes_pt1_violent_2011/ crime_rate_pop_2011;
,
calc_vars_labels=

)
proc export 
data=Schools.Crime_tract2010_to_seniorhigh
dbms=csv
outfile="L:\Libraries\Schools\Data\ODCA demand factor\Crime_1116_by_seniorhigh.csv"
replace;
run;
