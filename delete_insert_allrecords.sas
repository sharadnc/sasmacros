/**************************************************************************************************************
* Macro_Name:   delete_insert_allrecords
*
* Purpose: This macro is used to delete all records in the dataset.
*
* Usage: %delete_insert_allrecords(into_dsn,from_dsn);
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
* 04/24/2013  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro delete_insert_allrecords(into_dsn,from_dsn);
%put Start macro delete_insert_allrecords;

%if %sysfunc(exist(&from_dsn)) %then
%do;
	%if %sysfunc(exist(&into_dsn)) %then
	%do;
			%if %records_in_dataset(&from_dsn) %then
			%do;
				%delete_allrecords_in(&into_dsn);
				%insert_allrecords_into_from(&into_dsn,&from_dsn);
			%end;
			%else
			%do;
				%put No Records in &from_dsn to Insert;
				%goto EXIT;
			%end;		
	 %end;
	 %else
	 %do;
			%put &into_dsn DOES NOT EXISTS;
			%goto EXIT;
		%end;		
%end;
%else
%do;
	%put &from_dsn DOES NOT EXISTS;
	%goto EXIT;
%end;	

%EXIT:

%put End macro delete_insert_allrecords;
%mend delete_insert_allrecords;