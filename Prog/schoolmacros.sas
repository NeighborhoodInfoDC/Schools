/**************************************************************************
 Program:  School Macros
 Author:   S. Litschwartz
 Created:  08/4/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 Description: Macros for School data work
 Modifications:
**************************************************************************/


/*macros from dc data school work*/

*macro to output all variables for a range;
*this macro works for years that are of the form 2002 to 2010;
%macro yearrange1(var,y1,y2);
%local c x v yr;
%let c=%sysfunc(countw("&var.",' ',));
%do x=1 %to &c.;
	%let v=	%scan(&var.,&x.,' ');
	%do yr=&y1. %to &y2.;
		&v.&yr.
	%end;
%end;
%mend;



*this macro works for school years of the form 0910;
%macro yearrange2(var,y1,y2);
%local c x v yr i j;
%let c=%sysfunc(countw("&var.",' ',));
%do x=1 %to &c.;
	%let v=	%scan(&var.,&x.,' ');
	%do yr=&y1. %to &y2.;
		%let yr2=%eval(&yr. + 1);
		%let i=%substr(&yr.,3,2);
		%let j=%substr(&yr2.,3,2);
		&v.&i.&j.
	 %end;
%end;
%mend;


%macro varrange(varlist,range);
%local c1 c2 yr i var a v; 
%let c1=%sysfunc(countw("&range.",' ',));
%let c2=%sysfunc(countw("&varlist.",' ',));
%do v=1 %to &c2.;
	%let var=%scan(&varlist., &v.,' ');
	%do a=1 %to &c1.;
		%let i=%scan(&range., &a.,' ');
		&var.&i.
	%end;
%end;
%mend;	



%macro vareqrange(var,new,range);
%local c yr i; 
%let c=%sysfunc(countw("&range.",' ',));
%do yr=1 %to &c.;
	%let i=%scan(&range., &yr,' ');
	 &var.&i.=&new.&i
%end;
%mend;	



