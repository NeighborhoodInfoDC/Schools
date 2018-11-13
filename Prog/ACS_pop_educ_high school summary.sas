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

data ACS_1116;
merge ACS.Acs_2012_16_dc_sum_tr_tr10 ACS.Acs_2011_15_dc_sum_tr_tr10 ACS.Acs_2010_14_dc_sum_tr_tr10 ACS.Acs_2009_13_sum_tr_tr10 ACS.Acs_2008_12_sum_tr_tr10 ACS.Acs_2007_11_sum_tr_tr10; 
by Geo2010;
run;


%Transform_geo_data(
keep_nonmatch=n,
dat_ds_name=work.ACS_1116,
dat_org_geo=geo2010,
dat_count_vars=totpop_2012_16 pop25andoverwcollege_2012_16 totpop_2011_15 pop25andoverwcollege_2011_15 totpop_2010_14 pop25andoverwcollege_2010_14 totpop_2009_13 pop25andoverwcollege_2009_13 totpop_2008_12 pop25andoverwcollege_2008_12 totpop_2007_11 pop25andoverwcollege_2007_11,
dat_prop_vars=,
wgt_ds_name=Schools.Wt_tr10_seniorhigh,
wgt_org_geo=Geo2010,
wgt_new_geo=seniorhigh,
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=Schools.ACS_1116_seniorhigh,
out_ds_label=%str(ACS 5 year estimiates 2011-2016 Population and education attainment from tract 2010 to senior high school boundaries),
calc_vars=
 pctcollege_2012_16= 100 *  pop25andoverwcollege_2012_16/ totpop_2012_16;
 pctcollege_2011_15= 100 *  pop25andoverwcollege_2011_15/ totpop_2011_15;
 pctcollege_2010_14= 100 *  pop25andoverwcollege_2010_14/ totpop_2010_14;
 pctcollege_2009_13= 100 *  pop25andoverwcollege_2009_13/ totpop_2009_13;
 pctcollege_2008_12= 100 *  pop25andoverwcollege_2008_12/ totpop_2008_12;
 pctcollege_2007_11= 100 *  pop25andoverwcollege_2007_11/ totpop_2007_11;
,
calc_vars_labels=
)


proc export 
data=Schools.ACS_1116_seniorhigh
dbms=csv
outfile="L:\Libraries\Schools\Data\ODCA demand factor\ACS_1116_seniorhigh.csv"
replace;
run;
