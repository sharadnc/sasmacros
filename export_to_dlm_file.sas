/**************************************************************************************************************
* Macro_Name:   export_to_dlm_file
*
* Purpose: This macro is used to export a sas data set to a delimited text file
*
* Usage: %export_to_dlm_file(dsn,outputfile,export_type);
*
* Input_parameters: None.
*
* Outputs:  dsn
*            Data set to export
*           outputfile
*            Full pathname of export file
*           export_type
*            txt/csv/tab
*           column_headers_in_export (global)
*            Y/N
*           use_var_labels_for_export (global)
*            Y/N
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
* 07/10/2012  | Michael Gilman   | Removed column_headers input parameter. Now use new parameter obtained     *
*             |                  | from programsetup: column_headers_in_export.                               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro export_to_dlm_file(dsn,outputfile,export_type);
%put Start macro export_to_dlm_file putnames flag_label;

 %local delimiter dbms_type;

 %if %lowcase(&export_type)=txt %then
 %do;

    %let dbms_type=dlm;

    %let delimiter=%str(delimiter="|");

 %end;
 %else
 %if %lowcase(&export_type)=csv %then
 %do;

    %let dbms_type=csv;

    %let delimiter=;

 %end;
 %else
 %if %lowcase(&export_type)=tab %then
 %do;

    %let dbms_type=tab;

    %let delimiter=;

 %end;

 %if &column_headers_in_export=Y %then %let putnames=%str(putnames=yes);
 %else %let putnames=%str(putnames=no);

 %if &use_var_labels_for_export=Y %then %let flag_label=label;
 %else  %let flag_label=;

 proc export data=&dsn &flag_label
      file = "&outputfile"
      dbms=&dbms_type
      replace;
      &delimiter;
      &putnames;
 run;

%put End macro export_to_dlm_file;
%mend export_to_dlm_file;
