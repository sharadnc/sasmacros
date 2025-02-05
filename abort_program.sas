/**************************************************************************************************************
* Macro_Name:   abort_program
*
* Purpose: Execute an abort statement and send email to that effect.
*
* Usage: %abort_program(abort_type);
*
* Input_parameters: abort_type
*                    Valid values: ABEND, CANCEL, RETURN
*                   Default: ABEND
*
* Outputs:  None.
*
* Returns:  None.
*
* Example:
*
* Modules_called: None.
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 05/01/2012  | Michael Gilman| Initial creation.                                                             *
* 05/16/2012  | Michael Gilman| Added proc printto to execute before the abort statement. Without it, was     *
*             |               | causing the sas log to not be created.                                        *
* 06/08/2012  | Michael Gilman| Added putting error message(s) to log. Also now email notification of abort.  *
* 06/13/2012  | Michael Gilman| Conditionally execute proc printto when executing from EG.                    *
* 09/06/2012  | Michael Gilman| Now set notify_email to notify_email_override if notify_email_override if     *
*             |               | it is set.                                                                    *
* 01/29/2013  | Sharad        | Add rstats.program_restart_step record prior to the record                    *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro abort_program(abort_type);
%put Start macro abort_program;

 %local i;

 %if &abort_type=%str() %then %let abort_type=ABEND;

 %put;
 
 /*************************************************************************************************************/
 /* There can be up to 10 error messages, so put them to the log.                                             */
 /*************************************************************************************************************/

 %do i=1 %to 10;

    %let temp=&&errormsg&i;

    %if %superq(temp) ne %str() %then %put ERROR: &temp;

 %end;

 %put;

 %put ERROR: Program aborted.;
 
  %let jumptoexit=1;
  %let end_project_specifics_error=0;
  %program_end_step(&pgmName);

 %if %str(&notify_email_override) ne %str() %then %let notify_email=&notify_email_override;

 %if %superq(notify_email) ne %str() %then %let useTo=&notify_email;
 %else %let useTo=&email_global_from;

 filename outbox email "&email_global_from";

 data _null_;

 file outbox from=("&email_global_from") to=("&useTo") Subject=("ERROR: &Pgmname aborted")
      CT="text/html"
 ;

 put '<html>';

 put '<body>';

 %put;

 %do i=1 %to 10;

    %let temp=&&errormsg&i;

    %if %superq(temp) ne %str() %then
    %do;

       put "ERROR: &temp";

	     put "<br />";

	%end;

 %end;

 run;

 %abort &abort_type 16;

%put End macro abort_program;
%mend abort_program;