/**************************************************************************************************************
* Macro_Name:   end_project_specifics
*
* Purpose: Export sas datasets to txt, csv or other files.
*          E-mail notifications to users as defined in ProgramSetup.
*          Write error messages (if any) to the log.
*          Update RSTATS.RUNTIMESTATS.
*          Set the step that the job should start at next time it executes.
*
* Usage: %end_project_specifics;
*
* Input_parameters: Several global macro variables.
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: check_split_dsn
*                 record_check_export_encrypt
*                 error_messages_to_log
*                 send_email
*                 clear_error_messages
*                 update_runtimestats
*                 stop_on_error
*                 program_info
*                 program_end_step
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 05/05/2012  | Michael Gilman   | Commented out invocation of %delete_from_library.                          *
* 06/30/2011  | Michael Gilman   | Added call to macro program_info.                                          *
* 07/11/2012  | Michael Gilman   | Removed code dealing with CreateHistory macro variable - not used.         *
* 08/01/2012  | Michael Gilman   | Now set SYSCC=16 at end of macro if jumptoexit=1.                          *
* 08/08/2012  | Michael Gilman   | Fixed minor bug that caused 2 emails to be sent when there was an error.   *
* 08/14/2012  | Michael Gilman   | Now use %symdel to delete out_xxx macro vars at end of thsi macro.         *
* 08/15/2012  | Michael Gilman   | Fixed bug. update_runtimestats was being called twice.                     *
* 08/15/2012  | Michael Gilman   | Now invoke %check_split_dsn macro.                                         *
* 08/15/2012  | Michael Gilman   | Now symdel all out_ and split_ macro variables at end of macro.            *
* 09/11/2012  | Michael Gilman   | Commented out %else %let syscc=0;                                          *
* 09/17/2012  | Michael Gilman   | Fixed bug created when commenting out: %else %let syscc=0;                 *
* 10/03/2012  | Michael Gilman   | Now symdel out_html and out_rtf.                                           *
* 11/28/2012  | Michael Gilman   | Set new flag: end_project_specifics_error=1 when error encountered any     *
*             |                  | where in the macro. This flag is used in macro program_end_step to set     *
*             |                  | restart_step=-1 when end_project_specifics_error=1. This has the effect    *
*             |                  | of the pgm restarting at label StopMacroProcessing.                        *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro end_project_specifics;
%put Start macro end_project_specifics;

 %local i temp old_jumptoexit;

 %let end_project_specifics_error=0;

 /* If job successful, check if we need to split the final output data set(s) */

 %if &jumptoexit=0 %then %check_split_dsn;

 /* If job successful, export/encrypt and zip the data sets/files specified by the %let out_xxx= specifications. */

 %if &jumptoexit=0 %then %record_check_export_encrypt;

 %if &jumptoexit %then
 %do; /* Job failed */

    %error_messages_to_log; /* Print error messages to the log */

    /* Set _ERROR to error messages. It is used to print error messages in the email body. */

    %let _ERROR=;

    %do i=1 %to 10;

       %let temp=&&errormsg&i;

       %if %superq(temp) ne %str() %then %let _ERROR=&_ERROR &temp;

    %end;

    %clear_error_messages;

    %let _ERROR=%sysfunc(compbl(%superq(_ERROR)));

    /* Flag_Email is used as input parameter to %send_email. */

    %let Flag_Email=WARN;

 %end;/* Job failed */

 /* Send an email to the stake holders based on Flag_Email. Note that Flag_Email is initialized to SUCCESS in %initialize. */

 %send_email(&Flag_Email);

 %if &send_email_rc ne 0 and &send_email_rc ne 4 %then
 %do; /* Send an email to the DABI@sasanalytics if there was a problem in sending the email */

    %let jumptoexit=1;

    %let end_project_specifics_error=1;

    %let errormsg1=&syserrortext;

    %let errormsg2=Email step to the End Users failed;

    %error_messages_to_log;

    %clear_error_messages;

    %let Flag_Email=EMAILWARN;

    %send_email(&Flag_Email); /* Send an email to the stake holders based on the Flag_Email */

    %if &send_email_rc ne 0 and &send_email_rc ne 4 %then
    %do; /* Still can't send email, so terminate the job */

       %let errormsg1=syserrortext;

       %let errormsg2=Email to the DABI Analytics Failed;

       %error_messages_to_log;

       %clear_error_messages;

       %update_runtimestats; /* Update RuntimeStats*/

       %program_end_step(&pgmName);

       %program_info(program_completion_info);

       %stop_on_error;       /* Abort the job */

    %end;/* Still can't send email, so terminate the job */

 %end;/* Send an email to the DABI@sasanalytics if there was a problem in sending the email */

 %if &useEG=0 %then
 %do; /* Update the RuntimeStats data set with job status info */

    /* Save the value of jumptoexit and set to 0. This allows us to to determine if %update_runtimestats */
    /* itself sets jumptoexit to 0.                                                                      */

    %let old_jumptoexit=&jumptoexit;

    %let jumptoexit=0;

    /* Update the runtimestats dataset with the job completion attributes */

    %update_runtimestats;

    %if &jumptoexit %then
    %do; /* Error updating RuntimeStats */

       %let end_project_specifics_error=1;

       %error_messages_to_log;

       %clear_error_messages;

       %send_email(&Flag_Email);

     %end;/* Error updating RuntimeStats */
     %else %let jumptoexit=&old_jumptoexit;

 %end;/* Update the RuntimeStats data set with job status info */

 /* Set the step that the program should start at next time it executes */

 %program_end_step(&pgmName);

 /* Print key information about the program parameters to the sas log */

 %program_info(program_completion_info);

 /* Delete the out_xxx and split_xxx macro variables. This is needed when running from EG */

 %do i=1 %to &number_of_output_files;

   %if %symexist(out_txt&i) %then %symdel out_txt&i/nowarn;
   %else
   %if %symexist(out_csv&i) %then %symdel out_csv&i/nowarn;
   %else
   %if %symexist(out_tab&i) %then %symdel out_tab&i/nowarn;
   %else
   %if %symexist(out_sas&i) %then %symdel out_sas&i/nowarn;
   %else
   %if %symexist(out_xls&i) %then %symdel out_xls&i/nowarn;
   %else
   %if %symexist(out_html&i) %then %symdel out_html&i/nowarn;
   %else
   %if %symexist(out_rtf&i) %then %symdel out_rtf&i/nowarn;
   %else
   %if %symexist(out_zipsas&i) %then %symdel out_zipsas&i/nowarn;
   %else

   %if %symexist(split_txt&i) %then %symdel split_txt&i/nowarn;
   %else
   %if %symexist(split_csv&i) %then %symdel split_csv&i/nowarn;
   %else
   %if %symexist(split_tab&i) %then %symdel split_tab&i/nowarn;
   %else
   %if %symexist(split_sas&i) %then %symdel split_sas&i/nowarn;
   %else
   %if %symexist(split_xls&i) %then %symdel split_xls&i/nowarn;
   %else
   %if %symexist(split_html&i) %then %symdel split_html&i/nowarn;
   %else
   %if %symexist(split_rtf&i) %then %symdel split_rtf&i/nowarn;

 %end;

 /* If job ended in error, set the return condition code to 16. Cntrl-M uses this to determine if a job has failed. */

 %if &jumptoexit %then %let syscc=16;
 
 /*----PLEASE DO NOT CHECK THIS TO PRODUCTION-------
 %else %let syscc=0;
 */

%put End macro end_project_specifics;
%mend end_project_specifics;