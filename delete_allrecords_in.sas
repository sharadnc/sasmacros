/**************************************************************************************************************
* Macro_Name:   delete_allrecords_in
*
* Purpose: This macro is used to delete all records in the dataset.
*
* Usage: %delete_allrecords_in(in_dsn);
*
* Input_parameters: in_dsn
*                    dataset name path
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

%macro delete_allrecords_in(in_dsn);
%put Start macro delete_allrecords_in;

%if %sysfunc(exist(&in_dsn)) %then
%do;
	%if %records_in_dataset(&in_dsn) %then
	%do;
		%lock_on_member(&in_dsn);
		proc sql feedback;
		delete *from &in_dsn;
		quit;
		%lock_off_member(&in_dsn);
	%end;
	%else
	%do;
		%put No Records in &in_dsn to delete;
		%goto EXIT;
	%end;
%end;
%else
%do;
	%put &in_dsn DOES NOT EXISTS;
	%goto EXIT;
%end;

%EXIT:

%put End macro delete_allrecords_in;
%mend delete_allrecords_in ;