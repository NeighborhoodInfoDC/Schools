***************************************************
Program: IEP_share_enrollment.sas

Author: ZM

Date: 3/24/2011

Description: This program reads in IEP data and calculates the share of each school that has
                and IEP

Modifications:

***************************************************;

*** The raw data ****;
%let filepath = K:\Metro\PTatian\DCData\Libraries\Schools\Raw\IEP;

libname raw "&filepath.";
libname data "K:\Metro\PTatian\DCData\Libraries\Schools\Raw\IEP";

/*Read in the file from the Excel sheet, making sure that the excel sheet is open when this runs*/
/* Note that filename years refer to the SPRING of that school year **/

%macro readin (year=, row=);

filename dat dde "excel|&filepath.\[Students with IEPs &year..xls]&year.! r2c1:r&row.c10" ;
	data IEP_&year.; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			SchoolName_&year.			$40.
			UI_ID				$8.
			Sort_ID 			$8.
			School_type			$8.
			Total_&year.	 			8.
			Level1_&year.			8.
			Level2_&year.			8.
			Level3_&year.			8.
			Level4_&year.			8.
			Level5_&year.			8.
;

		input
			SchoolName_&year.		$	
			UI_ID			$
			Sort_ID 		$	
			School_type	    $
			Total_&year.	 	
			Level1_&year.		
			Level2_&year.		
			Level3_&year.		
			Level4_&year.		
			Level5_&year.		
		;
run;
%mend;
%readin (year=2003 , row=216)
%readin (year=2004 , row=223)
%readin (year=2005 , row=235)
%readin (year=2006 , row=249)
%readin (year=2007 , row=260)
%readin (year=2008 , row=252)
%readin (year=2009 , row=243)
%readin (year=2010 , row=241)
;

* Read 2002 in separately due to different format;

filename dat dde "excel|&filepath.\[Students with IEPs 2002.xls]2002! r2c1:r218c5" ;
	data IEP_2002; 
		infile dat   notab missover dlm='09'x dsd;
		informat 
			SchoolName_2002			$40.
			UI_ID				$8.
			Sort_ID 			$8.
			School_type			$8.
			Total_2002	 			8.			
;
		input
			SchoolName_2002		$	
			UI_ID			$
			Sort_ID 		$	
			School_type	    $
			Total_2002	 				
		;
run;

%macro merge;
%do year=2002 %to 2010;
	proc sort data=IEP_&year.;
		by UI_ID;
	run;
%end;

	data IEP_allyear;
		merge
		%do year=2002 %to 2010;
			IEP_&year.
		%end;
		;
		by UI_ID;
	run;
%mend;
%merge

proc sort data=Iep_allyear nodupkey out=ieptest;
by UI_ID;
run;
