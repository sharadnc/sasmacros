/**************************************************************************************************************
* Macro_Name:   reorder_variables_alphabetically                                                                        
* 
* Purpose: this macro is used to reorder sas dataset variables alphabetically
*          
*                                                                                                              
* Usage: %reorder_variables_alphabetically(dsn);
*
* Input_parameters: dsn - dataset name
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: 
*                                                                                                              
* Modules_called: None
* 
* Maintenance_History:                                                                                        
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro reorder_variables_alphabetically(dsn); 
 
	/* Get the variables names to a dataset using proc contents and keeping the variable name only */ 
	proc contents data=&dsn
	out=varnames(keep=name) noprint;
	run;

	/* It is very much important that you UPCASE or LOWCASE the variable names...
	otherwise you get a different order...Remove this datastep and see for yourself... */ 
	data varnames;
		set varnames;
		name=lowcase(name);
	run;

/* Sort the variable names in alphabetical order */ 
proc sort data=varnames; 
by name;
run;

/* Get the observation count */ 

data _null_;
	set varnames nobs=num;
	call symput('obscnt',num);/* Get the observation count */ 
	call symput(compress('macvar'||_n_),trim(left(name))); /* Get the variable names into macro variables */ 
run;

%let obscnt=&obscnt; /*remove the leading and trailing blankspaces generated when numeric is converted to Best12. format */ 
%put obscnt=&obscnt;
/*Please NOTE that the step of getting all variable names into a macro variable could be simply done by using SQL instead of a macro
proc sql noprint;
select trim(left(name)) into:macvar separated by ' '
from varnames;
quit;

and the next datastep simply

data &dsn;
retain &macvar;
set &dsn;
run;

But the cons here is that if there are too many variables and the total length of all the names put together crosses 32767 bytes the SQL approach would'nt work...
*/ 

 
data &dsn;
retain %do i=1 %to &obscnt; 
            &&macvar&i  /* NOTE: there should be a blank space after &&macvar&i to separate the variable names by space
                 eg. retain subject a b c; NOTE: NO semicolon should be typed here*/ 
       %end;;
set &dsn;
run;

%mend reorder_variables_alphabetically;
