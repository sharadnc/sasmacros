/**************************************************************************************************************
* Macro_Name:   create_global_variables
*
* Purpose: This macro creates most of the global macro variables required for the Toolkit.
*
* Usage: %create_global_variables;
*
* Input_parameters: None
*
* Outputs:  None.
*
* Returns:  max_number_of_output_files
*           Many other globalized macro variables.
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
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 04/15/2012  | Michael Gilman   | Added new global macro variable validate_program_restart_steps.            *
* 04/23/2012  | Michael Gilman   | Added new global macro variable validate_program.                          *
* 04/28/2012  | Michael Gilman   | Added new global macro variable notify_email.                              *
* 05/05/2012  | Michael Gilman   | Added new global macro variable program_start_step.                        *
* 06/22/2012  | Michael Gilman   | Added new global macro variable notify_email_override.                     *
* 06/22/2012  | Michael Gilman   | Added new global macro variable number_of_output_files.                    *
* 06/30/2012  | Michael Gilman   | Added new global macro variable _LastStepNumber.                           *
* 06/30/2012  | Michael Gilman   | Added new global macro variables out_sas&p, out_sas_n&p                    *
* 07/04/2012  | Michael Gilman   | Added new global macro variables _reportName, report_date                  *
* 07/10/2012  | Michael Gilman   | Added new global macro variable  column_headers_in_export                  *
* 07/10/2012  | Michael Gilman   | Removed creation of all out_n macro variables (e.g. out_txt_n).            *
* 07/10/2012  | Michael Gilman   | Added new global macro variables out_rename&p, out_ftp&p                   *
* 07/10/2012  | Michael Gilman   | Added new global macro variable outfile_rename                             *
* 07/12/2012  | Michael Gilman   | Changed report_date to emaildate.                                          *
* 07/13/2012  | Michael Gilman   | Forgot to globalize out_rename vars.                                       *
* 07/14/2012  | Michael Gilman   | Added new global macro variable extract_libref_w                           *
* 07/14/2012  | Michael Gilman   | Added new global macro variable unixdumpdir                                *
* 07/14/2012  | Michael Gilman   | Added new global macro variable history_datasets_directory                 *
* 07/14/2012  | Michael Gilman   | Added new global macro variable history_libref_w                           *
* 07/22/2012  | Michael Gilman   | Removed global macro variable Flag_Process (not used).                     *
* 07/22/2012  | Michael Gilman   | Removed Flag_EmailTurnOn and replaced with EmailTurnOn.                    *
* 07/27/2012  | Michael Gilman   | Removed the setting of the out_xxx variables.                              *
* 07/30/2012  | Michael Gilman   | Added new global macro variable dataset_prefix                             *
* 08/23/2012  | Michael Gilman   | Added new global macro variable rundate                                    *
* 09/10/2012  | Michael Gilman   | Added new global macro variable legacy_extract_directory                   *
* 09/17/2012  | Michael Gilman   | Added new global macro variable attach_filesize_max                        *
* 09/22/2012  | Michael Gilman   | Added new global macro variable number_of_security_levels                  *
* 10/20/2012  | Michael Gilman   | Added new global macro variable email_subject.                             *
* 12/10/2012  | Michael Gilman   | Added new global macro variable zip_extension.                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro create_global_variables;
%put Start macro create_global_variables;

 %local p;

 %global env lob PgmFreq rootloc runtime logfile rundate dt_prcs
         StartTime EndTime CommonProgLoc Debug
         Num_outputfiles unixrootloc unixcodedir unixshldir unixfmtdir
         unixlogdir unixmacrdir unixstpdir unixstpsasdir unixstppromptdir
         unixstppromptdatadir unixdatadir unixrptdir unixhistdir
         unixcfgdir unixadmindir unixportaldir unixadmindatadir unixrstatsdir
         unixextractdir unixdumpdir
         unixdmgcubesdir unixmetadatadir unixpgmmetadir
         Flag_Email
         adminlib rtelib PgmName PgmDescr
         _ERROR _STEP _StepType jumptoexit encr_pwd recs
         dbtype alias user passwd database server dsnname spec_instruc addtnlcode
         success_attach success_attach_text success_subject success_email_text
         warn_attach warn_subject warn_email_text
         emailerr_attach emailerr_subject emailerr_email_text
         pgmid CreateHistory FilePrefix
         send_email_rc report_name rootlocDev outputLibref
         userid dataset_prefix LibDsnPrefix step_count
         email_commontext lob useEG dt_prcs_sas dt_sas yr_year end_date dt_prcs_data
         date30 date31 date60 date61 date90 date91 date120 date121
         SendZip security_level SubjectArea
         ecnt efrom eto ebcc eattach esubj etext ebcccnt eattachcnt eattachtxt
         gotostep step_at_program_end program_step
         start_date_year start_date_month start_date_day start_date_weekday start_date_yearmonth
         end_date_year end_date_month end_date_day end_date_weekday end_date_yearmonth
         nextid max_number_of_output_files
         outfile export_type extension column_headers
         validate_program email_global_from notify_email
		     program_start_step notify_email_override number_of_output_files
		     _LastStepNumber _reportName emaildate use_var_labels_for_export column_headers_in_export
		     outfile_rename history_datasets_directory history_libref_w DeliveryMethod
		     EmailTurnON program_start_step_EG dataset_prefix split_records_default
		     rundate attach_filesize_max number_of_security_levels
         Email_Subject zip_extension
 ;

 %let max_number_of_output_files=50;

 /* Globalize macro variables for the error messages */

 %do p=1 %to 10;

    %global errormsg&p;

    %let errormsg&p=;

 %end;

%put End macro create_global_variables;
%mend create_global_variables;
