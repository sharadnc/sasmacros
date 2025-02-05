/**************************************************************************************************************
* Macro_Name:   chkerr
*
* Purpose: This macro checks if the last sas step completed in error. It also increments the step_count variable
*          when the step input parameter is not missing.
*
* Usage: %chkerr(step=,errCaptur=,msg1-msg10=);
*
* Input_parameters:  step
*                     Optional. A descriptive name of the last sas step executed
*                    errCaptur
*                     The sas return code from the previous sas step. If not passed in errCaptur:
*                       If &sqlxrc is greater than 4, it is used
*                       else
*                       if &sqlrc is greater than 4, it is used
*                       else &syserr is used
*                    msg1-msg10
*                     Error messages to set if in error
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*           If &step is not missing, &step_count is incremented.
*           Sets sqlrc and sqlxrc to 0.
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/15/2011  | Michael Gilman   | Modify input parameters.                                                   *
* 06/25/2011  | Michael Gilman   | Removed invocation of %chk_outfile_length as now being called from         *
*             |                  | check_restart_step.                                                        *
* 10/18/2012  | Michael Gilman   | Fixed bug: Errors were not detected correctly in the case where a          *
*             |                  | successful proc sql was followed by an unsuccessful data step.             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro chkerr(step=,errCaptur=,msg1=,msg2=,msg3=,msg4=,msg5=,msg6=,msg7=,msg8=,msg9=,msg10=);
%put Start macro chkerr;

 %local i temp sqlxrc_n sqlrc_n syserr_n;

 %if &errCaptur=%str() %then
 %do; /* errCaptur not passed in, so set it */

    %let sqlxrc_n=0;
    %let sqlrc_n=0;
    %let syserr_n=0;

    %if %symexist(sqlxrc) %then %let sqlxrc_n=&sqlxrc;

    %if %symexist(sqlrc) %then %let sqlrc_n=&sqlrc;

    %if %symexist(syserr) %then %let syserr_n=&syserr;

    %if &sqlxrc_n>4 %then %let errCaptur=&sqlxrc_n;
    %else
    %if &sqlrc_n>4 %then %let errCaptur=&sqlrc_n;
    %else %let errCaptur=&syserr_n;

 %end;/* errCaptur not passed in, so set it */

 %if &errCaptur>4 %then
 %do; /* Last step has error */

    %if %superq(msg1)=%str() %then %let errormsg1=&syserrortext;
    %else %let errormsg1=&msg1;

    %do i=2 %to 10;

       %let temp=&&msg&i;

       %if %superq(temp) ne %str() %then %let errormsg&i=&temp;

    %end;

    %let jumptoexit=1;

 %end;/* Last step has error */

 /* It is assumed that each STEP is followed by an invocation of this macro or the &check_error_and_zero_records macro. */
 /* This allows us to keep track of the step count by incrementing the step_count variable here.                        */
 /* Note that this is only done when the step input parameter is not missing.                                           */

 %if %superq(step) ne %str() %then
 %do; /* Increment the step_count variable */

    %put;

    %if &jumptoexit=0 %then
    %do; /* No error */

       %let step_count=%eval(&step_count+1);

       %put NOTE: Step &step_count &step completed successfully.;

    %end;/* No error */
    %else
    %do; /* Error */

       %put ERROR: Program &PgmName has an error in Step %eval(&step_count+1) &step..;

       %do i=1 %to 5;

          %let temp=&&errormsg&i;

          %if %superq(temp) ne %str() %then %put ERROR: &temp;

       %end;

    %end;/* Error */

    %put;

 %end;/* Increment the step_count variable */

 %let sqlrc=0;

 %let sqlxrc=0;

%EXIT2:

%put End macro chkerr;
%mend chkerr;