



proc format;
    value yesno
		1   = "Yes"
		0   = "No";	
	value yesmsng
		1   = "Yes"
		.   = "No";
    value gndr
		1   = "Male"
		2   = "Female";	
	value schltyp
		1   = "DCPS"
		2   = "PCSB-PCS"
		3   = "BOE-PCS";
	value schcat
		1   = "Elementary School"
		2   = "Middle School"
		3   = "Junior High School"
		4   = "Senior High School"
		5   = "Education Center"
		6   = "Special Education"
		7   = "School Within A School"
		8   = "Alternative Education"
		9   = "Tuition Grant"
		10   = "Katrina CARE Center"
		.   = "Unclassified";
    value pubc
		0   = "Public School"
		1   = "Charter School";	
	value $grdlvl
		"ECU"   = "Early Childhood Unit"
		"PS"   = "Pre-School"
		"PK"   = "Pre-Kindergarten"
		"K"   = "Kindergarten "
		"1"   = "1st"
		"2"   = "2nd"
		"3"   = "3rd"
		"4"   = "4th"
		"5"   = "5th"
		"6"   = "6th"
		"7"   = "7th"
		"8"   = "8th"
		"9"   = "9th"
		"10"   = "10th"
		"11"   = "11th"
		"12"   = "12th";
	value gradecat
	   -3-0 = "Early Education"  
		1-5 = "Elementary School"
		6-8 = "Middle / Junior High School" 
	   9-12 = "Senior High School"
	  other = "Other/Missing";
	value grdnum
		-3   = "Early Childhood Unit"
		-2   = "Pre-School"
		-1   = "Pre-Kindergarten"
		0   = "Kindergarten "
		1   = "1st"
		2   = "2nd"
		3   = "3rd"
		4   = "4th"
		5   = "5th"
		6   = "6th"
		7   = "7th"
		8   = "8th"
		9   = "9th"
		10   = "10th"
		11   = "11th"
		12   = "12th"
		other = "Other/unknown";		
   value $ethf
      "W"     = "White"
      "B"     = "Black"
	  "H"     = "Hispanic"
	  "A"     = "Asian"
	  "I"     = "Indian"
      "O"     = "Other/unknown"
       .     = "Missing/Bad code"
      other =  "Bad code";

   value agecat
      2-5		= "2 to 5"
      6-10		= "6 to 10"
	  11-14		= "11 to 14"
	  15-18		= "15 to 18"
	  19-23		= "19 to 23"
	  23<-85 	= "Over 23"
	  other 	=  "Unknown/Bad Code";
   value distcat
      0-.25		= "0 to 0.25"
      .25<-.5	= ".26 to 0.5"
	  .5<-.75	= ".51 to 0.75"
	  .75<-1.0	= ".76 to 1.0"
	  1.0<-1.5	= "1.01 to 1.5"
	  1.5 <- 2 	= "1.51 to 2.0"
	  2 <- 2.5 	= "2.01 to 2.5"
	   2.5<- high 	= "Over 2.51";
	  *other 	=  "Unknown/Bad Code";

	value numethf
       2    = "White"
       1    = "Black"
	   3    = "Hispanic"
	   4    = "Asian"
	   5    = "Indian"
       6    = "Other/unknown"
       7    = "Missing/Bad code"
       8	=  "Bad code"
	   100  = "District of Columia"
		.	= "Missing/Bad code"
	  other = "Missing/Bad code";

	 value ethgrp
       2    = "White"
       1    = "Black"
	   3    = "Hispanic"
	   4-6  = "Other/unknown"
       7    = "Missing/Bad code"
       8	=  "Bad code"
	   100  = "District of Columia"
		.	= "Missing/Bad code"
	  other = "Missing/Bad code";
run;
