/**************************************************************************************************************
* Macro_Name:   convert_varval_seriesof_macroval                                                                        
* 
* Purpose: This macro is used to create a series of macro variables with values from a datastep variables 
*          from a dataset 
*          
*                                                                                                              
* Usage: %convert_varval_seriesof_macroval(dsn,var,prefix);
*
* Input_parameters: dsn - dataset name where the variable is picked up from
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: %convert_varval_seriesof_macroval(links_accesses,sid);
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

%macro convert_varval_seriesof_macroval(dsn,var,prefix);

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

%let cnt=%records_in_dataset(&lib..&dsn);

%do i=1 %to &cnt;
	%global &prefix.&i.;
%end;

proc sql feedback noprint;
	select &var into :&prefix.1 - :&prefix.&cnt.
	from &lib..&dsn;
quit;

%do i=1 %to &cnt;
	%let &prefix.&i.=%superq(&prefix.&i.);
%end;


/*testing only*/

%do i=1 %to &cnt;
	%put &prefix.&i.=%superq(&prefix.&i.);
%end;


%mend convert_varval_seriesof_macroval;