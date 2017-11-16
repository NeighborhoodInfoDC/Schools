/**************************************************************************
 Program:  Schools_forweb
 Library:  Schools
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  11/16/2017
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( Schools )
%DCData_lib( Web )


/***** Update the let statements for the data you want to create CSV files for *****/

%let library = schools; /* Library of the summary data to be transposed */
%let outfolder = schools; /* Name of folder where output CSV will be saved */
%let sumdata = msf_sum; /* Summary dataset name (without geo suffix) */
%let start = 2001; /* Start year */
%let end = 2013; /* End year */
%let keepvars = school_present charter_present dcps_present aud aud_charter aud_dcps; /* Summary variables to keep and transpose */


/***** Update the web_varcreate marcro if you need to create final indicators for the website after transposing *****/

%macro web_varcreate;

label school_present = "Number of schools";
label dcps_present = "Number of DCPS schools";
label charter_present = "Number of charter schools";
label aud = "Total school enrollment";
label aud_charter = "Charter school enrollment";
label aud_dcps = "DCPS school enrollment";

%mend web_varcreate;



/**************** DO NOT UPDATE BELOW THIS LINE ****************/

%macro csv_create(geo);
			 
%web_transpose(&library., &outfolder., &sumdata., &geo., &start., &end., &keepvars. );

/* Load transposed data, create indicators for profiles */
data &sumdata._&geo._long_allyr;
	set &sumdata._&geo._long;
	%web_varcreate;
	label start_date = "Start Date"
		  end_date = "End Date"
		  timeframe = "Year of Data";
run;

/* Create metadata for the dataset */
proc contents data = &sumdata._&geo._long_allyr out = &sumdata._&geo._metadata noprint;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&outfolder.\&outfolder._&geo._metadata..csv";
	proc print data =&sumdata._&geo._metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&outfolder.\&outfolder._&geo..csv";
	proc print data =&sumdata._&geo._long_allyr noobs;
	run;
ods csv close


%mend csv_create;
%csv_create (tr10);
%csv_create (tr00);
%csv_create (anc12);
%csv_create (wd02);
%csv_create (wd12);
%csv_create (city);
%csv_create (psa12);
%csv_create (zip);

