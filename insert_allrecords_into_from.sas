/**************************************************************************************************************
* Macro_Name:   insert_allrecords_into_from
*
* Purpose: This macro is used to insert all records into one dataset from the second dataset.
*
* Usage: %insert_allrecords_into_from(into_dsn,from_dsn);
*
* Input_parameters: in_dsn - in dataset
*                   from_dsn - from dataset
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 04/03/2013  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro insert_allrecords_into_from(into_dsn,from_dsn);
%put Start macro insert_allrecords_into_from;

%if %sysfunc(exist(&into_dsn)) %then
%do;
	%if %sysfunc(exist(&from_dsn)) %then
	%do;
			%if %records_in_dataset(&from_dsn) %then
			%do;
				%lock_on_member(&into_dsn);
				proc sql feedback;
				insert into &into_dsn
				select * from &from_dsn;
				quit;
				%lock_off_member(&into_dsn);
			%end;
			%else
			%do;
				%put No Records in &from_dsn to Insert;
				%goto EXIT;
			%end;		
	 %end;
	 %else
	 %do;
			%put &from_dsn DOES NOT EXISTS;
			%goto EXIT;
		%end;		
%end;
%else
%do;
	%put &into_dsn DOES NOT EXISTS;
	%goto EXIT;
%end;	

%EXIT:

%put End macro insert_allrecords_into_from;
%mend insert_allrecords_into_from ;
