/**************************************************************************************************************
* Macro_Name:   program_info
*
* Purpose: This macro prints key information about the program parameters to the sas log.
*
* Usage: %program_info(toolkit_position);
*
* Input_parameters: toolkit_position
*                    Text to appear centered on the asterisk line.
*                   Several global macro variables
*
* Outputs:  None.
*
* Returns:  None.
*
* Example:
*
* Modules_called: get_macro_system_options
*                 get_outfile_attrs
*                 center_text_in_line
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 06/29/2012  | Michael Gilman| Initial creation.                                                             *
* 07/10/2012  | Michael Gilman| Now print out the new out_rename values, if set.                              *
* 07/22/2012  | Michael Gilman| Now print out start time.                                                     *
* 07/22/2012  | Michael Gilman| Now print out email_bcc.                                                      *
* 07/22/2012  | Michael Gilman| Now print out None for Output files if there aren't any.                      *
* 10/03/2012  | Michael Gilman| Added check for number_of_output_files>0 at bottom of macro.                  *
* 10/10/2012  | Michael Gilman| Suppress printing of bcc email addresses when EmailTurnON=N.                  *
* 10/18/2012  | Michael Gilman| Now print pathname of saslib.                                                 *
* 10/25/2012  | Michael Gilman| Now print Delivery Method.                                                    *
* 12/10/2012  | Michael Gilman| Now print zip_extension                                                       *
* 12/20/2012  | Michael Gilman| Now print emaildate                                                           *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro program_info(toolkit_position);
%put Start macro program_info;

 %local program_step lastStep use_format dt_prcsc string StartTimec EndTime ElapsedTime system_options i j
        success_bcc bcc_n
 ;

 %let system_options=%get_macro_system_options;

 options NOMPRINT NOMLOGIC NOSYMBOLGEN NOMPRINTNEST NOMLOGICNEST NOMAUTOLOCDISPLAY;

 %let string=;

 %let success_bcc=;

 proc sql noprint;
  select distinct email into : success_bcc separated by '^'
  from adminlib.programsetup_emails_bcc
  where pgmname="&PgmName"
 ;
 quit;

 %let bcc_n=&sqlobs;

 %if %superq(dt_prcs)>0 %then %let dt_prcsc=%sysfunc(putn(&dt_prcs,mmddyy10.));
 %else %let dt_prcsc=;

 %put %center_text_in_line(text=&toolkit_position);
 %put %center_text_in_line(text=&pgmname);

 %put * Sysjobid:         &sysjobid;

 %if &toolkit_position=check_restart_step or &toolkit_position=program_completion_info %then
 %do;

    %put * Start Step:       &gotoStep;

	  %if &_LastStepNumber>0 %then
	  %do;

   	   %if &_LastStepNumber<=99 %then %let use_format=z2.;
       %else %let use_format=z3.;

       %let program_step=%sysfunc(putn(&_LastStepNumber,&use_format));

       %let lastStep=STEP&program_step;

	   %put * Last Step:        &lastStep;

	%end;

 %end;

 %if &toolkit_position=program_completion_info %then
 %do;

    %if &step_count<=99 %then %let use_format=z2.;
    %else %let use_format=z3.;

    %let program_step=%sysfunc(putn(&step_count,&use_format));

    %let lastStep=STEP&program_step;

  	%put * Last Suc Step:    &lastStep;

    %let EndTime=%sysfunc(datetime());

    %let StartTimec=&StartTime;

    %let StartTime=%sysfunc(inputn(%superq(StartTime),datetime23.));

    %let ElapsedTime=%sysevalf(&EndTime-&StartTime);

    %let EndTime=%sysfunc(datetime(),datetime23.);

    %if &jumptoexit %then %put * Status:           Failed;
    %else %put * Status:           Successful;

    %if &jumptoexit %then %put &_ERROR;

    %put * Started at:       &StartTimec;
    %put * Completed at:     &EndTime;
    %put * Elapsed time:     %time_hours_minutes_secs_format(&elapsedTime);

 %end;

 %if &toolkit_position=check_restart_step or &toolkit_position=program_completion_info %then
 %do;

    %if &notify_email_override ne %str() %then %let string=(override);

 %end;

 %if &dt_prcsc ne %str() %then %put * Process date:     &dt_prcsc;
 %if &dt_prcs_data ne %str() %then %put * dt_prcs_data:     &dt_prcs_data;

 %put * Env:              &env;
 %put * UserID:           &userid;
 %put * Pgmid:            &pgmid;
 %put * Pgmfreq:          &pgmfreq;
 %put * Delivery Method:  &DeliveryMethod;
 %put * SecurityLevel:    &security_level;
 %put * Lob:              &lob;
 %put * SubjectArea:      &subjectArea;
 %put * saslib:           %sysfunc(pathname(saslib));
 %put * ReportName:       &_reportName;

 %if &FilePrefix ne %str() %then %put * FilePrefix:       &FilePrefix;

 %put * email_date:       &emaildate;
 %put * EmailTurnON:      &EmailTurnON;
 %put * SendZip:          &sendzip;
 %put * zip_extension:    &zip_extension;
 %put * Cols in Export:   &column_headers_in_export;
 %put * Labels in Export: &use_var_labels_for_export;
 %put * notify_email:     &notify_email &string;

 %if &EmailTurnON=Y and %superq(success_bcc) ne %str()%then
 %do;

    %do i=1 %to &bcc_n;

     %if &i=1 %then %put * bcc_email:        %scan(%superq(success_bcc),&i,%str(^));
	   %else          %put *                   %scan(%superq(success_bcc),&i,%str(^));

    %end;

 %end;

 %if &toolkit_position=check_restart_step or &toolkit_position=program_completion_info %then
 %do;

    %if &number_of_output_files>0 %then
    %do;

       %do i=1 %to &number_of_output_files;

          %get_outfile_attrs(&i);

          %if %superq(outfile)=%str() %then %goto NEXT;

          %if &toolkit_position=program_completion_info and &jumptoexit=0 and %symexist(reccnt&i)and %str(&&reccnt&i)>=0 %then
             %let records=(%qtrim(%qleft(%qsysfunc(putn(&&reccnt&i,comma32.)))) records);
          %else %let records=;

	        %if &i=1 %then %put * Output files:     &outfile &records (&export_type);
	        %else          %put *                   &outfile &records (&export_type);

       %end;

    %end;
    %else
    %do;

       %put * Output files:     None;

    %end;

%NEXT:

    %if &number_of_output_files>0 %then
    %do;

       %do i=1 %to &number_of_output_files;

          %get_outfile_attrs(&i);

          %if %superq(outfile_rename) ne %str() %then
          %do;

	           %put * Rename file&i:     &outfile_rename;

          %end;

       %end;

    %end;

 %end;

 %put %center_text_in_line;
 %put %center_text_in_line;

 options &system_options;

%put End macro program_info;
%mend program_info;