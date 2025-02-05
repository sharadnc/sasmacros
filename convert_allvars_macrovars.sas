/**************************************************************************************************************
* Macro_Name:   convert_allvars_macrovars                                                                        
* 
* Purpose: This macro is used to create macro variables with values from similar datastep variables from a dataset 
*          with one record
*          
*                                                                                                              
* Usage: %convert_allvars_macrovars(dsn);
*
* Input_parameters: dsn - dataset name where the variable is picked up from
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: %convert_allvars_macrovars(new);
*                                                                                                              
* Modules_called: None
* 
* Maintenance_History:                                                                                        
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 01/24/2012  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro convert_allvars_macrovars(dsn);

 %if %index(&dsn,.) %then                                                                                                          
 %do;                                                                                                                                   
                                                                                                                                        
    %let lib=%upcase(%scan(&dsn,1,.));                                                                                                  
                                                                                                                                        
    %let dsn=%upcase(%scan(&dsn,2,.));                                                                                                  
                                                                                                                                        
 %end;                                                                                                                                  
 %else                                                                                                                                  
 %do;                                                                                                                                   
                                                                                                                                        
    %let lib=WORK;                                                                                                                      
                                                                                                                                        
    %let dsn=%upcase(&dsn);                                                                                                             
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let lib=%upcase(&lib);                                                                                                                
 %let dsn=%upcase(&dsn);  

proc contents data=&lib..&dsn out=temp(keep=name) noprint;run;

%let cnt=%records_in_dataset(temp);

proc sql feedback noprint;
select strip(name) into :name1 - :name&cnt.
from temp;
quit;

%do i=1 %to &cnt;
	%global &&name&i.;
%end;

data _null_;
set &lib..&dsn;
	%do i=1 %to &cnt;
	call symputx(compress("&&name&i."),&&name&i.);
	%end;
run;

/*testing only*/

%do i=1 %to &cnt;
	%put &&name&i.=%superq(&&name&i.);
%end;


%mend convert_allvars_macrovars;
