/**************************************************************************
 Program:  Update_MSF_1011.sas
 Library:  Prog\cleaning
 Project:  schools
 Author:   KF
 Created:  11/30/11
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Updates Master School File
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas"; 
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\schoolmacros.sas";
%include "K:\Metro\PTatian\DCData\Libraries\Schools\prog\Enrollment\School Formats.sas"; 
%DCData_lib( Schools)
%let filepath = D:\DCData\Libraries\schools\raw\;

%let newyr= 2011;
%let lastyr= 2010;

****Notes
DCPS:
in 2010 Youth Engagement Academy changed to Washington Metropolitan High School in 
August 2010 and moved to 300 Bryant St NW
in 2011-12 added 12th grade

in 2011 new Langley Education Campus was Emery Education Campus
101 T Street NE 20002, grades PS-8

in 2010-11 Wilson HS at UDC Building 52
4340 Connecticut Ave NW 20008

in 2011-12 Wilson HS returns to 3950 Chesapeake ST NW

in 2011-12 Shaed Education Campus was closed, consolidated with Emery into Langley Edu Campus

in 2010-11 and 2011-12 for part of the year, Takoma Education Campus temporarily located to
 2501 11th St NW (Meyer) due to a serious fire in December of 2010

in 2011-12, new school
Capitol Hill Montessori at Logan
215 G Street NE
Washington, DC 20002
PS-5

in 2011-12, 
looks likw Shaw Middle School lost 9th grade

in 2010-11,
looks like Hamilton Center lost 1-2 grade

in 2011-12,
looks like Hamilton Center was closed, 3rd to 5th transferred to Prospect, 6-8 transferred
to Ron Brown

in 2011-12,
Transition Academy moved to Ballou HS

What happened to Twilight Academy?

Oddities:
Marie Reed on DCPS site is listed with new address:
2201 18th St. NW
It hasn't moved, and both represent where school is located
The address didn't change on Reed school site
Name is Marie Reed Elementary School

Patterson Elementary School listed with new address:
4399 South Capitol Terrace SW
It hasn't moved, but the address changed

Payne Elementary School listed with new address:
1445 C St SE
It hasn't moved, but the address changed

PCSB:
in 2011-12 Hyde Leadership now Perry Street Prep

new in 2010-11:
E.L. Haynes PCS –Kansas Avenue (Grades PK3-2)
KIPP DC: College Preparatory
KIPP DC: Grow Academy
Options Academy

new in 2011-12:
Appletree Early Learning - Douglass Knoll 2017 Savannah Terrace SE 20020 PS?
AppleTree Early Learning - Lincoln  138 12th Street NE 20019 PS?
Appletree Early Learning - Oklaholma Ave (East Capitol) 320 21st Street NE 20002 PS?
Appletree Early Learning - Parkland 2017 Savannah Terrace SE 20020 PS?
E.L. Haynes PCS - Kansas Avenue (Grade 9)
Inspired Teaching Demonstration PCS
Richard Wright PCS
Shining Stars Montessori

Achievement Prep Added 8th Grade
Arts and Technology Academy Removed 6th Grade
Carlos Rosario Int'll (AD/GED Only)
Capital City Upper only 9-12
Capital City Lower PK-8
Cesar Chavez Parkside broke out into a Lower (Gr 6-8) and Upper (9-12) campus with same address
COMMUNITY ACADEMY BUTLER CAMPUS (THOMAS CIRCLE) Added 5th Grade
DC BILINGUAL (LOWER SCHOOL)added 5th grade
E.L. Haynes Georgia Ave 3600 GEORGIA AV NW now has Grades 3-8
E.L. Haynes Kansas Ave High School 4501 Kansas Ave NW Grade 9
E.L. Haynes Kansas Ave Elem. School 4501 Kansas Ave NW Grade PS-2
Eagle Academy Southeast 1017 New Jersey Ave SE Grades 1-2
Eagle Academy Southeast 770 M Street SE Grades PS-3
ESF- EDUCATION STRENGTENS FAMILIES PCS - MARY's CE PS-Adult/GED
ESF- EDUCATION STRENGTENS FAMILIES PCS - BANCROFT Closed?
;

data msf0910;
set schools.master_school_file_final_082011;
/*2010-11 Changes*/

if ui_id= "1046300" then notes_2010= "School relocated to UDC during renovations";
if ui_id= "1046300" then sch_2010_address= "4340 CONNECTICUT AV NW" ;
if ui_id= "1046300" then sch_2010_zip= "20008";

if ui_id= "1032400" then notes_2010= "School relocated to Meyer due to fire in 2010";
if ui_id= "1032400" then sch_2010_address= "2501 11 ST NW" ;
if ui_id= "1032400" then sch_2010_zip= "20001";

if ui_id= "1047400" then notes_2010= "Youth Engagement Academy changed to Washington Metropolitan High School in Aug 2010 and moved to 300 Bryant St NW";
if ui_id= "1047400" then school_name_2010= "WASHINGTON METROPOLITAN HIGH SCHOOL";
if ui_id= "1047400" then sch_2010_address= "300 BRYANT ST NW";
if ui_id= "1047400" then sch_2010_zip= "Washington Metropolitan High School";

if ui_id= "1056700" then notes_2010= "Hamilton 3rd through 8th Grade";
if ui_id= "1056700" then grade_min_2010= '3'; *Hamilton loses 3rd grade;
if ui_id= "1056700" then grade_max_2010= '8'; *Hamilton has an 8th grade;

if ui_id= "1025900" then notes_2010= "Kimball gained PS";
if ui_id= "1025900" then grade_min_2010= '-2'; *Kimball Elementary gained PS;

run;

data test;

retain school_name_2009 school_name_2010 grade_min_2009 grade_min_2010 grade_max_2009
grade_max_2010 
Sch_2009_address
Sch_2010_address ;
set msf0910;
keep school_name_2009 school_name_2010 grade_min_2009 grade_min_2010 grade_max_2009
grade_max_2010 
Sch_2009_address
Sch_2010_address ;
run;

      ods html file = "D:\DCData\Libraries\schools\raw\MSF_0910.xls" style = minimal;
      proc print data = test label noobs;
      run;
      ods html close;



data msf1011;
set msf0910;

Notes_&newyr.='';
Sch_&newyr._address=Sch_&lastyr._address;
Sch_&newyr._zip=Sch_&lastyr._zip;
School_Name_&newyr.=School_Name_&lastyr.;
addr_var_&newyr.=addr_var_&lastyr.;
grade_max_&newyr.=grade_max_&lastyr.;
grade_min_&newyr.=grade_min_&lastyr.;


/*2011-12 Changes*/
/*grade changes*/
if ui_id= "1047800" then grade_max_2011='12'; *Phelps gains 12th Grade;
if ui_id= "1045700" then grade_min_2011='9'; *Eastern HS gains 9th Grade;
if ui_id= "1042800" then grade_min_2011='6'; *Stuart Hobson loses 5th Grade;
if ui_id= "1033300" then grade_min_2011='1'; *Watkins loses PS-K Montessori;
if ui_id= "1033300" then grade_max_2011='5'; *Watkins gains 5th Grade;
if ui_id= "1047400" then grade_max_2011='12';*Washington Metro HS gained 12th Grade;
*in 2011 new Langley Education Campus was Emery Education Campus
101 T Street NE 20002, grades PS-8

in 2011-12 Wilson HS returns to 3950 Chesapeake ST NW

in 2011-12 Shaed Education Campus was closed, consolidated with Emery into Langley Edu Campus
in 2011-12,
looks like Hamilton Center was closed, 3rd to 5th transferred to Prospect, 6-8 transferred
to Ron Brown

in 2011-12,
Transition Academy moved to Ballou HS


in 2011-12, new school
Capitol Hill Montessori at Logan
215 G Street NE
Washington, DC 20002
PS-5

in 2011-12, 
looks likw Shaw Middle School lost 9th grade

;
run;


proc contents data=msf0910;
run;

school_name_2011=school_name_2009;
Sch_2009_address	Sch_2009_zip
grade_min_2010	grade_max_2010
