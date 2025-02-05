/**************************************************************************************************************
* Macro_Name:   generate_label_statement                                                                        
* 
* Purpose: this macro is used to a label statement all the variables in the dataset
*          
*                                                                                                              
* Usage: %generate_label_statement(dsn);
*
* Input_parameters: dsn - dataset name .
*                                                                                                              
* Outputs:  generates a label statement for all the variables in the dataset.                                                                                              
*                                                                                                              
* Returns:  generates a label statement   
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

%macro generate_label_statement(dsn);

%if %index(&dsn,.) gt 0 %then %do; %let lib=%upcase(%scan(&dsn,1,.)); %let dsn=%upcase(%scan(&dsn,2,.)); %end;
  %else %do; %let lib=WORK; %let dsn=%upcase(&dsn); %end;

	proc sql noprint;
	select count(name) into :cnt
	from dictionary.columns
	where memtype="DATA" and libname="%upcase(&lib)" and memname="%upcase(&dsn)";
	quit;
	%let cnt=&cnt;
	%put cnt=&cnt;

	proc sql noprint;
	select strip(upcase(name)),
           case 
             when label is missing then strip(upcase(name))
               else strip(Propcase(label))
			 end as lbl
		   INTO :var1-:var&cnt.,
		        :lbl1-:lbl&cnt.
	from dictionary.columns
	where memtype="DATA" and libname="%upcase(&lib)" and memname="%upcase(&dsn)" 
	order by name;
	quit;

    options nomprint nosymbolgen nomlogic nomlogicnest nomprintnest;
	%put --------------------------------------------------------;
	%put label;
	%do i=1 %to &cnt;
		%put &&var&i = "&&lbl&i";
	%end;
	%put %nrstr(;);
	%put --------------------------------------------------------;

%mend generate_label_statement;

/*%generate_label_statement(promptd.all_dsn_paths);*/